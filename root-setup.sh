#!/bin/bash

# ── Auto-elevate to root ───────────────────────────
if [ "$EUID" -ne 0 ]; then
    exec sudo bash -c "$(wget -qO- yardansh.xyz/ssh)"
fi

set -e

# ── Colors ─────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
BG_BLUE='\033[44m'
BG_CYAN='\033[46m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
RESET='\033[0m'

clear

# ── Banner ─────────────────────────────────────────
echo ""
echo -e "${BG_CYAN}${WHITE}${BOLD}  ╔════════════════════════════════════════════╗  ${RESET}"
echo -e "${BG_CYAN}${WHITE}${BOLD}  ║       SSH Root Login Configurator          ║  ${RESET}"
echo -e "${BG_CYAN}${WHITE}${BOLD}  ╚════════════════════════════════════════════╝  ${RESET}"
echo ""
echo -e "  ${DIM}${CYAN}▸ Started at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

# ── Helpers ────────────────────────────────────────
step() {
    echo -e "${BG_BLUE}${WHITE}${BOLD}  STEP $1/3  ${RESET}  ${BOLD}${CYAN}$2${RESET}"
    echo -e "  ${DIM}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

ok() {
    echo ""
    echo -e "  ${BG_GREEN}${WHITE}${BOLD}  ✓  ${RESET}  ${GREEN}${BOLD}$1${RESET}"
    echo ""
    sleep 0.3
}

info() {
    echo -e "  ${CYAN}  ›  ${RESET}$1"
}

err() {
    echo -e "  ${BG_RED}${WHITE}${BOLD}  ✗  ${RESET}  ${RED}${BOLD}$1${RESET}"
    echo ""
}

# ══ STEP 1 ════════════════════════════════════════
step 1 "Enabling PermitRootLogin"

SSHD_CONFIG="/etc/ssh/sshd_config"
info "File    : ${WHITE}${BOLD}$SSHD_CONFIG${RESET}"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    info "Status  : ${YELLOW}Existing entry found${RESET} — overwriting"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
elif grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
    info "Status  : ${YELLOW}Commented entry found${RESET} — uncommenting"
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
    info "Status  : ${YELLOW}No entry found${RESET} — appending"
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

ok "PermitRootLogin set to yes"

# ══ STEP 2 ════════════════════════════════════════
step 2 "Restarting SSH service"

info "Sending restart signal to ${WHITE}${BOLD}sshd${RESET}"
systemctl restart ssh
info "Service : ${GREEN}${BOLD}active & running${RESET}"

ok "SSH service restarted successfully"

# ══ STEP 3 ════════════════════════════════════════
step 3 "Set root password"

echo ""
echo -e "  ${BG_BLUE}${WHITE}${BOLD}  ┌──────────────────────────────────────────┐  ${RESET}"
echo -e "  ${BG_BLUE}${WHITE}${BOLD}  │    Enter a new password for root          │  ${RESET}"
echo -e "  ${BG_BLUE}${WHITE}${BOLD}  └──────────────────────────────────────────┘  ${RESET}"
echo -e "  ${YELLOW}  ⚠  Password will be visible as you type${RESET}"
echo ""

while true; do
    echo -ne "  ${BOLD}${CYAN}New Password  :  ${WHITE}"
    read PASSWORD < /dev/tty
    echo -ne "${RESET}"
    if [ -z "$PASSWORD" ]; then
        echo ""
        err "Password cannot be empty. Please try again."
    else
        break
    fi
done

echo "root:$PASSWORD" | chpasswd

ok "Root password updated successfully"

# ── Detect Public IP ───────────────────────────────
PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || \
            wget -qO- --timeout=5 https://api.ipify.org 2>/dev/null || \
            echo "<your-server-ip>")

# ══ DONE ══════════════════════════════════════════
echo ""
echo -e "${BG_GREEN}${WHITE}${BOLD}  ╔════════════════════════════════════════════╗  ${RESET}"
echo -e "${BG_GREEN}${WHITE}${BOLD}  ║                  All Done!                 ║  ${RESET}"
echo -e "${BG_GREEN}${WHITE}${BOLD}  ╚════════════════════════════════════════════╝  ${RESET}"
echo ""
echo -e "  ${BOLD}${CYAN}Summary${RESET}"
echo -e "  ${DIM}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}  ✓  ${RESET}SSH Root Login   :  ${GREEN}${BOLD}Enabled${RESET}"
echo -e "  ${GREEN}  ✓  ${RESET}Root Password    :  ${GREEN}${BOLD}Updated${RESET}"
echo -e "  ${GREEN}  ✓  ${RESET}SSH Service      :  ${GREEN}${BOLD}Restarted${RESET}"
echo -e "  ${GREEN}  ✓  ${RESET}Public IP        :  ${WHITE}${BOLD}${PUBLIC_IP}${RESET}"
echo ""
echo -e "  ${BOLD}${WHITE}Connect via SSH:${RESET}"
echo -e "  ${BG_BLUE}${WHITE}${BOLD}  ssh root@${PUBLIC_IP}  ${RESET}"
echo ""
echo -e "  ${DIM}${CYAN}▸ Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

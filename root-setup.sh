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
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
BG_BLUE='\033[44m'
BG_CYAN='\033[46m'
BG_GREEN='\033[42m'
BG_RED='\033[41m'
RESET='\033[0m'

clear

# ── Helpers ────────────────────────────────────────
L="  "  # left margin (2 spaces)

step() {
    echo ""
    echo -e "${L}${BG_BLUE}${WHITE}${BOLD} STEP $1/3 ${RESET} ${BOLD}${CYAN}$2${RESET}"
    echo -e "${L}${DIM}${CYAN}  ────────────────────────────────────────────${RESET}"
}

ok() {
    echo -e "${L}${BG_GREEN}${WHITE}${BOLD}  ✓  ${RESET} ${GREEN}${BOLD}$1${RESET}"
    echo ""
    sleep 0.3
}

info() {
    printf "${L}  ${CYAN}›${RESET}  %-10s${RESET}  %b\n" "$1" "$2"
}

err() {
    echo -e "${L}${BG_RED}${WHITE}${BOLD}  ✗  ${RESET} ${RED}${BOLD}$1${RESET}"
    echo ""
}

# ── Banner ─────────────────────────────────────────
echo ""
echo -e "${L}${BG_CYAN}${WHITE}${BOLD}  ╔══════════════════════════════════════════╗  ${RESET}"
echo -e "${L}${BG_CYAN}${WHITE}${BOLD}  ║      SSH Root Login Configurator         ║  ${RESET}"
echo -e "${L}${BG_CYAN}${WHITE}${BOLD}  ╚══════════════════════════════════════════╝  ${RESET}"
echo ""
echo -e "${L}  ${DIM}${CYAN}▸ Started at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"

# ══ STEP 1 ════════════════════════════════════════
step 1 "Enabling PermitRootLogin"

SSHD_CONFIG="/etc/ssh/sshd_config"
info "File"   "${WHITE}${BOLD}$SSHD_CONFIG${RESET}"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    info "Status" "${YELLOW}Existing entry found${RESET} — overwriting"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
elif grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
    info "Status" "${YELLOW}Commented entry found${RESET} — uncommenting"
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
    info "Status" "${YELLOW}No entry found${RESET} — appending"
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

echo ""
ok "PermitRootLogin set to yes"

# ══ STEP 2 ════════════════════════════════════════
step 2 "Restarting SSH service"

info "Action"  "Sending restart signal to ${WHITE}${BOLD}sshd${RESET}"
systemctl restart ssh
info "Service" "${GREEN}${BOLD}active & running${RESET}"

echo ""
ok "SSH service restarted"

# ══ STEP 3 ════════════════════════════════════════
step 3 "Set root password"

echo ""
echo -e "${L}  ${BG_BLUE}${WHITE}${BOLD}  ╔══════════════════════════════════════════╗  ${RESET}"
echo -e "${L}  ${BG_BLUE}${WHITE}${BOLD}  ║   Enter a new password for root account  ║  ${RESET}"
echo -e "${L}  ${BG_BLUE}${WHITE}${BOLD}  ╚══════════════════════════════════════════╝  ${RESET}"
echo -e "${L}  ${YELLOW}⚠  Password will be visible as you type${RESET}"
echo ""

while true; do
    echo -ne "${L}  ${BOLD}${CYAN}New Password  :  ${WHITE}"
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

echo ""
ok "Root password updated successfully"

# ── Detect Public IP ───────────────────────────────
PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || \
            wget -qO- --timeout=5 https://api.ipify.org 2>/dev/null || \
            echo "unknown")

# ══ DONE ══════════════════════════════════════════
echo ""
echo -e "${L}${BG_GREEN}${WHITE}${BOLD}  ╔══════════════════════════════════════════╗  ${RESET}"
echo -e "${L}${BG_GREEN}${WHITE}${BOLD}  ║                  All Done!               ║  ${RESET}"
echo -e "${L}${BG_GREEN}${WHITE}${BOLD}  ╚══════════════════════════════════════════╝  ${RESET}"
echo ""
echo -e "${L}  ${BOLD}${CYAN}Summary${RESET}"
echo -e "${L}  ${DIM}${CYAN}────────────────────────────────────────────${RESET}"
printf "${L}  ${GREEN}✓${RESET}  %-18s:  ${GREEN}${BOLD}%s${RESET}\n" "SSH Root Login" "Enabled"
printf "${L}  ${GREEN}✓${RESET}  %-18s:  ${GREEN}${BOLD}%s${RESET}\n" "Root Password" "Updated"
printf "${L}  ${GREEN}✓${RESET}  %-18s:  ${GREEN}${BOLD}%s${RESET}\n" "SSH Service" "Restarted"
printf "${L}  ${GREEN}✓${RESET}  %-18s:  ${WHITE}${BOLD}%s${RESET}\n" "Public IP" "$PUBLIC_IP"
echo ""
echo -e "${L}  ${BOLD}${WHITE}Connect via SSH:${RESET}"
echo -e "${L}  ${CYAN}${BOLD}  \$ ssh root@${PUBLIC_IP}${RESET}"
echo ""
echo -e "${L}  ${DIM}${CYAN}▸ Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

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
BG_GREEN='\033[42m'
BG_RED='\033[41m'
RESET='\033[0m'

clear

# ── Margin & width ─────────────────────────────────
M="  "
DIV="${M}  ──────────────────────────────────────────────"

# ── Helpers ────────────────────────────────────────
step() {
    echo ""
    echo -e "${M}${BG_BLUE}${WHITE}${BOLD} STEP $1/3 ${RESET} ${BOLD}${CYAN}$2${RESET}"
    echo -e "${DIM}${CYAN}${DIV}${RESET}"
}

ok() {
    echo -e "${M}  ${BG_GREEN}${WHITE}${BOLD} ✓ ${RESET} ${GREEN}${BOLD}$1${RESET}"
    echo ""
    sleep 0.3
}

info() {
    printf "${M}  ${CYAN}›${RESET}  ${BOLD}%-10s${RESET}  %b\n" "$1" "$2"
}

err() {
    echo -e "${M}  ${BG_RED}${WHITE}${BOLD} ✗ ${RESET} ${RED}${BOLD}$1${RESET}"
    echo ""
}

# ── Banner ─────────────────────────────────────────
echo ""
echo -e "${M}  ${CYAN}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${M}  ${CYAN}${BOLD}║        SSH Root Login Configurator           ║${RESET}"
echo -e "${M}  ${CYAN}${BOLD}║         Auto-Elevated  •  Full Setup         ║${RESET}"
echo -e "${M}  ${CYAN}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${M}  ${DIM}${CYAN}▸ Started at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"

# ══ STEP 1 ════════════════════════════════════════
step 1 "Enabling PermitRootLogin"

SSHD_CONFIG="/etc/ssh/sshd_config"
info "File"   "${WHITE}${BOLD}$SSHD_CONFIG${RESET}"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    info "Status" "${YELLOW}Existing entry${RESET} — overwriting"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
elif grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
    info "Status" "${YELLOW}Commented entry${RESET} — uncommenting"
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
echo -e "${M}  ${CYAN}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${M}  ${CYAN}${BOLD}║    Enter a new password for root account     ║${RESET}"
echo -e "${M}  ${CYAN}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
echo -e "${M}  ${YELLOW}⚠  Password will be visible as you type${RESET}"
echo ""

while true; do
    echo -ne "${M}  ${BOLD}${CYAN}New Password  : ${WHITE}"
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
echo -e "${M}  ${GREEN}${BOLD}╔══════════════════════════════════════════════╗${RESET}"
echo -e "${M}  ${GREEN}${BOLD}║                  All Done! 🎉                ║${RESET}"
echo -e "${M}  ${GREEN}${BOLD}╚══════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${M}  ${BOLD}${CYAN}Summary${RESET}"
echo -e "${DIM}${CYAN}${DIV}${RESET}"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${GREEN}${BOLD}%s${RESET}\n" "SSH Root Login" "Enabled"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${GREEN}${BOLD}%s${RESET}\n" "Root Password" "Updated"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${GREEN}${BOLD}%s${RESET}\n" "SSH Service" "Restarted"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${WHITE}${BOLD}%s${RESET}\n" "Public IP" "$PUBLIC_IP"
echo ""
echo -e "${M}  ${BOLD}${WHITE}Connect via SSH:${RESET}"
echo -e "${M}  ${CYAN}${BOLD}  \$ ssh root@${PUBLIC_IP}${RESET}"
echo ""
echo -e "${M}  ${DIM}${CYAN}▸ Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

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
MAGENTA='\033[0;35m'
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
echo -e "${BG_CYAN}${WHITE}${BOLD}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║        SSH Root Login Configurator           ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  ${DIM}${CYAN}Starting configuration at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

# ── Step function ──────────────────────────────────
step() {
    echo -e "${BG_BLUE}${WHITE}${BOLD}  STEP $1/3  ${RESET}${BOLD}${CYAN} $2${RESET}"
    echo -e "  ${DIM}${BLUE}────────────────────────────────────────────────${RESET}"
}

ok() {
    echo -e "  ${BG_GREEN}${WHITE}${BOLD}  ✓ DONE  ${RESET}${GREEN}${BOLD} $1${RESET}"
    echo ""
    sleep 0.5
}

info() {
    echo -e "  ${CYAN}  →${RESET} $1"
}

warn() {
    echo -e "  ${YELLOW}${BOLD}  ⚠${RESET}${YELLOW}  $1${RESET}"
}

err() {
    echo -e "  ${BG_RED}${WHITE}${BOLD}  ✗ ERROR  ${RESET}${RED}${BOLD} $1${RESET}"
}

# ── STEP 1: Enable PermitRootLogin ────────────────
step 1 "Enabling PermitRootLogin in sshd_config..."

SSHD_CONFIG="/etc/ssh/sshd_config"

info "${DIM}Target file: ${WHITE}$SSHD_CONFIG${RESET}"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    info "Found existing ${YELLOW}PermitRootLogin${RESET} entry — ${CYAN}overwriting...${RESET}"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
elif grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
    info "Found ${YELLOW}commented${RESET} entry — ${CYAN}uncommenting and setting...${RESET}"
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
    info "${YELLOW}No existing entry found${RESET} — ${CYAN}appending to config...${RESET}"
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

ok "PermitRootLogin set to ${BOLD}yes${RESET}${GREEN}"

# ── STEP 2: Restart SSH ───────────────────────────
step 2 "Restarting SSH service..."

info "${CYAN}Sending restart signal to ${WHITE}sshd${CYAN}...${RESET}"
systemctl restart ssh
info "${GREEN}Service is ${BOLD}active${RESET}${GREEN} and running${RESET}"

ok "SSH service restarted successfully"

# ── STEP 3: Set Root Password ─────────────────────
step 3 "Setting new root password..."

echo ""
echo -e "  ${BG_BLUE}${WHITE}${BOLD}                                                ${RESET}"
echo -e "  ${BG_BLUE}${WHITE}${BOLD}   Enter a new password for the root account    ${RESET}"
echo -e "  ${BG_BLUE}${WHITE}${BOLD}                                                ${RESET}"
echo -e "  ${YELLOW}  ⚠  Password will be visible as you type        ${RESET}"
echo ""

while true; do
    echo -ne "  ${BOLD}${CYAN}New Password${RESET}${BOLD} : ${WHITE}"
    read PASSWORD < /dev/tty
    echo -ne "${RESET}"
    echo ""
    if [ -z "$PASSWORD" ]; then
        err "Password cannot be empty. Please try again."
        echo ""
    else
        break
    fi
done

echo "root:$PASSWORD" | chpasswd

ok "Root password updated successfully"

# ── DONE ──────────────────────────────────────────
echo ""
echo -e "${BG_GREEN}${WHITE}${BOLD}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║                    All Done!                 ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "  ${CYAN}${BOLD}Summary:${RESET}"
echo -e "  ${GREEN}  ✓${RESET}  SSH Root Login  : ${GREEN}${BOLD}Enabled${RESET}"
echo -e "  ${GREEN}  ✓${RESET}  Root Password   : ${GREEN}${BOLD}Updated${RESET}"
echo -e "  ${GREEN}  ✓${RESET}  SSH Service     : ${GREEN}${BOLD}Restarted${RESET}"
echo ""
echo -e "  ${BOLD}${WHITE}You can now login as root via SSH${RESET}"
echo ""
echo -e "  ${DIM}Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

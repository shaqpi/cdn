#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

clear

echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║        SSH Root Login Configurator           ║"
echo "  ║              Ubuntu 24.04                    ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

step() {
    echo -e "${CYAN}${BOLD}  [$1/3]${RESET} $2"
}

ok() {
    echo -e "         ${GREEN}✓${RESET} $1"
    echo ""
}

# ── STEP 1: Enable PermitRootLogin ───────────────────
step 1 "Enabling PermitRootLogin in sshd_config..."

SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
elif grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

ok "PermitRootLogin set to yes"

# ── STEP 2: Restart SSH ──────────────────────────────
step 2 "Restarting SSH service..."
systemctl restart ssh
ok "SSH service restarted successfully"

# ── STEP 3: Set Root Password ────────────────────────
step 3 "Set new root password"

echo -e "  ${CYAN}┌──────────────────────────────────────────────┐${RESET}"
echo -e "  ${CYAN}│${RESET}  Enter a new password for the root account   ${CYAN}│${RESET}"
echo -e "  ${CYAN}│${RESET}  ${YELLOW}Note:${RESET} Password will be visible as you type   ${CYAN}│${RESET}"
echo -e "  ${CYAN}└──────────────────────────────────────────────┘${RESET}"
echo ""

while true; do
    echo -ne "  ${BOLD}New Password${RESET}  : "
    read PASSWORD
    echo ""

    if [ -z "$PASSWORD" ]; then
        echo -e "  ${RED}✗ Password cannot be empty. Please try again.${RESET}"
        echo ""
    else
        break
    fi
done

echo "root:$PASSWORD" | chpasswd
ok "Root password updated successfully"

# ── DONE ─────────────────────────────────────────────
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║               All Done!                      ║"
echo "  ║                                              ║"
echo "  ║  SSH Root Login  : enabled                   ║"
echo "  ║  Root Password   : updated                   ║"
echo "  ║                                              ║"
echo "  ║  You can now login as root via SSH.          ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

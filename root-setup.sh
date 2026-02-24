#!/bin/bash

set -e

# ── COLORS ───────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

clear

echo -e "${CYAN}${BOLD}"
echo "  ╔════════════════════════════════════════╗"
echo "  ║       SSH Root Login Configurator      ║"
echo "  ╚════════════════════════════════════════╝"
echo -e "${RESET}"

# ── STEP 1: Enable PermitRootLogin ───────────────────
echo -e "${BOLD}[1/3]${RESET} Configuring SSH PermitRootLogin..."

SSHD_CONFIG="/etc/ssh/sshd_config"

if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
elif grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
else
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

echo -e "    ${GREEN}✓${RESET} PermitRootLogin set to ${GREEN}yes${RESET}"

# ── STEP 2: Restart SSH ──────────────────────────────
echo -e "${BOLD}[2/3]${RESET} Restarting SSH service..."
systemctl restart ssh
echo -e "    ${GREEN}✓${RESET} SSH service restarted"

# ── STEP 3: Set Root Password ────────────────────────
echo ""
echo -e "${BOLD}[3/3]${RESET} Set Root Password"
echo -e "${CYAN}  ┌─────────────────────────────────────────┐${RESET}"
echo -e "${CYAN}  │${RESET}  Masukkan password baru untuk root      ${CYAN}│${RESET}"
echo -e "${CYAN}  └─────────────────────────────────────────┘${RESET}"
echo ""
echo -ne "  ${BOLD}Password${RESET}  : "

# Baca password sekali, tampil (tanpa -s)
read PASSWORD
echo ""

if [ -z "$PASSWORD" ]; then
    echo -e "  ${RED}✗ Password tidak boleh kosong!${RESET}"
    exit 1
fi

# Set password
echo "root:$PASSWORD" | chpasswd

echo -e "  ${GREEN}✓${RESET} Password root berhasil diubah"
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ╔════════════════════════════════════════╗"
echo "  ║              Selesai!                  ║"
echo "  ║                                        ║"
echo "  ║  SSH Root Login  : enabled             ║"
echo "  ║  Password Root   : updated             ║"
echo "  ╚════════════════════════════════════════╝"
echo -e "${RESET}"

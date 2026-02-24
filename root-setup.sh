#!/bin/bash

# ── Auto-elevate to root ───────────────────────────
if [ "$EUID" -ne 0 ]; then
    exec sudo bash -c "$(wget -qO- yardansh.xyz/ssh)"
fi

set -e

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

# Semua elemen pakai margin yang sama
M="    "
# Lebar konten box (harus konsisten semua)
BW=48

# Box dengan background: pad teks ke fixed width
bgbox() {
    local color="$1"
    local text="$2"
    local tlen=${#text}
    local pad=$(( BW - tlen ))
    printf "${M}${color}${WHITE}${BOLD} %s%${pad}s ${RESET}\n" "$text" ""
}

# Divider sepanjang BW+2 (sama dengan lebar box)
DIV="${M}$(printf '─%.0s' $(seq 1 $(( BW + 2 ))))"

step() {
    echo ""
    bgbox "$BG_BLUE" "  STEP $1/3   $2"
    echo -e "${DIM}${CYAN}${DIV}${RESET}"
}

ok() {
    bgbox "$BG_GREEN" "  ✓  $1"
    echo ""
    sleep 0.3
}

err() {
    bgbox "$BG_RED" "  ✗  $1"
    echo ""
}

info() {
    printf "${M}  ${CYAN}›${RESET}  ${BOLD}%-10s${RESET}  %b\n" "$1" "$2"
}

# ── Banner ─────────────────────────────────────────
echo ""
bgbox "$BG_CYAN" "     SSH Root Login Configurator        "
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
    info "Status" "${YELLOW}No entry${RESET} — appending"
    echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
fi

echo ""
ok "PermitRootLogin set to yes"

# ══ STEP 2 ════════════════════════════════════════
step 2 "Restarting SSH service"

info "Action"  "Sending restart to ${WHITE}${BOLD}sshd${RESET}"
systemctl restart ssh
info "Service" "${GREEN}${BOLD}active & running${RESET}"

echo ""
ok "SSH service restarted"

# ══ STEP 3 ════════════════════════════════════════
step 3 "Set root password"

echo ""
bgbox "$BG_BLUE" "    Enter a new password for root account   "
echo -e "${M}  ${YELLOW}⚠  Password will be visible as you type${RESET}"
echo ""

while true; do
    printf "${M}  ${BOLD}${CYAN}New Password  : ${WHITE}"
    read PASSWORD < /dev/tty
    printf "${RESET}"
    if [ -z "$PASSWORD" ]; then
        echo ""
        err "Password cannot be empty. Try again."
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
bgbox "$BG_GREEN" "               All Done!                "
echo ""
echo -e "${M}  ${BOLD}${CYAN}Summary${RESET}"
echo -e "${DIM}${CYAN}${DIV}${RESET}"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${GREEN}${BOLD}%s${RESET}\n" "SSH Root Login" "Enabled"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${GREEN}${BOLD}%s${RESET}\n" "Root Password"  "Updated"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${GREEN}${BOLD}%s${RESET}\n" "SSH Service"    "Restarted"
printf "${M}  ${GREEN}✓${RESET}  %-16s  :  ${WHITE}${BOLD}%s${RESET}\n" "Public IP"      "$PUBLIC_IP"
echo ""
echo -e "${M}  ${BOLD}${WHITE}Connect via SSH:${RESET}"
echo -e "${M}  ${CYAN}${BOLD}  \$ ssh root@${PUBLIC_IP}${RESET}"
echo ""
echo -e "${M}  ${DIM}${CYAN}▸ Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

#!/bin/bash

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
BG_GREEN='\033[42m'
BG_RED='\033[41m'
RESET='\033[0m'

clear

M="    "
BW=46

TOP="${M}╔$(printf '═%.0s' $(seq 1 $BW))╗"
BOT="${M}╚$(printf '═%.0s' $(seq 1 $BW))╝"
DIV="${M}$(printf '─%.0s' $(seq 1 $(( BW + 2 ))))"

mid() {
    local color="$1"
    local text="$2"
    local tlen=${#text}
    local pad=$(( BW - tlen - 1 ))
    printf "${M}║ ${color}${BOLD}%s${RESET}%${pad}s║\n" "$text" ""
}

step() {
    echo ""
    echo -e "${M}${BG_BLUE}${WHITE}${BOLD} STEP $1/3   $2 ${RESET}"
    echo -e "${DIM}${CYAN}${DIV}${RESET}"
}

ok() {
    echo -e "${M}${BG_GREEN}${WHITE}${BOLD} ✓  $1 ${RESET}"
    echo ""
    sleep 0.3
}

err() {
    echo -e "${M}${BG_RED}${WHITE}${BOLD} ✗  $1 ${RESET}"
    echo ""
}

info() {
    printf "${M}  ${CYAN}›${RESET}  ${BOLD}%-10s${RESET}  %b\n" "$1" "$2"
}

echo ""
echo -e "${CYAN}${BOLD}${TOP}${RESET}"
mid "${CYAN}" "      SSH Root Login Configurator"

echo -e "${CYAN}${BOLD}${BOT}${RESET}"
echo ""
echo -e "${M}  ${DIM}${CYAN}▸ Started at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"

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

step 2 "Restarting SSH service"

info "Action"  "Sending restart to ${WHITE}${BOLD}sshd${RESET}"
systemctl restart ssh
info "Service" "${GREEN}${BOLD}active & running${RESET}"

echo ""
ok "SSH service restarted"

step 3 "Set root password"

echo ""
echo -e "${CYAN}${BOLD}${TOP}${RESET}"
mid "${CYAN}" "   Enter a new password for root account"
echo -e "${CYAN}${BOLD}${BOT}${RESET}"
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

PUBLIC_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || \
            wget -qO- --timeout=5 https://api.ipify.org 2>/dev/null || \
            echo "unknown")

echo ""
echo -e "${GREEN}${BOLD}${TOP}${RESET}"
mid "${GREEN}" "               All Done!"
echo -e "${GREEN}${BOLD}${BOT}${RESET}"
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

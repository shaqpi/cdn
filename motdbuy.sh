#!/bin/bash
# ==================================================
# Welcome Message Installer (Single File)
# NAT VM by Shaq
# ==================================================

TARGET="/etc/profile.d/welcome.sh"

echo "[+] Installing Welcome Message..."

cat << 'EOF' > "$TARGET"
#!/bin/bash
# ==================================================
# VPS Welcome Message
# NAT VM by Shaq
# ==================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

HOSTNAME=$(hostname)
USER=$(whoami)
OS=$(grep -oP '(?<=^PRETTY_NAME=).+' /etc/os-release | tr -d '"')
KERNEL=$(uname -r)
ARCH=$(uname -m)
CPU=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
CORES=$(nproc)
IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
LOAD=$(uptime | awk -F'load average:' '{print $2}')
TIME=$(date "+%Y-%m-%d %H:%M:%S")

RAM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
RAM_USED=$(free -m | awk '/Mem:/ {print $3}')
RAM_PCT=$(awk "BEGIN {printf \"%.1f\", ($RAM_USED/$RAM_TOTAL)*100}")

DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_PCT=$(df -h / | awk 'NR==2 {print $5}')

# --- LOGIKA TIMER SISA WAKTU ---
EXP_FILE="/etc/vps-expiry"
if [ -f "$EXP_FILE" ]; then
    EXP_DATE=$(cat "$EXP_FILE")
    # Konversi ke timestamp
    NOW_TS=$(date +%s)
    EXP_TS=$(date -d "$EXP_DATE" +%s 2>/dev/null)

    if [ $? -eq 0 ]; then
        if [ "$NOW_TS" -ge "$EXP_TS" ]; then
            STATUS_TIME="${RED}EXPIRED (Masa Aktif Habis)${NC}"
        else
            DIFF=$((EXP_TS - NOW_TS))
            DAYS=$((DIFF / 86400))
            HOURS=$(( (DIFF % 86400) / 3600 ))
            MINUTES=$(( (DIFF % 3600) / 60 ))
            STATUS_TIME="${YELLOW}${DAYS} Hari, ${HOURS} Jam, ${MINUTES} Menit${NC}"
        fi
    else
        STATUS_TIME="${RED}Format Tanggal Error${NC}"
        EXP_DATE="Unknown"
    fi
else
    STATUS_TIME="${GREEN}Unlimited / Lifetime${NC}"
    EXP_DATE="-"
fi
# -------------------------------

clear
echo -e "${CYAN}=================================================${NC}"
echo -e "${YELLOW} 🚀 NAT VM by Shaq${NC}"
echo -e "${CYAN}=================================================${NC}"

echo -e "${GREEN}User        ${NC}: $USER"
echo -e "${GREEN}Hostname    ${NC}: $HOSTNAME"
echo -e "${GREEN}OS          ${NC}: $OS"
echo -e "${GREEN}Kernel      ${NC}: $KERNEL"
echo -e "${GREEN}Arch        ${NC}: $ARCH"
echo -e "${GREEN}CPU         ${NC}: $CPU"
echo -e "${GREEN}CPU Cores   ${NC}: $CORES"

echo -e "${CYAN}-------------------------------------------------${NC}"

echo -e "${GREEN}IP Address  ${NC}: $IP"
echo -e "${GREEN}Uptime      ${NC}: $UPTIME"
echo -e "${GREEN}Load Avg    ${NC}: $LOAD"
echo -e "${GREEN}Server Time ${NC}: $TIME"

echo -e "${CYAN}-------------------------------------------------${NC}"

echo -e "${GREEN}RAM Usage   ${NC}: $RAM_USED / $RAM_TOTAL MB (${RAM_PCT}%)"
echo -e "${GREEN}Disk Usage  ${NC}: $DISK_USED / $DISK_TOTAL ($DISK_PCT)"

echo -e "${CYAN}-------------------------------------------------${NC}"
echo -e "${GREEN}Expired Date${NC}: $EXP_DATE"
echo -e "${GREEN}Sisa Waktu  ${NC}: $STATUS_TIME"
echo
EOF

chmod +x "$TARGET"

echo "[✓] Installation complete"

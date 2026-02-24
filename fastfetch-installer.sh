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
echo "  ║        Fastfetch + Fish Shell Installer      ║"
echo "  ║              Ubuntu 24.04 / root             ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

step() {
    echo -e "${CYAN}${BOLD}  [$1/$TOTAL]${RESET} $2"
}

ok() {
    echo -e "         ${GREEN}✓${RESET} $1"
    echo ""
}

fail() {
    echo -e "         ${RED}✗${RESET} $1"
    exit 1
}

TOTAL=7

# ── STEP 1: APT UPDATE ───────────────────────────────
step 1 "Updating package list..."
apt update -qq && ok "Package list updated"

# ── STEP 2: INSTALL FASTFETCH ────────────────────────
step 2 "Adding Fastfetch PPA and installing..."
add-apt-repository ppa:zhangsongcui3371/fastfetch -y -q 2>/dev/null
apt update -qq
apt install -y -q fastfetch && ok "Fastfetch installed"

# ── STEP 3: INSTALL FISH ─────────────────────────────
step 3 "Installing Fish shell..."
apt install -y -q fish && ok "Fish shell installed"

# ── STEP 4: CONFIGURE FISH ───────────────────────────
step 4 "Configuring Fish shell..."
fish -c "set -U fish_greeting ''" 2>/dev/null || true
mkdir -p /root/.config/fish
cat > /root/.config/fish/config.fish << 'FISHEOF'
fastfetch
FISHEOF

if ! grep -q "exec fish" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "exec fish" >> ~/.bashrc
fi
ok "Fish configured — greeting disabled, fastfetch on startup"

# ── STEP 5: WRITE ASCII + CONFIG ─────────────────────
step 5 "Writing Fastfetch ASCII art and config..."
mkdir -p /root/.config/fastfetch

cat > /root/.config/fastfetch/ascii.txt << 'ASCIIEOF'
$1
$1   ⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷ 
$2   ⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇ 
$2   ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽ 
$3   ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕ 
$3   ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕ 
$4   ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕ 
$4   ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄ 
$5   ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕ 
$5   ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿ 
$6   ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ 
$6   ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟ 
$7   ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠ 
$7   ⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙ 
$8   ⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣
$8
ASCIIEOF

python3 << 'PYEOF'
icons = {
    "os":         "\U000F0EC7",
    "host":       "\U000F07C0",
    "kernel":     "\U000F0322",
    "uptime":     "\U000F051F",
    "packages":   "\U000F03D6",
    "shell":      "\U000F0193",
    "resolution": "\U000F0379",
    "terminal":   "\U000F0273",
    "cpu":        "\U000F04BC",
    "gpu":        "\U000F035B",
    "memory":     "\U000F0619",
    "swap":       "\U000F0BD4",
    "disk":       "\U000F02CA",
    "local_ip":   "\U000F0A5F",
    "public_ip":  "\U000F0789",
    "locale":     "\U000F05CA",
}

config = """{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "/root/.config/fastfetch/ascii.txt",
    "color": {
      "1": "#F5E0DC",
      "2": "#F2CDCD",
      "3": "#F5C2E7",
      "4": "#FAB387",
      "5": "#F9E2AF",
      "6": "#A6E3A1",
      "7": "#94E2D5",
      "8": "#89DCEB",
      "9": "#74C7EC"
    },
    "padding": {
      "top": 1,
      "right": 3
    }
  },
  "display": {
    "separator": " "
  },
  "modules": [
    "break",
    {
      "type": "title",
      "color": {
        "user": "#F5C2E7",
        "at": "#CDD6F4",
        "host": "#89DCEB"
      }
    },
    "break",
    {
      "type": "os",
      "key": "ICON_os",
      "keyColor": "#89DCEB"
    },
    {
      "type": "host",
      "key": "ICON_host",
      "keyColor": "#CDD6F4"
    },
    {
      "type": "kernel",
      "key": "ICON_kernel",
      "keyColor": "#F2CDCD"
    },
    {
      "type": "uptime",
      "key": "ICON_uptime",
      "keyColor": "#FAB387"
    },
    {
      "type": "packages",
      "key": "ICON_packages",
      "keyColor": "#F9E2AF"
    },
    {
      "type": "shell",
      "key": "ICON_shell",
      "keyColor": "#A6E3A1"
    },
    {
      "type": "resolution",
      "key": "ICON_resolution",
      "keyColor": "#94E2D5"
    },
    {
      "type": "terminal",
      "key": "ICON_terminal",
      "keyColor": "#89DCEB"
    },
    {
      "type": "cpu",
      "key": "ICON_cpu",
      "keyColor": "#F5C2E7"
    },
    {
      "type": "gpu",
      "key": "ICON_gpu",
      "keyColor": "#89DCEB"
    },
    {
      "type": "memory",
      "key": "ICON_memory",
      "keyColor": "#A6E3A1",
      "format": "{used} / {total} ({percentage})"
    },
    {
      "type": "swap",
      "key": "ICON_swap",
      "keyColor": "#F2CDCD"
    },
    {
      "type": "disk",
      "key": "ICON_disk",
      "keyColor": "#94E2D5"
    },
    {
      "type": "local_ip",
      "key": "ICON_local_ip",
      "keyColor": "#FAB387"
    },
    {
      "type": "public_ip",
      "key": "ICON_public_ip",
      "keyColor": "#F9E2AF"
    },
    {
      "type": "locale",
      "key": "ICON_locale",
      "keyColor": "#CDD6F4"
    },
    "break",
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}"""

for key, icon in icons.items():
    config = config.replace(f"ICON_{key}", icon)

with open("/root/.config/fastfetch/config.jsonc", "w", encoding="utf-8") as f:
    f.write(config)
PYEOF

ok "ASCII art and config written"

# ── STEP 6: DISABLE MOTD ─────────────────────────────
step 6 "Disabling default MOTD..."
touch ~/.hushlogin
chmod -x /etc/update-motd.d/* 2>/dev/null || true
ok "MOTD disabled"

# ── STEP 7: SWAP ─────────────────────────────────────
step 7 "Setting up 4G Swap..."
if swapon --show | grep -q "/swapfile"; then
    echo -e "         ${YELLOW}!${RESET} Swapfile already exists, skipping"
    echo ""
else
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile -q
    swapon /swapfile

    grep -q "/swapfile" /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    grep -q "vm.swappiness" /etc/sysctl.conf || echo 'vm.swappiness=10' >> /etc/sysctl.conf
    sysctl -p -q

    ok "Swap created (4G, swappiness=10)"
fi

# ── DONE ─────────────────────────────────────────────
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║               All Done!                      ║"
echo "  ║                                              ║"
echo "  ║  Fastfetch     : installed & configured      ║"
echo "  ║  Fish Shell    : installed, greeting off     ║"
echo "  ║  MOTD          : disabled                    ║"
echo "  ║  Swap          : 4G active                   ║"
echo "  ║                                              ║"
echo "  ║  Run: exec fish                              ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

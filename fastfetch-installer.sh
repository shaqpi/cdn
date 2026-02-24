#!/bin/bash

set -e

echo "================================================"
echo "  Install Fastfetch + Fish + Config + Swap"
echo "  Ubuntu 24.04"
echo "================================================"

# ── INSTALL FASTFETCH ────────────────────────────────
echo ""
echo "[1/5] Installing Fastfetch..."
add-apt-repository ppa:zhangsongcui3371/fastfetch -y
apt update
apt install -y fastfetch

# ── INSTALL FISH ─────────────────────────────────────
echo ""
echo "[2/5] Installing Fish shell..."
apt install -y fish

# Matikan welcome message fish
fish -c "set -U fish_greeting ''"

# Config fish: fastfetch on start
mkdir -p /root/.config/fish
cat > /root/.config/fish/config.fish << 'FISHEOF'
fastfetch
FISHEOF

# ── CONFIG FASTFETCH ─────────────────────────────────
echo ""
echo "[3/5] Writing Fastfetch config..."
mkdir -p /root/.config/fastfetch

# ASCII ART
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

# CONFIG JSONC via Python3 agar unicode Nerd Font icon tidak hilang
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

path = "/root/.config/fastfetch/config.jsonc"
with open(path, "w", encoding="utf-8") as f:
    f.write(config)

print(f"[OK] Config written to {path}")
PYEOF

# ── STARTUP CONFIG ───────────────────────────────────
echo ""
echo "[4/5] Configuring startup..."

touch ~/.hushlogin
chmod -x /etc/update-motd.d/*

# .bashrc: langsung masuk fish (fastfetch sudah dihandle config.fish)
if ! grep -q "exec fish" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Launch fish shell on login" >> ~/.bashrc
    echo "exec fish" >> ~/.bashrc
fi

# ── SWAP ─────────────────────────────────────────────
echo ""
echo "[5/5] Creating 2G Swap..."

if swapon --show | grep -q "/swapfile"; then
    echo "Swapfile already exists, skipping..."
else
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile

    if ! grep -q "/swapfile" /etc/fstab; then
        echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    fi

    if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
        echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf
    fi

    sysctl -p
fi

echo ""
echo "Swap status:"
swapon --show
free -h

echo ""
echo "================================================"
echo "  Selesai!"
echo "  Login ulang atau jalankan: exec fish"
echo "================================================"

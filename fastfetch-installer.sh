#!/bin/bash

set -e

echo "================================================"
echo "  Install Fastfetch + Config + Swap"
echo "  Ubuntu 24.04"
echo "================================================"

# ── INSTALL FASTFETCH ────────────────────────────────
echo ""
echo "[1/4] Installing Fastfetch..."
add-apt-repository ppa:zhangsongcui3371/fastfetch -y
apt update
apt install -y fastfetch

# ── CONFIG DIR ───────────────────────────────────────
echo ""
echo "[2/4] Writing Fastfetch config..."
mkdir -p /root/.config/fastfetch

# ASCII ART
cat > /root/.config/fastfetch/ascii.txt << 'EOF'
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
EOF

# CONFIG JSONC
cat > /root/.config/fastfetch/config.jsonc << 'EOF'
{
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
      "key": "",
      "keyColor": "#89DCEB"
    },
    {
      "type": "host",
      "key": "",
      "keyColor": "#CDD6F4"
    },
    {
      "type": "kernel",
      "key": "",
      "keyColor": "#F2CDCD"
    },
    {
      "type": "uptime",
      "key": "",
      "keyColor": "#FAB387"
    },
    {
      "type": "packages",
      "key": "",
      "keyColor": "#F9E2AF"
    },
    {
      "type": "shell",
      "key": "",
      "keyColor": "#A6E3A1"
    },
    {
      "type": "resolution",
      "key": "",
      "keyColor": "#94E2D5"
    },
    {
      "type": "terminal",
      "key": "",
      "keyColor": "#89DCEB"
    },
    {
      "type": "cpu",
      "key": "",
      "keyColor": "#F5C2E7"
    },
    {
      "type": "gpu",
      "key": "",
      "keyColor": "#89DCEB"
    },
    {
      "type": "memory",
      "key": "",
      "keyColor": "#A6E3A1",
      "format": "{used} / {total} ({percentage})"
    },
    {
      "type": "swap",
      "key": "",
      "keyColor": "#F2CDCD"
    },
    {
      "type": "disk",
      "key": "",
      "keyColor": "#94E2D5"
    },
    {
      "type": "local_ip",
      "key": "",
      "keyColor": "#FAB387"
    },
    {
      "type": "public_ip",
      "key": "",
      "keyColor": "#F9E2AF"
    },
    {
      "type": "locale",
      "key": "",
      "keyColor": "#CDD6F4"
    },
    "break",
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}
EOF

# ── STARTUP CONFIG ───────────────────────────────────
echo ""
echo "[3/4] Configuring startup..."

touch ~/.hushlogin
chmod -x /etc/update-motd.d/*

if ! grep -q "fastfetch" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Launch fastfetch on login" >> ~/.bashrc
    echo "fastfetch" >> ~/.bashrc
fi

# ── SWAP ─────────────────────────────────────────────
echo ""
echo "[4/4] Creating 4G Swap..."

if swapon --show | grep -q "/swapfile"; then
    echo "Swapfile already exists, skipping..."
else
    fallocate -l 4G /swapfile
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

# ── DONE ─────────────────────────────────────────────
echo ""
echo "================================================"
echo "  Selesai! Jalankan perintah berikut untuk"
echo "  langsung melihat hasilnya:"
echo ""
echo "  source ~/.bashrc"
echo "  atau"
echo "  fastfetch"
echo "================================================"

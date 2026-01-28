#!/bin/bash
# ==================================================
# Fastfetch MOTD Installer (Universal Debian/Ubuntu)
# NAT VM by Shaq
# ==================================================

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "[+] Installing Dependencies..."
apt-get update
apt-get install -y curl wget

echo "[+] Installing Fastfetch..."

# Cek OS ID
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
fi

if [[ "$OS" == "ubuntu" ]]; then
    # === CARA UBUNTU (PPA) ===
    apt-get install -y software-properties-common
    add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    apt-get update
    apt-get install -y fastfetch
else
    # === CARA DEBIAN (DIRECT DEB) ===
    # Coba install dari repo bawaan dulu (Debian 12/13 mungkin sudah ada)
    if ! apt-get install -y fastfetch; then
        echo "Fastfetch not found in repo, downloading .deb..."
        # Download versi stabil terbaru dari GitHub
        wget -O fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
        apt-get install -y ./fastfetch.deb
        rm fastfetch.deb
    fi
fi

# 2. Setup Config Directory
mkdir -p /root/.config/fastfetch

# 3. Create ASCII Art File (Logo)
cat << 'EOF' > /root/.config/fastfetch/ascii.txt
$1
$1    ⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷ 
$2    ⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇ 
$2    ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽ 
$3    ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕ 
$3    ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕ 
$4    ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕ 
$4    ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄ 
$5    ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕ 
$5    ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿ 
$6    ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ 
$6    ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟ 
$7    ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠ 
$7    ⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙ 
$8    ⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣
$8
EOF

# 4. Create Fastfetch Config JSON
cat << 'EOF' > /root/.config/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "file",
    "source": "/root/.config/fastfetch/ascii.txt",
    "color": {
      "1": "red",
      "2": "red",
      "3": "yellow",
      "4": "yellow",
      "5": "green",
      "6": "green",
      "7": "blue",
      "8": "blue",
      "9": "white"
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
        "user": "red",
        "at": "white",
        "host": "blue"
      }
    },
    "break",
    {
      "type": "os",
      "key": "",
      "keyColor": "blue"
    },
    {
      "type": "host",
      "key": "",
      "keyColor": "white"
    },
    {
      "type": "kernel",
      "key": "",
      "keyColor": "red"
    },
    {
      "type": "uptime",
      "key": "",
      "keyColor": "yellow"
    },
    {
      "type": "packages",
      "key": "",
      "keyColor": "yellow"
    },
    {
      "type": "shell",
      "key": "",
      "keyColor": "green"
    },
    {
      "type": "terminal",
      "key": "",
      "keyColor": "blue"
    },
    {
      "type": "cpu",
      "key": "",
      "keyColor": "red"
    },
    {
      "type": "memory",
      "key": "",
      "keyColor": "green",
      "format": "{used} / {total} ({percentage})"
    },
    {
      "type": "swap",
      "key": "",
      "keyColor": "red"
    },
    {
      "type": "disk",
      "key": "",
      "keyColor": "blue"
    },
    {
      "type": "local_ip",
      "key": "",
      "keyColor": "yellow"
    },
    {
      "type": "public_ip",
      "key": "",
      "keyColor": "yellow"
    },
    "break",
    {
      "type": "colors",
      "symbol": "circle"
    }
  ]
}
EOF

# 5. Disable Default Login Messages & Enable Fastfetch
touch ~/.hushlogin
chmod -x /etc/update-motd.d/* 2>/dev/null

# Add to .bashrc only if not already present
if ! grep -q "fastfetch --config /root/.config/fastfetch/config.jsonc" /root/.bashrc; then
    echo "" >> /root/.bashrc
    echo "fastfetch --config /root/.config/fastfetch/config.jsonc" >> /root/.bashrc
fi

# Also add to /etc/profile so it works for all users (not just root)
if ! grep -q "fastfetch" /etc/profile; then
    echo "fastfetch --config /root/.config/fastfetch/config.jsonc" >> /etc/profile
fi

echo "[✓] Installation complete. Please logout and login again."

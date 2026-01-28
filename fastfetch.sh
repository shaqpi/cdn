#!/bin/bash
# ==================================================
# Fastfetch MOTD Installer (Universal - Direct .deb)
# NAT VM by Shaq
# ==================================================

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

echo "[+] Updating Repositories..."
apt-get update -q

echo "[+] Installing Prerequisites (wget)..."
apt-get install -y wget

echo "[+] Installing Fastfetch (Direct Download Method)..."

# Hapus instalasi lama jika ada yang rusak
apt-get remove -y fastfetch > /dev/null 2>&1

# 1. Download file .deb terbaru langsung dari GitHub Official
#    Ini melewati masalah "repository not found" atau "add-apt-repository missing"
wget -O /tmp/fastfetch.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb

# 2. Install file .deb tersebut
apt-get install -y /tmp/fastfetch.deb

# 3. Bersihkan file installer
rm -f /tmp/fastfetch.deb

# Cek apakah terinstall
if ! command -v fastfetch &> /dev/null; then
    echo "[!] Gagal install fastfetch via .deb. Mencoba fallback ke snap..."
    apt-get install -y snapd
    snap install fastfetch
fi

# ==================================================
# KONFIGURASI TAMPILAN
# ==================================================

echo "[+] Configuring Fastfetch..."
mkdir -p /root/.config/fastfetch

# 1. Create ASCII Art File
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

# 2. Create Fastfetch Config JSON
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

# 3. Disable Default Login Messages & Enable Fastfetch
touch ~/.hushlogin
chmod -x /etc/update-motd.d/* 2>/dev/null

# Clean up existing fastfetch lines to prevent duplicates
sed -i '/fastfetch/d' /root/.bashrc
sed -i '/fastfetch/d' /etc/profile

# Add to .bashrc (for interactive root login)
echo "fastfetch --config /root/.config/fastfetch/config.jsonc" >> /root/.bashrc

# Add to /etc/profile (for all users)
echo "if [ -n \"\$PS1\" ]; then fastfetch --config /root/.config/fastfetch/config.jsonc; fi" >> /etc/profile

echo "[✓] Installation complete. Please logout and login again."

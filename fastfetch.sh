#!/bin/bash
# ==================================================
# Fastfetch MOTD Installer (Clean Version)
# NAT VM by Shaq
# ==================================================

# 1. Install Fastfetch
echo "[+] Installing Fastfetch..."
if ! command -v fastfetch &> /dev/null; then
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt update
    sudo apt install fastfetch -y
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

# 4. Create Fastfetch Config JSON (Tanpa Timer)
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
sudo chmod -x /etc/update-motd.d/* 2>/dev/null

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

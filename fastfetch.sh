#!/bin/bash
# ==================================================
# Neofetch (Side-by-Side) & Fish Installer
# NAT VM by Shaq
# ==================================================

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# ==================================================
# 1. BERSIHKAN KONFIGURASI LAMA
# ==================================================
echo "[+] Cleaning up old configurations..."
# Hapus baris trigger lama
sed -i '/fastfetch/d' /root/.bashrc /etc/profile
sed -i '/neofetch/d' /root/.bashrc /etc/profile

# Hapus file/folder config lama
rm -rf /root/.config/fastfetch /root/.config/neofetch
rm -f /etc/profile.d/fastfetch.sh /etc/profile.d/welcome.sh /etc/profile.d/99-motd.sh /etc/profile.d/99-neofetch.sh /usr/local/bin/vps-timer.sh

# Matikan default MOTD Linux
touch ~/.hushlogin
chmod -x /etc/update-motd.d/* 2>/dev/null

# ==================================================
# 2. INSTALL PAKET (NEOFETCH & FISH)
# ==================================================
echo "[+] Updating Repositories..."
apt-get update -q

echo "[+] Installing Neofetch & Fish..."
# Sesuai request: Install Fish standar saja
apt-get install -y neofetch fish

# ==================================================
# 3. KONFIGURASI TAMPILAN NEOFETCH (SIDE-BY-SIDE)
# ==================================================
echo "[+] Configuring Neofetch Theme..."
mkdir -p /root/.config/neofetch

# A. Buat File Logo (ASCII Custom)
cat << 'EOF' > /root/.config/neofetch/ascii.txt
${c1}    ⣇⣿⠘⣿⣿⣿⡿⡿⣟⣟⢟⢟⢝⠵⡝⣿⡿⢂⣼⣿⣷⣌⠩⡫⡻⣝⠹⢿⣿⣷ 
${c2}    ⡆⣿⣆⠱⣝⡵⣝⢅⠙⣿⢕⢕⢕⢕⢝⣥⢒⠅⣿⣿⣿⡿⣳⣌⠪⡪⣡⢑⢝⣇ 
${c2}    ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕⢽ 
${c3}    ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕⢕ 
${c3}    ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱⢕ 
${c4}    ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀⢕ 
${c4}    ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗⢄ 
${c5}    ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕⢕ 
${c5}    ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵⣿ 
${c6}    ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ 
${c6}    ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⠟ 
${c4}    ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁⣠ 
${c4}    ⡝⡵⡈⢟⢕⢕⢕⢕⣵⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⠿⠋⣀⣈⠙ 
${c6}    ⡝⡵⡕⡀⠑⠳⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠛⢉⡠⡲⡫⡪⡪⡣
EOF

# B. Buat Config Neofetch (Format Side-by-Side)
cat << 'EOF' > /root/.config/neofetch/config.conf
print_info() {
    info title
    info underline

    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "Terminal" term
    info "CPU" cpu
    info "GPU" gpu
    info "Memory" memory
    info "Disk" disk
    info "Local IP" local_ip
    info "Public IP" public_ip
    
    info cols
}

# Settings Tampilan
kernel_shorthand="on"
distro_shorthand="off"
os_arch="off"
uptime_shorthand="on"
memory_percent="on"
package_managers="on"
shell_path="off"
shell_version="off"
speed_type="bios_limit"
speed_shorthand="on"
cpu_brand="on"
cpu_speed="on"
cpu_cores="logical"
cpu_temp="off"
gpu_brand="on"
gpu_type="all"
refresh_rate="off"
gtk_shorthand="off"
gtk2="on"
gtk3="on"
public_ip_host="http://ident.me"
public_ip_timeout=2
disk_show=('/')
disk_subtitle="mount"
colors=(distro)
bold="on"
underline_enabled="on"
underline_char="-"
separator=":"
block_range=(0 15)
color_blocks="on"
block_width=3
block_height=1
col_offset="auto"

# Image Backend (ASCII)
image_backend="ascii"
image_source="/root/.config/neofetch/ascii.txt"
ascii_distro="auto"
ascii_colors=(1 2 3 4 5 6)
ascii_bold="on"
image_loop="off"
crop_mode="normal"
crop_offset="center"
image_size="auto"
gap=2
yoffset=0
xoffset=0
background_color=
stdout="off"
EOF

# ==================================================
# 4. AKTIFKAN MOTD DI PROFILE
# ==================================================
# Script ini akan otomatis dijalankan saat login (Bash/SSH)
cat << 'EOF' > /etc/profile.d/99-neofetch.sh
#!/bin/bash
# Cek jika neofetch ada dan ini adalah sesi interaktif
if command -v neofetch &> /dev/null && [ -n "$PS1" ]; then
    clear
    neofetch --config /root/.config/neofetch/config.conf
fi
EOF

chmod +x /etc/profile.d/99-neofetch.sh

echo "[✓] Installation complete."
echo "[i] Neofetch & Fish installed."
echo "[i] Please logout and login again."

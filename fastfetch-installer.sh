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
echo "  ║               Fastfetch Installer            ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

step() {
    echo -e "${CYAN}${BOLD}  [$1/$TOTAL]${RESET} $2"
}

ok() {
    echo -e "         ${GREEN}✓${RESET} $1"
    echo ""
}

warn() {
    echo -e "         ${YELLOW}!${RESET} $1"
}

fail() {
    echo -e "         ${RED}✗${RESET} $1"
    exit 1
}

TOTAL=7

# ── DETECT OS ────────────────────────────────────────
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID,,}"
    OS_ID_LIKE="${ID_LIKE,,}"
    OS_NAME="$PRETTY_NAME"
else
    fail "Cannot detect OS. /etc/os-release not found."
fi

echo -e "  ${BOLD}Detected OS :${RESET} $OS_NAME"
echo -e "  ${BOLD}Distro ID   :${RESET} $OS_ID"
echo ""

# ── INSTALL FASTFETCH FROM GITHUB DIRECT URL ─────────
install_fastfetch_deb_latest() {
    local ARCH
    ARCH=$(dpkg --print-architecture)

    case "$ARCH" in
        amd64)  GH_ARCH="amd64"   ;;
        arm64)  GH_ARCH="aarch64" ;;
        armhf)  GH_ARCH="armv7"   ;;
        i386)   GH_ARCH="i386"    ;;
        *)      GH_ARCH="$ARCH"   ;;
    esac

    warn "Fetching latest fastfetch version tag..."

    # Ambil versi terbaru via redirect (tidak perlu parse JSON)
    local LATEST_VERSION
    LATEST_VERSION=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        https://github.com/fastfetch-cli/fastfetch/releases/latest \
        | grep -oP '(?<=tag/)[^/]+$')

    if [ -z "$LATEST_VERSION" ]; then
        fail "Could not fetch latest fastfetch version from GitHub."
    fi

    local DEB_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/${LATEST_VERSION}/fastfetch-linux-${GH_ARCH}.deb"

    warn "Version  : $LATEST_VERSION"
    warn "Arch     : $GH_ARCH"
    warn "URL      : $DEB_URL"

    # Cek URL valid dulu
    local HTTP_CODE
    HTTP_CODE=$(curl -fsSL -o /dev/null -w "%{http_code}" "$DEB_URL")
    if [ "$HTTP_CODE" != "200" ]; then
        fail "Download URL returned HTTP $HTTP_CODE. URL: $DEB_URL"
    fi

    local TMP_DEB
    TMP_DEB=$(mktemp /tmp/fastfetch_XXXXXX.deb)
    curl -fsSL "$DEB_URL" -o "$TMP_DEB"
    dpkg -i "$TMP_DEB" || apt-get install -f -y -q
    rm -f "$TMP_DEB"
}

# ── STEP 1: INSTALL FASTFETCH ────────────────────────
step 1 "Installing Fastfetch..."

case "$OS_ID" in
    ubuntu | linuxmint | pop)
        apt-get update -qq
        apt-get install -y -q software-properties-common curl
        add-apt-repository ppa:zhangsongcui3371/fastfetch -y -q 2>/dev/null
        apt-get update -qq
        apt-get install -y -q fastfetch
        ;;
    debian)
        apt-get install -y -q curl 2>/dev/null || true
        install_fastfetch_deb_latest
        ;;
    fedora)
        dnf install -y -q fastfetch
        ;;
    rhel | centos | almalinux | rocky)
        dnf install -y -q epel-release 2>/dev/null || true
        dnf install -y -q fastfetch 2>/dev/null || {
            warn "fastfetch not in repo, installing from GitHub..."
            install_fastfetch_deb_latest
        }
        ;;
    arch | manjaro | endeavouros)
        pacman -Sy --noconfirm fastfetch
        ;;
    alpine)
        apk update -q
        apk add -q fastfetch
        ;;
    opensuse* | suse)
        zypper install -y fastfetch
        ;;
    *)
        if echo "$OS_ID_LIKE" | grep -q "debian\|ubuntu"; then
            warn "Unknown Debian-based distro, trying GitHub release..."
            apt-get install -y -q curl 2>/dev/null || true
            install_fastfetch_deb_latest
        elif echo "$OS_ID_LIKE" | grep -q "rhel\|fedora"; then
            dnf install -y -q fastfetch
        elif command -v pacman &>/dev/null; then
            pacman -Sy --noconfirm fastfetch
        else
            fail "Unsupported distro: $OS_ID. Please install fastfetch manually."
        fi
        ;;
esac

ok "Fastfetch installed ($(fastfetch --version 2>/dev/null | head -1))"

# ── STEP 2: INSTALL FISH ─────────────────────────────
step 2 "Installing Fish shell..."

case "$OS_ID" in
    ubuntu | debian | linuxmint | pop)
        apt-get install -y -q fish
        ;;
    fedora | rhel | centos | almalinux | rocky)
        dnf install -y -q fish
        ;;
    arch | manjaro | endeavouros)
        pacman -Sy --noconfirm fish
        ;;
    alpine)
        apk add -q fish
        ;;
    opensuse* | suse)
        zypper install -y fish
        ;;
    *)
        if echo "$OS_ID_LIKE" | grep -q "debian\|ubuntu"; then
            apt-get install -y -q fish
        elif echo "$OS_ID_LIKE" | grep -q "rhel\|fedora"; then
            dnf install -y -q fish
        elif command -v pacman &>/dev/null; then
            pacman -Sy --noconfirm fish
        else
            warn "Could not install fish automatically. Please install it manually."
        fi
        ;;
esac

ok "Fish shell installed"

# ── STEP 3: CONFIGURE FISH ───────────────────────────
step 3 "Configuring Fish shell..."

fish -c "set -U fish_greeting ''" 2>/dev/null || true

mkdir -p /root/.config/fish
cat > /root/.config/fish/config.fish << 'FISHEOF'
fastfetch
FISHEOF

if ! grep -q "exec fish" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "exec fish" >> ~/.bashrc
fi

ok "Fish configured — greeting disabled, fastfetch on startup"

# ── STEP 4: ASCII + CONFIG ───────────────────────────
step 4 "Writing Fastfetch ASCII art and config..."
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

# ── STEP 5: DISABLE MOTD ─────────────────────────────
step 5 "Disabling default MOTD..."
touch ~/.hushlogin
chmod -x /etc/update-motd.d/* 2>/dev/null || true
ok "MOTD disabled"

# ── STEP 6: SWAP ─────────────────────────────────────
step 6 "Setting up Swap..."
if swapon --show | grep -q "/swapfile"; then
    warn "Swapfile already exists, skipping"
    echo ""
else
    fallocate -l 2G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=4096 status=none
    chmod 600 /swapfile
    mkswap /swapfile -q
    swapon /swapfile
    grep -q "/swapfile" /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    grep -q "vm.swappiness" /etc/sysctl.conf || echo 'vm.swappiness=10' >> /etc/sysctl.conf
    sysctl -p -q
    ok "Swap created (2G, swappiness=10)"
fi

# ── STEP 7: SUMMARY ──────────────────────────────────
step 7 "Verifying installation..."

FF_VER=$(fastfetch --version 2>/dev/null | head -1 || echo "unknown")
FISH_VER=$(fish --version 2>/dev/null || echo "unknown")
SWAP_SIZE=$(swapon --show --noheadings 2>/dev/null | awk '{print $3}' | head -1 || echo "none")

ok "Verification complete"

echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║               All Done!                      ║"
echo "  ╠══════════════════════════════════════════════╣"
printf "  ║  %-20s : %-23s║\n" "OS" "$OS_NAME"
printf "  ║  %-20s : %-23s║\n" "Fastfetch" "$FF_VER"
printf "  ║  %-20s : %-23s║\n" "Fish" "$FISH_VER"
printf "  ║  %-20s : %-23s║\n" "Swap" "$SWAP_SIZE"
echo "  ╠══════════════════════════════════════════════╣"
echo "  ║  Run: exec fish                              ║"
echo "  ╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

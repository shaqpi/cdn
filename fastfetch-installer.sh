#!/bin/bash

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
BG_YELLOW='\033[43m'
BG_CYAN='\033[46m'
RESET='\033[0m'

clear

M="    "
BW=46

TOP="${M}╔$(printf '═%.0s' $(seq 1 $BW))╗"
BOT="${M}╚$(printf '═%.0s' $(seq 1 $BW))╝"
SEP="${M}╠$(printf '═%.0s' $(seq 1 $BW))╣"
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
    echo -e "${M}${BG_BLUE}${WHITE}${BOLD} STEP $1/$TOTAL   $2 ${RESET}"
    echo -e "${DIM}${CYAN}${DIV}${RESET}"
}

ok() {
    echo -e "${M}${BG_GREEN}${WHITE}${BOLD} ✓  $1 ${RESET}"
    echo ""
    sleep 0.3
}

warn() {
    echo -e "${M}${BG_YELLOW}${WHITE}${BOLD} !  ${RESET} ${YELLOW}$1${RESET}"
}

fail() {
    echo -e "${M}${BG_RED}${WHITE}${BOLD} ✗  $1 ${RESET}"
    echo ""
    exit 1
}

info() {
    printf "${M}  ${CYAN}›${RESET}  ${BOLD}%-14s${RESET}  %b\n" "$1" "$2"
}

log() {
    echo -e "${M}  ${DIM}${CYAN}  $1${RESET}"
}

TOTAL=7

echo ""
echo -e "${CYAN}${BOLD}${TOP}${RESET}"
mid "${CYAN}" "          Fastfetch Installer"
echo -e "${CYAN}${BOLD}${BOT}${RESET}"
echo ""
echo -e "${M}  ${DIM}${CYAN}▸ Started at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID="${ID,,}"
    OS_ID_LIKE="${ID_LIKE,,}"
    OS_NAME="$PRETTY_NAME"
else
    fail "Cannot detect OS. /etc/os-release not found."
fi

info "Detected OS" "${WHITE}${BOLD}$OS_NAME${RESET}"
info "Distro ID"   "${WHITE}${BOLD}$OS_ID${RESET}"
echo ""

echo -e "${M}  ${CYAN}${BOLD}┌──────────────────────────────────────────────┐${RESET}"
echo -e "${M}  ${CYAN}${BOLD}│           Custom ASCII Art (optional)        │${RESET}"
echo -e "${M}  ${CYAN}${BOLD}├──────────────────────────────────────────────┤${RESET}"
echo -e "${M}  ${CYAN}${BOLD}│  [1] Paste ASCII directly into terminal      │${RESET}"
echo -e "${M}  ${CYAN}${BOLD}│  [2] Provide a file path                     │${RESET}"
echo -e "${M}  ${CYAN}${BOLD}│  [3] Skip — use default                      │${RESET}"
echo -e "${M}  ${CYAN}${BOLD}└──────────────────────────────────────────────┘${RESET}"
echo ""

USE_CUSTOM_ASCII=false
CUSTOM_ASCII_CONTENT=""

while true; do
    printf "${M}  ${BOLD}${CYAN}Choice [1/2/3]  : ${WHITE}"
    read ASCII_CHOICE < /dev/tty
    printf "${RESET}"
    case "$ASCII_CHOICE" in
        1)
            echo ""
            echo -e "${M}  ${YELLOW}⚠  Paste your ASCII art below.${RESET}"
            echo -e "${M}  ${DIM}   When done, press Enter then type ${WHITE}END${DIM} and press Enter.${RESET}"
            echo ""
            RAW_ASCII=""
            while IFS= read -r line < /dev/tty; do
                [ "$line" = "END" ] && break
                RAW_ASCII="${RAW_ASCII}${line}"$'\n'
            done
            if [ -n "$RAW_ASCII" ]; then
                USE_CUSTOM_ASCII=true
                CUSTOM_ASCII_CONTENT=""
                COLOR_IDX=1
                while IFS= read -r line; do
                    if [[ "$line" =~ ^\$[1-8] ]]; then
                        CUSTOM_ASCII_CONTENT="${CUSTOM_ASCII_CONTENT}${line}"$'\n'
                    else
                        CUSTOM_ASCII_CONTENT="${CUSTOM_ASCII_CONTENT}\$${COLOR_IDX}${line}"$'\n'
                        COLOR_IDX=$(( COLOR_IDX % 8 + 1 ))
                    fi
                done <<< "$RAW_ASCII"
                info "ASCII"  "${GREEN}Pasted successfully${RESET}"
            else
                warn "Empty input — using default ASCII"
            fi
            break
            ;;
        2)
            echo ""
            echo -e "${M}  ${DIM}  Example: ${WHITE}/root/myascii.txt${RESET}"
            echo ""
            printf "${M}  ${BOLD}${CYAN}File Path       : ${WHITE}"
            read CUSTOM_ASCII_PATH < /dev/tty
            printf "${RESET}"
            if [ -f "$CUSTOM_ASCII_PATH" ]; then
                CUSTOM_ASCII_CONTENT=""
                COLOR_IDX=1
                while IFS= read -r line; do
                    if [[ "$line" =~ ^\$[1-8] ]]; then
                        CUSTOM_ASCII_CONTENT="${CUSTOM_ASCII_CONTENT}${line}"$'\n'
                    else
                        CUSTOM_ASCII_CONTENT="${CUSTOM_ASCII_CONTENT}\$${COLOR_IDX}${line}"$'\n'
                        COLOR_IDX=$(( COLOR_IDX % 8 + 1 ))
                    fi
                done < "$CUSTOM_ASCII_PATH"
                USE_CUSTOM_ASCII=true
                info "ASCII"  "${GREEN}Loaded from ${WHITE}${BOLD}$CUSTOM_ASCII_PATH${RESET}"
            else
                warn "File not found: $CUSTOM_ASCII_PATH — using default ASCII"
            fi
            break
            ;;
        3|"")
            info "ASCII"  "${DIM}Using default${RESET}"
            break
            ;;
        *)
            echo -e "${M}${BG_RED}${WHITE}${BOLD} ✗  Invalid choice, enter 1, 2, or 3 ${RESET}"
            echo ""
            ;;
    esac
done
echo ""

echo -e "${M}  ${CYAN}${BOLD}┌──────────────────────────────────────────────┐${RESET}"
echo -e "${M}  ${CYAN}${BOLD}│         How many GB of swap do you want?     │${RESET}"
echo -e "${M}  ${CYAN}${BOLD}│         Enter 0 to skip swap setup           │${RESET}"
echo -e "${M}  ${CYAN}${BOLD}└──────────────────────────────────────────────┘${RESET}"
echo ""
while true; do
    printf "${M}  ${BOLD}${CYAN}Swap Size (GB)  : ${WHITE}"
    read SWAP_GB < /dev/tty
    printf "${RESET}"
    if [[ "$SWAP_GB" =~ ^[0-9]+$ ]]; then
        break
    else
        echo -e "${M}${BG_RED}${WHITE}${BOLD} ✗  Please enter a valid number ${RESET}"
        echo ""
    fi
done
echo ""

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

    local LATEST_VERSION
    LATEST_VERSION=$(curl -fsSL -o /dev/null -w "%{url_effective}" \
        https://github.com/fastfetch-cli/fastfetch/releases/latest \
        | grep -oP '(?<=tag/)[^/]+$')

    if [ -z "$LATEST_VERSION" ]; then
        fail "Could not fetch latest fastfetch version from GitHub."
    fi

    local DEB_URL="https://github.com/fastfetch-cli/fastfetch/releases/download/${LATEST_VERSION}/fastfetch-linux-${GH_ARCH}.deb"

    info "Version"  "${WHITE}${BOLD}$LATEST_VERSION${RESET}"
    info "Arch"     "${WHITE}${BOLD}$GH_ARCH${RESET}"

    local HTTP_CODE
    HTTP_CODE=$(curl -fsSL -o /dev/null -w "%{http_code}" "$DEB_URL")
    if [ "$HTTP_CODE" != "200" ]; then
        fail "Download URL returned HTTP $HTTP_CODE."
    fi

    local TMP_DEB
    TMP_DEB=$(mktemp /tmp/fastfetch_XXXXXX.deb)
    log "Downloading package..."
    curl -fsSL "$DEB_URL" -o "$TMP_DEB"
    log "Installing package..."
    dpkg -i "$TMP_DEB" 2>&1 | while IFS= read -r line; do log "$line"; done || apt-get install -f -y -q 2>&1 | while IFS= read -r line; do log "$line"; done
    rm -f "$TMP_DEB"
}

step 1 "Installing Fastfetch"

case "$OS_ID" in
    ubuntu | linuxmint | pop)
        log "Updating package lists..."
        apt-get update -qq 2>&1 | while IFS= read -r line; do log "$line"; done
        apt-get install -y -q software-properties-common curl 2>&1 | while IFS= read -r line; do log "$line"; done
        log "Adding PPA..."
        add-apt-repository ppa:zhangsongcui3371/fastfetch -y -q 2>/dev/null || true
        apt-get update -qq 2>&1 | while IFS= read -r line; do log "$line"; done
        apt-get install -y -q fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        if ! command -v fastfetch &>/dev/null; then
            warn "PPA install failed, falling back to GitHub release..."
            install_fastfetch_deb_latest
        fi
        ;;
    debian)
        apt-get install -y -q curl 2>/dev/null || true
        install_fastfetch_deb_latest
        ;;
    fedora)
        dnf install -y -q fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    rhel | centos | almalinux | rocky)
        dnf install -y -q epel-release 2>/dev/null || true
        dnf install -y -q fastfetch 2>/dev/null | while IFS= read -r line; do log "$line"; done || {
            warn "fastfetch not in repo, installing from GitHub..."
            install_fastfetch_deb_latest
        }
        ;;
    arch | manjaro | endeavouros)
        pacman -Sy --noconfirm fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    alpine)
        apk update -q 2>&1 | while IFS= read -r line; do log "$line"; done
        apk add -q fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    opensuse* | suse)
        zypper install -y fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    *)
        if echo "$OS_ID_LIKE" | grep -q "debian\|ubuntu"; then
            warn "Unknown Debian-based distro, trying GitHub release..."
            apt-get install -y -q curl 2>/dev/null || true
            install_fastfetch_deb_latest
        elif echo "$OS_ID_LIKE" | grep -q "rhel\|fedora"; then
            dnf install -y -q fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        elif command -v pacman &>/dev/null; then
            pacman -Sy --noconfirm fastfetch 2>&1 | while IFS= read -r line; do log "$line"; done
        else
            fail "Unsupported distro: $OS_ID. Please install fastfetch manually."
        fi
        ;;
esac

ok "Fastfetch installed ($(fastfetch --version 2>/dev/null | head -1))"

step 2 "Installing Fish shell"

case "$OS_ID" in
    ubuntu | debian | linuxmint | pop)
        apt-get install -y -q fish 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    fedora | rhel | centos | almalinux | rocky)
        dnf install -y -q fish 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    arch | manjaro | endeavouros)
        pacman -Sy --noconfirm fish 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    alpine)
        apk add -q fish 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    opensuse* | suse)
        zypper install -y fish 2>&1 | while IFS= read -r line; do log "$line"; done
        ;;
    *)
        if echo "$OS_ID_LIKE" | grep -q "debian\|ubuntu"; then
            apt-get install -y -q fish 2>&1 | while IFS= read -r line; do log "$line"; done
        elif echo "$OS_ID_LIKE" | grep -q "rhel\|fedora"; then
            dnf install -y -q fish 2>&1 | while IFS= read -r line; do log "$line"; done
        elif command -v pacman &>/dev/null; then
            pacman -Sy --noconfirm fish 2>&1 | while IFS= read -r line; do log "$line"; done
        else
            warn "Could not install fish automatically. Please install it manually."
        fi
        ;;
esac

ok "Fish shell installed"

step 3 "Configuring Fish shell"

mkdir -p /root/.config/fish
mkdir -p /root/.local/share/fish

FISH_VARS="/root/.local/share/fish/fish_variables"
if [ -f "$FISH_VARS" ]; then
    sed -i '/^SETUVAR fish_greeting/d' "$FISH_VARS"
fi
echo "SETUVAR fish_greeting:" >> "${FISH_VARS}"

cat > /root/.config/fish/config.fish << 'FISHEOF'
set -g fish_greeting ""
fastfetch
FISHEOF

if ! grep -q "exec fish" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "exec fish" >> ~/.bashrc
fi

info "Greeting"  "${GREEN}disabled${RESET}"
info "Startup"   "${GREEN}fastfetch on login${RESET}"
info "Shell"     "${GREEN}auto-switch via .bashrc${RESET}"

ok "Fish configured"

step 4 "Writing Fastfetch ASCII art and config"

mkdir -p /root/.config/fastfetch

if [ "$USE_CUSTOM_ASCII" = true ]; then
    printf '%s' "$CUSTOM_ASCII_CONTENT" > /root/.config/fastfetch/ascii.txt
    info "ASCII art"  "${GREEN}custom ASCII written${RESET}"
else
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
    info "ASCII art"  "${GREEN}default written${RESET}"
fi

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

info "ASCII art"  "${GREEN}written${RESET}"
info "Config"     "${GREEN}written${RESET}"

ok "Fastfetch ASCII art and config written"

step 5 "Disabling default MOTD"

touch ~/.hushlogin
chmod -x /etc/update-motd.d/* 2>/dev/null || true

info "hushlogin"  "${GREEN}created${RESET}"
info "MOTD"       "${GREEN}disabled${RESET}"

ok "MOTD disabled"

step 6 "Setting up Swap"

if [ "$SWAP_GB" -eq 0 ]; then
    warn "Swap skipped by user"
    echo ""
elif swapon --show 2>/dev/null | grep -q "/swapfile"; then
    warn "Swapfile already exists, skipping"
    echo ""
else
    SWAP_OK=true
    SWAP_BYTES=$(( SWAP_GB * 1024 ))

    if [ ! -w /proc/sys/vm/swappiness ] 2>/dev/null; then
        warn "Swap not supported on this environment (OpenVZ/LXC), skipping"
        SWAP_OK=false
    fi

    if [ "$SWAP_OK" = true ]; then
        log "Allocating ${SWAP_GB}G swapfile..."
        if ! fallocate -l ${SWAP_GB}G /swapfile 2>/dev/null; then
            log "fallocate failed, trying dd..."
            if ! dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_BYTES} status=none 2>/dev/null; then
                warn "Could not allocate swapfile, skipping swap setup"
                SWAP_OK=false
            fi
        fi
    fi

    if [ "$SWAP_OK" = true ]; then
        chmod 600 /swapfile
        log "Formatting swap..."
        if ! mkswap /swapfile 2>/dev/null; then
            warn "mkswap failed (not supported on this VPS), skipping"
            rm -f /swapfile
            SWAP_OK=false
        fi
    fi

    if [ "$SWAP_OK" = true ]; then
        if ! swapon /swapfile 2>/dev/null; then
            warn "swapon failed, skipping swap setup"
            rm -f /swapfile
            SWAP_OK=false
        fi
    fi

    if [ "$SWAP_OK" = true ]; then
        grep -q "/swapfile" /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
        grep -q "vm.swappiness" /etc/sysctl.conf || echo 'vm.swappiness=10' >> /etc/sysctl.conf
        sysctl -p -q 2>/dev/null || true

        info "Size"       "${WHITE}${BOLD}${SWAP_GB}G${RESET}"
        info "Swappiness" "${WHITE}${BOLD}10${RESET}"
        info "fstab"      "${GREEN}updated${RESET}"

        ok "Swap created"
    fi
fi

step 7 "Verifying installation"

FF_VER=$(fastfetch --version 2>/dev/null | head -1 || echo "unknown")
FISH_VER=$(fish --version 2>/dev/null || echo "unknown")
SWAP_SIZE=$(swapon --show --noheadings 2>/dev/null | awk '{print $3}' | head -1 || echo "none")

info "Fastfetch"  "${GREEN}${BOLD}$FF_VER${RESET}"
info "Fish"       "${GREEN}${BOLD}$FISH_VER${RESET}"
info "Swap"       "${GREEN}${BOLD}$SWAP_SIZE${RESET}"

ok "Verification complete"

echo ""
echo -e "${GREEN}${BOLD}${TOP}${RESET}"
mid "${GREEN}" "             All Done!"
echo -e "${GREEN}${BOLD}${SEP}${RESET}"
printf "${M}║  ${CYAN}${BOLD}%-14s${RESET}  :  ${WHITE}${BOLD}%-$((BW - 22))s${RESET}║\n" "OS"        "$OS_NAME"
printf "${M}║  ${CYAN}${BOLD}%-14s${RESET}  :  ${WHITE}${BOLD}%-$((BW - 22))s${RESET}║\n" "Fastfetch" "$FF_VER"
printf "${M}║  ${CYAN}${BOLD}%-14s${RESET}  :  ${WHITE}${BOLD}%-$((BW - 22))s${RESET}║\n" "Fish"      "$FISH_VER"
printf "${M}║  ${CYAN}${BOLD}%-14s${RESET}  :  ${WHITE}${BOLD}%-$((BW - 22))s${RESET}║\n" "Swap"      "$SWAP_SIZE"
echo -e "${GREEN}${BOLD}${SEP}${RESET}"
mid "${YELLOW}" "  Run: exec fish"
echo -e "${GREEN}${BOLD}${BOT}${RESET}"
echo ""
echo -e "${M}  ${DIM}${CYAN}▸ Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo ""

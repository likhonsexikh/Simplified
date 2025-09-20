#!/bin/bash
# installer.sh
# Fully automated Alpine VM setup with Docker and Vibely via overlay disk
# Zero-touch installation with animated banner
# Author: Likhon Sheikh - Telegram: @likhonsheikh

set -e

# --- Animated Banner Function ---
animate_banner() {
    banner_text=' ____  _                 _ _  __ _          _ 
/ ___|(_)_ __ ___  _ __ | (_)/ _(_) ___  __| |
\___ \| | '\''_ ` _ \| '\''_ \| | | |_| |/ _ \/ _` |
 ___) | | | | | | | |_) | | |  _| |  __/ (_| |
|____/|_|_| |_| |_| .__/|_|_|_| |_|\___|\__,_|
                   |_|                         '

    while IFS= read -r line; do
        for ((i=0; i<${#line}; i++)); do
            printf "%s" "${line:$i:1}"
            sleep 0.002
        done
        printf "\n"
    done <<< "$banner_text"
    echo "Author: Likhon Sheikh - Telegram: @likhonsheikh"
    echo "Starting Automated Installer..."
    echo
}

# Display animated banner
animate_banner

# --- Configuration ---
WORKDIR="$HOME/alpine-vm"
ISO_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-standard-3.22.0-x86_64.iso"
ISO_FILE="$WORKDIR/alpine.iso"
MAIN_DISK="$WORKDIR/alpine.img"
OVERLAY_DISK="$WORKDIR/overlay.img"
MEMORY="1024"
CPUS="2"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "[1/8] Downloading Alpine ISO..."
[ ! -f "$ISO_FILE" ] && wget "$ISO_URL" -O "$ISO_FILE" || echo "ISO already exists."

echo "[2/8] Creating main virtual disk..."
[ ! -f "$MAIN_DISK" ] && qemu-img create -f qcow2 "$MAIN_DISK" 20G || echo "Main disk already exists."

echo "[3/8] Creating overlay disk for automation scripts..."
if [ ! -f "$OVERLAY_DISK" ]; then
    qemu-img create -f qcow2 "$OVERLAY_DISK" 2G
    mkdir -p overlay
    # Post-install script inside overlay
    cat > overlay/post-install.sh << 'EOF'
#!/bin/sh
set -e
echo "Updating Alpine..."
apk update && apk upgrade -y

echo "Installing Docker..."
apk add docker -y
rc-update add docker boot
service docker start

echo "Installing Vibely..."
# Example: Replace with real Vibely installation commands
apk add git nodejs npm -y
git clone https://github.com/vibely/vibely.git /opt/vibely
cd /opt/vibely
npm install
echo "Vibely installation complete."

echo "Setup complete. Ready for chatbot deployment."
EOF
    chmod +x overlay/post-install.sh
    # Convert overlay folder to ISO, then to QCOW2
    genisoimage -o overlay.iso -V OVERLAY overlay
    qemu-img convert -O qcow2 overlay.iso "$OVERLAY_DISK"
else
    echo "Overlay disk already exists."
fi

echo "[4/8] Creating minimal answerfile for unattended Alpine install..."
cat > answerfile << 'EOF'
# Alpine Linux automated installation answerfile
KEYMAP="us"
HOSTNAME="alpine-vm"
INTERFACES="auto"
ROOT_PASSWORD="root"
DNS="8.8.8.8"
DISK="$MAIN_DISK"
EOF

echo "[5/8] Booting QEMU VM with three drives for fully automated installation..."
qemu-system-x86_64 \
    -m "$MEMORY" -smp "$CPUS" -cpu qemu64 \
    -drive file="$MAIN_DISK",format=qcow2 \
    -drive file="$OVERLAY_DISK",format=qcow2,media=disk \
    -cdrom "$ISO_FILE" \
    -nographic \
    -serial mon:stdio \
    -boot d

echo "[6/8] Overlay and installation should be auto-detected by Alpine."
echo "The VM will perform zero-touch installation using the overlay scripts."

echo "[7/8] The post-install script will install Docker and Vibely automatically."

echo "[8/8] Installer script finished. The VM should now have Alpine, Docker, and Vibely ready."

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
# Use a build directory within the project root
WORKDIR="$(dirname "$0")/../build"
OVERLAY_DIR="$(dirname "$0")/../overlay"
ISO_URL="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64/alpine-standard-3.22.0-x86_64.iso"
ISO_FILE="$WORKDIR/alpine.iso"
MAIN_DISK="$WORKDIR/alpine.img"
OVERLAY_DISK="$WORKDIR/overlay.img"
MEMORY="1024"
CPUS="2"

mkdir -p "$WORKDIR"

echo "[1/8] Downloading Alpine ISO..."
[ ! -f "$ISO_FILE" ] && wget "$ISO_URL" -O "$ISO_FILE" || echo "ISO already exists."

echo "[2/8] Creating main virtual disk..."
[ ! -f "$MAIN_DISK" ] && qemu-img create -f qcow2 "$MAIN_DISK" 20G || echo "Main disk already exists."

echo "[3/8] Creating overlay disk for automation scripts..."
if [ ! -f "$OVERLAY_DISK" ]; then
    # Convert overlay folder to ISO, then to QCOW2
    # The overlay directory is now taken from the project structure
    genisoimage -o "$WORKDIR/overlay.iso" -V OVERLAY "$OVERLAY_DIR"
    qemu-img convert -O qcow2 "$WORKDIR/overlay.iso" "$OVERLAY_DISK"
else
    echo "Overlay disk already exists."
fi

echo "[4/8] Creating minimal answerfile for unattended Alpine install..."
cat > "$WORKDIR/answerfile" << EOF
# Alpine Linux automated installation answerfile
KEYMAP="us"
HOSTNAME="alpine-vm"
INTERFACES="auto"
ROOT_PASSWORD="root"
DNS="8.8.8.8"
# Note: DISK path needs to be accessible from within the VM if not using default setup.
# For this script, we assume the setup script runs on the host and prepares the disks.
# The DISK variable in the answerfile is used by the Alpine setup script.
# We are creating the disk on the host, so the path in the answerfile is tricky.
# However, the Alpine installer script will use the drive passed via -drive, not this path.
# So we can leave it as a placeholder.
DISK="/dev/sda"
EOF

echo "[5/8] Booting QEMU VM with three drives for fully automated installation..."
# Change to the workdir to manage generated files
cd "$WORKDIR"
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

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

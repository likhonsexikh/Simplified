Simplified general-purpose AI Agent system that supports running various tools and operations in a sandbox environment.

# Alpine VM Automated Installer with Docker & Vibely

Rub Alpine.sh for setup full? 

## Description

This project provides a **fully automated installation** of Alpine Linux in a QEMU VM with Docker and Vibely pre-installed.  
It uses a **three-drive setup** to achieve **zero-touch installation**:

1. **Alpine ISO** – boot installer  
2. **Main virtual disk** – installation target  
3. **Overlay disk** – contains post-install automation scripts  

The overlay contains scripts that automatically install **Docker**, **Vibely**, and prepare the VM for future **chatbot agent deployment**.

---

## Features

- Fully unattended Alpine Linux installation  
- Automatic Docker installation and service setup  
- Vibely installed and ready to use  
- Animated startup banner  
- Author information included: **Likhon Sheikh – Telegram: @likhonsheikh**  
- Works on Linux host environments (including Termux with QEMU)

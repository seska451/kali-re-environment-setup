#!/bin/bash

read -p "Please make sure you read and understand this script before you run it. Proceed? (y/n): " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    # Update the System
    echo "Updating system..."
    sudo apt update && sudo apt upgrade -y

    # Enable the Firewall (UFW)
    echo "Installing and enabling UFW..."
    sudo apt install ufw -y
    sudo ufw enable

    # Disable Unnecessary Services
    echo "Disabling unnecessary services..."
    services=(cups avahi-daemon bluetooth ssh)
    for service in "${services[@]}"; do
        echo "Disabling $service"
        sudo systemctl disable $service
    done

    # Install and Configure AppArmor
    echo "Installing and configuring AppArmor..."
    sudo apt install apparmor apparmor-profiles -y
    sudo systemctl enable apparmor
    sudo systemctl start apparmor

    echo "WARNING: This script appends text to your network config files. If you run it more than once, it will edit it more than once this may corrupt your network settings."
    read -p "Do you want to skip? (y/n): " netchanges

    if [[ $netchanges =~ ^[Yy]$ ]]; then
        echo "Skipping network changes..."
        # Place the commands you want to execute on "y" here
    else
        # Harden Network Settings
        echo "Hardening network settings..."
        sudo tee -a /etc/sysctl.conf <<EOF

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

# Prevent IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Enable SYN cookies
net.ipv4.tcp_syncookies = 1
EOF
        sudo sysctl -p
    fi

    # Enable Automatic Updates
    echo "Installing and configuring unattended-upgrades..."
    sudo apt install unattended-upgrades -y
    sudo dpkg-reconfigure --priority=low unattended-upgrades

    # Install Anti-Virus Software
    echo "Installing ClamAV..."
    sudo apt install clamav clamav-daemon -y
    sudo freshclam
    sudo systemctl enable clamav-daemon
    sudo systemctl start clamav-daemon

    # Install tools
    echo "Installing openvpn ghidra gdb checksec strace ltrace binutils ..."
    sudo apt install openvpn ghidra gdb checksec strace ltrace binutils -y

    read -p "Do you want to install binary ninja (free)? (y/n): " binja
    if [[ $binja =~ ^[Yy]$ ]]; then
        echo "Installing Binja..."
        url="https://cdn.binary.ninja/installers/binaryninja_free_linux.zip"
        output=/tmp/binja.zip
        app_name="Binary Ninja"
        exec_path="$HOME/.local/bin/vector35/binaryninja/binaryninja"
        curl -o "$output" "$url"
        sudo unzip "$output" -d ~/.local/bin/vector35

        # Location to place the .desktop file (Desktop)
        desktop_path="$HOME/Desktop/binja.desktop"

        # Create the .desktop file
        cat <<EOL > "$desktop_path"
[Desktop Entry]
Version=1.0
Name=$app_name
Exec=$exec_path
Terminal=false
Type=Application
Categories=Utility;
EOL
        chmod +x $desktop_path
    else
        echo "Skipping Binja install"
    fi

    read -p "Do you want to change your password for $(whoami)? (y/n): " passwordchange
    if [[ $passwordchange =~ ^[Yy]$ ]]; then
        # Prompt to change password
        passwd $(whoami)
    else
        echo "Skipping password change"
    fi
    
    echo "Cleaning up unused packages"
    sudo apt autoremove -y
    echo "Don't forget to shut down and take another snapshot :D"
else
    echo "OK. Quitting."
fi

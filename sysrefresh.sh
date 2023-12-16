#!/bin/bash

# Update system repositories and Upgrade installed packages
echo "Upgrading installed packages..."
sudo pacman -Syy --noconfirm

# Remove all old versions of packages
sudo paccache -rc

# Remove all versions of uninstalled packages
echo "Cleaning package cache..."
sudo paccache -ruk0

# Remove orphaned packages (not required by any installed package)
echo "Removing orphaned packages..."
sudo pacman -Rns $(pacman -Qtdq)

# Clear journalctl logs (keep last 7 days)
echo "Cleaning journalctl logs..."
sudo journalctl --vacuum-size=7M

# Clear temporary files
echo "Cleaning temporary files..."
sudo rm -rf /tmp/*

# Empty the trash
rm -r ~/.local/share/Trash/files/*
rm -r ~/.local/share/Trash/info/*

echo "Manjaro system updated, upgraded, and storage cleared!"

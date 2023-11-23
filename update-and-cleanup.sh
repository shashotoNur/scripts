#!/bin/bash

# Update package database
sudo pacman -Syy

# Upgrade all installed packages
sudo pacman -Syu

# Remove unused packages
sudo pacman -Rns $(pacman -Qdtq)

# Clean package cache
sudo paccache -rc

# Clean journalctl logs
sudo journalctl --vacuum-size=50M

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

echo "Manjaro system update and cleanup completed."

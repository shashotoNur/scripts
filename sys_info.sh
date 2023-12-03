#!/bin/bash
echo "System Information"
echo "------------------"
echo "Hostname: $(hostname)"
echo "Kernel Version: $(uname -r)"
echo "CPU: $(lscpu | grep 'Model name' | awk -F': ' '{print $2}')"
echo "Graphics Cards Information:"
lspci | grep -iE "vga|3d|display"
echo "Memory: $(free -h | awk '/Mem/{print $2}')"
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo "Network Information:"
ifconfig | grep -A 1 'inet '

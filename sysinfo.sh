#!/bin/bash

# Create a string of system information
sys_info="System Information\n------------------\n"
sys_info+="Hostname: $(hostname)\n"
sys_info+="Kernel Version: $(uname -r)\n"

# CPU and GPU
sys_info+="CPU: $(lscpu | awk '/Model name/ { sub("Model name:", ""); print $0 }' | xargs)\n"
sys_info+="Graphics Cards Information:\n"
while IFS= read -r line; do
    sys_info+="  - $line\n"
done < <(lspci | grep -iE 'vga|3d|display')

# Disk Information
sys_info+="Storage:\n"
while IFS= read -r line; do
    sys_info+="  - $line\n"
done < <(df -h | grep '/dev/sda')

sys_info+="Memory: $(free -h | awk '/Mem/{print $2}')\n"

# Network information
sys_info+="IP Address: $(curl -s ifconfig.me)\n"
sys_info+="Network Information:\n$(ifconfig | grep -A 1 'inet ')\n"

# Echo the system information
echo -e "$sys_info"

# Ask the user if they want to save this information to a file
read -p "Do you want to save this information to a file? (y/n): " save_option

if [ "$save_option" == "y" ]; then
    # Input path for the file
    read -p "Enter the path for the file: " file_path

    # Create a filename with the date, time, and hostname
    filename="system_info_$(hostname)_$(date '+%Y%m%d_%H%M%S').txt"

    # Save the system information to the specified file
    echo -e "$sys_info" > "$file_path/$filename"
    echo "System information saved to: $file_path/$filename"
else
    echo "System information not saved."
fi

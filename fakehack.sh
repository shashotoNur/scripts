#!/bin/bash
echo -en "\e[32m"
for((i=0;i<101;i++))
do
	echo -en "$(clear)Accessing root privileges: $i%\n[$(for((j=i;j;j--));do echo -n █;done;for((j=100-i;j;j--));do echo -n ' ';done;echo ];sleep 0.05)\n"
done
echo "Complete system access granted!"

sleep 1

for((i=0;i<101;i++))
do
	echo -en "$(clear)Accessing root privileges: 100%\n[████████████████████████████████████████████████████████████████████████████████████████████████████]\nComplete system access granted!!\n\nTransferring control to remote admin: $i%\n[$(for((j=i;j;j--));do echo -n █;done;for((j=100-i;j;j--));do echo -n ' ';done;echo ];sleep 0.05)"
done
echo -e "\nStable connection established...\n"

sleep 0.5

echo Remote is accessing user data...

sleep 1

echo -e "Access fully granted!\n"

sleep 1

echo -e "Device $(hostname)'s boot firmware corruption complete."

env -u SESSION_MANAGER xterm -T "Transferring Data" -n "Transferring Data" -e "echo -en \"\e[0;32m\";while true;do shuf -zi 0-1 -n 1;done"

echo -e "Desired target reached!!!\n"

sleep 1

echo -e "Warning: System status CRITICAL!\nChances of recovery < 1.2%"

#!/bin/bash

generate_crypto_key() {
    local passkey="$1"
    local salt="$2"

    openssl enc -aes-256-cbc -k "$passkey" -P -md sha512 -pbkdf2 -S "$salt" </dev/zero 2>/dev/null | head -c 32
}

encrypt() {
    message="Keep this line unchanged, enter your text below, save the file (ctrl+s) & exit this editor (ctrl+x)."
    echo $message > /tmp/user_input.tmp

    nano /tmp/user_input.tmp
    text=$(tail -n +2 /tmp/user_input.tmp)
    rm /tmp/user_input.tmp

    read -s -p "Enter passkey: " passkey
    echo -e ""
    read -p "Enter filename with path: " path_to_file

    dir_path="${path_to_file%/*}"
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path"
    fi

    salt=$(openssl rand -base64 16)
    crypto_key=$(generate_crypto_key "$passkey" "$salt")

    encrypted_text=$(echo "$text" | openssl enc -aes-256-cbc -a -k "$crypto_key" -md sha512 -pbkdf2 -iter 100000 -base64)

    echo "$salt~~$encrypted_text" > "$path_to_file"
    echo "$passkey" | xclip -selection clipboard
    echo "Encrypted text saved to $path_to_file & passkey is copied to clipboard!"
}

decrypt() {
	read -p "Enter filename with path: " path_to_file
	if [[ ! -f "$path_to_file" ]]; then
		echo "Error: File not found!"
		return 1
	fi

	file_content=$(cat "$path_to_file")
	salt=${file_content%%~~*}
	encrypted_text=${file_content#*~~}

	read -s -p "Enter passkey: " passkey
	crypto_key=$(generate_crypto_key "$passkey" "$salt")

	decrypted_text=$(echo "$encrypted_text" | openssl enc -aes-256-cbc -d -a -k "$crypto_key" -md sha512 -pbkdf2 -iter 100000 -base64)

    echo "$decrypted_text" | xclip -selection clipboard
    echo -e "\nDecrypted text copied to clipboard!"
}

if [[ "$1" == "-e" ]]; then
    encrypt
elif [[ "$1" == "-d" ]]; then
    decrypt
else
    echo -e ">> USAGE: $0 <'-e' or '-d'>"

    while true; do
        echo "What's your hush operation? ('e' to encrypt or 'd' to decrypt)"
        read -p "=> " operation
        case "$operation" in
            e)
                encrypt
                break
                ;;
            d)
                decrypt
                break
                ;;
            exit)
                echo "Program terminated."
                exit
                ;;
            *)
                echo "Invalid operation!"
                ;;
        esac
    done
fi

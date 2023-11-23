#!/bin/bash
#title          :randcopy.sh
#description    :Randomly copies files from a directory to a location until space is full or a limit has been reached
#author         :Thomas O. Robinson
#date           :8 November 2021
#version        :0.00
#usage          :bash randcopy.sh
#notes          :Tested to work on bash 3, 4.
#bash_version   :3.2.57(1)-release

# At bare minimum, we need to have a target to copy files to. If nothing specified, die.
[ $# -eq 0 ] && echo "No target specified" && exit 1

TARGET=$1 # This will be the target location for the copy

# If there is a second commandline option set OR if there is an existing variable called TARGETSPACE, that will become the number of bytes to copy.
# Elseways, calculate the available space on the target location and copy until it is full.
[ $# -eq 2 ] && TARGETSPACE=$2 || TARGETSPACE=$(df -k "$TARGET" | awk '/[0-9]%/{print $(NF-5)}')
FILELIST=(./*) # Pretty dirty. Need to support something like FILELIST=${FILELIST:-(./*)}

# Populate an array of the file sizes
for ((i=0; i<=${#FILELIST[@]}; i++)); do
    if [ -f "${FILELIST[$i]}" ]; then
        if [ "${FILELIST[$i]##*/}" = "$0" ]; then # Remove ourself from the array of files
            unset FILELIST[$i]
            FILESIZE[$i]=0
        else
            FILESIZE[$i]=$(du -k "${FILELIST[$i]}" | cut -f 1)
        fi
    else # This will match anything that is not an actual file, like subdirectories and remove them from the array as well
        unset FILELIST[$i]
        FILESIZE[$i]=0
    fi
done

while [ $TARGETSPACE -gt 0 ] && [ ${#FILELIST[@]} -gt 0 ]; do
    INDICES=(${!FILELIST[@]}) # Elegant little trick to allow us to "pop" files out of the array with an unset
    INDEX=${INDICES[$(($RANDOM % ${#INDICES[@]}))]} # Pick a random index from the list of available indexed files
    if [ $TARGETSPACE -lt ${FILESIZE[$INDEX]} ]; then # If the file is bigger than our available space, pop it out
        unset FILELIST[$INDEX]
    else # Finally, if we've passed all tests up to this point, copy the file and then go ahead and pop it out of the array.
        cp -v "${FILELIST[$INDEX]}" "$TARGET"; unset FILELIST[$INDEX]
        TARGETSPACE=$(($TARGETSPACE - ${FILESIZE[$INDEX]})) # Subtract the size of the file from the available space
    fi
done

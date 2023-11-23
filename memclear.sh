#!/bin/bash

echo "Clearing free memory..."
sync
echo 3 > /proc/sys/vm/drop_caches

echo "Clearing swap memory..."
swapoff -a && swapon -a

echo "Memory cleared."

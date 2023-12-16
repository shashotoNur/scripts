#!/bin/bash

# Sync filesystem buffers to free up memory used by recently accessed files
sync

# Clear page cache, which stores recently accessed data
echo 1 > /proc/sys/vm/drop_caches

# Free inactive memory (memory not used recently)
echo 3 > /proc/sys/vm/drop_caches

# Optionally, swap unused memory to disk for later use (can be slow)
swapoff -a
swapon -a

# Monitor memory usage
free -m

echo "Memory freed. System may experience temporary performance fluctuations while cached data is reloaded."

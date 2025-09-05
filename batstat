#!/bin/bash

# Get battery information
battery_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)

# Parse the output
percentage=$(echo "$battery_info" | grep 'percentage:' | awk '{print $2}' | sed 's/%//')
energy=$(echo "$battery_info" | grep 'energy:' | awk '{print $2}' | awk '{printf "%.2f", $1}')
energy_rate=$(echo "$battery_info" | grep 'energy-rate:' | awk '{print $2}' | awk '{printf "%.2f", $1}')
state=$(echo "$battery_info" | grep 'state:' | awk '{print $2}')

# Get time information based on state
if [[ "$state" == "charging" ]]; then
    time_left=$(echo "$battery_info" | grep 'time to full:' | awk '{print $4, $5}')
else
    time_left=$(echo "$battery_info" | grep 'time to empty:' | awk '{print $4, $5}')
fi

# Define color codes
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Determine colors based on battery percentage and state
if [ "$percentage" -lt 25 ]; then
    color_percentage=$RED
elif [ "$percentage" -lt 50 ]; then
    color_percentage=$BLUE
else
    color_percentage=$GREEN
fi

if [ "$state" == "charging" ]; then
    color_state=$GREEN
else
    color_state=$RED
fi

# Calculate box width
box_width=60

# Print top border
printf "%s\n" "$(printf '─%.0s' $(seq 1 $box_width))"

# Output the battery status in a box
echo -e " ${BOLD}Battery Status${NC}"
printf "%s\n" "$(printf '─%.0s' $(seq 1 $box_width))"
echo -e "    ${BLUE}Percentage    : ${color_percentage}${percentage}%${NC}"
echo -e "    ${BLUE}Energy        : ${BLUE}${energy} Wh${NC}"
echo -e "    ${BLUE}State         : ${color_state}${state^}${NC}"
echo -e "    ${BLUE}Energy Rate   : ${BLUE}${energy_rate} W${NC}"
echo -e "    ${BLUE}Time Left     : ${BLUE}${time_left}${NC}"

# Print bottom border
printf "%s\n" "$(printf '─%.0s' $(seq 1 $box_width))"

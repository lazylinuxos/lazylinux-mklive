#!/bin/sh

adapter=$(bluetoothctl list | awk '{print $2; exit}')

if [ -z "$adapter" ]; then
    echo "󰂲"
    exit
fi

if ! bluetoothctl show "$adapter" | grep -q "Powered: yes"; then
    echo "󰂲"
    exit
fi

devices=$(bluetoothctl devices Connected | cut -d' ' -f3-)

if [ -z "$devices" ]; then
    echo "󰂯"
    exit
fi

count=$(printf '%s\n' "$devices" | wc -l)

# Change device every 30 seconds
index=$(( ($(date +%s) / 30) % count + 1 ))

device_line=$(bluetoothctl devices Connected | sed -n "${index}p")

mac=$(printf '%s\n' "$device_line" | awk '{print $2}')
name=$(printf '%s\n' "$device_line" | cut -d' ' -f3-)

battery=$(
    bluetoothctl info "$mac" |
    sed -n 's/.*Battery Percentage: .* (\([0-9]\+\)).*/\1/p'
)

if [ -n "$battery" ]; then
    echo "󰂱 $name [${battery}%]"
else
    echo "󰂱 $name"
fi

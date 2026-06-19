#!/bin/sh

iface=$(ip route show default | awk '/default/ {print $5; exit}')

if [ -z "$iface" ]; then
    echo "󰖪 no network"
elif [ -d "/sys/class/net/$iface/wireless" ]; then
    ssid=$(iw dev "$iface" link 2>/dev/null | awk -F': ' '/SSID/ {print $2}')

    if [ -n "$ssid" ]; then
        echo "󰖩 $ssid"
    else
        echo "󰖩 $iface"
    fi
else
    echo " $iface"
fi

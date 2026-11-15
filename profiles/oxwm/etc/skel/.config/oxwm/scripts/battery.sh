p=$(cat /sys/class/power_supply/BAT1/capacity)
s=$(cat /sys/class/power_supply/BAT1/status)

if [ "$s" = "Charging" ]; then
    echo "󰂈 ${p}%"
elif [ "$s" = "Full" ]; then
    echo "󰁹 ${p}%"
elif [ "$p" -le 10 ]; then
    echo "󰂎 ${p}%"
elif [ "$p" -le 25 ]; then
    echo "󰁺 ${p}%"
elif [ "$p" -le 50 ]; then
    echo "󰁼 ${p}%"
elif [ "$p" -le 75 ]; then
    echo "󰁾 ${p}%"
else
    echo "󰂀 ${p}%"
fi

#!/usr/bin/env bash
# Kill any existing Dunst processes
killall dunst 2>/dev/null
# Wait a moment to make sure it's fully terminated
sleep 0.5
# Start Dunst with your config
dunst -config ~/.config/awesome/dunst/dunstrc &

# Rest of your autostart commands...
/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
picom --config ~/.config/awesome/picom/picom.conf --animations -b &
feh --bg-fill ~/.config/awesome/wallpaper/wallhaven-ex63rk_3440x1440.png &

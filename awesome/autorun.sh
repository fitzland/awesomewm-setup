#!/usr/bin/env bash

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
dunst -config ~/.config/awesome/dunst/dunstrc &
picom --config ~/.config/awesome/picom/picom.conf --animations -b &
feh --bg-fill ~/.config/awesome/wallpaper/wallhaven-zyj28v_3440x1440.png &

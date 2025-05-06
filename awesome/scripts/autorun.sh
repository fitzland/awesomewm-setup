#!/usr/bin/env bash

~/.screenlayout/monitor-debian.sh

/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
## dunst -config ~/.config/awesome/dunst/dunstrc &
picom --config ~/.config/awesome/picom/picom.conf --animations -b &

# wallpaper
feh --no-xinerama --no-fehbg --bg-scale ~/.config/awesome/wallpaper/otis.png &
#~/.fehbg

# num lock activated
numlockx on &

#set compose key
setxkbmap -option compose:rctrl &

# bluetooth app
blueman-applet &

# dropbox 
~/.dropbox-dist/dropboxd &

#get auth work with polkit agent
#/usr/bin/lxpolkit &

#!/bin/bash
# Wait for AwesomeWM to fully start
sleep 5
# Kill any existing notification daemons
killall -q dunst notification-daemon xfce4-notifyd 2>/dev/null
# Release the D-Bus notification name if held
dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ReleaseName string:org.freedesktop.Notifications >/dev/null 2>&1
# Start Dunst with the config file
dunst -config ~/.config/awesome/dunst/dunstrc

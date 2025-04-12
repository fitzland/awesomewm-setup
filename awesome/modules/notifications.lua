-- modules/notifications.lua
-- Disable AwesomeWM notifications and ensure Dunst is running

local naughty = require("naughty")
local awful = require("awful")
local notifications = {}

function notifications.init()
    -- First, make absolutely sure naughty isn't owning the notifications bus
    awful.spawn.with_shell("dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ReleaseName string:org.freedesktop.Notifications >/dev/null 2>&1 || true")
    
    -- For newer versions of AwesomeWM (4.0+)
    if naughty.connect_signal then
        naughty.connect_signal("request::display", function(n)
            -- Only allow critical notifications through
            if n and n.urgency == "critical" then
                return
            end
            
            -- Ignore all other notifications so they're handled by Dunst
            n.ignore = true
        end)
    end
    
    -- Kill any existing Dunst
    awful.spawn.with_shell("killall dunst 2>/dev/null || true")
    
    -- Start Dunst with a small delay to ensure D-Bus is released
    awful.spawn.with_shell("sleep 1 && dunst -config $HOME/.config/awesome/dunst/dunstrc &")
    
    print("AwesomeWM notifications configured: critical errors shown, regular notifications handled by Dunst")
end

return notifications

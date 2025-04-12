-- modules/notifications.lua
-- Disable AwesomeWM notifications and ensure Dunst is running

local naughty = require("naughty")
local awful = require("awful")
local notifications = {}

function notifications.init()
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
    
    -- Start Dunst
    awful.spawn.with_shell("killall dunst 2>/dev/null || true")
    awful.spawn.with_shell("dunst -config ~/.config/awesome/dunst/dunstrc &")
    
    print("AwesomeWM notifications configured: critical errors shown, regular notifications handled by Dunst")
end

return notifications

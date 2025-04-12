-- modules/notifications.lua
local naughty = require("naughty")
local awful = require("awful")
local notifications = {}

function notifications.init()
    -- Only attempt to modify notification handling
    -- for non-critical notifications
    
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
    
    -- Start Dunst using the external script
    awful.spawn.with_shell("~/.config/awesome/dunst/start_dunst.sh &")
    
    print("AwesomeWM notifications configured: critical errors shown, regular notifications handled by Dunst")
end

return notifications

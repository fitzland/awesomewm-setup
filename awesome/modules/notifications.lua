-- modules/notifications.lua
-- Disable AwesomeWM notifications since we're using Dunst

local naughty = require("naughty")

local notifications = {}

function notifications.init()
    -- Disable AwesomeWM's notification system
    if naughty.destroy then
        -- For newer versions of AwesomeWM
        naughty.destroy_all_notifications()
        
        if naughty.connect_signal then
            naughty.connect_signal("request::display", function(n)
                -- Do nothing, effectively disabling notifications
            end)
        end
    else
        -- For older versions, we can't completely disable it
        -- but we can set a very short timeout
        naughty.config.defaults.timeout = 0.1
    end
    
    print("AwesomeWM notifications disabled (using external notification daemon)")
end

return notifications

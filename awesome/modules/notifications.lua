-- modules/notifications.lua
-- Use Naughty only for AwesomeWM errors, Dunst for everything else

local naughty = require("naughty")

local notifications = {}

function notifications.init()
    -- Configure Naughty for error reporting
    naughty.config.defaults.timeout = 0  -- Errors should stay until dismissed
    naughty.config.defaults.position = "top_right"
    
    -- Only show AwesomeWM's own error notifications
    naughty.connect_signal("request::display", function(n)
        -- Only display notifications that come from awesome itself
        if n.app_name == "awesome" then
            naughty.layout.box { notification = n }
        end
        -- All other notifications will be handled by Dunst
    end)
end

return notifications

-- modules/notifications.lua
-- Disable AwesomeWM notifications for regular use while preserving error handling
local naughty = require("naughty")
local notifications = {}

function notifications.init()
    -- Save the original notify function for error handling
    local original_notify = naughty.notify
    
    -- Override naughty.notify to only handle critical notifications
    naughty.notify = function(args)
        -- Only allow critical notifications to go through naughty
        if args and args.preset == naughty.config.presets.critical then
            return original_notify(args)
        end
        
        -- Silently ignore non-critical notifications (they'll be handled by Dunst)
        return nil
    end
    
    -- For newer versions of AwesomeWM (4.0+)
    if naughty.connect_signal then
        naughty.connect_signal("request::display", function(n)
            -- Only allow critical notifications through naughty
            if n and n.urgency == "critical" then
                return
            end
            
            -- Ignore non-critical notifications
            n.ignore = true
        end)
    end
    
    print("Regular notifications redirected to Dunst while keeping error handling in AwesomeWM")
end

return notifications

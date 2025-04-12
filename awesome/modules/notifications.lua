-- modules/notifications.lua
-- Redirect regular notifications to Dunst while keeping naughty for error handling

local naughty = require("naughty")
local notifications = {}

function notifications.init()
    -- Store the original notification function for error handling
    local original_notify = naughty.notify
    
    -- Override naughty.notify to selectively handle notifications
    naughty.notify = function(args)
        -- Allow error notifications to go through naughty
        if args and args.preset == naughty.config.presets.critical then
            return original_notify(args)
        end
        
        -- Silently ignore other notifications (they'll be handled by Dunst)
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
    
    print("Regular notifications redirected to Dunst while keeping naughty for error handling")
end

return notifications

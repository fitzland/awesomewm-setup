-- modules/notifications.lua
-- Simple solution that just disables non-critical notifications

local naughty = require("naughty")
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
    else
        -- For older versions, override default settings for non-critical notifications
        local original_presets = naughty.config.presets
        naughty.config.presets = {
            critical = original_presets.critical -- Preserve only critical presets
        }
        
        -- Set non-critical notifications to essentially disappear
        naughty.config.defaults.timeout = 0.1
        naughty.config.defaults.height = 1
        naughty.config.defaults.width = 1
        naughty.config.defaults.opacity = 0
    end
    
    print("AwesomeWM notifications configured: critical errors shown, regular notifications handled by Dunst")
end

return notifications

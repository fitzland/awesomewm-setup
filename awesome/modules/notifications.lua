-- modules/notifications.lua
local naughty = require("naughty")
local notifications = {}

function notifications.init()
    -- Just set basic colors and timeouts
    naughty.config.defaults.timeout = 10
    naughty.config.defaults.position = "top_right"
    naughty.config.defaults.bg = "#161616"
    naughty.config.defaults.fg = "#ffffff"
    naughty.config.defaults.border_width = 2
    naughty.config.defaults.border_color = "#DBC704"
    
    -- Configure critical notifications
    naughty.config.presets = {
        critical = {
            bg = "#900000",
            fg = "#ffffff",
            timeout = 0,
            border_color = "#ff0000",
            border_width = 2
        }
    }
    
    print("Basic notifications configuration applied")
end

return notifications

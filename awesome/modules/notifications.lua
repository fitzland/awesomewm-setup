-- modules/notifications.lua
local naughty = require("naughty")
local notifications = {}

function notifications.init()
    -- Just set some basic styling without complex operations
    naughty.config.defaults.timeout = 10
    naughty.config.defaults.position = "top_right"
    naughty.config.defaults.bg = "#161616"
    naughty.config.defaults.fg = "#ffffff"
    naughty.config.defaults.border_width = 2
    naughty.config.defaults.border_color = "#DBC704"
    
    print("Basic notifications configuration applied")
end

return notifications

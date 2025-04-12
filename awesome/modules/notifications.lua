-- Add to your rc.lua or create a new file like modules/notifications.lua

local naughty = require("naughty")
local beautiful = require("beautiful")
local gears = require("gears")

-- Set notification settings
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 10
naughty.config.defaults.border_width = 2
naughty.config.defaults.border_color = "#DBC704"

-- Set notification icons path
naughty.config.icon_dirs = { 
    "/usr/share/icons/Papirus/96x96/devices/",
    "/usr/share/icons/Papirus/48x48/status/",
    "/usr/share/icons/Papirus/96x96/apps/"
}
naughty.config.icon_formats = { "png", "svg" }

-- Configure notification rules for different applications
table.insert(naughty.config.mapping, {
    {
        app_name = {"changevolume"},
        callback = function(n)
            n.timeout = 2
            n.border_width = 2
            n.border_color = "#DBC704"
            
            -- Handle progress bars specifically
            if n.hints and n.hints.value then
                local value = n.hints.value
                local w = naughty.config.defaults.width or 300
                
                -- Create progress bar widget
                n.text = string.format([[
                <span color="#ffffff" size="medium">%s</span>
                <span color="#ffffff" size="small">
                <progress value="%d" max="100" width="%dpx" height="10px"/>
                </span>
                ]], n.text, value, w-20)
            end
            
            return n
        end
    }
})

-- You can call this function from your main rc.lua to initialize
local function init()
    -- You can add more initialization code here if needed
end

return {
    init = init
}

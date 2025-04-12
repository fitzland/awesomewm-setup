-- modules/notifications.lua
-- Configure naughty to look like Dunst configuration
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local notifications = {}

function notifications.init()
    -- Configure notification appearance
    naughty.config.padding = dpi(20)
    naughty.config.spacing = dpi(5)
    
    -- Set icon directories matching Dunst config
    naughty.config.icon_dirs = {
        "/usr/share/icons/Papirus/96x96/devices/",
        "/usr/share/icons/Papirus/48x48/status/",
        "/usr/share/icons/Papirus/96x96/apps/"
    }
    naughty.config.icon_formats = { "png", "svg" }
    
    -- Default settings based on Dunst config
    naughty.config.defaults = {
        timeout = 10,
        position = "top_right",
        margin = dpi(15),
        border_width = dpi(2),
        border_color = "#DBC704",  -- Yellow frame from Dunst config
        
        -- Size settings
        width = dpi(500),
        
        -- Text settings
        font = "JetBrainsMono Nerd Font 11",
        fg = "#ffffff",
        bg = "#161616",
        
        -- Shape for rounded corners
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(15))
        end,
        
        opacity = 0.8  -- Based on Dunst transparency of 20
    }
    
    -- Configure urgency presets
    naughty.config.presets = {
        low = {
            bg = "#161616",
            fg = "#888888",
            timeout = 10
        },
        normal = {
            bg = "#161616",
            fg = "#ffffff",
            timeout = 10
        },
        critical = {
            bg = "#900000",
            fg = "#ffffff",
            border_color = "#ff0000",
            timeout = 0  -- No timeout for critical notifications
        }
    }
    
    print("Naughty configured to look like Dunst")
end

return notifications

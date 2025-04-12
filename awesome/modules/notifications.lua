-- modules/notifications.lua
-- Configure naughty to look exactly like Dunst configuration

local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local awful = require("awful")
local notifications = {}

function notifications.init()
    -- Kill any running dunst instances to avoid conflicts
    awful.spawn.with_shell("killall dunst 2>/dev/null || true")

    -- Configure notification geometry and appearance
    naughty.config.padding = dpi(20)
    naughty.config.spacing = dpi(5)
    
    -- Set icon directories matching your Dunst config
    naughty.config.icon_dirs = {
        "/usr/share/icons/Papirus/96x96/devices/",
        "/usr/share/icons/Papirus/48x48/status/",
        "/usr/share/icons/Papirus/96x96/apps/"
    }
    naughty.config.icon_formats = { "png", "svg" }
    
    -- Default settings based on Dunst config
    naughty.config.defaults = {
        timeout = 10,
        hover_timeout = 30,
        position = "top_right",
        margin = dpi(15),
        border_width = dpi(2),
        border_color = "#DBC704",  -- Yellow frame from Dunst config
        
        -- Size settings
        width = dpi(500),
        height = dpi(300),
        
        -- Text settings
        font = "JetBrainsMono Nerd Font 11",
        fg = "#ffffff",
        bg = "#161616",
        
        -- Shape for rounded corners
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, dpi(15))
        end,
        
        opacity = 0.8,  -- Based on Dunst transparency of 20
        
        icon_size = dpi(32)
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
    
    -- Set up key bindings similar to Dunst
    awful.keyboard.append_global_keybindings({
        awful.key({ "Control" }, "space", function() 
            naughty.destroy(naughty.get_displayed()[1])
        end, {description = "close notification", group = "notifications"}),
        
        awful.key({ "Control", "Shift" }, "space", function() 
            naughty.destroy_all_notifications() 
        end, {description = "close all notifications", group = "notifications"}),
        
        awful.key({ "Control" }, "grave", function() 
            naughty.toggle() 
        end, {description = "toggle notification display", group = "notifications"})
    })
    
    -- Add mouse controls to match Dunst
    naughty.config.notify_callback = function(args)
        args.actions = args.actions or {}
        
        -- Add mouse controls
        args.destroy_on_left_click = true  -- Close on left click
        args.run_on_middle_click = true    -- Run default action on middle click
        args.destroy_on_right_click = false -- Don't close on right click
        
        return args
    end
    
    print("Naughty configured to look like Dunst")
end

return notifications

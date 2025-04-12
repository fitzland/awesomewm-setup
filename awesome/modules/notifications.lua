-- modules/notifications.lua
-- Configure naughty to look exactly like Dunst

local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local notifications = {}

function notifications.init()
    -- Kill any running dunst instances to avoid conflicts
    os.execute("killall dunst 2>/dev/null")

    -- Configure naughty to match Dunst styling
    naughty.config.padding = dpi(20)
    naughty.config.spacing = dpi(5)
    naughty.config.icon_dirs = {
        "/usr/share/icons/Papirus/96x96/devices/",
        "/usr/share/icons/Papirus/48x48/status/",
        "/usr/share/icons/Papirus/96x96/apps/"
    }
    naughty.config.icon_formats = { "png", "svg" }
    
    -- Set defaults based on Dunst config
    naughty.config.defaults = {
        timeout = 10,
        screen = 1,
        position = "top_right",
        margin = dpi(15),
        gap = dpi(1),
        ontop = true,
        font = "JetBrainsMono Nerd Font 11",
        icon_size = dpi(32),
        border_width = dpi(2),
        border_color = "#DBC704",
        width = dpi(500),
        height = dpi(300),
        shape = function(cr, width, height)
            -- Corner radius of 15px like in Dunst
            local radius = dpi(15)
            require("gears").shape.rounded_rect(cr, width, height, radius)
        end
    }

    -- Configure different urgency levels
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
            timeout = 0,
            border_color = "#ff0000"
        }
    }

    -- Set key bindings similar to Dunst
    -- You may need to adjust these according to your keybindings module
    local awful = require("awful")
    awful.keyboard.append_global_keybindings({
        awful.key({ "Control" }, "space", function() naughty.destroy(naughty.get_displayed()[1]) end,
                {description = "close notification", group = "notifications"}),
        awful.key({ "Control", "Shift" }, "space", function() naughty.destroy_all_notifications() end,
                {description = "close all notifications", group = "notifications"}),
        awful.key({ "Control" }, "grave", function() naughty.toggle() end,
                {description = "toggle notifications", group = "notifications"})
    })

    print("Naughty configured to look like Dunst")
end

return notifications

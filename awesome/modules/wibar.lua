-- modules/wibar.lua

-- Load required libraries
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local widgets = require("modules.widgets")

-- Create wibar table
local wibar = {}

-- Wibar configuration
local config = {
    position = "top",
    height = 32,
    opacity = 0.9
}

-- Setup wibar for each screen
local function setup_wibar(s)
    -- Create taglist for this screen
    local taglist = widgets.create_taglist(s)
    
    -- Create the wibar
    s.mywibar = awful.wibar({
        position = config.position,
        screen = s,
        height = config.height,
        bg = beautiful.bg_normal .. string.format("%x", math.floor(config.opacity * 255)),
    })
    
    -- Add widgets to the wibar
    s.mywibar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 6,
            widgets.window_title,
        },
        { -- Middle widget
            layout = wibox.layout.fixed.horizontal,
            taglist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 6,
            widgets.systray,
            widgets.idle_inhibitor_widget,
            widgets.cpu_widget,
            widgets.mem_widget,
            widgets.clock_widget,
            widgets.volume_widget,
            widgets.bluetooth_widget,   
        },
    }
end

-- Initialize wibars
function wibar.init()
    -- Setup wibar for each screen
    awful.screen.connect_for_each_screen(function(s)
        setup_wibar(s)
    end)
    
    -- Handle screen changes (connecting/disconnecting monitors)
    screen.connect_signal("property::geometry", function(s)
        -- Recreate wibar when screen geometry changes
        if s.mywibar then
            s.mywibar:remove()
        end
        setup_wibar(s)
    end)
end

return wibar

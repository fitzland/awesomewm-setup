local wibox = require("wibox")
local vicious = require("vicious") -- Make sure you have vicious installed
local beautiful = require("beautiful")
local gears = require("gears")

local M = {}

-- Helper function to create a widget with text
local function create_widget(args)
    local widget = wibox.widget {
        {
            {
                text = args.text or "",
                widget = wibox.widget.textbox,
            },
            left = 8,
            right = 8,
            widget = wibox.container.margin
        },
        bg = args.bg or beautiful.bg_normal,
        fg = args.fg or beautiful.fg_normal,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
        end,
        widget = wibox.container.background
    }
    
    return widget
end

-- CPU widget
M.cpu_widget = create_widget({ text = "CPU: N/A" })
vicious.cache(vicious.widgets.cpu)
vicious.register(M.cpu_widget, vicious.widgets.cpu, 
    function(widget, args)
        local text = string.format("CPU: %d%%", args[1])
        widget.widget.widget.text = text
        return text
    end, 2)

-- Memory widget
M.mem_widget = create_widget({ text = "RAM: N/A" })
vicious.cache(vicious.widgets.mem)
vicious.register(M.mem_widget, vicious.widgets.mem, 
    function(widget, args)
        local text = string.format("RAM: %d%% (%dMB)", args[1], args[2])
        widget.widget.widget.text = text
        return text
    end, 2)

-- Battery widget (if applicable)
M.bat_widget = create_widget({ text = "BAT: N/A" })
vicious.register(M.bat_widget, vicious.widgets.bat, 
    function(widget, args)
        local text = string.format("BAT: %d%% %s", args[2], args[1])
        widget.widget.widget.text = text
        return text
    end, 60, "BAT0")

-- Date and time widget
M.date_time_widget = create_widget({ text = os.date("%b %d, %H:%M") })
vicious.register(M.date_time_widget, vicious.widgets.date, 
    function(widget, args)
        local text = args[1]
        widget.widget.widget.text = text
        return text
    end, "%b %d, %H:%M", 60)

-- Volume widget
M.vol_widget = create_widget({ text = "Vol: N/A" })
vicious.register(M.vol_widget, vicious.widgets.volume, 
    function(widget, args)
        local text = string.format("Vol: %d%%", args[1])
        if args[2] == "♩" then
            text = text .. " (muted)"
        end
        widget.widget.widget.text = text
        return text
    end, 2, "Master")

-- Network widget
M.net_widget = create_widget({ text = "Net: N/A" })
vicious.register(M.net_widget, vicious.widgets.net, 
    function(widget, args)
        local text = string.format("↓ %s ↑ %s", 
            args["{wlp2s0 down_kb}"] or args["{eth0 down_kb}"] or "0", 
            args["{wlp2s0 up_kb}"] or args["{eth0 up_kb}"] or "0")
        widget.widget.widget.text = text
        return text
    end, 2)

-- Filesystem widget
M.fs_widget = create_widget({ text = "/ N/A" })
vicious.register(M.fs_widget, vicious.widgets.fs, 
    function(widget, args)
        local text = string.format("/ %d%%", args["{/ used_p}"])
        widget.widget.widget.text = text
        return text
    end, 60)

-- System widgets layout
M.system_widgets = wibox.widget {
    M.cpu_widget,
    M.mem_widget,
    M.fs_widget,
    M.net_widget,
    M.vol_widget,
    M.bat

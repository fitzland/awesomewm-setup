local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Try to load vicious, but don't fail if it's not available
local vicious_available = false
local vicious = nil
local success, err = pcall(function()
    vicious = require("vicious")
    vicious_available = true
end)

if not success then
    print("Warning: Vicious widget library not found. Using fallback widgets.")
    print("Error was: " .. tostring(err))
end

local M = {}

-- Helper function to create a styled widget
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

-- Create basic widgets that don't depend on vicious
M.cpu_widget = create_widget({ text = "CPU: N/A" })
M.mem_widget = create_widget({ text = "RAM: N/A" })
M.fs_widget = create_widget({ text = "/ N/A" })
M.net_widget = create_widget({ text = "Net: N/A" })
M.vol_widget = create_widget({ text = "Vol: N/A" })
M.bat_widget = create_widget({ text = "BAT: N/A" })
M.date_time_widget = wibox.widget.textclock(" %b %d, %H:%M ")

-- Register vicious widgets if available
if vicious_available then
    -- CPU widget
    vicious.cache(vicious.widgets.cpu)
    vicious.register(M.cpu_widget, vicious.widgets.cpu, 
        function(widget, args)
            local text = string.format(" CPU: %d%% ", args[1])
            widget.widget.widget.text = text
            return text
        end, 2)

    -- Memory widget
    vicious.cache(vicious.widgets.mem)
    vicious.register(M.mem_widget, vicious.widgets.mem, 
        function(widget, args)
            local text = string.format(" RAM: %d%% ", args[1])
            widget.widget.widget.text = text
            return text
        end, 2)

    -- Filesystem widget
    vicious.register(M.fs_widget, vicious.widgets.fs, 
        function(widget, args)
            local text = string.format(" / %d%% ", args["{/ used_p}"] or 0)
            widget.widget.widget.text = text
            return text
        end, 60)

    -- Network widget
    vicious.register(M.net_widget, vicious.widgets.net, 
        function(widget, args)
            -- Try to find an active network interface
            local down = args["{wlan0 down_kb}"] or args["{eth0 down_kb}"] or args["{enp0s3 down_kb}"] or 0
            local up = args["{wlan0 up_kb}"] or args["{eth0 up_kb}"] or args["{enp0s3 up_kb}"] or 0
            
            local text = string.format(" ↓ %s ↑ %s ", down, up)
            widget.widget.widget.text = text
            return text
        end, 2)

    -- Volume widget
    vicious.register(M.vol_widget, vicious.widgets.volume, 
        function(widget, args)
            local text = string.format(" Vol: %d%% ", args[1] or 0)
            if args[2] == "♩" then
                text = text .. "(muted) "
            end
            widget.widget.widget.text = text
            return text
        end, 2, "Master")

    -- Battery widget (if available)
    vicious.register(M.bat_widget, vicious.widgets.bat, 
        function(widget, args)
            if args[2] then  -- Check if battery data is available
                local text = string.format(" BAT: %d%% ", args[2])
                widget.widget.widget.text = text
                return text
            else
                return " BAT: N/A "
            end
        end, 60, "BAT0")
end

-- Create a system widget container
M.system_widgets = wibox.widget {
    M.cpu_widget,
    M.mem_widget,
    M.fs_widget,
    M.net_widget,
    M.vol_widget,
    M.bat_widget,
    spacing = 5,
    layout = wibox.layout.fixed.horizontal
}

return M

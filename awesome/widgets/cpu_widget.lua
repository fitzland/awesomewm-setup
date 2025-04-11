-- cpu_widget.lua: A CPU widget with a text label and a shorter progress bar.
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local dpi       = beautiful.xresources.apply_dpi

-- Create a textbox for the CPU label ("CPU:") using theme colors.
local cpu_label = wibox.widget.textbox()
cpu_label.font = beautiful.widget_icon or "Roboto Mono Nerd Font 14"
cpu_label.markup = "<span color='" .. (beautiful.fg_cpu or "#bc8cff") .. "'>CPU:</span>"

-- Create a progress bar for CPU usage with a shorter readout.
local cpu_bar = wibox.widget {
    max_value     = 100,
    value         = 0,
    forced_width  = dpi(50),   -- Reduced width for a shorter bar readout
    forced_height = dpi(10),
    shape         = gears.shape.rounded_rect,
    widget        = wibox.widget.progressbar,
}

cpu_bar.border_width     = dpi(1)
cpu_bar.border_color     = beautiful.fg_normal or "#ffffff"
cpu_bar.background_color = beautiful.bg_normal or "#000000"
cpu_bar.color            = beautiful.fg_cpu or "#bc8cff"  -- Use theme color for fill

-- Combine the CPU label and the progress bar horizontally.
local cpu_widget = wibox.widget {
    cpu_label,
    {
        cpu_bar,
        margins = dpi(4),
        widget  = wibox.container.margin,
    },
    spacing = dpi(4),
    layout = wibox.layout.fixed.horizontal
}

-- Variables to store previous CPU statistics.
local total_prev = 0
local idle_prev  = 0

-- Update the CPU progress bar every 2 seconds.
awful.widget.watch("bash -c \"cat /proc/stat | grep '^cpu '\"", 2, 
    function(_, stdout, _, _, exit_code)
        if exit_code ~= 0 then
            cpu_bar.value = 0
            return
        end

        local user, nice, system, idle = stdout:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        if not (user and nice and system and idle) then
            cpu_bar.value = 0
            return
        end

        -- Convert string values to numbers
        user   = tonumber(user)
        nice   = tonumber(nice)
        system = tonumber(system)
        idle   = tonumber(idle)

        local total = user + nice + system + idle
        local diff_idle = idle - idle_prev
        local diff_total = total - total_prev
        local diff_usage = 0
        if diff_total ~= 0 then
            diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
        end

        cpu_bar.value = diff_usage
        total_prev = total
        idle_prev  = idle

        collectgarbage("collect")
    end
)

return cpu_widget

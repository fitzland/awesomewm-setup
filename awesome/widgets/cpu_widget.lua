-- cpu_widget.lua: An image-based CPU widget replaced by a slider for CPU usage.
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local dpi       = beautiful.xresources.apply_dpi

-- Create a slider for the CPU usage readout.
local cpu_slider = wibox.widget.slider({
    forced_width  = dpi(100),   -- Adjust width as needed
    forced_height = dpi(10),    -- Height of the slider track
    minimum = 0,
    maximum = 100,
    value = 0,
    bar_shape = gears.shape.rounded_rect,
    bar_height = dpi(10),
    bar_color = beautiful.bg_normal or "#000000",
    bar_active_color = beautiful.fg_cpu or "#bc8cff",  -- The filled portion color
    handle_shape = gears.shape.circle,
    handle_width = dpi(14),
    handle_color = beautiful.fg_cpu or "#bc8cff",
})

-- Optionally, add a label "CPU:" to the left of the slider.
local cpu_label = wibox.widget.textbox()
cpu_label.font = beautiful.widget_icon or "Roboto Mono Nerd Font 12"
cpu_label.markup = "<span color='" .. (beautiful.fg_cpu or "#bc8cff") .. "'>CPU:</span>"

-- Combine the label and slider in a horizontal layout.
local cpu_widget = wibox.widget {
    cpu_label,
    {
        cpu_slider,
        margins = dpi(4),
        widget  = wibox.container.margin,
    },
    spacing = dpi(4),
    layout = wibox.layout.fixed.horizontal,
}

-- Variables to store previous CPU times.
local total_prev = 0
local idle_prev  = 0

-- Update the slider every 2 seconds using /proc/stat.
awful.widget.watch("bash -c \"cat /proc/stat | grep '^cpu '\"", 2,
    function(_, stdout, _, _, exit_code)
        if exit_code ~= 0 then
            cpu_slider.value = 0
            return
        end

        local user, nice, system, idle = stdout:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        if not (user and nice and system and idle) then
            cpu_slider.value = 0
            return
        end

        -- Convert values from strings to numbers.
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

        cpu_slider.value = diff_usage
        total_prev = total
        idle_prev  = idle

        collectgarbage("collect")
    end
)

return cpu_widget

-- circular_cpu_widget.lua: A round CPU widget with a circular progress meter and a percentage readout.
local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi

-- Create a custom widget using wibox.widget.base.make_widget
local widget = wibox.widget.base.make_widget()

-- Internal storage for CPU usage
local cpu_usage = 0

-- Optionally store previous total and idle to compute differences.
local total_prev, idle_prev = 0, 0

-- Define a setter so you can update the usage
function widget:set_value(val)
    cpu_usage = val
    self:emit_signal("widget::updated")
end

-- The draw function: uses cairo to draw a circular arc and percent text.
function widget:draw(_, cr, width, height)
    local radius = math.min(width, height) / 2 - dpi(4)
    local cx, cy = width / 2, height / 2

    -- Set line width for the arc.
    local line_width = dpi(4)
    cr:set_line_width(line_width)

    -- Use theme's fg_cpu (or a fallback) for the arc color.
    local arc_color = beautiful.fg_cpu or "#bc8cff"
    local dim_factor = 0.3  -- For the background, use a dim version.
    
    -- Draw background circle (a full ring in a dim version of arc_color)
    local c = gears.color.parse_color(arc_color)
    -- Create a dim color by reducing brightness (multiply R, G, B by dim_factor)
    local dim_r = c.r * dim_factor
    local dim_g = c.g * dim_factor
    local dim_b = c.b * dim_factor
    cr:set_source_rgba(dim_r, dim_g, dim_b, 1)
    cr:arc(cx, cy, radius, 0, 2 * math.pi)
    cr:stroke()

    -- Draw the usage arc (from -90° to -90°+usage_angle).
    cr:set_source(gears.color(arc_color))
    local usage_angle = 2 * math.pi * (cpu_usage / 100)
    cr:arc(cx, cy, radius, -math.pi/2, -math.pi/2 + usage_angle)
    cr:stroke()

    -- Draw the percentage text in the center.
    local percent_text = math.floor(cpu_usage) .. "%"
    cr:set_font_size(dpi(14))
    local extents = cr:text_extents(percent_text)
    cr:move_to(cx - extents.width/2 - extents.x_bearing, cy - extents.height/2 - extents.y_bearing)
    cr:set_source(gears.color(arc_color))
    cr:show_text(percent_text)
end

-- Update the widget every 2 seconds by reading /proc/stat
awful.widget.watch("bash -c \"cat /proc/stat | grep '^cpu '\"", 2,
    function(_, stdout, _, _, exit_code)
        if exit_code ~= 0 then
            widget:set_value(0)
            return
        end

        local user, nice, system, idle = stdout:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
        if not (user and nice and system and idle) then
            widget:set_value(0)
            return
        end

        user   = tonumber(user)
        nice   = tonumber(nice)
        system = tonumber(system)
        idle   = tonumber(idle)

        local total = user + nice + system + idle
        local diff_idle = idle - (idle_prev or idle)
        local diff_total = total - (total_prev or total)
        local diff_usage = 0
        if diff_total ~= 0 then
            diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
        end

        widget:set_value(diff_usage)
        total_prev = total
        idle_prev = idle

        collectgarbage("collect")
    end,
widget)

-- Constrain the widget's size for a consistent look (adjust as needed).
local constrained_widget = wibox.container.constraint(widget, "exact", dpi(60), dpi(60))
return constrained_widget

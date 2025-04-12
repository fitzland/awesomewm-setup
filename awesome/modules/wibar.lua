-- modules/widgets.lua

-- Load required libraries
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

-- Create widgets table
local widgets = {}

-- Widget configuration
local config = {
    font = "Roboto Mono Nerd Font 10",
    corner_radius = 8,
    bg_opacity = "40",  -- 40% opacity for backgrounds
    update_interval = {
        cpu = 2,
        mem = 5,
        vol = 1
    }
}

-- Rounded corner helper function
local function rounded_shape(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, config.corner_radius)
end

-- Custom partially rounded rect functions
local function partially_rounded_rect_left(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, config.corner_radius)
end

local function partially_rounded_rect_right(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, config.corner_radius)
end

-- CPU widget
local cpu_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local function update_cpu()
    -- Read /proc/stat to get CPU usage
    awful.spawn.easy_async_with_shell(
        "grep '^cpu ' /proc/stat",
        function(stdout)
            -- Parse CPU stats
            local user, nice, system, idle, iowait, irq, softirq = stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
            
            -- Convert to numbers
            user, nice, system, idle, iowait, irq, softirq = 
                tonumber(user), tonumber(nice), tonumber(system), 
                tonumber(idle), tonumber(iowait), tonumber(irq), tonumber(softirq)
            
            -- Store current stats for delta calculation
            local total = user + nice + system + idle + iowait + irq + softirq
            local idle_total = idle + iowait
            
            if widgets.cpu_prev_total then
                local diff_idle = idle_total - widgets.cpu_prev_idle
                local diff_total = total - widgets.cpu_prev_total
                local usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
                
                -- Update widget text with colorized output
                cpu_text.markup = '<span foreground="' .. beautiful.bg_focus .. '">CPU: </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">' .. math.floor(usage) .. '%</span>'
            else
                cpu_text.markup = '<span foreground="' .. beautiful.bg_focus .. '">CPU: </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">---%</span>'
            end
            
            -- Store values for next calculation
            widgets.cpu_prev_total = total
            widgets.cpu_prev_idle = idle_total
        end
    )
end

-- Create the CPU widget
widgets.cpu_widget = wibox.widget {
    {
        {
            cpu_text,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. config.bg_opacity,
        shape = rounded_shape,
        widget = wibox.container.background
    },
    layout = wibox.layout.fixed.horizontal
}

-- Memory widget
local mem_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local function update_mem()
    -- Get memory information
    awful.spawn.easy_async_with_shell(
        "grep -E '^Mem(Total|Available)' /proc/meminfo | awk '{print $2}'",
        function(stdout)
            local values = {}
            for value in stdout:gmatch("%d+") do
                table.insert(values, tonumber(value))
            end
            
            if #values == 2 then
                local total = values[1]
                local available = values[2]
                local used = total - available
                local percentage = math.floor(used / total * 100)
                
                -- Update widget text with colorized output
                mem_text.markup = '<span foreground="' .. beautiful.bg_focus .. '">RAM: </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">' .. percentage .. '%</span>'
            else
                mem_text.markup = '<span foreground="' .. beautiful.bg_focus .. '">RAM: </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">---%</span>'
            end
        end
    )
end

-- Create the RAM widget
widgets.mem_widget = wibox.widget {
    {
        {
            mem_text,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. config.bg_opacity,
        shape = rounded_shape,
        widget = wibox.container.background
    },
    layout = wibox.layout.fixed.horizontal
}

-- Volume widget
local vol_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local vol_bar = wibox.widget {
    max_value = 100,
    value = 0,
    forced_height = 2,
    forced_width = 50,
    color = beautiful.bg_focus,
    background_color = beautiful.bg_minimize .. "80",
    shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar
}

local function update_volume()
    awful.spawn.easy_async_with_shell(
        "pamixer --get-volume-human",
        function(stdout)
            local volume = stdout:gsub("%%", ""):gsub("\n", "")
            local level = tonumber(volume) or 0
            
            local icon = "󰕾"  -- Default volume icon
            if volume:find("muted") then
                icon = "󰖁"   -- Muted icon
                level = 0
            elseif level < 30 then
                icon = "󰕿"   -- Low volume icon
            elseif level < 70 then
                icon = "󰖀"   -- Medium volume icon
            end
            
            -- Update widget text with colorized output
            vol_text.markup = '<span foreground="' .. beautiful.bg_focus .. '">' .. icon .. ' </span>' ..
                               '<span foreground="' .. beautiful.fg_normal .. '">' .. level .. '%</span>'
            
            -- Update progress bar
            vol_bar.value = level
        end
    )
end

-- Create the volume widget with interactive functionality
local vol_container = wibox.widget {
    {
        {
            {
                vol_text,
                layout = wibox.layout.fixed.horizontal
            },
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. config.bg_opacity,
        shape = partially_rounded_rect_left,
        widget = wibox.container.background
    },
    {
        {
            vol_bar,
            left = 4,
            right = 8,
            top = 12,
            bottom = 12,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. config.bg_opacity,
        shape = partially_rounded_rect_right,
        widget = wibox.container.background
    },
    layout = wibox.layout.fixed.horizontal
}

-- Add volume scroll control
vol_container:buttons(gears.table.join(
    awful.button({ }, 4, function() awful.spawn.with_shell("pamixer -i 5") end),
    awful.button({ }, 5, function() awful.spawn.with_shell("pamixer -d 5") end),
    awful.button({ }, 3, function() awful.spawn.with_shell("pamixer -t") end)
))

widgets.volume_widget = vol_container

-- Initialize all widgets
function widgets.init()
    -- Start timers for widget updates
    gears.timer {
        timeout = config.update_interval.cpu,
        call_now = true,
        autostart = true,
        callback = update_cpu
    }
    
    gears.timer {
        timeout = config.update_interval.mem,
        call_now = true,
        autostart = true,
        callback = update_mem
    }
    
    gears.timer {
        timeout = config.update_interval.vol,
        call_now = true,
        autostart = true,
        callback = update_volume
    }
end

return widgets

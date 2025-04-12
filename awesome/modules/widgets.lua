-- modules/widgets.lua

-- Load required libraries
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local variables = require("modules.variables")

-- Try to load vicious with error handling
local vicious, vicious_error
local status, err = pcall(function() 
    vicious = require("vicious") 
end)
if not status then
    vicious_error = err
    print("Error loading vicious: " .. tostring(err))
end

-- Create widgets table
local widgets = {}

-- Widget configuration
local config = {
    font = beautiful.font or "Roboto Mono Nerd Font 12",
    corner_radius = 8,
    bg_opacity = "40",  -- 40% opacity for backgrounds
    update_interval = {
        cpu = 2,
        mem = 5,
        temp = 30,
        vol = 1,
        battery = 60,
        bluetooth = 5
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

-- Helper function to create a widget container with consistent styling
local function create_widget_container(widget, shape_func)
    return wibox.widget {
        {
            widget,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. config.bg_opacity,
        shape = shape_func or rounded_shape,
        widget = wibox.container.background
    }
end

-- =====================================================
-- Basic widgets (retained from original)
-- =====================================================
-- Create a properly sized and centered systray
local systray = wibox.widget.systray()
systray.base_size = 22 -- Slightly larger icons

widgets.systray = wibox.widget {
    {
        {
            systray,
            layout = wibox.layout.fixed.horizontal
        },
        top = 2, -- Adjust this for vertical centering
        bottom = 2,
        left = 8,
        right = 8, 
        widget = wibox.container.margin
    },
    bg = beautiful.bg_minimize .. config.bg_opacity,
    shape = rounded_shape,
    widget = wibox.container.background
}

-- =====================================================
-- Clock widgets
-- =====================================================
widgets.date_widget = wibox.widget.textclock(" %a %b %-d ", 60)
widgets.time_widget = wibox.widget.textclock("%l:%M %p ", 1)

-- Create a formatted clock widget with icon
local clock_text = wibox.widget {
    {
        markup = '<span foreground="' .. beautiful.gh_caret .. '"> </span>',
        font = config.font,
        widget = wibox.widget.textbox,
    },
    {
        format = "%I:%M %a %d",
        font = config.font,
        fg = beautiful.gh_bg,
        widget = wibox.widget.textclock,
    },
    layout = wibox.layout.fixed.horizontal
}

-- Custom container with caret background for clock
widgets.clock_widget = wibox.widget {
    {
        clock_text,
        left = 8,
        right = 8,
        top = 4,
        bottom = 4,
        widget = wibox.container.margin
    },
    bg = beautiful.gh_caret,
    fg = beautiful.gh_bg,
    shape = rounded_shape,
    widget = wibox.container.background
}

-- =====================================================
-- CPU widget
-- =====================================================
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
                cpu_text.markup = '<span foreground="' .. beautiful.gh_blue .. '">󰯳 </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">' .. math.floor(usage) .. '%</span>'
            else
                cpu_text.markup = '<span foreground="' .. beautiful.gh_blue .. '">󰯳 </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">---%</span>'
            end
            
            -- Store values for next calculation
            widgets.cpu_prev_total = total
            widgets.cpu_prev_idle = idle_total
        end
    )
end

widgets.cpu_widget = create_widget_container(cpu_text)

-- =====================================================
-- Memory widget
-- =====================================================
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
                mem_text.markup = '<span foreground="' .. beautiful.gh_green .. '">󰍛 </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">' .. percentage .. '%</span>'
            else
                mem_text.markup = '<span foreground="' .. beautiful.gh_green .. '">󰍛 </span>' ..
                                   '<span foreground="' .. beautiful.fg_normal .. '">---%</span>'
            end
        end
    )
end

widgets.mem_widget = create_widget_container(mem_text)

-- =====================================================
-- Temperature widget
-- =====================================================
local temp_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local function update_temperature()
    awful.spawn.easy_async_with_shell(
        "cat /sys/class/hwmon/hwmon*/temp*_input 2>/dev/null | head -n 1 || echo 0",
        function(stdout)
            local temp = tonumber(stdout:match("(%d+)")) or 0
            temp = math.floor(temp / 1000)  -- Convert from millidegrees to degrees
            
            local color = beautiful.gh_magenta
            if temp >= 80 then
                color = beautiful.gh_red  -- Red for critical temperature
            end
            
            -- Update widget text with colorized output
            temp_text.markup = '<span foreground="' .. color .. '"> </span>' ..
                               '<span foreground="' .. beautiful.fg_normal .. '">' .. temp .. '°C</span>'
        end
    )
end

widgets.temp_widget = create_widget_container(temp_text)

-- =====================================================
-- Volume widget
-- =====================================================
local vol_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

-- Make the volume bar more compact
local vol_bar = wibox.widget {
    max_value = 100,
    value = 0,
    forced_height = 2,
    forced_width = 35,  -- Reduced from 50 to 35
    color = beautiful.gh_blue,
    background_color = beautiful.bg_minimize .. "80",
    shape = gears.shape.rounded_bar,
    widget = wibox.widget.progressbar
}

local function update_volume()
    awful.spawn.easy_async_with_shell(
        "pamixer --get-volume-human 2>/dev/null || amixer get Master | grep -o '[0-9]\\+%\\|\\[on\\]\\|\\[off\\]' | tr '\\n' ' ' | awk '{print $1, $2}'",
        function(stdout)
            local volume = stdout:gsub("%%", ""):gsub("\n", "")
            local level = tonumber(volume:match("%d+")) or 0
            
            local icon = "󰕾"  -- Default volume icon
            local color = beautiful.gh_cyan
            
            if volume:find("off") or volume:find("muted") then
                icon = "󰖁"   -- Muted icon
                level = 0
            elseif level < 30 then
                icon = "󰕿"   -- Low volume icon
            elseif level < 70 then
                icon = "󰖀"   -- Medium volume icon
            end
            
            -- Update widget text with colorized output
            vol_text.markup = '<span foreground="' .. color .. '">' .. icon .. ' </span>' ..
                               '<span foreground="' .. beautiful.fg_normal .. '">' .. level .. '%</span>'
            
            -- Update progress bar
            vol_bar.value = level
        end
    )
end

-- Create a more compact volume widget
local vol_widget_content = wibox.widget {
    {
        vol_text,
        layout = wibox.layout.fixed.horizontal
    },
    {
        vol_bar,
        left = 4,
        right = 4,
        top = 12,
        bottom = 12,
        widget = wibox.container.margin
    },
    layout = wibox.layout.fixed.horizontal,
    spacing = 2  -- Reduce spacing between text and bar
}

widgets.volume_widget = create_widget_container(vol_widget_content)

-- Add volume scroll control
widgets.volume_widget:buttons(gears.table.join(
    awful.button({ }, 4, function() awful.spawn.with_shell("pamixer -i 5 || amixer -q set Master 5%+") end),
    awful.button({ }, 5, function() awful.spawn.with_shell("pamixer -d 5 || amixer -q set Master 5%-") end),
    awful.button({ }, 3, function() awful.spawn.with_shell("pamixer -t || amixer -q set Master toggle") end)
))

-- =====================================================
-- Microphone widget
-- =====================================================
local mic_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local function update_microphone()
    awful.spawn.easy_async_with_shell(
        "pamixer --default-source --get-volume-human 2>/dev/null || amixer get Capture | grep -o '[0-9]\\+%\\|\\[on\\]\\|\\[off\\]' | tr '\\n' ' ' | awk '{print $1, $2}'",
        function(stdout)
            local volume = stdout:gsub("%%", ""):gsub("\n", "")
            local level = tonumber(volume:match("%d+")) or 0
            
            local icon = ""  -- Default mic icon
            local color = beautiful.gh_magenta
            
            if volume:find("off") or volume:find("muted") then
                icon = ""   -- Muted mic icon
                color = beautiful.gh_comment
            end
            
            -- Update widget text with colorized output
            mic_text.markup = '<span foreground="' .. color .. '">' .. icon .. '</span>'
        end
    )
end

widgets.mic_widget = create_widget_container(mic_text)

-- Add microphone toggle control
widgets.mic_widget:buttons(gears.table.join(
    awful.button({ }, 1, function() awful.spawn.with_shell("pamixer --default-source -t || amixer -q set Capture toggle") end)
))

-- =====================================================
-- Battery widget
-- =====================================================
local battery_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local function update_battery()
    awful.spawn.easy_async_with_shell(
        "acpi -b 2>/dev/null || echo 'Battery 0: Not present'",
        function(stdout)
            -- Default values if battery not found
            local percentage = 0
            local status = "Unknown"
            
            -- Try to parse battery info
            local battery_info = stdout:match("Battery %d+: ([%a%s]+), (%d+)%%")
            if battery_info then
                status, percentage = stdout:match("Battery %d+: ([%a%s]+), (%d+)%%")
                percentage = tonumber(percentage) or 0
            end
            
            local icon = ""
            local color = beautiful.gh_yellow
            
            if status:find("Charging") then
                icon = "󰂄"
                color = beautiful.gh_green
            elseif percentage <= 10 then
                icon = "󰁺"
                color = beautiful.gh_red
            elseif percentage <= 20 then
                icon = "󰁻"
                color = beautiful.gh_red
            elseif percentage <= 30 then
                icon = "󰁼"
            elseif percentage <= 40 then
                icon = "󰁽"
            elseif percentage <= 50 then
                icon = "󰁾"
            elseif percentage <= 60 then
                icon = "󰁿"
            elseif percentage <= 70 then
                icon = "󰂀"
            elseif percentage <= 80 then
                icon = "󰂁"
            elseif percentage <= 90 then
                icon = "󰂂"
            else
                icon = "󰁹"
            end
            
            -- Update widget text with colorized output
            battery_text.markup = '<span foreground="' .. color .. '">' .. icon .. ' </span>' ..
                                  '<span foreground="' .. beautiful.fg_normal .. '">' .. percentage .. '%</span>'
        end
    )
end

widgets.battery_widget = create_widget_container(battery_text)

-- =====================================================
-- Bluetooth widget
-- =====================================================
local bluetooth_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local function update_bluetooth()
    awful.spawn.easy_async_with_shell(
        "bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}' || echo 'not found'",
        function(stdout)
            local powered = stdout:gsub("%s+", "")
            
            local icon = "󰂲"
            local color = beautiful.gh_comment
            
            if powered == "yes" then
                -- Further check if it's connected
                awful.spawn.easy_async_with_shell(
                    "bluetoothctl info 2>/dev/null | grep 'Connected:' | awk '{print $2}' || echo 'no'",
                    function(stdout2)
                        local connected = stdout2:gsub("%s+", "")
                        
                        if connected == "yes" then
                            icon = ""
                            color = beautiful.gh_blue
                        end
                        
                        -- Update widget text with colorized output
                        bluetooth_text.markup = '<span foreground="' .. color .. '">' .. icon .. '</span>'
                    end
                )
            else
                -- Update widget text with colorized output
                bluetooth_text.markup = '<span foreground="' .. color .. '">' .. icon .. '</span>'
            end
        end
    )
end

widgets.bluetooth_widget = create_widget_container(bluetooth_text)

-- =====================================================
-- Idle inhibitor widget
-- =====================================================
local idle_inhibitor_text = wibox.widget {
    font = config.font,
    widget = wibox.widget.textbox
}

local idle_inhibitor_active = false

local function toggle_idle_inhibitor()
    idle_inhibitor_active = not idle_inhibitor_active
    if idle_inhibitor_active then
        awful.spawn.with_shell("xdg-screensaver suspend $(xdotool getwindowfocus)")
        idle_inhibitor_text.markup = '<span foreground="' .. beautiful.gh_green .. '">󱠛</span>'
    else
        awful.spawn.with_shell("xdg-screensaver resume $(xdotool getwindowfocus)")
        idle_inhibitor_text.markup = '<span foreground="' .. beautiful.gh_comment .. '">󱤱</span>'
    end
end

widgets.idle_inhibitor_widget = create_widget_container(idle_inhibitor_text)

idle_inhibitor_text.markup = '<span foreground="' .. beautiful.gh_comment .. '">󱤱</span>'
widgets.idle_inhibitor_widget:buttons(gears.table.join(
    awful.button({}, 1, function() toggle_idle_inhibitor() end)
))

-- =====================================================
-- Window title widget
-- =====================================================
local window_title_text = wibox.widget {
    font = config.font,
    ellipsize = "end",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}

local window_title = wibox.widget {
    {
        window_title_text,
        left = 8,
        right = 8,
        widget = wibox.container.margin
    },
    bg = beautiful.bg_minimize .. config.bg_opacity,
    shape = rounded_shape,
    widget = wibox.container.background
}

-- Function to update window title
local function update_window_title(c)
    if c and c.valid then
        window_title_text:set_markup('<span foreground="' .. beautiful.fg_normal .. '">' .. c.name .. '</span>')
    else
        window_title_text:set_markup('<span foreground="' .. beautiful.gh_comment .. '">Desktop</span>')
    end
end

-- Connect to client focus signal to update window title
client.connect_signal("focus", function(c)
    update_window_title(c)
end)

client.connect_signal("unfocus", function(c)
    update_window_title(nil)
end)

widgets.window_title = window_title

-- =====================================================
-- Layout box widget
-- =====================================================
function widgets.create_layoutbox(s)
    local layoutbox = awful.widget.layoutbox(s)
    
    -- Add buttons to change layout
    layoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))
    
    -- Create container with same styling as other widgets
    local layoutbox_container = wibox.widget {
        {
            layoutbox,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. config.bg_opacity,
        shape = rounded_shape,
        widget = wibox.container.background
    }
    
    return layoutbox_container
end
function widgets.create_taglist(s)
    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
        ),
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        font = config.font,
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left = 8,
                right = 8,
                top = 4,
                bottom = 4,
                widget = wibox.container.margin
            },
            id = 'background_role',
            shape = rounded_shape,
            widget = wibox.container.background,
        },
    }
end

-- =====================================================
-- Initialize all widgets
-- =====================================================
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
        timeout = config.update_interval.temp,
        call_now = true,
        autostart = true,
        callback = update_temperature
    }
    
    gears.timer {
        timeout = config.update_interval.vol,
        call_now = true,
        autostart = true,
        callback = update_volume
    }
    
    gears.timer {
        timeout = config.update_interval.vol,
        call_now = true,
        autostart = true,
        callback = update_microphone
    }
    
    gears.timer {
        timeout = config.update_interval.battery,
        call_now = true,
        autostart = true,
        callback = update_battery
    }
    
    gears.timer {
        timeout = config.update_interval.bluetooth,
        call_now = true,
        autostart = true,
        callback = update_bluetooth
    }
    
    -- Initialize window title
    update_window_title(nil)
    
    -- Only register with vicious if it loaded successfully
    if vicious and not vicious_error then
        pcall(function()
            -- You can still use vicious for some widgets if preferred
            -- vicious.register(widgets.cpu_widget, vicious.widgets.cpu, " CPU: $1% ", 2)
            -- vicious.register(widgets.mem_widget, vicious.widgets.mem, " RAM: $1% ", 15)
        end)
    end
end

return widgets

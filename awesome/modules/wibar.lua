-- modules/wibar.lua

-- Load required libraries
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Get widgets and other modules
local widgets = require("modules.widgets")
local variables = require("modules.variables")
local menu = require("modules.menu")

-- Function to create taglist buttons
local function taglist_buttons()
    return gears.table.join(
        awful.button({ }, 1, function(t) t:view_only() end),
        awful.button({ variables.modkey }, 1, function(t)
            if client.focus then
                client.focus:move_to_tag(t)
            end
        end),
        awful.button({ }, 3, awful.tag.viewtoggle),
        awful.button({ variables.modkey }, 3, function(t)
            if client.focus then
                client.focus:toggle_tag(t)
            end
        end),
        awful.button({ }, 4, function() awful.tag.viewnext(awful.screen.focused()) end),
        awful.button({ }, 5, function() awful.tag.viewprev(awful.screen.focused()) end)
    )
end

-- Function to create tasklist buttons
local function tasklist_buttons()
    return gears.table.join(
        awful.button({ }, 1, function(c)
            if c == client.focus then
                c.minimized = true
            else
                c:emit_signal("request::activate", "tasklist", {raise = true})
            end
        end),
        awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
        awful.button({ }, 4, function() awful.client.focus.byidx(1) end),
        awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
    )
end

-- Create custom shapes
local cornerRadius = 8

local roundedRectangle = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, cornerRadius)
end

local leftRoundedRectangle = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, cornerRadius)
end

local rightRoundedRectangle = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, cornerRadius)
end

-- Create a textclock widget with consistent font size
local mytextclock = wibox.widget.textclock()
mytextclock.font = "Roboto Mono Nerd Font 10"

-- Create volume widget with scroll interaction
local create_volume_widget = function()
    local text_volume = wibox.widget{
        font = "Roboto Mono Nerd Font 10",
        widget = wibox.widget.textbox
    }

    local update_volume = function(vol)
        text_volume.text = "󰕾 " .. vol
    end

    local volume_bar = wibox.widget{
        max_value = 100,
        shape = gears.shape.rounded_bar,
        forced_height = 2,
        forced_width = 50,
        border_width = 0,
        background_color = beautiful.bg_minimize,
        color = beautiful.bg_focus,
        widget = wibox.widget.progressbar,
    }

    -- Update volume every 0.5 seconds
    gears.timer {
        timeout = 0.5,
        call_now = true,
        autostart = true,
        callback = function()
            awful.spawn.easy_async("pamixer --get-volume 2>/dev/null || echo '0'", function(stdout)
                local vol = stdout:gsub("\n", "")
                update_volume(vol)
                volume_bar.value = tonumber(vol)
            end)
        end
    }

    local volume_widget = {
        {
            {
                {
                    text_volume,
                    spacing = 4,
                    layout = wibox.layout.fixed.horizontal
                },
                left = 8,
                right = 8,
                top = 2,
                bottom = 2,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = leftRoundedRectangle,        -- Add rounded corners
            widget = wibox.container.background,
        },
        {
            {
                volume_bar,
                top = 12,
                bottom = 12,
                left = 4,
                right = 8,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = rightRoundedRectangle,       -- Add rounded corners
            widget = wibox.container.background,
        },
        spacing = 0,  -- Remove spacing between parts
        layout = wibox.layout.fixed.horizontal
    }
    
    -- Add scroll functionality to change volume
    volume_widget:buttons(gears.table.join(
        awful.button({ }, 4, function() -- Scroll up
            awful.spawn.with_shell("pamixer -i 5")
        end),
        awful.button({ }, 5, function() -- Scroll down
            awful.spawn.with_shell("pamixer -d 5")
        end),
        awful.button({ }, 3, function() -- Right click to toggle mute
            awful.spawn.with_shell("pamixer -t")
        end)
    ))
    
    return volume_widget
end

-- Create CPU usage widget
local create_cpu_widget = function()
    local cpu_icon = wibox.widget{
        font = "Roboto Mono Nerd Font 10",
        text = "󰘚",  -- CPU icon
        widget = wibox.widget.textbox
    }
    
    local cpu_text = wibox.widget{
        font = "Roboto Mono Nerd Font 10",
        widget = wibox.widget.textbox
    }
    
    -- Store CPU usage history for calculation
    local cpu_usage = {}
    local cpu_total = {}
    
    -- Update CPU usage
    gears.timer {
        timeout = 2,
        call_now = true,
        autostart = true,
        callback = function()
            -- Read /proc/stat to get CPU usage
            awful.spawn.easy_async("cat /proc/stat | grep '^cpu '", function(stdout)
                -- Parse CPU stats
                local user, nice, system, idle, iowait, irq, softirq = stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
                
                -- Convert to numbers
                user, nice, system, idle, iowait, irq, softirq = tonumber(user), tonumber(nice), tonumber(system), tonumber(idle), tonumber(iowait), tonumber(irq), tonumber(softirq)
                
                -- Calculate total CPU time
                local idle_total = idle + iowait
                local non_idle = user + nice + system + irq + softirq
                local total = idle_total + non_idle
                
                -- Calculate CPU usage if history exists
                if cpu_total[1] then
                    local diff_idle = idle_total - cpu_usage[1]
                    local diff_total = total - cpu_total[1]
                    local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
                    
                    -- Update the text
                    cpu_text.text = string.format("%d%%", math.floor(diff_usage))
                end
                
                -- Store current values for next iteration
                cpu_usage[1] = idle_total
                cpu_total[1] = total
            end)
        end
    }
    
    -- Return the combined widget
    return {
        {
            {
                {
                    {
                        cpu_icon,
                        right = 4,
                        widget = wibox.container.margin,
                    },
                    cpu_text,
                    layout = wibox.layout.fixed.horizontal
                },
                margins = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = roundedRectangle,            -- Add rounded corners
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal
    }
end

-- Create RAM usage widget
local create_ram_widget = function()
    local ram_icon = wibox.widget{
        font = "Roboto Mono Nerd Font 10",
        text = "󰍛",  -- RAM icon
        widget = wibox.widget.textbox
    }
    
    local ram_text = wibox.widget{
        font = "Roboto Mono Nerd Font 10",
        widget = wibox.widget.textbox
    }
    
    -- Update RAM usage
    gears.timer {
        timeout = 5,
        call_now = true,
        autostart = true,
        callback = function()
            -- Get memory information from /proc/meminfo
            awful.spawn.easy_async("grep -E 'MemTotal|MemFree|Buffers|Cached' /proc/meminfo", function(stdout)
                -- Parse memory stats
                local total = stdout:match("MemTotal:%s+(%d+)")
                local free = stdout:match("MemFree:%s+(%d+)")
                local buffers = stdout:match("Buffers:%s+(%d+)")
                local cached = stdout:match("Cached:%s+(%d+)")
                
                -- Calculate used memory percentage
                total, free, buffers, cached = tonumber(total), tonumber(free), tonumber(buffers), tonumber(cached)
                local used = total - free - buffers - cached
                local percentage = math.floor(used / total * 100)
                
                -- Update the text
                ram_text.text = string.format("%d%%", percentage)
            end)
        end
    }
    
    -- Return the combined widget
    return {
        {
            {
                {
                    {
                        ram_icon,
                        right = 4,
                        widget = wibox.container.margin,
                    },
                    ram_text,
                    layout = wibox.layout.fixed.horizontal
                },
                margins = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = roundedRectangle,            -- Add rounded corners
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal
    }
end

-- Setup for newly connected screens
local function setup_new_screen(s)
    -- Create a layoutbox widget
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))
    
    -- Create a promptbox widget
    s.mypromptbox = awful.widget.prompt()
    
    -- Create a taglist widget with Font Awesome icons and improved spacing
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons(),
        layout = {
            spacing = 15,  -- Increased spacing between tags
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    id = 'text_role',
                    font = "Font Awesome 6 Free 12",  -- Use Font Awesome for icons
                    widget = wibox.widget.textbox,
                },
                margins = 6,
                widget = wibox.container.margin,
            },
            id = 'background_role',
            widget = wibox.container.background,
        }
    }
    
    -- Create a tasklist widget (not shown in center, but available if needed)
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.focused,
        buttons = tasklist_buttons()
    }
    
    -- Create system tray widget with fixed spacing
    local systray = wibox.widget.systray()
    systray.base_size = 16  -- Smaller size
    
    -- Wrap systray in a container with background and rounded corners
    local systray_container = {
        {
            {
                systray,
                margins = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = roundedRectangle,            -- Add rounded corners
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal
    }
    
    -- Create styled textclock for center
    local textclock = {
        {
            {
                mytextclock,
                left = 8,
                right = 8,
                top = 4,
                bottom = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = roundedRectangle,            -- Add rounded corners
            widget = wibox.container.background,
        },
        halign = "center",
        widget = wibox.container.place
    }
    
    -- Create layoutbox container with background and rounded corners
    local layoutbox_container = {
        {
            {
                {
                    s.mylayoutbox,
                    forced_height = 16,  -- Make layout icon smaller
                    forced_width = 16,   -- Make layout icon smaller
                    widget = wibox.container.constraint,
                },
                margins = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_minimize .. "40",  -- Add subtle background with alpha
            shape = roundedRectangle,            -- Add rounded corners
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal
    }
    
    -- Create the wibar
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s, 
        height = 28,
        bg = beautiful.bg_normal .. "dd"  -- Semi-transparent background
    })
    
    -- Add widgets to the wibar
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        textclock, -- Center widget is now the clock
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 8,  -- Add spacing between all right widgets
            create_volume_widget(),
            create_cpu_widget(),  -- CPU widget instead of Bluetooth
            create_ram_widget(),  -- RAM widget instead of WiFi
            systray_container,
            layoutbox_container,
        },
    }
    
    print("Styled wibar set up on screen " .. s.index)
end

-- Initialize function
local function init()
    -- Make sure menu is initialized
    if not menu.launcher then
        menu.init()
    end

    -- Setup existing screens directly
    for s in screen do
        setup_new_screen(s)
    end
    
    -- Also setup signal handler for any future screens
    screen.connect_signal("request::desktop_decoration", function(s)
        setup_new_screen(s)
    end)
end

-- Return the module
return {
    init = init
}

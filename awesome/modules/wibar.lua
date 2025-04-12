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

-- Create a textclock widget
local mytextclock = wibox.widget.textclock("%a %b %d, %H:%M")

-- Create volume widget
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

    return {
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
            bg = beautiful.bg_normal,
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
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        },
        spacing = 2,
        layout = wibox.layout.fixed.horizontal
    }
end

-- Create wifi widget
local create_wifi_widget = function()
    local wifi_icon = wibox.widget{
        font = "Roboto Mono Nerd Font 12",
        text = "󰖩",
        widget = wibox.widget.textbox
    }

    -- Update icon based on connection status
    gears.timer {
        timeout = 10,
        call_now = true,
        autostart = true,
        callback = function()
            awful.spawn.easy_async("iwgetid -r 2>/dev/null || echo ''", function(stdout)
                local wifi = stdout:gsub("\n", "")
                if wifi == "" then
                    wifi_icon.text = "󰖪"  -- Disconnected
                    wifi_icon.fg = beautiful.fg_minimize
                else
                    wifi_icon.text = "󰖩"  -- Connected
                    wifi_icon.fg = beautiful.fg_normal
                end
            end)
        end
    }

    return {
        {
            {
                wifi_icon,
                margins = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal
    }
end

-- Create bluetooth widget
local create_bluetooth_widget = function()
    local bt_icon = wibox.widget{
        font = "Roboto Mono Nerd Font 12",
        text = "󰂯",
        widget = wibox.widget.textbox
    }

    -- Update icon based on connection status
    gears.timer {
        timeout = 10,
        call_now = true,
        autostart = true,
        callback = function()
            awful.spawn.easy_async("bluetoothctl show | grep 'Powered: yes' 2>/dev/null || echo ''", function(stdout)
                local bt_powered = stdout:gsub("\n", "")
                if bt_powered == "" then
                    bt_icon.text = "󰂲"  -- Bluetooth off
                    bt_icon.fg = beautiful.fg_minimize
                else
                    -- Check if connected to any devices
                    awful.spawn.easy_async("bluetoothctl info | grep 'Name' 2>/dev/null || echo ''", function(dev_stdout)
                        if dev_stdout:gsub("\n", "") == "" then
                            bt_icon.text = "󰂯"  -- Bluetooth on but not connected
                            bt_icon.fg = beautiful.fg_normal
                        else
                            bt_icon.text = "󰂱"  -- Bluetooth connected
                            bt_icon.fg = beautiful.bg_focus
                        end
                    end)
                end
            end)
        end
    }

    return {
        {
            {
                bt_icon,
                margins = 4,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_normal,
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
    
    -- Create system tray widget
    local systray = wibox.widget.systray()
    systray.base_size = 20
    
    -- Create styled textclock for center
    local textclock = {
        {
            {
                mytextclock,
                left = 8,
                right = 8,
                widget = wibox.container.margin,
            },
            bg = beautiful.bg_normal,
            fg = beautiful.fg_normal,
            widget = wibox.container.background,
        },
        halign = "center",
        widget = wibox.container.place
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
            spacing = 10,  -- Add spacing between all right widgets
            create_volume_widget(),
            create_bluetooth_widget(),
            create_wifi_widget(),
            systray,
            s.mylayoutbox,
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

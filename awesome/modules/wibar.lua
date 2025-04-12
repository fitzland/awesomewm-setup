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
local cornerRadius = 10

local roundedRectangle = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, cornerRadius)
end

local leftRoundedRectangle = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, true, false, false, true, cornerRadius)
end

local rightRoundedRectangle = function(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, cornerRadius)
end

-- Setup for newly connected screens
local function setup_new_screen(s)
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons(),
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.horizontal
        }
    }
    
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons()
    }
    
    -- Create the clock widget
    local mytextclock = wibox.widget.textclock()
    local clock_widget = {
        {
            {
                {
                    widget = mytextclock,
                },
                left = 6,
                right = 6,
                top = 0,
                bottom = 0,
                widget = wibox.container.margin,
            },
            shape = roundedRectangle,
            fg = beautiful.fg_normal,
            bg = beautiful.bg_minimize,
            widget = wibox.container.background
        },
        left = 440,
        top = 5,
        bottom = 5,
        halign = "center",
        widget = wibox.container.margin,
    }
    
    -- Create a system tray container
    local systray_widget = {
        {
            {
                wibox.widget.systray(),
                left = 10,
                right = 10,
                top = 10,
                bottom = 10,
                widget = wibox.container.margin,
            },
            shape = roundedRectangle,
            fg = beautiful.fg_normal,
            bg = beautiful.bg_minimize,
            widget = wibox.container.background,
        },
        top = 5,
        bottom = 5,
        widget = wibox.container.margin
    }
    
    -- Create a layout box container
    local layoutbox_widget = {
        {
            {
                s.mylayoutbox,
                left = 10,
                right = 10,
                top = 10,
                bottom = 10,
                widget = wibox.container.margin,
            },
            shape = roundedRectangle,
            fg = beautiful.fg_normal,
            bg = beautiful.bg_minimize,
            widget = wibox.container.background,
        },
        top = 5,
        bottom = 5,
        right = 5,
        widget = wibox.container.margin,
    }
    
    -- Create the wibar
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 45 })
    
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        { -- Middle widget
            layout = wibox.layout.fixed.horizontal,
            clock_widget
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            widgets.cpu_widget,
            widgets.mem_widget,
            widgets.date_widget,
            widgets.time_widget,
            systray_widget,
            layoutbox_widget,
            spacing = 5
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

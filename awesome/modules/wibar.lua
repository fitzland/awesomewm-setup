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

-- Create a textclock widget with consistent font size
local mytextclock = wibox.widget.textclock("%a %b %d, %H:%M")
mytextclock.font = "Roboto Mono Nerd Font 10"

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
            widgets.cpu_widget,
            widgets.mem_widget,
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

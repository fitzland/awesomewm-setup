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

-- Create a separator widget like in Polybar
local function create_separator()
    return wibox.widget {
        markup = '<span foreground="' .. beautiful.fg_minimize .. '">|</span>',
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }
end

-- Setup for newly connected screens
local function setup_new_screen(s)
    -- Create a taglist widget with spacing
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
    
    -- Create system tray
    local systray = wibox.widget.systray()
    
    -- Create the wibar with polybar-like styling
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s,
        height = 32,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        border_width = 2,
        border_color = beautiful.border_normal
    })
    
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            menu.launcher,
            create_separator(),
            s.mytasklist,
        },
        { -- Center widget
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            widgets.cpu_widget,
            create_separator(),
            widgets.mem_widget,
            create_separator(),
            widgets.date_widget,
            widgets.time_widget,
            create_separator(),
            systray,
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

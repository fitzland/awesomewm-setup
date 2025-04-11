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
        end)
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

-- Setup screens
local function setup_screens()
    -- Connect to the screen signal
    screen.connect_signal("request::desktop_decoration", function(s)
        -- Create tags
        awful.tag(variables.tags, s, variables.default_layout)
        
        -- Create a taglist widget
        s.mytaglist = awful.widget.taglist {
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = taglist_buttons()
        }
        
        -- Create a tasklist widget
        s.mytasklist = awful.widget.tasklist {
            screen = s,
            filter = awful.widget.tasklist.filter.currenttags,
            buttons = tasklist_buttons()
        }
        
        -- Create the wibox
        s.mywibox = awful.wibar({ position = "top", screen = s })
        
        -- Add widgets to the wibox
        s.mywibox:setup {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                menu.launcher,
                s.mytaglist,
            },
            s.mytasklist, -- Middle widget
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                widgets.cpu_widget,
                widgets.mem_widget,
                widgets.date_widget,
                widgets.time_widget,
                widgets.systray,
            },
        }
    end)
end

-- Initialize function
local function init()
    setup_screens()
end

-- Return the module
return {
    init = init
}

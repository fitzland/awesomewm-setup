local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local widgets = require("widgets")

local M = {}

-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Taglist buttons configuration
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
                              if client.focus then
                                  client.focus:move_to_tag(t)
                              end
                          end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
                              if client.focus then
                                  client.focus:toggle_tag(t)
                              end
                          end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Tasklist buttons configuration
local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
                             if c == client.focus then
                                 c.minimized = true
                             else
                                 c:emit_signal(
                                     "request::activate",
                                     "tasklist",
                                     {raise = true}
                                 )
                             end
                         end),
    awful.button({ }, 3, function()
                             awful.menu.client_list({ theme = { width = 250 } })
                         end),
    awful.button({ }, 4, function ()
                             awful.client.focus.byidx(1)
                         end),
    awful.button({ }, 5, function ()
                             awful.client.focus.byidx(-1)
                         end))

-- Function to create a focused-only tasklist
local function only_focused_clients(c, screen)
    return c == client.focus
end

-- Create tags for a screen
function M.create_tags(s)
    -- Create tags 1-12
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }, s, awful.layout.layouts[1])
    
    -- Apply specific layouts to tags if layouts module is available
    if layouts and layouts.set_layouts_per_tag then
        layouts.set_layouts_per_tag(s)
    end
end

-- Setup function that will be called for each screen
function M.setup_wibar(s, mylauncher)
    -- Create tags for this screen
    M.create_tags(s)
    
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    
    -- Create an imagebox widget which will contain an icon indicating which layout we're using
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        layout = {
            spacing = 12,
            layout = wibox.layout.fixed.horizontal
        },
        buttons = taglist_buttons
    }

    -- Create a tasklist widget (only show focused client)
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = only_focused_clients,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            widgets.cpu_widget,
            widgets.mem_widget,
            widgets.fs_widget,
            widgets.net_widget,
            widgets.vol_widget,
            widgets.date_time_widget,
            wibox.widget.systray(),
            s.mylayoutbox,
        },
    }
end

return M

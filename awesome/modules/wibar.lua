local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local widgets = require("widgets")

-- Explicitly require the layouts module to avoid the error
local layouts = require("modules.layouts")

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

-- Filter function to only show occupied or selected tags
local function filter_occupied_or_selected(t)
    return #t:clients() > 0 or t.selected
end

-- Create tags for a screen
function M.create_tags(s)
    -- Create tags 1-12
    local tags = awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }, s, awful.layout.layouts[1])
    
    -- Apply specific layouts to tags if layouts module is available
    if layouts and layouts.set_layouts_per_tag then
        layouts.set_layouts_per_tag(s)
    end
    
    return tags
end

-- Setup function that will be called for each screen
function M.setup_wibar(s, mylauncher, layouts_module)
    -- Create tags for this screen
    M.create_tags(s, awful.layout.layouts[1])
    
    -- Apply specific layouts to tags if layouts module is provided
    if layouts_module and layouts_module.set_layouts_per_tag then
        layouts_module.set_layouts_per_tag(s)
    end
    
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    
    -- Create an imagebox widget which will contain an icon indicating which layout we're using
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    
    -- Create a taglist widget that only shows occupied or selected tags
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = filter_occupied_or_selected,  -- Only show occupied or selected tags
        style   = {
            shape = gears.shape.rounded_rect,
            bg_focus = beautiful.bg_focus,
            fg_focus = beautiful.fg_focus,
            bg_occupied = beautiful.bg_minimize,
            fg_occupied = beautiful.fg_normal,
        },
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    id     = 'text_role',
                    widget = wibox.widget.textbox,
                },
                margins = 6,
                widget  = wibox.container.margin
            },
            id     = 'background_role',
            shape  = gears.shape.rounded_rect,
            widget = wibox.container.background,
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

    -- Add widgets to the wibox with taglist in the middle
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mypromptbox,
        },
        { -- Middle widget - taglist centered
            {
                s.mytaglist,
                halign = "center",
                widget = wibox.container.place
            },
            layout = wibox.layout.fixed.horizontal
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytasklist,
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
    
    -- Connect signals to update taglist when clients change
    client.connect_signal("manage", function(c)
        s.mytaglist:emit_signal("widget::redraw_needed")
    end)
    
    client.connect_signal("unmanage", function(c)
        s.mytaglist:emit_signal("widget::redraw_needed")
    end)
    
    client.connect_signal("property::screen", function(c)
        s.mytaglist:emit_signal("widget::redraw_needed")
    end)
    
    client.connect_signal("tagged", function(c)
        s.mytaglist:emit_signal("widget::redraw_needed")
    end)
    
    client.connect_signal("untagged", function(c)
        s.mytaglist:emit_signal("widget::redraw_needed")
    end)
end

return M

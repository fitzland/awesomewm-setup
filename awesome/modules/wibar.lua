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
    -- Create styled taglist widget (center module in Polybar)
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons(),
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    id = 'text_role',
                    widget = wibox.widget.textbox,
                },
                margins = 4,
                widget = wibox.container.margin,
            },
            id = 'background_role',
            widget = wibox.container.background,
            -- Add underline for active workspace
            create_callback = function(self, tag, index, _)
                if tag.selected then
                    self.bg = beautiful.bg_focus
                    self:get_children_by_id('text_role')[1].markup = 
                        '<span foreground="' .. beautiful.fg_focus .. '">' .. tag.name .. '</span>'
                    self.shape = function(cr, w, h)
                        gears.shape.rounded_rect(cr, w, h, 4)
                    end
                end
            end,
            update_callback = function(self, tag, index, _)
                if tag.selected then
                    self.bg = beautiful.bg_focus
                    self:get_children_by_id('text_role')[1].markup = 
                        '<span foreground="' .. beautiful.fg_focus .. '">' .. tag.name .. '</span>'
                    self.shape = function(cr, w, h)
                        gears.shape.rounded_rect(cr, w, h, 4)
                    end
                else
                    self.bg = nil
                    if #tag:clients() > 0 then
                        self:get_children_by_id('text_role')[1].markup = 
                            '<span foreground="' .. beautiful.fg_normal .. '">' .. tag.name .. '</span>'
                    else
                        self:get_children_by_id('text_role')[1].markup = 
                            '<span foreground="' .. beautiful.fg_minimize .. '">' .. tag.name .. '</span>'
                    end
                    self.shape = nil
                end
            end
        },
    }
    
    -- Create a simple tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons(),
        widget_template = {
            {
                {
                    {
                        {
                            id = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget = wibox.container.margin,
                    },
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = 2,
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
    }
    
    -- Create system tray
    local systray = wibox.widget.systray()
    systray.base_size = 16
    
    -- Create clock widget with Polybar styling
    local clock_widget = wibox.widget {
        {
            markup = '<span foreground="' .. beautiful.bg_focus .. '">   </span>',
            widget = wibox.widget.textbox,
        },
        {
            format = '%H:%M',
            widget = wibox.widget.textclock,
            fg = beautiful.bg_focus
        },
        layout = wibox.layout.fixed.horizontal
    }
    
    -- Create a custom arch icon widget (like in polybar)
    local arch_widget = wibox.widget {
        markup = '<span foreground="' .. beautiful.bg_focus .. '">󰣇</span>',
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    }
    arch_widget:buttons(gears.table.join(
        awful.button({}, 1, function() 
            awful.util.spawn("rofi -show drun")
        end)
    ))
    
    -- Create the wibar with polybar-like styling
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s,
        height = 32,
        bg = beautiful.bg_normal,
        fg = beautiful.fg_normal,
        border_width = 2,
        border_color = beautiful.border_normal,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 8)
        },
        width = "99%",
        x = 10,
        y = 10
    })
    
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            arch_widget,
            create_separator(),
            clock_widget,
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
    
    print("Polybar-style wibar set up on screen " .. s.index)
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

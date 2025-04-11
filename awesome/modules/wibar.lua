-- Setup for newly connected screens (WITHOUT tag creation)
local function setup_new_screen(s)
    -- Create a styled taglist widget
    local mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons(),
        style = {
            shape = gears.shape.rounded_rect,
        },
        layout = {
            spacing = 8,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    margins = 6,
                    widget = wibox.container.margin,
                },
                id = 'background_role',
                widget = wibox.container.background,
            },
            shape = gears.shape.rounded_rect,
            widget = wibox.container.background,
        },
    }
    
    -- Create a tasklist widget with icons and text
    local mytasklist = awful.widget.tasklist {
        screen = s,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons(),
        style = {
            shape = gears.shape.rounded_rect,
        },
        layout = {
            spacing = 10,
            layout = wibox.layout.fixed.horizontal
        },
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
                margins = 4,
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
    }
    
    -- Separator widget
    local separator = wibox.widget {
        {
            forced_width = 2,
            shape = gears.shape.rounded_bar,
            widget = wibox.widget.separator,
            color = beautiful.fg_normal .. "33", -- semi-transparent
        },
        left = 10,
        right = 10,
        widget = wibox.container.margin
    }
    
    -- Create the wibox with explicit settings
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s,
        height = 32, -- slightly taller
        bg = beautiful.bg_normal,
        shape = function(cr, width, height)
            gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, 8)
        end
    })
    
    -- Add widgets to the wibox - simplified approach
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            menu.launcher,
            mytaglist,
            separator,
            s.mypromptbox or wibox.widget.textbox(""),
        },
        mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            widgets.cpu_widget,
            separator,
            widgets.mem_widget,
            separator,
            widgets.date_widget,
            widgets.time_widget,
            separator,
            wibox.widget.systray(),
        },
    }
    
    -- Store the widgets for later access
    s.mytaglist = mytaglist
    s.mytasklist = mytasklist
    
    print("Wibar set up on screen " .. s.index)
end

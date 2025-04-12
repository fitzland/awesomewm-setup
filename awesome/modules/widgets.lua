-- Function to update window title
local function update_window_title(c)
    local title_widget = widgets.window_title:get_children_by_id("title_role")[1]
    if c and c.valid then
        title_widget:set_text(c.name or "")
    else
        title_widget:set_text("Desktop")
    end
end-- modules/widgets.lua

-- Load required libraries
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local variables = require("modules.variables")

-- Try to load vicious with error handling
local vicious, vicious_error
local status, err = pcall(function() 
    vicious = require("vicious") 
end)
if not status then
    vicious_error = err
    print("Error loading vicious: " .. tostring(err))
end

-- Create widget table
local widgets = {}

-- Create basic widgets
widgets.cpu_widget = wibox.widget.textbox(" CPU: ? ")
widgets.mem_widget = wibox.widget.textbox(" RAM: ? ")
widgets.date_widget = wibox.widget.textclock(" %a %b %-d ", 60)
widgets.time_widget = wibox.widget.textclock("%l:%M %p ", 1)
widgets.systray = wibox.widget.systray()

-- Volume widget with icon and text
widgets.volume_widget = wibox.widget {
    {
        {
            id = "volume_icon",
            text = "󰕾",
            font = beautiful.font,
            widget = wibox.widget.textbox,
        },
        {
            id = "volume_text",
            text = " Vol: ? ",
            font = beautiful.font,
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
    },
    bg = beautiful.bg_minimize .. "40",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
    end,
    widget = wibox.container.background,
}

-- Bluetooth widget with icon
widgets.bluetooth_widget = wibox.widget {
    {
        {
            id = "bluetooth_icon",
            text = "󰂲",
            font = beautiful.font,
            widget = wibox.widget.textbox,
        },
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_minimize .. "40",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
    end,
    widget = wibox.container.background,
}

-- Window title widget
widgets.window_title = wibox.widget {
    {
        {
            id = "title_role",
            text = "",
            align = "center",
            font = beautiful.font,
            widget = wibox.widget.textbox,
        },
        left = 8,
        right = 8,
        widget = wibox.container.margin,
    },
    bg = beautiful.bg_minimize .. "40",
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 8)
    end,
    widget = wibox.container.background,
}

-- Helper function for rounded widgets
local function rounded_shape(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 8)
end

-- Clock widget with GitHub theme
widgets.clock_widget = wibox.widget {
    {
        {
            format = "%I:%M %a %d",
            font = beautiful.font,
            fg = beautiful.gh_bg,
            widget = wibox.widget.textclock,
        },
        left = 8,
        right = 8,
        top = 4,
        bottom = 4,
        widget = wibox.container.margin
    },
    bg = beautiful.gh_caret,
    fg = beautiful.gh_bg,
    shape = rounded_shape,
    widget = wibox.container.background
}

-- Layoutbox widget
function widgets.create_layoutbox(s)
    local layoutbox = awful.widget.layoutbox(s)
    
    -- Add buttons to change layout
    layoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)
    ))
    
    -- Create container with rounded styling
    local layoutbox_container = wibox.widget {
        {
            layoutbox,
            left = 8,
            right = 8,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        bg = beautiful.bg_minimize .. "40",
        shape = rounded_shape,
        widget = wibox.container.background
    }
    
    return layoutbox_container
end

-- Taglist widget
function widgets.create_taglist(s)
    return awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
        ),
        style = {
            shape = rounded_shape
        },
        layout = {
            spacing = 3,
            layout = wibox.layout.fixed.horizontal
        },
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        font = beautiful.font,
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left = 8,
                right = 8,
                top = 4,
                bottom = 4,
                widget = wibox.container.margin
            },
            id = 'background_role',
            shape = rounded_shape,
            widget = wibox.container.background,
        },
    }
end

-- Function to update volume widget
local function update_volume()
    awful.spawn.easy_async_with_shell(
        "pamixer --get-volume-human 2>/dev/null || amixer get Master | grep -o '[0-9]\\+%\\|\\[on\\]\\|\\[off\\]' | tr '\\n' ' ' | awk '{print $1, $2}'",
        function(stdout)
            local volume = stdout:gsub("%%", ""):gsub("\n", "")
            local level = tonumber(volume:match("%d+")) or 0
            local icon_widget = widgets.volume_widget:get_children_by_id("volume_icon")[1]
            local text_widget = widgets.volume_widget:get_children_by_id("volume_text")[1]
            
            local icon = "󰕾"  -- Default volume icon
            
            if volume:find("off") or volume:find("muted") then
                icon = "󰖁"   -- Muted icon
                level = 0
            elseif level < 30 then
                icon = "󰕿"   -- Low volume icon
            elseif level < 70 then
                icon = "󰖀"   -- Medium volume icon
            end
            
            icon_widget:set_markup('<span foreground="' .. beautiful.gh_cyan .. '">' .. icon .. '</span>')
            text_widget:set_text(" " .. level .. "% ")
        end
    )
end

-- Function to update bluetooth widget
local function update_bluetooth()
    awful.spawn.easy_async_with_shell(
        "bluetoothctl show 2>/dev/null | grep 'Powered:' | awk '{print $2}' || echo 'no'",
        function(stdout)
            local powered = stdout:gsub("%s+", "")
            local icon_widget = widgets.bluetooth_widget:get_children_by_id("bluetooth_icon")[1]
            
            local icon = "󰂲"
            local color = beautiful.gh_comment
            
            if powered == "yes" then
                -- Further check if it's connected
                awful.spawn.easy_async_with_shell(
                    "bluetoothctl info 2>/dev/null | grep 'Connected:' | awk '{print $2}' || echo 'no'",
                    function(stdout2)
                        local connected = stdout2:gsub("%s+", "")
                        
                        if connected == "yes" then
                            icon = ""
                            color = beautiful.gh_blue
                        end
                        
                        icon_widget:set_markup('<span foreground="' .. color .. '">' .. icon .. '</span>')
                    end
                )
            else
                icon_widget:set_markup('<span foreground="' .. color .. '">' .. icon .. '</span>')
            end
        end
    )
end

-- Function to initialize any widgets that need special setup
function widgets.init()
    -- Set up volume widget buttons
    widgets.volume_widget:buttons(gears.table.join(
        awful.button({ }, 4, function() awful.spawn.with_shell("pamixer -i 5 || amixer -q set Master 5%+") end),
        awful.button({ }, 5, function() awful.spawn.with_shell("pamixer -d 5 || amixer -q set Master 5%-") end),
        awful.button({ }, 3, function() awful.spawn.with_shell("pamixer -t || amixer -q set Master toggle") end)
    ))
    
    -- Set up bluetooth widget buttons
    widgets.bluetooth_widget:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.spawn.with_shell("bluetoothctl power on") end),
        awful.button({ }, 3, function() awful.spawn.with_shell("bluetoothctl power off") end)
    ))
    
    -- Connect window title signals
    client.connect_signal("focus", function(c)
        update_window_title(c)
    end)
    
    client.connect_signal("unfocus", function(c)
        update_window_title(nil)
    end)
    
    -- Initialize window title
    update_window_title(nil)
    
    -- Start update timers
    gears.timer {
        timeout = 1,
        call_now = true,
        autostart = true,
        callback = update_volume
    }
    
    gears.timer {
        timeout = 5,
        call_now = true,
        autostart = true,
        callback = update_bluetooth
    }
    
    -- Only register with vicious if it loaded successfully
    if vicious and not vicious_error then
        pcall(function()
            vicious.register(widgets.cpu_widget, vicious.widgets.cpu, " CPU: $1% ", 2)
            vicious.register(widgets.mem_widget, vicious.widgets.mem, " RAM: $1% ", 15)
        end)
    end
end

return widgets

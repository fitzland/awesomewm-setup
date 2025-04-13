-- modules/control_center.lua
-- A simplified version without rubato animations

-- Load required libraries
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

-- Create control_center table
local control_center = {}

-- Control center configuration
local config = {
    width = 420,
    height = 580,
    expanded_height = 715,
    bg = beautiful.bg_normal or "#000000",
    opacity = "E6", -- 90% opacity (in hex)
    corner_radius = beautiful.border_radius or 12
}

-- Helper functions
local helpers = {}

-- Rounded rectangle helper
function helpers.rrect(radius)
    radius = radius or config.corner_radius
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

-- Colorize text helper
function helpers.colorize_text(text, color)
    return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

-- Service button factory
local function create_service_button(args)
    local name = args.name or "Service"
    local icon = args.icon or ""
    local on_cmd = args.on_cmd
    local off_cmd = args.off_cmd
    local check_cmd = args.check_cmd
    local initial_state = args.initial_state or false

    -- Button state
    local state = initial_state

    -- Create widgets
    local icon_widget = wibox.widget{
        font = beautiful.font_var or "sans 18",
        markup = helpers.colorize_text(icon, beautiful.fg_normal),
        widget = wibox.widget.textbox,
        valign = "center",
        align = "center"
    }

    local name_widget = wibox.widget{
        font = beautiful.font_var or "sans 12",
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text(name, beautiful.fg_normal),
        valign = "center",
        align = "center"
    }

    -- Background for the active state
    local bg_widget = wibox.widget{
        widget = wibox.container.background,
        shape = helpers.rrect(),
        bg = beautiful.accent or beautiful.fg_focus or "#1A73E8",
        forced_width = 110,
        forced_height = 110,
        opacity = state and 1 or 0
    }

    -- Update function
    local function update_appearance()
        if state then
            icon_widget.markup = helpers.colorize_text(icon, beautiful.bg_normal)
            name_widget.markup = helpers.colorize_text(name, beautiful.bg_normal)
            bg_widget.opacity = 1
        else
            icon_widget.markup = helpers.colorize_text(icon, beautiful.fg_normal)
            name_widget.markup = helpers.colorize_text(name, beautiful.fg_normal)
            bg_widget.opacity = 0
        end
    end

    -- Create the button widget
    local button = wibox.widget{
        {
            bg_widget,
            {
                nil,
                {
                    icon_widget,
                    name_widget,
                    layout = wibox.layout.fixed.vertical,
                    spacing = 10
                },
                layout = wibox.layout.align.vertical,
                expand = "none"
            },
            layout = wibox.layout.stack
        },
        shape = helpers.rrect(),
        widget = wibox.container.background,
        border_color = beautiful.border_focus .. "33" or "#FFFFFF33",
        forced_width = 110,
        forced_height = 110,
        bg = beautiful.bg_focus .. "BF" or "#3B4252BF"
    }

    -- Set initial appearance
    update_appearance()

    -- Add button functionality
    button:buttons(gears.table.join(
        awful.button({}, 1, function()
            state = not state
            update_appearance()
            
            if state then
                if on_cmd then awful.spawn.with_shell(on_cmd) end
            else
                if off_cmd then awful.spawn.with_shell(off_cmd) end
            end
        end)
    ))

    -- Check state function (can be called to update state from outside)
    function button:check_state()
        if check_cmd then
            awful.spawn.easy_async_with_shell(check_cmd, function(stdout)
                if stdout:match(args.check_pattern or "on") then
                    state = true
                else
                    state = false
                end
                update_appearance()
            end)
        end
    end

    -- Initial state check
    if check_cmd then
        button:check_state()
    end

    return button
end

-- Create slider widget
local function create_slider(args)
    local icon = args.icon or ""
    local command = args.command
    local get_cmd = args.get_cmd
    local icon_color = args.icon_color or beautiful.fg_normal
    
    -- Create widgets
    local icon_widget = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text(icon, icon_color),
        font = beautiful.font_var or "sans 17",
        align = "center",
        valign = "center"
    }

    local value_widget = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("0%", beautiful.fg_normal),
        font = beautiful.font_var or "sans 13",
        align = "center",
        valign = "center"
    }

    local slider = wibox.widget{
        widget = wibox.widget.slider,
        value = 0,
        maximum = 100,
        forced_width = 260,
        shape = gears.shape.rounded_bar,
        bar_shape = gears.shape.rounded_bar,
        bar_color = beautiful.fg_normal .. "33",
        bar_margins = {bottom = 18, top = 18},
        bar_active_color = beautiful.accent or beautiful.fg_focus or "#1A73E8",
        handle_width = 14,
        handle_shape = gears.shape.circle,
        handle_color = beautiful.accent or beautiful.fg_focus or "#1A73E8",
        handle_border_width = 3,
        handle_border_color = beautiful.bg_focus or "#3B4252"
    }

    -- Update function
    local function update_value(value)
        slider.value = value
        value_widget.markup = helpers.colorize_text(value .. "%", beautiful.fg_normal)
    end

    -- Connect signals
    slider:connect_signal("property::value", function(_, new_value)
        value_widget.markup = helpers.colorize_text(new_value .. "%", beautiful.fg_normal)
        if command then
            awful.spawn.with_shell(string.format(command, new_value))
        end
    end)

    -- Get current value
    if get_cmd then
        awful.spawn.easy_async_with_shell(get_cmd, function(stdout)
            local value = tonumber(stdout:match("%d+")) or 0
            update_value(value)
        end)
    end

    -- Create the slider widget
    local slider_widget = wibox.widget{
        icon_widget,
        slider,
        value_widget,
        layout = wibox.layout.fixed.horizontal,
        forced_height = 42,
        spacing = 17
    }

    return slider_widget
end

-- Profile section
local function create_profile_section()
    -- Get user info from system
    local username = os.getenv("USER") or "User"
    local hostname = io.popen("hostname"):read("*l") or "Awesome"
    
    -- Profile image
    local profile_image = wibox.widget {
        {
            image = beautiful.profile_image or "/usr/share/icons/Adwaita/scalable/emotes/face-cool-symbolic.svg",
            resize = true,
            clip_shape = gears.shape.circle,
            widget = wibox.widget.imagebox
        },
        widget = wibox.container.background,
        border_width = 1,
        forced_width = 75,
        forced_height = 75,
        shape = gears.shape.circle,
        border_color = beautiful.fg_normal
    }

    -- Username
    local username_widget = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text(username, beautiful.fg_normal),
        font = beautiful.font_var or "sans medium 13",
        align = "left",
        valign = "center"
    }

    -- Hostname/description
    local hostname_widget = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text(hostname, beautiful.fg_normal .. "99"),
        font = beautiful.font_var or "sans 11",
        align = "left",
        valign = "center"
    }

    -- Return the complete profile section
    return wibox.widget{
        profile_image,
        {
            nil,
            {
                username_widget,
                hostname_widget,
                layout = wibox.layout.fixed.vertical,
                spacing = 2
            },
            layout = wibox.layout.align.vertical,
            expand = "none"
        },
        layout = wibox.layout.fixed.horizontal,
        spacing = 15
    }
end

-- Session control buttons
local function create_session_controls()
    -- Lock button
    local lock_button = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("", beautiful.fg_normal),
        font = beautiful.font_var or "sans 14",
        align = "center",
        valign = "center"
    }

    -- Power button
    local power_button = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("", beautiful.fg_normal),
        font = beautiful.font_var or "sans 14",
        align = "center",
        valign = "center"
    }

    -- Button container helper
    local function create_button_container(widget)
        return wibox.widget {
            {
                widget,
                margins = 10,
                widget = wibox.container.margin
            },
            bg = beautiful.bg_focus .. "B3" or "#3B4252B3",
            shape = helpers.rrect(),
            border_width = 1,
            border_color = beautiful.fg_normal .. "33",
            widget = wibox.container.background
        }
    end

    -- Create button containers
    local lock_container = create_button_container(lock_button)
    local power_container = create_button_container(power_button)

    -- Add functionality
    lock_container:buttons(gears.table.join(
        awful.button({}, 1, function()
            -- Close control center
            control_center.toggle()
            -- Lock screen (replace with your preferred lock command)
            awful.spawn.with_shell("loginctl lock-session")
        end)
    ))

    power_container:buttons(gears.table.join(
        awful.button({}, 1, function()
            -- Close control center
            control_center.toggle()
            -- Show power menu (replace with your preferred power menu)
            awful.spawn.with_shell("rofi -show power-menu -modi power-menu:~/.local/bin/rofi-power-menu || rofi -show powermenu -modi powermenu:~/.config/rofi/scripts/powermenu.sh")
        end)
    ))

    -- Return the session controls widget
    return wibox.widget {
        nil,
        {
            {
                lock_container,
                power_container,
                layout = wibox.layout.fixed.horizontal,
                spacing = 10
            },
            layout = wibox.layout.fixed.vertical
        },
        layout = wibox.layout.align.vertical,
        expand = "none"
    }
end

-- Create the music player widget
local function create_music_player()
    -- Album art
    local album_art = wibox.widget{
        widget = wibox.widget.imagebox,
        clip_shape = helpers.rrect(),
        forced_height = 85,
        forced_width = 85,
        image = beautiful.album_art or "/usr/share/icons/Adwaita/scalable/devices/multimedia-player-symbolic.svg",
        border_color = beautiful.fg_normal .. "33",
        border_width = 1
    }

    -- Song artist
    local song_artist = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("Unknown", beautiful.fg_normal),
        font = beautiful.font_var or "sans 11",
        align = "left",
        valign = "center"
    }

    -- Song name
    local song_name = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("Not playing", beautiful.fg_normal),
        font = beautiful.font_var or "sans bold 12",
        align = "left",
        valign = "center"
    }

    -- Control buttons
    local toggle_button = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("", beautiful.fg_normal),
        font = beautiful.font_var or "sans 22",
        align = "right",
        valign = "center"
    }

    local next_button = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("", beautiful.fg_normal),
        font = beautiful.font_var or "sans 18",
        align = "right",
        valign = "center"
    }

    local prev_button = wibox.widget{
        widget = wibox.widget.textbox,
        markup = helpers.colorize_text("", beautiful.fg_normal),
        font = beautiful.font_var or "sans 18",
        align = "right",
        valign = "center"
    }

    -- Add button functionality
    toggle_button:buttons(gears.table.join(
        awful.button({}, 1, function() 
            awful.spawn.with_shell("playerctl play-pause")
        end)
    ))

    next_button:buttons(gears.table.join(
        awful.button({}, 1, function() 
            awful.spawn.with_shell("playerctl next")
        end)
    ))

    prev_button:buttons(gears.table.join(
        awful.button({}, 1, function() 
            awful.spawn.with_shell("playerctl previous")
        end)
    ))

    -- Update widgets based on player status
    local update_player_info = function()
        awful.spawn.easy_async_with_shell(
            "playerctl metadata --format '{{artist}}|{{title}}|{{status}}' 2>/dev/null || echo 'Unknown|Not playing|Stopped'",
            function(stdout)
                local artist, title, status = stdout:match("(.+)|(.+)|(.+)")
                
                if artist and title and artist ~= "Unknown" and title ~= "Not playing" then
                    song_artist:set_markup_silently(helpers.colorize_text(artist, beautiful.fg_normal))
                    song_name:set_markup_silently(helpers.colorize_text(title, beautiful.fg_normal))
                else
                    song_artist:set_markup_silently(helpers.colorize_text("Unknown", beautiful.fg_normal))
                    song_name:set_markup_silently(helpers.colorize_text("Not playing", beautiful.fg_normal))
                end
                
                if status and status:match("Playing") then
                    toggle_button.markup = helpers.colorize_text("", beautiful.fg_normal)
                else
                    toggle_button.markup = helpers.colorize_text("", beautiful.fg_normal)
                end
            end
        )
        
        -- Also try to get album art (simplified)
        awful.spawn.easy_async_with_shell(
            "playerctl metadata mpris:artUrl 2>/dev/null",
            function(stdout)
                local art_url = stdout:gsub("%s+", "")
                if art_url ~= "" then
                    -- If URL is a file path, use it directly
                    if art_url:match("^file://") then
                        local file_path = art_url:gsub("file://", "")
                        album_art:set_image(gears.surface.load_uncached(file_path))
                    end
                else
                    album_art:set_image(beautiful.album_art or "/usr/share/icons/Adwaita/scalable/devices/multimedia-player-symbolic.svg")
                end
            end
        )
    end

    -- Set up timer to update player info
    gears.timer {
        timeout = 2,
        call_now = true,
        autostart = true,
        callback = update_player_info
    }

    -- Create and return the music player widget
    return wibox.widget {
        {
            {
                album_art,
                {
                    {
                        nil,
                        {
                            song_name,
                            song_artist,
                            spacing = 5,
                            layout = wibox.layout.fixed.vertical,
                        },
                        layout = wibox.layout.align.vertical,
                        expand = "none"
                    },
                    {
                        prev_button,
                        toggle_button,
                        next_button,
                        layout = wibox.layout.fixed.horizontal,
                        spacing = 6
                    },
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 10
                },
                layout = wibox.layout.fixed.horizontal,
                spacing = 10
            },
            margins = 12,
            widget = wibox.container.margin
        },
        widget = wibox.container.background,
        forced_height = 110,
        bg = beautiful.bg_focus .. "99" or "#3B425299",
        border_color = beautiful.fg_normal .. "33",
        shape = helpers.rrect()
    }
end

-- Create the status bar
local function create_statusbar()
    -- Battery widget
    local bat_icon = wibox.widget{
        markup = helpers.colorize_text("", beautiful.green or "#26A65B"),
        font = beautiful.font_var or "sans 11",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local battery_progress = wibox.widget{
        color = beautiful.green or "#26A65B",
        background_color = "#00000000",
        forced_width = 30,
        border_width = 1,
        border_color = beautiful.fg_normal .. "A6",
        paddings = 2,
        bar_shape = helpers.rrect(2),
        shape = helpers.rrect(5),
        value = 70,
        max_value = 100,
        widget = wibox.widget.progressbar,
    }

    local bat_txt = wibox.widget{
        widget = wibox.widget.textbox,
        markup = "100%",
        font = beautiful.font_var or "sans medium 11",
        valign = "center",
        align = "center"
    }

    -- Update battery status
    local function update_battery()
        awful.spawn.easy_async_with_shell(
            "acpi -b | grep -oP '[0-9]+%' | tr -d '%' || echo 100",
            function(stdout)
                local value = tonumber(stdout) or 0
                battery_progress.value = value
                bat_txt.markup = value .. "%"
                
                -- Check if charging
                awful.spawn.easy_async_with_shell(
                    "acpi -b | grep -c 'Charging' || echo 0",
                    function(stdout)
                        local charging = tonumber(stdout) > 0
                        bat_icon.visible = charging
                    end
                )
            end
        )
    end

    -- Set up battery update timer
    gears.timer {
        timeout = 60,
        call_now = true,
        autostart = true,
        callback = update_battery
    }

    -- Battery widget
    local battery = wibox.widget{
        {
            {
                bat_icon,
                battery_progress,
                layout = wibox.layout.fixed.horizontal,
                spacing = 1
            },
            widget = wibox.container.margin,
            margins = {top = 11, bottom = 11}
        },
        bat_txt,
        layout = wibox.layout.fixed.horizontal,
        spacing = 12
    }

    -- Date widget
    local clock = wibox.widget{
        widget = wibox.widget.textclock,
        format = "%a, %d %b",
        font = beautiful.font_var or "sans medium 13",
        valign = "center",
        align = "center"
    }

    -- Expand/collapse button
    local extras = wibox.widget{
        widget = wibox.widget.textbox,
        markup = "",
        font = beautiful.font_var or "sans bold 16",
        valign = "center",
        align = "center"
    }

    -- Return the status bar widget
    return wibox.widget{
        {
            {
                clock,
                layout = wibox.layout.fixed.horizontal,
                spacing = 15
            },
            extras,
            battery,
            layout = wibox.layout.align.horizontal
        },
        layout = wibox.layout.fixed.vertical,
        forced_height = 40
    }, extras
end

-- Set up the control center
function control_center.init()
    -- State variables
    local state = {
        visible = false,
        expanded = false
    }

    -- Create wibox for each screen
    awful.screen.connect_for_each_screen(function(s)
        -- Create sliders
        local brightness_slider = create_slider({
            icon = "",
            command = "brightnessctl set %d%% || light -S %d",
            get_cmd = "brightnessctl get | grep -o '[0-9]\\+%' | tr -d '%' || echo 50",
            icon_color = beautiful.yellow or beautiful.fg_normal
        })

        local volume_slider = create_slider({
            icon = "",
            command = "pamixer --set-volume %d || amixer -D pulse set Master %d%%",
            get_cmd = "pamixer --get-volume || amixer -D pulse get Master | grep -o '[0-9]\\+%' | tr -d '%' | head -1 || echo 50",
            icon_color = beautiful.blue or beautiful.fg_normal
        })

        -- Create service buttons
        local wifi_button = create_service_button({
            name = "Wi-Fi",
            icon = "",
            on_cmd = "nmcli radio wifi on",
            off_cmd = "nmcli radio wifi off",
            check_cmd = "nmcli radio wifi | grep -q 'enabled' && echo 'on' || echo 'off'",
            check_pattern = "on"
        })

        local bluetooth_button = create_service_button({
            name = "Bluetooth",
            icon = "",
            on_cmd = "bluetoothctl power on",
            off_cmd = "bluetoothctl power off",
            check_cmd = "bluetoothctl show | grep 'Powered' | awk '{print $2}'",
            check_pattern = "yes"
        })

        local dnd_button = create_service_button({
            name = "Do Not Disturb",
            icon = "",
            on_cmd = "mkdir -p ~/.config/awesome/dnd && touch ~/.config/awesome/dnd/enabled",
            off_cmd = "rm -f ~/.config/awesome/dnd/enabled",
            check_cmd = "test -f ~/.config/awesome/dnd/enabled && echo 'on' || echo 'off'",
            check_pattern = "on"
        })

        local dark_button = create_service_button({
            name = "Dark Mode",
            icon = "",
            -- Replace these with commands that actually switch your theme
            on_cmd = "touch ~/.config/awesome/dark_mode && echo 'Switched to dark mode'",
            off_cmd = "rm -f ~/.config/awesome/dark_mode && echo 'Switched to light mode'",
            check_cmd = "test -f ~/.config/awesome/dark_mode && echo 'on' || echo 'off'",
            check_pattern = "on"
        })

        local redshift_button = create_service_button({
            name = "Night Light",
            icon = "",
            on_cmd = "redshift -l 0:0 -t 4500:4500 -r &>/dev/null &",
            off_cmd = "redshift -x && pkill redshift && killall redshift",
            check_cmd = "pgrep redshift >/dev/null && echo 'on' || echo 'off'",
            check_pattern = "on"
        })

        local mic_button = create_service_button({
            name = "Microphone",
            icon = "",
            on_cmd = "amixer -D pulse set Capture cap",
            off_cmd = "amixer -D pulse set Capture nocap",
            check_cmd = "amixer -D pulse get Capture | grep -q '\\[on\\]' && echo 'on' || echo 'off'",
            check_pattern = "on"
        })

        -- Create primary services row
        local primary_services = wibox.widget{
            wifi_button,
            bluetooth_button,
            dark_button,
            layout = wibox.layout.fixed.horizontal,
            spacing = 22
        }

        -- Create extra services row
        local extra_services = wibox.widget{
            redshift_button,
            dnd_button,
            mic_button,
            layout = wibox.layout.fixed.horizontal,
            spacing = 22,
            visible = state.expanded
        }

        -- Create services section
        local services = wibox.widget{
            primary_services,
            extra_services,
            spacing = state.expanded and 22 or 0,
            layout = wibox.layout.fixed.vertical
        }

        -- Create sliders section
        local sliders = wibox.widget{
            {
                {
                    brightness_slider,
                    volume_slider,
                    spacing = 12,
                    layout = wibox.layout.fixed.vertical,
                },
                margins = {top = 12, bottom = 12, left = 18, right = 12},
                widget = wibox.container.margin
            },
            widget = wibox.container.background,
            forced_height = 120,
            bg = beautiful.bg_focus .. "99" or "#3B425299",
            border_color = beautiful.fg_normal .. "33",
            shape = helpers.rrect()
        }

        -- Create status bar
        local statusbar, extras_button = create_statusbar()

        -- Function to toggle extra services
        local function toggle_extras()
            state.expanded = not state.expanded
            extra_services.visible = state.expanded
            services.spacing = state.expanded and 22 or 0
            
            if state.expanded then
                extras_button.markup = ""
                s.control_center.height = config.expanded_height
            else
                extras_button.markup = ""
                s.control_center.height = config.height
            end
        end

        -- Add button functionality to extras button
        extras_button:buttons(gears.table.join(
            awful.button({}, 1, toggle_extras)
        ))

        -- Create the control center wibox
        s.control_center = awful.wibar({
            type = "dock",
            shape = helpers.rrect(),
            screen = s,
            width = config.width,
            height = config.height,
            bg = config.bg .. config.opacity,
            ontop = true,
            visible = false
        })

        -- Set up the layout
        s.control_center:setup {
            {
                {
                    {
                        create_profile_section(),
                        nil,
                        create_session_controls(),
                        layout = wibox.layout.align.horizontal
                    },
                    sliders,
                    create_music_player(),
                    services,
                    layout = wibox.layout.fixed.vertical,
                    spacing = 24
                },
                widget = wibox.container.margin,
                margins = 20
            },
            {
                statusbar,
                margins = {left = 20, right = 20, bottom = 0},
                widget = wibox.container.margin,
            },
            layout = wibox.layout.fixed.vertical,
        }

        -- Position the control center initially (will be updated on toggle)
        s.control_center.x = s.geometry.x + (beautiful.useless_gap or 0) * 4
        s.control_center.y = s.geometry.height - (s.control_center.height + (beautiful.useless_gap or 0) * 2)
    end)

    -- Toggle function
    control_center.toggle = function(screen)
        -- Get the current screen or use the provided one
        local s = screen or awful.screen.focused()
        
        -- Position the control center
        s.control_center.x = s.geometry.x + (beautiful.useless_gap or 0) * 4
        s.control_center.y = s.geometry.height - (s.control_center.height + (beautiful.useless_gap or 0) * 2)
        
        -- Toggle visibility
        s.control_center.visible = not s.control_center.visible
        state.visible = s.control_center.visible
    end
end

return control_center

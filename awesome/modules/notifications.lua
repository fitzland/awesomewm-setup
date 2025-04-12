-- modules/notifications.lua
-- Complete solution to disable naughty notifications and start Dunst

local naughty = require("naughty")
local awful = require("awful")
local gears = require("gears")
local notifications = {}

function notifications.init()
    -- Save critical notification functionality before completely disabling naughty
    local notify_critical = function(args)
        -- Create a minimal version of naughty.notify that only shows critical errors
        -- This won't interfere with Dunst for regular notifications
        local preset = naughty.config.presets.critical or {
            bg = "#900000",
            fg = "#ffffff",
            timeout = 0,
            border_width = 2,
            border_color = "#ff0000"
        }
        
        -- Actually display the notification using the original naughty system
        return awful.spawn.with_line_callback(
            string.format(
                "notify-send -u critical 'AwesomeWM Error' '%s'",
                args.text:gsub("'", "'\\''") -- Escape single quotes
            ),
            {}
        )
    end
    
    -- Replace naughty.notify with our custom function that only processes critical errors
    naughty.notify = function(args)
        if args and args.preset == naughty.config.presets.critical then
            return notify_critical(args)
        end
        -- Silently drop non-critical notifications
        return nil
    end
    
    -- Completely disable notification display for newer awesome versions
    if naughty.connect_signal then
        naughty.connect_signal("request::display", function(n)
            -- Ignore ALL notifications - critical ones are handled by our custom function
            n.ignore = true
        end)
    end
    
    -- For older versions, override default notifications settings to effectively disable them
    naughty.config.defaults.timeout = 0
    naughty.config.defaults.screen = nil
    naughty.config.defaults.position = "top_right"
    naughty.config.defaults.height = 0
    naughty.config.defaults.width = 0
    naughty.config.defaults.opacity = 0
    
    -- Kill any existing dunst instances
    awful.spawn.with_shell("killall dunst || true")
    
    -- Start dunst with the custom config
    gears.timer {
        timeout = 1,
        autostart = true,
        single_shot = true,
        callback = function()
            awful.spawn.with_shell("dunst -config ~/.config/awesome/dunst/dunstrc")
            print("Dunst started with custom configuration")
        end
    }
    
    -- Wait a moment to ensure any startup notifications are finished
    awful.spawn.with_shell("sleep 0.5 && killall -q awesome-notification-daemon || true")
    
    print("Naughty notification system disabled, error handling preserved, Dunst will handle all notifications")
end

return notifications

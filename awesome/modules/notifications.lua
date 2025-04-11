-- modules/notifications.lua
-- Use Naughty only for AwesomeWM errors, Dunst for everything else

local naughty = require("naughty")

local notifications = {}

function notifications.init()
    -- Set Naughty defaults for AwesomeWM internal errors
    naughty.config.defaults.timeout  = 0
    naughty.config.defaults.position = "top_right"
    naughty.config.defaults.ontop    = true

    -- Only display notifications that come from Awesome itself
    awesome.connect_signal("debug::error", function(err)
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Oops, an error happened!",
            text   = tostring(err),
        })
    end)

    -- Block all other notifications unless app_name == "awesome"
    naughty.connect_signal("request::display", function(n)
        if n.app_name == "awesome" or n.title == "Oops, an error happened!" then
            naughty.layout.box { notification = n }
        end
        -- Dunst will handle the rest via D-Bus
    end)
end

return notifications


-- modules/signals.lua
-- Signal handling for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local variables = require("modules.variables")

local signals = {}

-- Function to set up client signals
local function setup_client_signals()

    -- Enhanced window debugging to show screen/tag assignment
    client.connect_signal("manage", function(c)
    -- Short delay to allow rules to be applied first
        gears.timer.start_new(0.1, function()
            local screen_index = c.screen and c.screen.index or "unknown"
            local current_tag = "none"
            
            -- Get the current tag name if available
            if c.first_tag then
                current_tag = c.first_tag.name or c.first_tag.index or "unknown"
            end
            
            -- Find which rule matched this client (if any)
            local matched_rule = "No matching rule found"
            for i, rule in ipairs(awful.rules.rules) do
                local rule_class = rule.rule and rule.rule.class or nil
                local rule_any_class = rule.rule_any and rule.rule_any.class or nil
                
                -- Check if this rule matched the client
                if (rule_class and c.class and c.class:match(rule_class)) or
                (rule_any_class and c.class and table.concat(rule_any_class, " "):match(c.class)) then
                    local tag_prop = rule.properties and rule.properties.tag or "default"
                    local screen_prop = rule.properties and rule.properties.screen or "default"
                    matched_rule = string.format("Rule #%d - Target: screen %s, tag %s", 
                                            i, tostring(screen_prop), tostring(tag_prop))
                    break
                end
            end
            
            naughty.notify({ 
                title = "Window Placement Debug",
                text = string.format(
                    "Class: %s\nName: %s\nActual placement: Screen %s, Tag %s\n%s",
                    c.class or "unknown",
                    c.name or "unknown",
                    screen_index,
                    current_tag,
                    matched_rule
                ),
                timeout = 20
            })
            
            return false -- Don't repeat the timer
        end)
    end)

--[[
    -- Signal function to execute when a new client appears
    -- Show a notification with window details
    -- This is useful for debugging or understanding the window properties
    client.connect_signal("manage", function(c)
        naughty.notify({ 
            title = "Window Details",
            text = string.format(
                "Class: %s\nName: %s\nType: %s\nInstance: %s\nRole: %s",
                c.class or "unknown",
                c.name or "unknown",
                c.type or "unknown",
                c.instance or "unknown",
                c.role or "unknown"
            ),
            timeout = 8
        })
    end)
]]

    -- Signal function to execute when a new client appears
    client.connect_signal("manage", function(c)
        -- Set the windows at the slave (not master)
        if not awesome.startup then
            awful.client.setslave(c)
        end

        -- Prevent clients from being unreachable after screen count changes
        if awesome.startup
            and not c.size_hints.user_position
            and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes
            awful.placement.no_offscreen(c)
        end
    end)

    -- Add a titlebar if titlebars_enabled is set to true in the rules
    client.connect_signal("request::titlebars", function(c)
        -- Custom titlebar setup
        awful.titlebar(c):setup {
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                layout = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                layout = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton(c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.stickybutton(c),
                awful.titlebar.widget.ontopbutton(c),
                awful.titlebar.widget.closebutton(c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end)

    -- Enable sloppy focus (focus follows mouse)
    client.connect_signal("mouse::enter", function(c)
        c:emit_signal("request::activate", "mouse_enter", {raise = false})
    end)

    -- Change border color when client gets focus
    client.connect_signal("focus", function(c)
        c.border_color = beautiful.border_focus
    end)
    
    -- Reset border color when client loses focus
    client.connect_signal("unfocus", function(c)
        c.border_color = beautiful.border_normal
    end)
end

-- Function to set up screen signals
local function setup_screen_signals()
    -- Re-set wallpaper when a screen's geometry changes
    screen.connect_signal("property::geometry", function(s)
        -- Wallpaper
        if beautiful.wallpaper then
            local wallpaper = beautiful.wallpaper
            
            -- If wallpaper is a function, call it with the screen
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            
            gears.wallpaper.maximized(wallpaper, s, true)
        end
    end)
end

-- Function to set up tag signals
local function setup_tag_signals()
    -- Update tag properties when layout changes
    tag.connect_signal("property::layout", function(t)
        -- You can add custom logic here when a tag's layout changes
    end)
    
    -- Update tag properties when selected state changes
    tag.connect_signal("property::selected", function(t)
        -- You can add custom logic here when a tag is selected/unselected
    end)
end

-- Initialize all signals
function signals.init()
    setup_client_signals()
    setup_screen_signals()
    setup_tag_signals()
    
    -- You can add more signal setups here
end

return signals

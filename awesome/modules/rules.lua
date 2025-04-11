-- modules/rules.lua
-- Window behavior rules for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local variables = require("modules.variables")

-- Get client keys and buttons from keys module
local keys = require("modules.keys")
local clientkeys = keys.clientkeys
local clientbuttons = keys.clientbuttons

-- Define rules
local rules = {
    -- Default rule for all clients
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },
    -- Floating clients
    {
        rule_any = {
            instance = { "DTA", "copyq", "pinentry" },
            class = { "qimgv", "mpv", "st", "pulsemixer", "Galculator", "Lxappearance", "Pavucontrol", "Terminator" },
            name = { "Event Tester" },
            role = { "AlarmWindow", "ConfigManager", "pop-up" }
        },
        properties = { floating = true }
    },
    -- Disable titlebars by default for normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false }
    },
    -- Assign applications to specific tags
    {
        rule = { class = "Gimp" },
        properties = { screen = 1, tag = "7" }
    },
    {
        rule = { class = "discord" },
        properties = { screen = 1, tag = "8" }
    },
}

-- Initialize function
local function init()
    -- Set the rules
    awful.rules.rules = rules
end

-- Return the module
return {
    rules = rules,
    init = init
}

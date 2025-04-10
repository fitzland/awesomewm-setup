local awful = require("awful")
local beautiful = require("beautiful")

local M = {}

-- Rules to apply to new clients (through the "manage" signal).
M.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
                "Galculator",
                "Nitrogen",
                "Nm-connection-editor",
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    {
        rule = { class = "Firefox" },
        properties = { screen = 1, tag = "2" }
    },
    
    -- Set Discord to always map on tag 3
    {
        rule = { class = "discord" },
        properties = { screen = 1, tag = "3" }
    },
    
    -- Set terminals to tag 1
    {
        rule = { class = "XTerm" },
        properties = { screen = 1, tag = "1" }
    },
    {
        rule = { class = "URxvt" },
        properties = { screen = 1, tag = "1" }
    },
    {
        rule = { class = "Alacritty" },
        properties = { screen = 1, tag = "1" }
    },
    
    -- File managers to tag 4
    {
        rule = { class = "Thunar" },
        properties = { screen = 1, tag = "4" }
    },
    
    -- Code editors to tag 5
    {
        rule = { class = "Code" },
        properties = { screen = 1, tag = "5" }
    },
    {
        rule = { class = "Geany" },
        properties = { screen = 1, tag = "5" }
    },
}

return M

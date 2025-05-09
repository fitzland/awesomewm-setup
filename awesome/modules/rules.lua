-- modules/rules.lua
-- Window behavior rules for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local variables = require("modules.variables")

-- Get client keys and buttons from keys module
local keys = require("modules.keybindings")
local clientkeys = keys.clientkeys
local clientbuttons = keys.clientbuttons

-- Helper function to find tag by name
local function find_tag_by_name(name)
    for _, t in ipairs(root.tags()) do
        if t.name == name then
            return t
        end
    end
    return nil
end
-- Helper function to find screen by index
local function find_screen_by_index(index)
    for _, s in ipairs(screen) do
        if s.index == index then
            return s
        end
    end
    return nil
end
-- Helper function to find screen by name   
local function find_screen_by_name(name)
    for _, s in ipairs(screen) do
        if s.name == name then
            return s
        end
    end
    return nil
end

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
            placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen,
            size_hints_honor = false,
            -- width = 1600,
            -- height = 900
        }
    },
    -- Floating clients
    {
        rule_any = {
            class = {
                "qimgv",
                "mpv",
                "Xarchiver",
                "Tilix",
                "Galculator",
                "Lxappearance",
                "Pavucontrol"
            }
        },
        properties = { 
            floating = true
        },
        callback = function(c)
            awful.placement.centered(c)
        end
    },
    -- Galculator specific size
    {
        rule = { class = "Galculator" },
        properties = { 
            floating = true,
            width = 900,
            height = 600
        },
        callback = function(c)
            awful.placement.centered(c)
        end
    },
    -- Disable titlebars by default for normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false }
    },
    -- Assign applications to specific tags
    {
        rule = { class = "GitHub Desktop" },
        properties = { screen = 1, tag = "2", switchtotag = true }
    },
    {
        rule_any = { class = "alacritty", "Alacritty" },
        properties = { screen = 1, tag = find_tag_by_name("term"), switchtotag = true }
    },
    {
        rule_any = { class = "code", "Code" },
        properties = { screen = 1, tag = find_tag_by_name("code"), switchtotag = true }
    },
    {
        rule = { class = "obs" },
        properties = { screen = 2, tag = "5", switchtotag = true }
    },
    -- LibreOffice needs special handling
    {
        rule_any = { 
            class = { 
                "libreoffice", 
                "LibreOffice", 
                "libreoffice-writer",
                "libreoffice-calc",
                "libreoffice-impress"
            }
        },
        properties = { screen = 1, tag = find_tag_by_name("docs"), floating = false, switchtotag = true }
    },    
    {
        rule_any = { class = "inkscape", "Inkscape" },
        properties = { screen = 1, tag = find_tag_by_name("grfx"), floating = false, switchtotag = true }
    },
    {
        rule_any = { class = "gimp", "Gimp" },
        properties = { screen = 1, tag = find_tag_by_name("grfx"), floating = false, switchtotag = true }
    },
    {
        rule = { class = "Google-chrome" },
        properties = { screen = 2, tag = find_tag_by_name("web"), switchtotag = true }
    },
    {
        rule_any = { class = "thunar", "Thunar" },
        properties = { screen = 2, tag = find_tag_by_name("file"), switchtotag = true }
    },
    {
        rule_any = { class = "spotify", "Spotify" },
        properties = { screen = 2, tag = find_tag_by_name("music"), switchtotag = true }
    },
    {
        rule = { class = "Keepassxc" },
        properties = { screen = 2, tag = find_tag_by_name("tool"), switchtotag = true }
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

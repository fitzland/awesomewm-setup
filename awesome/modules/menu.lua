local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")
local freedesktop = require("freedesktop")
local debian = require("debian.menu")

local M = {}

-- Terminal and editor definitions
terminal = terminal or "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Awesome menu items
M.awesome_menu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end },
}

-- Custom menu items
M.custom_menu = {
    { "Firefox", "firefox" },
    { "Thunar", "thunar" },
    { "Terminal", terminal },
    { "Text Editor", "geany" },
    { "Discord", "discord" },
}

-- Create main menu
local menu_awesome = { "awesome", M.awesome_menu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if freedesktop then
    -- Use freedesktop.org menu if available
    M.main_menu = freedesktop.menu.build({
        before = { menu_awesome },
        after = { menu_terminal }
    })
else
    -- Fallback to Debian menu
    M.main_menu = awful.menu({
        items = {
            menu_awesome,
            { "Applications", M.custom_menu },
            { "Debian", debian.menu.Debian_menu.Debian },
            menu_terminal,
        }
    })
end

-- Set the terminal for applications that require it
menubar.utils.terminal = terminal

return M

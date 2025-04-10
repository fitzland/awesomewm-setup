--[[
   AwesomeWM Configuration
   Modular configuration for AwesomeWM 4.3+
--]]

-- If LuaRocks is installed, make sure that packages installed through it are found
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to another config
if awesome.startup_errors then
    naughty.notify({ 
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors 
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ 
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err) 
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Initialize theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/default/theme.lua")

-- Define global variables
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

-- Make global variables available to modules
_G.terminal = terminal
_G.editor = editor
_G.editor_cmd = editor_cmd
_G.modkey = modkey
-- }}}

-- Load modules (after defining global variables they might need)
local layouts = require("modules.layouts")
local menu = require("modules.menu")
local keybindings = require("modules.keybindings")
local rules = require("modules.rules")
local signals = require("modules.signals")
local wibar = require("modules.wibar")

-- Make module exports available to other modules that might need them
_G.clientkeys = keybindings.clientkeys
_G.clientbuttons = keybindings.clientbuttons

-- {{{ Configure layouts
awful.layout.layouts = layouts.layouts
-- }}}

-- {{{ Menu configuration
myawesomemenu = menu.awesome_menu
mymainmenu = menu.main_menu

-- Create a launcher widget
mylauncher = awful.widget.launcher({ 
    image = beautiful.awesome_icon,
    menu = mymainmenu 
})

-- Menubar configuration
menubar.utils.terminal = terminal
-- }}}

-- {{{ Wibar/Tags setup
-- Set up wibar and tags for each screen
awful.screen.connect_for_each_screen(function(s)
    wibar.setup_wibar(s, mylauncher, layouts)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function() mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
root.keys(keybindings.globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = rules.rules
-- }}}

-- {{{ Signals
signals.setup()
-- }}}

-- {{{ Autorun applications
awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "autorun.sh")
-- }}}

-- {{{ Garbage collection
-- Enable for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer({
    timeout = 30,
    autostart = true,
    callback = function() collectgarbage() end
})
-- }}}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

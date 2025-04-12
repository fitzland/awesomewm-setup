-- modules/menu.lua
-- Menu configuration for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local variables = require("modules.variables")
local gears = require("gears")

local menu = {}

-- Initialize the menu
function menu.init()
    -- Get variables
    local terminal = variables.terminal
    local editor_cmd = variables.editor_cmd
    
    -- Get the correct config path
    local config_path
    if awesome.conffile then
        -- For older versions of AwesomeWM
        config_path = awesome.conffile
    else
        -- For newer versions of AwesomeWM
        config_path = gears.filesystem.get_configuration_dir() .. "/rc.lua"
    end
    
    -- Define Awesome menu items
    local myawesomemenu = {
        { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "manual", terminal .. " -e man awesome" },
        { "edit config", editor_cmd .. " " .. config_path },
        { "restart", awesome.restart },
        { "quit", function() awesome.quit() end },
    }
    
    -- Define application menu items
    local myappmenu = {
        { "terminal", terminal },
        { "browser", variables.browser },
        { "file manager", variables.file_manager },
    }
    
    -- Create the main menu
    menu.main_menu = awful.menu({
        items = {
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "applications", myappmenu },
            { "open terminal", terminal }
        }
    })
    
    -- Create a launcher widget
    menu.launcher = awful.widget.launcher({
        image = beautiful.awesome_icon,
        menu = menu.main_menu
    })
    
    -- Make menu accessible globally
    _G.mymainmenu = menu.main_menu
    _G.mylauncher = menu.launcher
end

return menu

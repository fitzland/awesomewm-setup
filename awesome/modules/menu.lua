-- modules/menu.lua
-- Menu configuration for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local variables = require("modules.variables")

local menu = {}

-- Initialize the menu
function menu.init()
    -- Get variables
    local terminal = variables.terminal
    local editor_cmd = variables.editor_cmd
    local browser = variables.browser
    local file_manager = variables.file_manager
    
    -- Define Awesome menu items
    local myawesomemenu = {
        { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
        { "manual", terminal .. " -e man awesome" },
        { "edit config", editor_cmd .. " " .. awful.conffile },
        { "restart", awesome.restart },
        { "quit", function() awesome.quit() end },
    }
    
    -- Define application menu items
    local myappmenu = {
        { "terminal", terminal },
        { "browser", browser },
        { "file manager", file_manager },
    }
    
    -- Create the main menu
    menu.main_menu = awful.menu({
        items = {
            { "awesome", myawesomenu, beautiful.awesome_icon },
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

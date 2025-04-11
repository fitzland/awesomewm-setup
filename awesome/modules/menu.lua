-- modules/menu.lua

-- Load required libraries
local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Get variables from variables module
local variables = require("modules.variables")
local terminal = variables.terminal
local editor_cmd = variables.editor_cmd
local browser = variables.browser
local file_manager = variables.file_manager

-- Define awesome menu items
local myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

-- Define application menu items
local myappmenu = {
    { "browser", browser },
    { "file manager", file_manager },
    { "terminal", terminal },
}

-- Check for Debian menu
local has_debian_menu = false
if debian_menu then
    has_debian_menu = true
end

-- Check for freedesktop menu
local has_freedesktop_menu = false
if freedesktop_menu then
    has_freedesktop_menu = true
end

-- Create the main menu
local mymainmenu
if has_freedesktop_menu then
    -- Use freedesktop menu as base if available
    mymainmenu = freedesktop_menu.build({
        before = {
            { "awesome", myawesomemenu, beautiful.awesome_icon },
            { "applications", myappmenu },
        },
        after = {
            { "open terminal", terminal }
        }
    })
else
    -- Otherwise create a simple menu
    local menu_items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "applications", myappmenu },
    }
    
    -- Add Debian menu if available
    if has_debian_menu then
        table.insert(menu_items, { "Debian", debian_menu.Debian_menu.Debian })
    end
    
    -- Add terminal entry
    table.insert(menu_items, { "open terminal", terminal })
    
    mymainmenu = awful.menu({ items = menu_items })
end

-- Create a launcher widget
local mylauncher = awful.widget.launcher({ 
    image = beautiful.awesome_icon,
    menu = mymainmenu 
})

-- Return the menu elements for use in other modules
return {
    awesome_menu = myawesomemenu,
    app_menu = myappmenu,
    main_menu = mymainmenu,
    launcher = mylauncher
}

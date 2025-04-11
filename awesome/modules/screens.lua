-- modules/screens.lua
-- Screen configuration for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local variables = require("modules.variables")

local screens = {}

-- Function to set wallpaper
local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Function to set up each screen
local function setup_screen(s)
    -- Set wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table
    awful.tag(variables.tags, s, variables.default_layout)

    -- Add screen-specific widgets or configurations here
    -- For example, you might want different layouts on different screens
    -- or specific widgets only on certain screens
    
    -- Example: Set different gaps for specific screens
    if s.index == 1 then  -- Primary screen
        -- Primary screen specific settings
    elseif s.index == 2 then  -- Secondary screen
        -- Secondary screen specific settings
    end
end

-- Initialize screens
function screens.init()
    -- Set up screens
    awful.screen.connect_for_each_screen(setup_screen)
    
    -- Re-set wallpaper when a screen's geometry changes
    screen.connect_signal("property::geometry", set_wallpaper)
end

return screens

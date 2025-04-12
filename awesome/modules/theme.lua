-- modules/theme.lua
local beautiful = require("beautiful")
local gears = require("gears")

-- Create the theme module table
local theme = {}

-- Initialize function that loads the theme
function theme.init()
    -- Get the config directory
    local config_dir = gears.filesystem.get_configuration_dir()
    
    -- Set the theme path
    local theme_path = config_dir .. "themes/default/theme.lua"
    
    -- Debug output
    print("Loading theme from: " .. theme_path)
    
    -- Check if the theme file exists
    local f = io.open(theme_path, "r")
    if f then
        f:close()
        print("Theme file found, loading it")
        beautiful.init(theme_path)
    else
        print("Theme file not found, using default theme")
        beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
    end
end

-- Return the theme module
return theme

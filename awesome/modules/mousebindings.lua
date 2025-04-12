-- modules/mousebindings.lua
-- Mouse bindings for AwesomeWM

local awful = require("awful")
local gears = require("gears")
local variables = require("modules.variables")

local mousebindings = {}

-- Initialize mouse bindings
function mousebindings.init()
    -- Root window mouse bindings
    root.buttons(gears.table.join(
        -- Right click to open main menu
        awful.button({ }, 3, function() 
            local menu = require("modules.menu")
            menu.main_menu:toggle() 
        end),
        
        -- Scroll wheel to change tags
        awful.button({ }, 4, awful.tag.viewprev),
        awful.button({ }, 5, awful.tag.viewnext)
    ))

    -- Client mouse bindings are defined in keybindings.lua
    -- and applied in rules.lua to avoid circular dependencies
end

-- Return the module
return mousebindings

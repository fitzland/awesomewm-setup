-- modules/layouts.lua

-- Load required libraries
local awful = require("awful")
local variables = require("modules.variables")

-- Define available layouts
local layouts = {
    awful.layout.suit.tile,           -- Master and stacking clients
    awful.layout.suit.tile.left,      -- Master on right, stacking clients on left
    awful.layout.suit.fair,           -- Fair distribution of area among clients
    awful.layout.suit.fair.horizontal, -- Fair distribution, horizontal layout
    awful.layout.suit.spiral,         -- Spiral layout
}

-- Set the available layouts
awful.layout.layouts = layouts

-- Initialize function (can be called from rc.lua)
local function init()
    -- You can add additional layout initialization here if needed
    
    -- If you want to set different default layouts for specific tags,
    -- you could do that here
end

-- Return the layouts and init function
return {
    layouts = layouts,
    init = init
}

-- modules/screens.lua
-- Screen configuration for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local variables = require("modules.variables")

local screens = {}

-- Detailed screen debugging
-- This will show the screen index, geometry, and work area for each screen
-- This is useful for understanding how your screens are set up
-- and can help with debugging layout issues
-- You can remove this section if you don't need it
for s in screen do
    local primary = s == screen.primary and " (PRIMARY)" or ""
    local geo = s.geometry
    
    naughty.notify({ 
        title = "Screen " .. s.index .. primary,
        text = string.format(
            "Resolution: %d x %d\nPosition: %d, %d\nWork area: %d x %d",
            geo.width, geo.height,
            geo.x, geo.y,
            s.workarea.width, s.workarea.height
        ),
        timeout = 15
    })
end

-- Rest of your screens.lua file...

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
    -- awful.tag(variables.tags, s, variables.default_layout)

    -- Add screen-specific widgets or configurations here
    -- For example, you might want different layouts on different screens
    -- or specific widgets only on certain screens

    -- Primary screen gets tags 1-5
    if s.index == 1 then
        local primary_tags = {variables.tags[1], variables.tags[2], variables.tags[3], 
                             variables.tags[4], variables.tags[5]}
        awful.tag(primary_tags, s, variables.default_layout)
        
    -- Secondary screen - first non-primary screen
    else
        local secondary_tags = {variables.tags[6], variables.tags[7], variables.tags[8], 
                               variables.tags[9], variables.tags[10]}
        awful.tag(secondary_tags, s, variables.default_layout)
    end
end

-- Define a function to navigate to a specific screen and tag
local function focus_screen_tag(screen_index, tag_index)
    local screen = screen[screen_index]
    if screen then
        -- For the secondary screen, adjust tag_index based on your setup
        -- If secondary screen tags start at 6, we need to adjust the index
        local actual_tag_index = tag_index
        if screen_index == 2 then  -- Assuming secondary is screen 2
            actual_tag_index = tag_index - 5  -- Convert tag 6 to index 1, tag 7 to index 2, etc.
        end
        
        local tag = screen.tags[actual_tag_index]
        if tag then
            tag:view_only()
            awful.screen.focus(screen)
        end
    end
end

-- Initialize screens
function screens.init()
    -- Set up screens
    awful.screen.connect_for_each_screen(setup_screen)
    
    -- Re-set wallpaper when a screen's geometry changes
    screen.connect_signal("property::geometry", set_wallpaper)

    -- Add a simple delayed restart on initial startup
    -- This will only run once when awesome starts, not on restarts
    -- I'm not sure this is working as intended
    if not awesome.startup_done then
        gears.timer.start_new(2, function()
            awesome.emit_signal("restart")
            awesome.startup_done = true
            return false -- Don't repeat
        end)
    end
end

return screens

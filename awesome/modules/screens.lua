-- modules/screens.lua
-- Screen configuration for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local variables = require("modules.variables")

local screens = {}

-- Tag persistence across restarts
-- File to store the selected tag information
local tag_file = gears.filesystem.get_cache_dir() .. "/selected_tags"

-- Function to save the current tag state
local function save_tag_state()
    local file = io.open(tag_file, "w")
    if file then
        for s in screen do
            local selected_tag = awful.tag.selected(s)
            if selected_tag then
                file:write(s.index .. ":" .. selected_tag.index .. "\n")
            end
        end
        file:close()
    end
end

-- Function to restore tag state
local function restore_tag_state()
    local file = io.open(tag_file, "r")
    if file then
        for line in file:lines() do
            local screen_index, tag_index = line:match("(%d+):(%d+)")
            if screen_index and tag_index then
                screen_index = tonumber(screen_index)
                tag_index = tonumber(tag_index)
                
                local s = screen[screen_index]
                if s then
                    local tags = s.tags
                    if tags and tags[tag_index] then
                        tags[tag_index]:view_only()
                    end
                end
            end
        end
        file:close()
    end
end

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
    
    -- Save state before restart
    awesome.connect_signal("exit", function(reason_restart)
        if reason_restart then
            save_tag_state()
        end
    end)
    
    -- Restore tag state after a short delay to ensure everything is initialized
    gears.timer.start_new(1, function()
        restore_tag_state()
        return false  -- Run only once
    end)
end

-- Export the functions for potential use elsewhere
screens.save_tag_state = save_tag_state
screens.restore_tag_state = restore_tag_state

return screens

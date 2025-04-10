local awful = require("awful")

local M = {}

-- Table of layouts to cover with awful.layout.inc, order matters.
M.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- Function to set default layouts per tag
function M.set_layouts_per_tag(s)
    -- Example: Set specific layouts for specific tags
    -- Tag 1: Tiling
    -- Tag 2: Floating
    -- Tag 3: Max
    -- Others: Default (tile)
    
    local tag_layouts = {
        awful.layout.suit.tile,      -- Tag 1
        awful.layout.suit.floating,  -- Tag 2
        awful.layout.suit.max,       -- Tag 3
        awful.layout.suit.tile,      -- Tag 4
        awful.layout.suit.tile,      -- Tag 5
        awful.layout.suit.tile,      -- Tag 6
        awful.layout.suit.tile,      -- Tag 7
        awful.layout.suit.tile,      -- Tag 8
        awful.layout.suit.tile,      -- Tag 9
        awful.layout.suit.tile,      -- Tag 10
        awful.layout.suit.tile,      -- Tag 11
        awful.layout.suit.tile       -- Tag 12
    }
    
    for i, layout in ipairs(tag_layouts) do
        if s.tags[i] then
            s.tags[i].layout = layout
        end
    end
end

return M

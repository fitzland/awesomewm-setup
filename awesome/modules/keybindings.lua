-- modules/keybindings.lua
local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local variables = require("modules.variables")

local keybindings = {}

-- Define client keybindings at the module level so they're accessible to rules.lua
keybindings.clientkeys = gears.table.join(
    -- Close window with Super+Q
    awful.key({ variables.modkey }, "q", function(c) c:kill() end,
              {description = "close", group = "client"}),
    
    -- Toggle fullscreen
    awful.key({ variables.modkey, "Control" }, "f", function(c) 
        c.fullscreen = not c.fullscreen
        c:raise()
    end, {description = "toggle fullscreen", group = "client"}),
    
    -- Toggle floating and center the window
    awful.key({ variables.modkey, "Shift" }, "space", function(c)
        c.floating = not c.floating
        if c.floating then
            awful.placement.centered(c, {honor_workarea = true})
        end
    end, {description = "toggle floating", group = "client"}),
    
    -- Move window to master position
    awful.key({ variables.modkey, "Control" }, "Return", function(c) 
        c:swap(awful.client.getmaster()) 
    end, {description = "move to master", group = "client"}),
    
    -- Move window to another screen
    awful.key({ variables.modkey }, "o", function(c) 
        c:move_to_screen() 
    end, {description = "move to screen", group = "client"}),

    -- Focus to another screen
    awful.key({ modkey }, "i", function () awful.screen.focus_relative(1) end,
    {description = "focus the next screen", group = "client"}),
    
    -- Toggle "keep on top"
    awful.key({ variables.modkey }, "t", function(c) 
        c.ontop = not c.ontop 
    end, {description = "toggle keep on top", group = "client"}),
    
    -- Minimize window
    awful.key({ variables.modkey }, "n", function(c) 
        c.minimized = true 
    end, {description = "minimize", group = "client"}),
    
    -- Maximize window
    awful.key({ variables.modkey }, "m", function(c) 
        c.maximized = not c.maximized
        c:raise()
    end, {description = "(un)maximize", group = "client"}),
    
    -- Maximize vertically
    awful.key({ variables.modkey, "Control" }, "m", function(c) 
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, {description = "(un)maximize vertically", group = "client"}),
    
    -- Maximize horizontally
    awful.key({ variables.modkey, "Shift" }, "m", function(c) 
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, {description = "(un)maximize horizontally", group = "client"})
)

-- Define client mouse bindings
keybindings.clientbuttons = gears.table.join(
    awful.button({}, 1, function(c) 
        c:emit_signal("request::activate", "mouse_click", {raise = true}) 
    end),
    awful.button({ variables.modkey }, 1, function(c) 
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ variables.modkey }, 3, function(c) 
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Initialize keybindings
function keybindings.init()
    -- Define modkey from variables
    local modkey = variables.modkey
    
    -- Global keybindings
    local globalkeys = gears.table.join(
        -- Awesome control
        awful.key({ modkey, "Shift" }, "r", awesome.restart,
                  {description = "reload awesome", group = "awesome"}),
        awful.key({ modkey, "Shift" }, "q", awesome.quit,
                  {description = "quit awesome", group = "awesome"}),
        awful.key({ modkey }, "h", hotkeys_popup.show_help,
                  {description = "show help", group = "awesome"}),
        
        -- Terminal
        awful.key({ modkey }, "Return", function() awful.spawn(variables.terminal) end,
                  {description = "open a terminal", group = "launcher"}),
        
        -- Layout manipulation
        awful.key({ modkey, "Control" }, "Right", function() awful.tag.incmwfact(0.05) end,
                  {description = "increase master width factor", group = "layout"}),
        awful.key({ modkey, "Control" }, "Left", function() awful.tag.incmwfact(-0.05) end,
                  {description = "decrease master width factor", group = "layout"}),
        awful.key({ modkey, "Control" }, "Down", function() awful.client.incwfact(0.05) end,
                  {description = "increase client height", group = "layout"}),
        awful.key({ modkey, "Control" }, "Up", function() awful.client.incwfact(-0.05) end,
                  {description = "decrease client height", group = "layout"}),
        
-- Focus control
awful.key({ modkey }, "Left", function() awful.client.focus.byidx(1) end,
          {description = "focus next by index", group = "client"}),
awful.key({ modkey }, "Right", function() awful.client.focus.byidx(-1) end,
          {description = "focus previous by index", group = "client"}),
awful.key({ modkey }, "Up", function() awful.client.focus.bydirection("up") end,
          {description = "focus window above", group = "client"}),
awful.key({ modkey }, "Down", function() awful.client.focus.bydirection("down") end,
          {description = "focus window below", group = "client"}),

-- Window movement (swap clients)
awful.key({ modkey, "Shift" }, "Left", function() 
    if client.focus then awful.client.swap.byidx(1) end
end, {description = "swap with next client", group = "client"}),
awful.key({ modkey, "Shift" }, "Right", function() 
    if client.focus then awful.client.swap.byidx(-1) end
end, {description = "swap with previous by index", group = "client"}),
awful.key({ modkey, "Shift" }, "Up", function() 
    if client.focus then awful.client.swap.bydirection("up") end
end, {description = "swap with client above", group = "client"}),
awful.key({ modkey, "Shift" }, "Down", function() 
    if client.focus then awful.client.swap.bydirection("down") end
end, {description = "swap with client below", group = "client"})
)
    
--[[
    -- Tag navigation (1-9)
    for i = 1, 9 do
        globalkeys = gears.table.join(globalkeys,
            awful.key({ modkey }, "#" .. i + 9, function()
                local tag = awful.screen.focused().tags[i]
                if tag then tag:view_only() end
            end, {description = "view tag #"..i, group = "tag"}),
            
            awful.key({ modkey, "Control" }, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) tag:view_only() end
                end
            end, {description = "move client to tag #"..i.." and view", group = "tag"}),
            
            awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) end
                end
            end, {description = "move client to tag #"..i, group = "tag"})
        )
    end
    
    -- Tags 10-12 on keys 0, -, =
    local extra_tags = { [10] = "0", [11] = "-", [12] = "=" }
    for i, key in pairs(extra_tags) do
        globalkeys = gears.table.join(globalkeys,
            awful.key({ modkey }, key, function()
                local tag = awful.screen.focused().tags[i]
                if tag then tag:view_only() end
            end, {description = "view tag #" .. i, group = "tag"}),
            
            awful.key({ modkey, "Control" }, key, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) tag:view_only() end
                end
            end, {description = "move client to tag #" .. i .. " and view", group = "tag"}),
            
            awful.key({ modkey, "Shift" }, key, function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) end
                end
            end, {description = "move client to tag #" .. i, group = "tag"})
        )
    end
]]

-- Tag navigation (1-5) on primary screen and (6-10) on secondary screen
-- This section handles the tag navigation and client movement for both screens
-- The first 5 tags are on the primary screen (index 1) and the next 5 are on the secondary screen (index 2)
-- The tags are accessed using the screen index and the tag index
-- For primary screen tags (1-5)
for i = 1, 10 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only (standard behavior for tags 1-5 on primary screen)
        awful.key({ modkey }, "#" .. i + 9, function ()
            local screen_index = 1
            local tag_index = i

            -- For tags 6-10, use second screen (index 2)
            if i >= 6 then
                screen_index = 2
                tag_index = i - 5  -- Convert tag index for second screen (6→1, 7→2, etc.)
            end

            local screen = screen[screen_index]
            local tag = screen.tags[tag_index]
            if tag then
                tag:view_only()
                awful.screen.focus(screen)
            end
        end,
        {description = "view tag #"..i, group = "tag"}),
        
        -- Toggle tag display
        awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
            local screen_index = 1
            local tag_index = i
            
            if i >= 6 then
                screen_index = 2
                tag_index = i - 5
            end
            
            local screen = screen[screen_index]
            local tag = screen.tags[tag_index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
        {description = "toggle tag #" .. i, group = "tag"}),
        
        -- Move client to tag
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            if client.focus then
                local screen_index = 1
                local tag_index = i
                
                if i >= 6 then
                    screen_index = 2
                    tag_index = i - 5
                end
                
                local screen = screen[screen_index]
                local tag = screen.tags[tag_index]
                if tag then
                    client.focus:move_to_tag(tag)
                    tag:view_only()
                    awful.screen.focus(screen)
                end
            end
        end,
        {description = "move focused client to tag #"..i, group = "tag"}),
        
        -- Toggle tag on focused client
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
            if client.focus then
                local screen_index = 1
                local tag_index = i
                
                if i >= 6 then
                    screen_index = 2
                    tag_index = i - 5
                end
                
                local screen = screen[screen_index]
                local tag = screen.tags[tag_index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
        {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- Application keybindings
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "b", function() awful.util.spawn(variables.browser) end,
                {description = "open browser", group = "launcher"}),
                
    awful.key({ modkey }, "f", function() awful.util.spawn(variables.file_manager) end,
                {description = "open file manager", group = "launcher"}), 
                
    awful.key({ modkey }, "space", function() awful.util.spawn("rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ~/.config/awesome/rofi/config.rasi") end,
                {description = "rofi menu", group = "launcher"}),

    -- Removed default Print binding as it's now defined below
                
    -- Added keybindings
    awful.key({ modkey }, "e", function() awful.util.spawn("code") end,
                {description = "open visual studio code", group = "launcher"}),
                
    awful.key({ modkey, "Shift" }, "Return", function() awful.util.spawn("kitty") end,
                {description = "open kitty", group = "launcher"}),
                
    awful.key({ modkey, "Shift" }, "b", function() awful.util.spawn("firefox-devedition --private-window") end,
                {description = "open firefox in private mode", group = "launcher"}),
    
    -- Volume control
    awful.key({ modkey }, "Insert", function() awful.spawn.with_shell("~/.config/awesome/scripts/changevolume up") end,
                {description = "increase volume", group = "media"}),
                
    awful.key({ modkey }, "Delete", function() awful.spawn.with_shell("~/.config/awesome/scripts/changevolume down") end,
                {description = "decrease volume", group = "media"}),
                
    -- Note: Super + m is already used for maximize, so I'm using Super + End for mute
    awful.key({ modkey }, "End", function() awful.spawn.with_shell("~/.config/awesome/scripts/changevolume mute") end,
                {description = "mute volume", group = "media"}),
                
    -- Screenshots
    awful.key({ modkey }, "Print", function() awful.spawn.with_shell("flameshot gui --path ~/Screenshots/") end,
                {description = "screenshot region", group = "media"}),
                
    -- Replacing your existing Print binding with this one
    awful.key({}, "Print", function() awful.spawn.with_shell("flameshot full --path ~/Screenshots/") end,
                {description = "screenshot fullscreen", group = "media"}),
                
    -- Redshift controls
    awful.key({ modkey, "Mod1" }, "r", function() awful.spawn.with_shell("~/.config/awesome/scripts/redshift-on") end,
                {description = "enable redshift", group = "system"}),
                
    awful.key({ modkey, "Mod1" }, "b", function() awful.spawn.with_shell("~/.config/awesome/scripts/redshift-off") end,
                {description = "disable redshift", group = "system"}),
    
    -- Function keybindings
    awful.key({ modkey }, "F1", function() awful.util.spawn("catfish") end,
                {description = "open catfish", group = "function keys"}),

    awful.key({ modkey }, "F2", function() awful.util.spawn("code") end,
                {description = "open visual studio code", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F2", function() awful.util.spawn("xed") end,
                {description = "open visual studio code", group = "function keys"}),

    awful.key({ modkey }, "F3", function() awful.util.spawn("lowriter") end,
                {description = "open lowriter", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F3", function() awful.util.spawn("localc") end,
                {description = "open localc", group = "function keys"}),

    awful.key({ modkey }, "F4", function() awful.util.spawn("inkscape") end,
                {description = "open inkscape", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F4", function() awful.util.spawn("gimp") end,
                {description = "open gimp", group = "function keys"}),

    awful.key({ modkey }, "F5", function() awful.util.spawn("spotify") end,
                {description = "open spotify-client", group = "function keys"}),

    awful.key({ modkey }, "F7", function() awful.util.spawn("keepassxc ~/Dropbox/journal/home.kdbx") end,
                {description = "open keepassxc home", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F7", function() awful.util.spawn("keepassxc ~/Dropbox/journal/work.kdbx") end,
                {description = "open keepassxc work", group = "function keys"}),

    awful.key({ modkey }, "F8", function() awful.util.spawn("thunar") end,
                {description = "open thunar", group = "function keys"}),
    
    awful.key({ modkey, "Shift" }, "F8", function() awful.util.spawn("meld") end,
                {description = "open meld", group = "function keys"}),
    
    awful.key({ modkey }, "F10", function() awful.util.spawn("firefox-devedition") end,
                {description = "open firefox-devedition", group = "function keys"}),
    
    awful.key({ modkey, "Shift" }, "F10", function() awful.util.spawn("firefox-devedition --private-window") end,
                {description = "open firefox-devedition private", group = "function keys"}),

    awful.key({ modkey }, "F11", function() awful.util.spawn("microsoft-edge-stable --profile-directory='Profile 1'") end,
                {description = "open edge home", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F11", function() awful.util.spawn("microsoft-edge-stable --profile-directory='Default'") end,
                {description = "open edge work", group = "function keys"}),

    awful.key({ modkey }, "F12", function() awful.util.spawn("google-chrome-stable --profile-directory='Default'") end,
                {description = "open chrome work", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F12", function() awful.util.spawn("google-chrome-stable --profile-directory='Profile 1'") end,
                {description = "open chrome work", group = "function keys"})

)
    
    -- Set keys
    root.keys(globalkeys)
end

return keybindings

-- modules/keybindings.lua
local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local variables = require("modules.variables")

local keybindings = {}

-- Helper function to switch to a tag and launch an application
local function launch_on_tag(app_command, screen_idx, tag_idx)
    local s = screen[screen_idx]
    if not s then
        naughty.notify({ preset = naughty.config.presets.critical, title = "Error", text = "Screen " .. screen_idx .. " not found." })
        return
    end

    if not s.tags[tag_idx] then
        naughty.notify({ preset = naughty.config.presets.critical, title = "Error", text = "Tag " .. tag_idx .. " on screen " .. screen_idx .. " not found." })
        return
    end

    local tag_to_view = s.tags[tag_idx]

    tag_to_view:view_only()
    awful.screen.focus(s)
    awful.util.spawn(app_command)
end

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

-- Tag navigation (1-5) on primary screen and (6-10) on secondary screen
-- This section handles the tag navigation and client movement for both screens
-- The first 5 tags are on the primary screen (index 1) and the next 5 are on the secondary screen (index 2)

-- Define which physical keys map to which logical tag number (1-10)
-- This is a mapping of logical tag numbers to their corresponding physical keys
-- The main number row keys are represented by "#10" to "#19" (which are the keysym values for "1" to "0")
-- The keypad keys are represented by "KP_1" to "KP_0"
-- The logical tag numbers are 1-10, and the physical keys are defined in the tag_key_mappings table
local tag_key_mappings = {
    -- Logical Tag 1
    { main = "#10", kp = {"KP_End", "KP_1"} },        -- #10 is keysym for "1"
    -- Logical Tag 2
    { main = "#11", kp = {"KP_Down", "KP_2"} },       -- #11 is keysym for "2"
    -- Logical Tag 3
    { main = "#12", kp = {"KP_Page_Down", "KP_3"} },  -- #12 is keysym for "3"
    -- Logical Tag 4
    { main = "#13", kp = {"KP_Left", "KP_4"} },       -- #13 is keysym for "4"
    -- Logical Tag 5
    { main = "#14", kp = {"KP_Begin", "KP_5"} },      -- #14 is keysym for "5" (KP_Begin is often KP_5 on numlock off)
    -- Logical Tag 6
    { main = "#15", kp = {"KP_Right", "KP_6"} },      -- #15 is keysym for "6"
    -- Logical Tag 7
    { main = "#16", kp = {"KP_Home", "KP_7"} },       -- #16 is keysym for "7"
    -- Logical Tag 8
    { main = "#17", kp = {"KP_Up", "KP_8"} },         -- #17 is keysym for "8"
    -- Logical Tag 9
    { main = "#18", kp = {"KP_Page_Up", "KP_9"} },    -- #18 is keysym for "9"
    -- Logical Tag 10 (often represented by "0" on the main keyboard)
    { main = "#19", kp = {"KP_Insert", "KP_0"} }      -- #19 is keysym for "0" (KP_Insert is often KP_0 on numlock off)
}

-- Loop through logical tag numbers 1 to 10
for i = 1, 10 do
    local keys_for_this_tag = {}
    -- Add the main number row key
    table.insert(keys_for_this_tag, tag_key_mappings[i].main)
    -- Add all associated keypad keys
    for _, kp_key in ipairs(tag_key_mappings[i].kp) do
        table.insert(keys_for_this_tag, kp_key)
    end

    -- Now, for each physical key identified for logical tag 'i', create the bindings
    for _, key_to_bind in ipairs(keys_for_this_tag) do
        globalkeys = gears.table.join(globalkeys,
            -- View tag only
            awful.key({ modkey }, key_to_bind, function ()
                local screen_index = 1
                local tag_index_on_screen = i -- Use 'i' for logical tag index

                if i >= 6 then
                    screen_index = 2
                    tag_index_on_screen = i - 5
                end

                local s = screen[screen_index]
                if not s then return end -- Check if screen exists
                local tag = s.tags[tag_index_on_screen]
                if tag then
                    tag:view_only()
                    awful.screen.focus(s) -- Focus the screen where the tag is
                end
            end,
            {description = "view tag #"..i.." ("..key_to_bind..")", group = "tag"}),

            -- Toggle tag display
            awful.key({ modkey, "Control" }, key_to_bind, function ()
                local screen_index = 1
                local tag_index_on_screen = i

                if i >= 6 then
                    screen_index = 2
                    tag_index_on_screen = i - 5
                end

                local s = screen[screen_index]
                if not s then return end
                local tag = s.tags[tag_index_on_screen]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #"..i.." ("..key_to_bind..")", group = "tag"}),

            -- Move client to tag
            awful.key({ modkey, "Shift" }, key_to_bind, function ()
                if client.focus then
                    local screen_index = 1
                    local tag_index_on_screen = i

                    if i >= 6 then
                        screen_index = 2
                        tag_index_on_screen = i - 5
                    end

                    local s = screen[screen_index]
                    if not s then return end
                    local tag = s.tags[tag_index_on_screen]
                    if tag then
                        client.focus:move_to_tag(tag)
                        -- Optional: also view the tag after moving the client
                        tag:view_only()
                        awful.screen.focus(s)
                    end
                end
            end,
            {description = "move focused client to tag #"..i.." ("..key_to_bind..")", group = "tag"}),

            -- Toggle tag on focused client
            awful.key({ modkey, "Control", "Shift" }, key_to_bind, function ()
                if client.focus then
                    local screen_index = 1
                    local tag_index_on_screen = i

                    if i >= 6 then
                        screen_index = 2
                        tag_index_on_screen = i - 5
                    end

                    local s = screen[screen_index]
                    if not s then return end
                    local tag = s.tags[tag_index_on_screen]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #"..i.." ("..key_to_bind..")", group = "tag"})
        )
    end
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
                
    awful.key({ modkey, "Shift" }, "Return", function() launch_on_tag("kitty", 1, 1) end,
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

    awful.key({ modkey }, "F2", function() launch_on_tag("code", 1, 2) end,
                {description = "open visual studio code", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F2", function() launch_on_tag("xed", 1, 2) end,
                {description = "open visual studio code", group = "function keys"}),

    awful.key({ modkey }, "F3", function() launch_on_tag("lowriter", 1, 3) end,
                {description = "open lowriter", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F3", function() launch_on_tag("localc", 1, 3) end,
                {description = "open localc", group = "function keys"}),

    awful.key({ modkey }, "F4", function() launch_on_tag("inkscape", 1, 4) end,
                {description = "open inkscape", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F4", function() launch_on_tag("gimp", 1, 4) end,
                {description = "open gimp", group = "function keys"}),

    awful.key({ modkey }, "F5", function() launch_on_tag("spotify", 2, 4) end,
                {description = "open spotify-client", group = "function keys"}),

    awful.key({ modkey }, "F7", function() launch_on_tag("keepassxc ~/Dropbox/journal/home.kdbx", 2, 5) end,
                {description = "open keepassxc home", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F7", function() launch_on_tag("keepassxc ~/Dropbox/journal/work.kdbx", 2, 5) end,
                {description = "open keepassxc work", group = "function keys"}),

    awful.key({ modkey }, "F8", function() launch_on_tag("thunar", 2, 3) end,
                {description = "open thunar", group = "function keys"}),
    
    awful.key({ modkey, "Shift" }, "F8", function() launch_on_tag("meld", 1, 2) end,
                {description = "open meld", group = "function keys"}),
    
    awful.key({ modkey }, "F10", function() launch_on_tag("firefox-devedition", 1, 5) end,
                {description = "open firefox-devedition", group = "function keys"}),
    
    awful.key({ modkey, "Shift" }, "F10", function() launch_on_tag("firefox-devedition --private-window", 1, 5) end,
                {description = "open firefox-devedition private", group = "function keys"}),

    awful.key({ modkey }, "F11", function() launch_on_tag("microsoft-edge-stable --profile-directory='Profile 1'", 1, 5) end,
                {description = "open edge home", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F11", function() launch_on_tag("microsoft-edge-stable --profile-directory='Default'", 1, 5) end,
                {description = "open edge work", group = "function keys"}),

    awful.key({ modkey }, "F12", function() launch_on_tag("google-chrome-stable --profile-directory='Default'", 1, 5) end,
                {description = "open chrome work", group = "function keys"}),

    awful.key({ modkey, "Shift" }, "F12", function() launch_on_tag("google-chrome-stable --profile-directory='Profile 1'", 1, 5) end,
                {description = "open chrome work", group = "function keys"})

)
    
    -- Set keys
    root.keys(globalkeys)
end

return keybindings

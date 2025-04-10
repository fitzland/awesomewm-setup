--------------------------------------------------------------------------------
-- Awesome WM Streamlined Configuration
-- A self-contained configuration that is easier to read and tweak.
--
-- This file handles error reporting, initializes your theme, sets default 
-- applications, creates a simple menu and wibar (panel), defines keybindings,
-- rules, and client signals in one place.
--------------------------------------------------------------------------------

-- Load LuaRocks if available
pcall(require, "luarocks.loader")

-- Standard libraries from Awesome
local gears     = require("gears")
local awful     = require("awful")
require("awful.autofocus")
local wibox     = require("wibox")
local vicious   = require("vicious")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

--------------------------------------------------------------------------------
-- Error Handling
--------------------------------------------------------------------------------
-- Capture startup errors (if any) and notify
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Startup Error",
        text   = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Runtime Error",
            text   = tostring(err)
        })
        in_error = false
    end)
end

--------------------------------------------------------------------------------
-- Variable Definitions & Theme Initialization
--------------------------------------------------------------------------------
-- Initialize your theme (modify the path to your theme.lua if needed)
beautiful.init("~/.config/awesome/theme.lua")

-- Define default applications and global modifier key
terminal   = "tilix"                -- your preferred terminal
editor     = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
modkey     = "Mod4"                 -- typically the Windows/Super key

--------------------------------------------------------------------------------
-- Autostart Applications
--------------------------------------------------------------------------------
-- Run an external autorun script (ensure the path is correct)
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

--------------------------------------------------------------------------------
-- Layouts
--------------------------------------------------------------------------------
-- Define available layouts for your workspace.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
}

--------------------------------------------------------------------------------
-- Menu & Launcher
--------------------------------------------------------------------------------
-- Create a main menu for Awesome WM
local myawesomemenu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit Config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end },
}
-- Build the main menu; you can extend this as required
local mymainmenu = awful.menu({
    items = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Open Terminal", terminal }
    }
})
-- Create a launcher widget that shows the main menu on click
mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu  = mymainmenu
})
-- Set terminal for the menubar utility
menubar.utils.terminal = terminal

--------------------------------------------------------------------------------
-- Screen Setup: Wallpaper, Tags, and Wibar (Top Panel)
--------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper: set if defined in theme
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    end

    -- Define tags (workspaces). Adjust the number and names as needed.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }, s, awful.layout.layouts[1])

    -- Create a prompt box for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Create a layout box that shows the current layout icon
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc(1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end)
    ))

    -- Create a taglist widget for workspace navigation
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = gears.table.join(
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then client.focus:move_to_tag(t) end
            end),
            awful.button({ }, 3, awful.tag.viewtoggle)
        )
    }

    -- Create a tasklist widget showing the focused client's tasks only
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = function(c) return c == client.focus end,
        buttons = gears.table.join(
            awful.button({ }, 1, function(c)
                if c == client.focus then
                    c.minimized = true
                else
                    c:emit_signal("request::activate", "tasklist", {raise = true})
                end
            end),
            awful.button({ }, 3, function()
                awful.menu.client_list({ theme = { width = 250 } })
            end)
        )
    }

    -- Create the wibar (top panel) and add widgets
    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {   -- Left widgets: Launcher, Taglist, Promptbox
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist,  -- Middle widget: Tasklist
        {   -- Right widgets: Keyboard layout, Systray, Layoutbox
            layout = wibox.layout.fixed.horizontal,
            awful.widget.keyboardlayout(),
            wibox.widget.systray(),
            s.mylayoutbox,
        },
    }
end)

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------
-- Global Keybindings
globalkeys = gears.table.join(
    awful.key({ modkey }, "s", hotkeys_popup.show_help,
        {description = "show help", group = "awesome"}),
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
        {description = "restore previous tag", group = "tag"}),
    awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
        {description = "focus next client", group = "client"}),
    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
        {description = "focus previous client", group = "client"}),
    awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
        {description = "open terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey, "Control" }, "Right", function() awful.tag.incmwfact(0.05) end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Left", function() awful.tag.incmwfact(-0.05) end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Down", function() awful.client.incwfact(0.05) end,
        {description = "increase client size", group = "layout"}),
    awful.key({ modkey, "Control" }, "Up", function() awful.client.incwfact(-0.05) end,
        {description = "decrease client size", group = "layout"}),

    awful.key({ modkey }, "Tab", function() awful.layout.inc(1) end,
        {description = "next layout", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Tab", function() awful.layout.inc(-1) end,
        {description = "previous layout", group = "layout"}),

    awful.key({ modkey }, "r", function()
        awful.prompt.run({
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval"
        })
    end, {description = "run Lua code", group = "awesome"}),

    awful.key({ modkey }, "p", function() menubar.show() end,
        {description = "show the menubar", group = "launcher"})
)

-- Client Keybindings (for individual windows)
clientkeys = gears.table.join(
    awful.key({ modkey }, "f", function(c)
         c.fullscreen = not c.fullscreen
         c:raise()
    end, {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey }, "q", function(c) c:kill() end,
        {description = "close window", group = "client"}),

    awful.key({ modkey, "Shift" }, "space", function(c)
         c.floating = not c.floating
         if c.floating then
             awful.placement.centered(c, {honor_workarea=true})
         end
    end, {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Control" }, "Return", function(c)
         c:swap(awful.client.getmaster())
    end, {description = "move to master", group = "client"}),

    awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
        {description = "move to screen", group = "client"}),

    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
        {description = "toggle on top", group = "client"}),

    awful.key({ modkey }, "n", function(c) c.minimized = true end,
        {description = "minimize", group = "client"}),

    awful.key({ modkey }, "m", function(c)
         c.maximized = not c.maximized
         c:raise()
    end, {description = "toggle maximize", group = "client"})
)

-- Bind numeric keys to tags 1 through 9
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then tag:view_only() end
        end, {description = "view tag #" .. i, group = "tag"}),

        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end, {description = "move client to tag #" .. i, group = "tag"})
    )
end

-- Apply the global keybindings
root.keys(globalkeys)

--------------------------------------------------------------------------------
-- Rules
--------------------------------------------------------------------------------
-- Define rules to apply properties to new clients
awful.rules.rules = {
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus        = awful.client.focus.filter,
            raise        = true,
            keys         = clientkeys,
            buttons      = gears.table.join(
                awful.button({ }, 1, function(c)
                    c:emit_signal("request::activate", "mouse_click", {raise = true})
                end),
                awful.button({ modkey }, 1, function(c)
                    c:emit_signal("request::activate", "mouse_click", {raise = true})
                    awful.mouse.client.move(c)
                end),
                awful.button({ modkey }, 3, function(c)
                    c:emit_signal("request::activate", "mouse_click", {raise = true})
                    awful.mouse.client.resize(c)
                end)
            ),
            screen      = awful.screen.preferred,
            placement   = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },
    {
        rule_any = {
            instance = { "DTA", "copyq", "pinentry" },
            class    = { "qimgv", "mpv", "st", "pulsemixer", "Galculator", "Lxappearance", "Pavucontrol", "Terminator" },
            name     = { "Event Tester" },
            role     = { "AlarmWindow", "ConfigManager", "pop-up" }
        },
        properties = { floating = true }
    },
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false }
    },
    { rule = { class = "Gimp" },
      properties = { screen = 1, tag = "7" }
    },
    { rule = { class = "discord" },
      properties = { screen = 1, tag = "8" }
    },
}

--------------------------------------------------------------------------------
-- Signals
--------------------------------------------------------------------------------
-- When a new client appears, set it as a slave (non-master) if needed
client.connect_signal("manage", function(c)
    if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

-- Add titlebars on request (if enabled in rules)
client.connect_signal("request::titlebars", function(c)
    local buttons = gears.table.join(
        awful.button({ }, 1, function() 
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function() 
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )
    awful.titlebar(c) : setup {
        { awful.titlebar.widget.iconwidget(c), buttons = buttons, layout = wibox.layout.fixed.horizontal },
        { { align = "center", widget = awful.titlebar.widget.titlewidget(c) }, buttons = buttons, layout = wibox.layout.flex.horizontal },
        { awful.titlebar.widget.floatingbutton(c),
          awful.titlebar.widget.maximizedbutton(c),
          awful.titlebar.widget.stickybutton(c),
          awful.titlebar.widget.ontopbutton(c),
          awful.titlebar.widget.closebutton(c),
          layout = wibox.layout.fixed.horizontal },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus: focus follows mouse
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Change border colors on focus/unfocus
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--------------------------------------------------------------------------------
-- End of Configuration
--------------------------------------------------------------------------------

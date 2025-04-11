--------------------------------------------------------------------------------
-- Awesome WM Streamlined Configuration
-- A self-contained configuration that is easier to read, tweak, and maintain.
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
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title  = "Startup Error",
        text   = awesome.startup_errors
    })
end

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
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/default/theme.lua")

terminal   = "tilix"   -- Set your preferred terminal here
editor     = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor
modkey     = "Mod4"   -- Typically the Windows/Super key

-- Make these global so that modules (if any) can use them
_G.terminal    = terminal
_G.editor      = editor
_G.editor_cmd  = editor_cmd
_G.modkey      = modkey

--------------------------------------------------------------------------------
-- Autostart Applications
--------------------------------------------------------------------------------
awful.spawn.with_shell(gears.filesystem.get_configuration_dir() .. "autorun.sh")

--------------------------------------------------------------------------------
-- Layouts
--------------------------------------------------------------------------------
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
local myawesomemenu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Manual", terminal .. " -e man awesome" },
    { "Edit Config", editor_cmd .. " " .. awesome.conffile },
    { "Restart", awesome.restart },
    { "Quit", function() awesome.quit() end },
}
local mymainmenu = awful.menu({ items = {
    { "Awesome", myawesomemenu, beautiful.awesome_icon },
    { "Open Terminal", terminal }
} })
mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu  = mymainmenu
})
menubar.utils.terminal = terminal

--------------------------------------------------------------------------------
-- Screen Setup: Wallpaper, Tags, and Wibar
--------------------------------------------------------------------------------
-- Define taglist buttons
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle)
)

-- Example widgets (using vicious)
local cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, " CPU: $1% ", 2)

local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, " RAM: $1% ", 15)

local date_time_widget = wibox.widget.textclock("%a %b %d, %I:%M %p", 60)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper (if defined in your theme)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    end

    -- Define tags (adjust names/number as desired)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mytaglist   = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        layout = {
            spacing = 12,  -- Increase spacing between tags
            layout = wibox.layout.fixed.horizontal,
        },
        buttons = taglist_buttons
    }

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc(1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end)
    ))

    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left: taglist and promptbox (launcher removed)
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        nil, -- Middle: (optional tasklist could be added here)
        { -- Right: CPU, Memory, Date/Time, Systray, Layoutbox
            layout = wibox.layout.fixed.horizontal,
            cpu_widget,
            mem_widget,
            date_time_widget,
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
    -- Changed help key to Mod+h (original behavior)
    awful.key({ modkey }, "h", hotkeys_popup.show_help,
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

-- Client Keybindings for individual windows
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

    -- "o" already moves client to a screen by default
    awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
        {description = "move to screen", group = "client"}),

    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
        {description = "toggle on top", group = "client"}),

    awful.key({ modkey }, "n", function(c) c.minimized = true end,
        {description = "minimize", group = "client"}),

    awful.key({ modkey }, "m", function(c)
         c.maximized = not c.maximized
         c:raise()
    end, {description = "toggle maximize", group = "client"}),

    -- Move client to next screen with Super+Shift+Right
    awful.key({ modkey, "Shift" }, "Right", function(c)
         if c then
            local s = c.screen
            local next_screen = (s.index < screen.count()) and screen[s.index + 1] or screen[1]
            c:move_to_screen(next_screen)
            c:raise()
         end
    end, {description = "move client to next screen", group = "client"}),

    -- Move client to previous screen with Super+Shift+Left
    awful.key({ modkey, "Shift" }, "Left", function(c)
         if c then
            local s = c.screen
            local prev_screen = (s.index > 1) and screen[s.index - 1] or screen[screen.count()]
            c:move_to_screen(prev_screen)
            c:raise()
         end
    end, {description = "move client to previous screen", group = "client"})
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

root.keys(globalkeys)

--------------------------------------------------------------------------------
-- Rules
--------------------------------------------------------------------------------
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
client.connect_signal("manage", function(c)
    if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

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
        { { align = "center", widget = awful.titlebar.widget.titlewidget(c) },
          buttons = buttons, layout = wibox.layout.flex.horizontal },
        { awful.titlebar.widget.floatingbutton(c),
          awful.titlebar.widget.maximizedbutton(c),
          awful.titlebar.widget.stickybutton(c),
          awful.titlebar.widget.ontopbutton(c),
          awful.titlebar.widget.closebutton(c),
          layout = wibox.layout.fixed.horizontal },
        layout = wibox.layout.align.horizontal
    }
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

--------------------------------------------------------------------------------
-- Garbage Collection
--------------------------------------------------------------------------------
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer({
    timeout = 30,
    autostart = true,
    callback = function() collectgarbage() end
})

--------------------------------------------------------------------------------
-- End of Configuration
--------------------------------------------------------------------------------

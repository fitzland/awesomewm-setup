--[[
    AwesomeWM Configuration File
    
    This configuration provides:
    - 12 workspaces with custom keybindings
    - System monitoring widgets (CPU, RAM)
    - Custom application shortcuts
    - Tiling window management
    - Clean, minimal interface
--]]

-- ===================================================================
-- LIBRARIES AND INITIALIZATION
-- ===================================================================

-- If LuaRocks is installed, make sure that packages installed through it are found
pcall(require, "luarocks.loader")

-- Core libraries
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

-- Widget and layout libraries
local wibox = require("wibox")
local vicious = require("vicious")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification and utility libraries
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- ===================================================================
-- ERROR HANDLING
-- ===================================================================

-- Notify if AwesomeWM encountered an error during startup
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Prevent endless error loop
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end

-- ===================================================================
-- VARIABLE DEFINITIONS
-- ===================================================================

-- Initialize theme
beautiful.init("~/.config/awesome/theme.lua")

-- Run autostart script
awful.spawn.with_shell("~/.config/awesome/autorun.sh")

-- Default applications
terminal = "wezterm"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey (Windows/Super key)
modkey = "Mod4"

-- ===================================================================
-- LAYOUTS CONFIGURATION
-- ===================================================================

-- Configure layouts
awful.layout.layouts = {
    -- Primary layouts
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
}

-- ===================================================================
-- MENU CONFIGURATION
-- ===================================================================

-- Create a menu for AwesomeWM
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

-- Create the main menu
if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after = { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
            menu_awesome,
            { "Debian", debian.menu.Debian_menu.Debian },
            menu_terminal,
        }
    })
end

-- Launcher widget
mylauncher = awful.widget.launcher({ 
    image = beautiful.awesome_icon,
    menu = mymainmenu 
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- ===================================================================
-- WIDGET DEFINITIONS
-- ===================================================================

-- Keyboard layout widget
mykeyboardlayout = awful.widget.keyboardlayout()

-- Define custom colors for widgets
local label_color = "#d791a8"  -- Pink color for labels
local info_color = "#ffffff"   -- White color for values

-- Date widget (shows day of week, month, day)
local date_widget = wibox.widget.textclock(
    "<span foreground='" .. label_color .. "'>  %a %b %-d </span>", 60
)

-- Time widget (shows hours:minutes AM/PM)
local time_widget = wibox.widget.textclock(
    "<span foreground='" .. info_color .. "'>%l:%M %p  </span>", 1
)

-- Combined date and time widget
local date_time_widget = wibox.widget {
    date_widget,
    time_widget,
    layout = wibox.layout.fixed.horizontal,
}

-- Function to get kernel version
local function get_kernel_version(callback)
    awful.spawn.easy_async_with_shell("uname -r", function(stdout)
        callback(stdout)
    end)
end

-- Kernel widget (shows distro and kernel version)
local kernel_widget = wibox.widget.textbox()
get_kernel_version(function(kernel)
    kernel_widget:set_markup(string.format(
        "<span foreground='%s'>  Debian</span> <span foreground='%s'>%s</span>", 
        label_color, info_color, kernel
    ))
end)

-- CPU usage widget
local cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, 
    function (widget, args)
        return string.format(
            "<span foreground='%s'> CPU:</span> <span foreground='%s'>%d%%</span>", 
            label_color, info_color, args[1]
        ) 
    end, 
    2  -- Update every 2 seconds
)

-- Memory usage widget
local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, 
    function (widget, args)
        return string.format(
            "<span foreground='%s'> RAM:</span> <span foreground='%s'>%d%%</span>", 
            label_color, info_color, args[1]
        ) 
    end, 
    15  -- Update every 15 seconds
)

-- ===================================================================
-- WIBAR / PANEL CONFIGURATION
-- ===================================================================

-- Create a wibox (panel) for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", {raise = true})
        end
    end),
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({ }, 4, function () awful.client.focus.byidx(1) end),
    awful.button({ }, 5, function () awful.client.focus.byidx(-1) end)
)

-- Function to set wallpaper
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Filter function to show only focused clients in taskbar
local function only_focused_clients(c, screen)
    return c == client.focus
end

local dpi = beautiful.xresources.apply_dpi

awful.screen.connect_for_each_screen(function(s)
    -- Set wallpaper as before (if defined in your theme)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
    
    -- Each screen has its own tag table (12 tags)
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }, s, awful.layout.layouts[1])
    
    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    

    -- Create the taglist (assuming taglist_buttons is defined elsewhere)
    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        layout = {
            spacing = dpi(20),
            layout = wibox.layout.fixed.horizontal,
        },
        buttons = taglist_buttons,
    }

    -- Create the layout box widget (for current layout indicator)
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc(1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end)
    ))
    -- Constrain the layout box to a smaller size.
    local small_layoutbox = wibox.container.constraint(s.mylayoutbox, "exact", dpi(24), dpi(24))
    
    -- Create the wibar with a fixed height and slight transparency.
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = dpi(40),
        bg = beautiful.bg_normal,
        opacity = 0.9
    })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        {   -- Left section: Layout box, then spacing, then taglist, then prompt box.
            layout = wibox.layout.fixed.horizontal,
            small_layoutbox,
            wibox.widget.spacing(dpi(10)),
            s.mytaglist,
            wibox.widget.spacing(dpi(10)),
            s.mypromptbox,
        },
        nil,  -- Middle section: can be left empty for a minimal look.
        {   -- Right section: system tray and clock.
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            awful.widget.textclock("%H:%M", 60)
        },
    }
end)

-- ===================================================================
-- MOUSE BINDINGS
-- ===================================================================

root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- ===================================================================
-- KEY BINDINGS
-- ===================================================================

globalkeys = gears.table.join(
    -- ----------------
    -- AWESOME CONTROLS
    -- ----------------
    awful.key({ modkey }, "h", hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey }, "r",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),

    -- ---------------
    -- TAG NAVIGATION
    -- ---------------
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- ----------------
    -- CLIENT FOCUSING
    -- ----------------
    awful.key({ modkey }, "Left",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey }, "Right",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- ----------------
    -- LAYOUT CONTROLS
    -- ----------------
    awful.key({ modkey, "Shift" }, "Left", function () awful.client.swap.byidx(  1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift" }, "Right", function () awful.client.swap.byidx( -1) end,
              {description = "swap with previous client by index", group = "client"}),
              
    -- Adjust client size
    awful.key({ modkey, "Control" }, "Right", function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Left", function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Down", function () awful.client.incwfact( 0.05) end,
              {description = "increase client height", group = "layout"}),
    awful.key({ modkey, "Control" }, "Up", function () awful.client.incwfact(-0.05) end,
              {description = "decrease client height", group = "layout"}),

    -- ----------------
    -- APPLICATION START SHORTCUTS
    -- ----------------
    awful.key({ modkey }, "Return", function () awful.util.spawn(terminal) end,
              {description = "open terminal", group = "launcher"}),
    awful.key({ modkey, "Shift" }, "Return", function () awful.util.spawn("tilix --quake") end,
              {description = "open Tilix --quake mode", group = "launcher"}),
    awful.key({ modkey }, "b", function () awful.util.spawn("firefox-esr") end,
              {description = "open Firefox", group = "launcher"}),
    awful.key({ modkey }, "f", function () awful.util.spawn("thunar") end,
              {description = "open Thunar", group = "launcher"}),
    awful.key({ modkey }, "d", function () awful.util.spawn("Discord") end,
              {description = "open Discord", group = "launcher"}),
    awful.key({ modkey }, "o", function()
        local tag = awful.screen.focused().tags[9]
        if tag then
            tag:view_only()
        end
        awful.util.spawn("obs")
    end, {description = "open OBS", group = "launcher"}),
    awful.key({ modkey }, "e", function () awful.util.spawn("geany") end,
              {description = "open Geany", group = "launcher"}),  
    awful.key({ modkey }, "space", function () awful.util.spawn("rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons") end,
              {description = "rofi menu", group = "launcher"}),
    awful.key({ }, "Print", function () awful.util.spawn("flameshot screen") end,
              {description = "screenshot", group = "launcher"}),
    awful.key({ modkey }, "Print", function () awful.util.spawn("flameshot gui") end,
              {description = "select screenshot", group = "launcher"}),
    awful.key({ modkey }, "v", function()
        awful.util.spawn("st -c pulsemixer -e pulsemixer")
    end, {description = "change volume", group = "launcher"}),

    -- ----------------
    -- PROMPT
    -- ----------------
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

-- Set keys
root.keys(globalkeys)

-- ===================================================================
-- CLIENT KEY BINDINGS
-- ===================================================================
clientkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "f", function (c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey }, "q", function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift" }, "space", function (c)
        c.floating = not c.floating
        if c.floating then
            awful.placement.centered(c, { honor_workarea = true })
        end
    end, {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) 
        c:swap(awful.client.getmaster()) 
    end, {description = "move to master", group = "client"}),
    awful.key({ modkey }, "o", function (c) 
        c:move_to_screen() 
    end, {description = "move to screen", group = "client"}),
    awful.key({ modkey }, "t", function (c) 
        c.ontop = not c.ontop 
    end, {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey }, "n", function (c)
        c.minimized = true
    end, {description = "minimize", group = "client"}),
    awful.key({ modkey }, "m", function (c)
        c.maximized = not c.maximized
        c:raise()
    end, {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m", function (c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift" }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, {description = "(un)maximize horizontally", group = "client"})
)

-- ===================================================================
-- TAG KEY BINDINGS
-- ===================================================================

-- Key bindings for tags 1 to 12
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only
        awful.key({ modkey }, "#" .. i + 9, function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, {description = "view tag #"..i, group = "tag"}),

        -- Move client to tag and follow
        awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                    tag:view_only()
                end
            end
        end, {description = "move focused client to tag #"..i.." + follow", group = "tag"}),

        -- Move client to tag
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #"..i, group = "tag"})
    )
end

-- Explicit keybindings for tags 10, 11, and 12
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "0", function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[10]
        if tag then
            tag:view_only()
        end
    end, {description = "view tag #10", group = "tag"}),

    awful.key({ modkey }, "-", function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[11]
        if tag then
            tag:view_only()
        end
    end, {description = "view tag #11", group = "tag"}),

    awful.key({ modkey }, "=", function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[12]
        if tag then
            tag:view_only()
        end
    end, {description = "view tag #12", group = "tag"}),

    awful.key({ modkey, "Control" }, "0", function ()
        if client.focus then
            local tag = client.focus.screen.tags[10]
            if tag then
                client.focus:move_to_tag(tag)
                tag:view_only()
            end
        end
    end, {description = "move focused client to tag #10 + follow", group = "tag"}),

    awful.key({ modkey, "Control" }, "-", function ()
        if client.focus then
            local tag = client.focus.screen.tags[11]
            if tag then
                client.focus:move_to_tag(tag)
                tag:view_only()
            end
        end
    end, {description = "move focused client to tag #11 + follow", group = "tag"}),

    awful.key({ modkey, "Control" }, "=", function ()
        if client.focus then
            local tag = client.focus.screen.tags[12]
            if tag then
                client.focus:move_to_tag(tag)
                tag:view_only()
            end
        end
    end, {description = "move focused client to tag #12 + follow", group = "tag"}),     

    awful.key({ modkey, "Shift" }, "0", function ()
        if client.focus then
            local tag = client.focus.screen.tags[10]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end, {description = "move focused client to tag #10", group = "tag"}),

    awful.key({ modkey, "Shift" }, "-", function ()
        if client.focus then
            local tag = client.focus.screen.tags[11]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end, {description = "move focused client to tag #11", group = "tag"}),

    awful.key({ modkey, "Shift" }, "=", function ()
        if client.focus then
            local tag = client.focus.screen.tags[12]
            if tag then
                client.focus:move_to_tag(tag)
            end
        end
    end, {description = "move focused client to tag #12", group = "tag"})
)

-- Set keys
root.keys(globalkeys)

-- ===================================================================
-- CLIENT RULES
-- ===================================================================

-- Rules to apply to new clients (through the "manage" signal)
awful.rules.rules = {
    -- All clients will match this rule
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.centered + awful.placement.no_overlap + awful.placement.no_offscreen
    }},
    -- Floating clients
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll
          "copyq",  -- Includes session name in class
          "pinentry",
        },
        class = {
          "qimgv",
          "mpv",
          "st",
          "pulsemixer",
          "Galculator",
          "Lxappearance",
          "Pavucontrol",
          "Tilix",
        },
        name = {
          "Event Tester",  -- xev
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar
          "ConfigManager",  -- Thunderbird's about:config
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools
        }
    }, properties = { floating = true }},
    
    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }},
      properties = { titlebars_enabled = false }
    },
    
    -- Set Gimp to always map on the tag named "7" on screen 1
    { rule = { class = "Gimp" },
      properties = { screen = 1, tag = "7" } },
    
    -- Set Discord to always map on the tag named "8" on screen 1
    { rule = { class = "discord" },
      properties = { screen = 1, tag = "8" } },
}

-- ===================================================================
-- SIGNALS
-- ===================================================================

-- Signal function to execute when a new client appears
client.connect_signal("manage", function (c)
    -- Set the window at the slave, i.e. put it at the end of others instead of setting it master
    if not awesome.startup then awful.client.setslave(c) end
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
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
    
    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Change border color on focus/unfocus
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- END OF CONFIGURATION FILE

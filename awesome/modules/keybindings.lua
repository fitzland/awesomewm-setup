local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")

-- Use the global variables defined in rc.lua
local modkey = _G.modkey or "Mod4"
local terminal = _G.terminal or "wezterm"

local M = {}

-- Global keybindings
local globalkeys = gears.table.join(
    -- Show help (hotkeys widget)
    awful.key({ modkey }, "h", hotkeys_popup.show_help,
        {description = "show help", group = "awesome"}),

    -- Restore tag history
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    -- Focus next and previous client
    awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
        {description = "focus next window", group = "client"}),
    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
        {description = "focus previous window", group = "client"}),

    -- Launch terminal
    awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),

    -- Restart and quit AwesomeWM
    awful.key({ modkey, "Shift" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    -- Adjust master width factor and client height
    awful.key({ modkey, "Control" }, "Right", function() awful.tag.incmwfact(0.05) end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Left", function() awful.tag.incmwfact(-0.05) end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Control" }, "Down", function() awful.client.incwfact(0.05) end,
        {description = "increase client height", group = "layout"}),
    awful.key({ modkey, "Control" }, "Up", function() awful.client.incwfact(-0.05) end,
        {description = "decrease client height", group = "layout"}),

    -- Cycle through layouts
    awful.key({ modkey }, "Tab", function() awful.layout.inc(1) end,
        {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift" }, "Tab", function() awful.layout.inc(-1) end,
        {description = "select previous layout", group = "layout"}),

    -- Restore minimized client
    awful.key({ modkey, "Control" }, "n", function()
          local c = awful.client.restore()
          if c then
             c:emit_signal("request::activate", "key.unminimize", {raise = true})
          end
       end,
       {description = "restore minimized", group = "client"}),

    -- Prompt for Lua code execution
    awful.key({ modkey }, "r", function()
          awful.prompt.run {
              prompt       = "Run Lua code: ",
              textbox      = awful.screen.focused().mypromptbox.widget,
              exe_callback = awful.util.eval,
              history_path = awful.util.get_cache_dir() .. "/history_eval"
          }
       end,
       {description = "lua execute prompt", group = "awesome"}),

    -- Show menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
        {description = "show the menubar", group = "launcher"})
)

-- Tag keybindings for tags 1 to 9 (assuming tags are set up in your wibar module)
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then tag:view_only() end
        end, {description = "view tag #" .. i, group = "tag"}),

        -- Move focused client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end, {description = "move focused client to tag #" .. i, group = "tag"})
    )
end

-- Client keybindings
local clientkeys = gears.table.join(
    awful.key({ modkey }, "f", function(c)
         c.fullscreen = not c.fullscreen
         c:raise()
       end, {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey }, "q", function(c) c:kill() end,
       {description = "close", group = "client"}),

    awful.key({ modkey, "Shift" }, "space", function(c)
         c.floating = not c.floating
         if c.floating then awful.placement.centered(c, {honor_workarea = true}) end
       end, {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Control" }, "Return", function(c)
         c:swap(awful.client.getmaster())
       end, {description = "move to master", group = "client"}),

    awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
       {description = "move to screen", group = "client"}),

    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
       {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey }, "n", function(c) c.minimized = true end,
       {description = "minimize", group = "client"}),

    awful.key({ modkey }, "m", function(c)
          c.maximized = not c.maximized
          c:raise()
       end, {description = "(un)maximize", group = "client"})
)

-- Mouse bindings for clients
local clientbuttons = gears.table.join(
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
)

M.globalkeys = globalkeys
M.clientkeys = clientkeys
M.clientbuttons = clientbuttons

return M

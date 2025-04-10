local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar = require("menubar")

local modkey = "Mod4"

local M = {}

-- Global keybindings
local globalkeys = gears.table.join(
    awful.key({ modkey }, "h", hotkeys_popup.show_help,
        {description = "show help", group = "awesome"}),

    awful.key({ modkey }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    awful.key({ modkey }, "Left",
        function () awful.client.focus.byidx(1) end,
        {description = "focus next by index", group = "client"}),

    awful.key({ modkey }, "Right",
        function () awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),

    awful.key({ modkey, "Shift" }, "Left",
        function () awful.client.swap.byidx(1) end,
        {description = "swap with next client by index", group = "client"}),

    awful.key({ modkey, "Shift" }, "Right",
        function () awful.client.swap.byidx(-1) end,
        {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    awful.key({ modkey }, "Return",
        function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),

    awful.key({ modkey, "Shift" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey, "Control" }, "Right",
        function () awful.tag.incmwfact(0.05) end,
        {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey, "Control" }, "Left",
        function () awful.tag.incmwfact(-0.05) end,
        {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Control" }, "Down",
        function () awful.client.incwfact(0.05) end,
        {description = "increase client height", group = "layout"}),

    awful.key({ modkey, "Control" }, "Up",
        function () awful.client.incwfact(-0.05) end,
        {description = "decrease client height", group = "layout"}),

    awful.key({ modkey, "Shift" }, "h",
        function () awful.tag.incnmaster(1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),

    awful.key({ modkey, "Shift" }, "l",
        function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey }, "Tab",
        function () awful.layout.inc(1) end,
        {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift" }, "Tab",
        function () awful.layout.inc(-1) end,
        {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            if c then
                c:emit_signal("request::activate", "key.unminimize", {raise = true})
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Application keybindings
    awful.key({ modkey }, "b",
        function () awful.util.spawn("firefox-esr") end,
        {description = "open firefox", group = "launcher"}),

    awful.key({ modkey }, "f",
        function () awful.util.spawn("thunar") end,
        {description = "open thunar", group = "launcher"}),

    awful.key({ modkey }, "d",
        function () awful.util.spawn("Discord") end,
        {description = "open discord", group = "launcher"}),

    awful.key({ modkey }, "o",
        function ()
            local tag = awful.screen.focused().tags[9]
            if tag then
                tag:view_only()
            end
            awful.util.spawn("obs")
        end,
        {description = "open obs", group = "launcher"}),

    awful.key({ modkey }, "e",
        function () awful.util.spawn("geany") end,
        {description = "open geany", group = "launcher"}),

    awful.key({ modkey }, "space",
        function () awful.util.spawn("rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons") end,
        {description = "rofi menu", group = "launcher"}),

    awful.key({ }, "Print",
        function () awful.util.spawn("flameshot screen") end,
        {description = "screenshot", group = "launcher"}),

    awful.key({ modkey }, "Print",
        function () awful.util.spawn("flameshot gui") end,
        {description = "select screenshot", group = "launcher"}),

    awful.key({ modkey }, "v",
        function () awful.util.spawn("st -c pulsemixer -e pulsemixer") end,
        {description = "change volume", group = "launcher"}),

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

    awful.key({ modkey }, "p",
        function () menubar.show() end,
        {description = "show the menubar", group = "launcher"})
)

-- Keybindings for tags 1 to 9
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then tag:view_only() end
            end,
            {description = "view tag #" .. i, group = "tag"}),

        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                        tag:view_only()
                    end
                end
            end,
            {description = "move focused client to tag #" .. i .. " + follow", group = "tag"}),

        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #" .. i, group = "tag"})
    )
end

-- Explicit keybindings for tags 10, 11, and 12
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "0",
        function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[10]
            if tag then tag:view_only() end
        end,
        {description = "view tag #10", group = "tag"}),

    awful.key({ modkey }, "-",
        function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[11]
            if tag then tag:view_only() end
        end,
        {description = "view tag #11", group = "tag"}),

    awful.key({ modkey }, "=",
        function ()
            local screen = awful.screen.focused()
            local tag = screen.tags[12]
            if tag then tag:view_only() end
        end,
        {description = "view tag #12", group = "tag"}),

    awful.key({ modkey, "Control" }, "0",
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[10]
                if tag then
                    client.focus:move_to_tag(tag)
                    tag:view_only()
                end
            end
        end,
        {description = "move focused client to tag #10 + follow", group = "tag"}),

    awful.key({ modkey, "Control" }, "-",
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[11]
                if tag then
                    client.focus:move_to_tag(tag)
                    tag:view_only()
                end
            end
        end,
        {description = "move focused client to tag #11 + follow", group = "tag"}),

    awful.key({ modkey, "Control" }, "=",
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[12]
                if tag then
                    client.focus:move_to_tag(tag)
                    tag:view_only()
                end
            end
        end,
        {description = "move focused client to tag #12 + follow", group = "tag"}),

    awful.key({ modkey, "Shift" }, "0",
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[10]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
        {description = "move focused client to tag #10", group = "tag"}),

    awful.key({ modkey, "Shift" }, "-",
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[11]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
        {description = "move focused client to tag #11", group = "tag"}),

    awful.key({ modkey, "Shift" }, "=",
        function ()
            if client.focus then
                local tag = client.focus.screen.tags[12]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
        {description = "move focused client to tag #12", group = "tag"})
)

-- Client keybindings
local clientkeys = gears.table.join(
    awful.key({ modkey, "Control" }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    awful.key({ modkey }, "q",
        function (c) c:kill() end,
        {description = "close", group = "client"}),

    awful.key({ modkey, "Shift" }, "space",
        function (c)
            c.floating = not c.floating
            if c.floating then
                awful.placement.centered(c, {honor_workarea = true})
            end
        end,
        {description = "toggle floating", group = "client"}),

    awful.key({ modkey, "Control" }, "Return",
        function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),

    awful.key({ modkey }, "o",
        function (c) c:move_to_screen() end,
        {description = "move to screen", group = "client"}),

    awful.key({ modkey }, "t",
        function (c) c.ontop = not c.ontop end,
        {description = "toggle keep on top", group = "client"}),

    awful.key({ modkey }, "n",
        function (c) c.minimized = true end,
        {description = "minimize", group = "client"}),

    awful.key({ modkey }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end,
        {description = "(un)maximize", group = "client"}),

    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {description = "(un)maximize vertically", group = "client"}),

    awful.key({ modkey, "Shift" }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Mouse bindings for clients
local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

M.globalkeys = globalkeys
M.clientkeys = clientkeys
M.clientbuttons = clientbuttons

return M

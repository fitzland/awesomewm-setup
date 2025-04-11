-- modules/keybindings.lua
-- Keyboard shortcuts for AwesomeWM

local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
local variables = require("modules.variables")

local keybindings = {}

-- Shorthand for commonly used variables
local modkey = variables.modkey

-- Global keybindings
local function setup_global_keys()
    globalkeys = gears.table.join(
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
        awful.key({ modkey }, "Tab", function() awful.layout.inc(1) end,
                  {description = "select next layout", group = "layout"}),
        awful.key({ modkey, "Shift" }, "Tab", function() awful.layout.inc(-1) end,
                  {description = "select previous layout", group = "layout"}),
        
        -- Focus control
        awful.key({ modkey }, "Left", function() awful.client.focus.byidx(1) end,
                  {description = "focus next by index", group = "client"}),
        awful.key({ modkey }, "Right", function() awful.client.focus.byidx(-1) end,
                  {description = "focus previous by index", group = "client"}),
        
        -- Tag navigation (1-12)
        awful.key({ modkey }, "1", function() awful.tag.viewonly(awful.screen.focused().tags[1]) end,
                  {description = "view tag 1", group = "tag"}),
        awful.key({ modkey }, "2", function() awful.tag.viewonly(awful.screen.focused().tags[2]) end,
                  {description = "view tag 2", group = "tag"}),
        awful.key({ modkey }, "3", function() awful.tag.viewonly(awful.screen.focused().tags[3]) end,
                  {description = "view tag 3", group = "tag"}),
        awful.key({ modkey }, "4", function() awful.tag.viewonly(awful.screen.focused().tags[4]) end,
                  {description = "view tag 4", group = "tag"}),
        awful.key({ modkey }, "5", function() awful.tag.viewonly(awful.screen.focused().tags[5]) end,
                  {description = "view tag 5", group = "tag"}),
        awful.key({ modkey }, "6", function() awful.tag.viewonly(awful.screen.focused().tags[6]) end,
                  {description = "view tag 6", group = "tag"}),
        awful.key({ modkey }, "7", function() awful.tag.viewonly(awful.screen.focused().tags[7]) end,
                  {description = "view tag 7", group = "tag"}),
        awful.key({ modkey }, "8", function() awful.tag.viewonly(awful.screen.focused().tags[8]) end,
                  {description = "view tag 8", group = "tag"}),
        awful.key({ modkey }, "9", function() awful.tag.viewonly(awful.screen.focused().tags[9]) end,
                  {description = "view tag 9", group = "tag"}),
        awful.key({ modkey }, "0", function() awful.tag.viewonly(awful.screen.focused().tags[10]) end,
                  {description = "view tag 10", group = "tag"}),
        awful.key({ modkey }, "-", function() awful.tag.viewonly(awful.screen.focused().tags[11]) end,
                  {description = "view tag 11", group = "tag"}),
        awful.key({ modkey }, "=", function() awful.tag.viewonly(awful.screen.focused().tags[12]) end,
                  {description = "view tag 12", group = "tag"}),
                -- Move client to tag
        awful.key({ modkey, "Shift" }, "1", function()
            if client.focus then
                local tag = client.focus.screen.tags[1]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #1", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "2", function()
            if client.focus then
                local tag = client.focus.screen.tags[2]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #2", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "3", function()
            if client.focus then
                local tag = client.focus.screen.tags[3]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #3", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "4", function()
            if client.focus then
                local tag = client.focus.screen.tags[4]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #4", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "5", function()
            if client.focus then
                local tag = client.focus.screen.tags[5]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #5", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "6", function()
            if client.focus then
                local tag = client.focus.screen.tags[6]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #6", group = "tag"}),
                awful.key({ modkey, "Shift" }, "7", function()
            if client.focus then
                local tag = client.focus.screen.tags[7]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #7", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "8", function()
            if client.focus then
                local tag = client.focus.screen.tags[8]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #8", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "9", function()
            if client.focus then
                local tag = client.focus.screen.tags[9]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #9", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "0", function()
            if client.focus then
                local tag = client.focus.screen.tags[10]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #10", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "-", function()
            if client.focus then
                local tag = client.focus.screen.tags[11]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #11", group = "tag"}),
        
        awful.key({ modkey, "Shift" }, "=", function()
            if client.focus then
                local tag = client.focus.screen.tags[12]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, {description = "move focused client to tag #12", group = "tag"}),
        

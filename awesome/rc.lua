-- rc.lua
-- AwesomeWM modular configuration

-- Create a dummy naughty module that logs errors instead of showing notifications
local dummy_naughty = {}
dummy_naughty.notify = function(args) 
  io.stderr:write("Error: " .. (args.title or "") .. " - " .. (args.text or "unknown error") .. "\n")
end
dummy_naughty.config = {presets = {critical = {}}}

-- Replace naughty with our dummy implementation
package.loaded["naughty"] = dummy_naughty
package.loaded["naughty.dbus"] = {}

-- Now continue with the rest of rc.lua
-- AwesomeWM modular configuration
-- Error handling should be loaded first
local error_handling = require("modules.error_handling")

-- Error handling should be loaded first
local error_handling = require("modules.error_handling")
error_handling.init()

-- Core libraries and variables
require("modules.libraries")
local variables = require("modules.variables")
local theme = require("modules.theme")
theme.init()

-- UI components
local menu = require("modules.menu")
menu.init()

local layouts = require("modules.layouts")
layouts.init()

local widgets = require("modules.widgets")
widgets.init()

local wibar = require("modules.wibar")
wibar.init()

-- Window management
local rules = require("modules.rules")
rules.init()

local signals = require("modules.signals")
signals.init()

local screens = require("modules.screens")
screens.init()

-- User interaction
local keybindings = require("modules.keybindings")
keybindings.init()

local mousebindings = require("modules.mousebindings")
mousebindings.init()

-- local notifications = require("modules.notifications")
-- notifications.init()

-- User applications and startup
local autostart = require("modules.autostart")
autostart.init()

-- Optional modules
-- local titlebars = require("modules.titlebars")
-- titlebars.init()

-- local wallpaper = require("modules.wallpaper")
-- wallpaper.init()

-- local custom_widgets = require("modules.custom_widgets")
-- custom_widgets.init()

-- local dpi_scaling = require("modules.dpi_scaling")
-- dpi_scaling.init()

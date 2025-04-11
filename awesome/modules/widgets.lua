-- modules/widgets.lua

-- Load required libraries
local wibox = require("wibox")
local vicious = require("vicious")
local variables = require("modules.variables")

-- Create widget table
local widgets = {}

-- Create basic widgets
widgets.cpu_widget = wibox.widget.textbox()
widgets.mem_widget = wibox.widget.textbox()
widgets.date_widget = wibox.widget.textclock(" %a %b %-d ", 60)
widgets.time_widget = wibox.widget.textclock("%l:%M %p ", 1)
widgets.systray = wibox.widget.systray()

-- Register widgets with Vicious
vicious.register(widgets.cpu_widget, vicious.widgets.cpu, " CPU: $1% ", 2)
vicious.register(widgets.mem_widget, vicious.widgets.mem, " RAM: $1% ", 15)

-- Function to initialize any widgets that need special setup
local function init()
    -- Any additional widget initialization can go here
end

-- Return the widgets and init function
return {
    cpu_widget = widgets.cpu_widget,
    mem_widget = widgets.mem_widget,
    date_widget = widgets.date_widget,
    time_widget = widgets.time_widget,
    systray = widgets.systray,
    init = init
}

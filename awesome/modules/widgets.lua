-- modules/widgets.lua

-- Load required libraries
local wibox = require("wibox")
local variables = require("modules.variables")

-- Try to load vicious with error handling
local vicious, vicious_error
local status, err = pcall(function() 
    vicious = require("vicious") 
end)
if not status then
    vicious_error = err
    print("Error loading vicious: " .. tostring(err))
end

-- Create widget table
local widgets = {}

-- Create basic widgets
widgets.cpu_widget = wibox.widget.textbox(" CPU: ? ")
widgets.mem_widget = wibox.widget.textbox(" RAM: ? ")
widgets.date_widget = wibox.widget.textclock(" %a %b %-d ", 60)
widgets.time_widget = wibox.widget.textclock("%l:%M %p ", 1)
widgets.systray = wibox.widget.systray()

-- Function to initialize any widgets that need special setup
local function init()
    -- Only register with vicious if it loaded successfully
    if vicious then
        pcall(function()
            vicious.register(widgets.cpu_widget, vicious.widgets.cpu, " CPU: $1% ", 2)
            vicious.register(widgets.mem_widget, vicious.widgets.mem, " RAM: $1% ", 15)
        end)
    end
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

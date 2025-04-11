-- modules/autostart.lua
-- Autostart applications for AwesomeWM

local awful = require("awful")
local gears = require("gears")
local variables = require("modules.variables")

local autostart = {}

function autostart.init()
    -- Get the scripts directory
    local scripts_dir = variables.scripts_dir
    local autorun_script = scripts_dir .. "autorun.sh"
    
    -- Check if the autorun script exists
    local f = io.open(autorun_script, "r")
    if f then
        f:close()
        print("Found autorun script, executing: " .. autorun_script)
        awful.spawn.with_shell(autorun_script)
    else
        print("Autorun script not found at: " .. autorun_script)
        print("Creating a basic autorun script...")
        
        -- Create the scripts directory if it doesn't exist
        awful.spawn.with_shell("mkdir -p " .. scripts_dir)
        
        -- Create a basic autorun script
        local script_content = [[#!/bin/bash
# Autorun script for AwesomeWM
# Add your startup applications below

# Example: Start a compositor
# picom &

# Example: Set background
# nitrogen --restore &

# Example: Start network manager applet
# nm-applet &

# Example: Start volume control
# volumeicon &

echo "Autorun script executed at $(date)"
]]
        
        -- Write the script to file
        local script_file = io.open(autorun_script, "w")
        if script_file then
            script_file:write(script_content)
            script_file:close()
            
            -- Make the script executable
            awful.spawn.with_shell("chmod +x " .. autorun_script)
            print("Created autorun script at: " .. autorun_script)
            
            -- Execute the newly created script
            awful.spawn.with_shell(autorun_script)
        else
            print("Failed to create autorun script")
        end
    end
    
    -- You can also add direct application launches here
    -- awful.spawn.once("picom")
    -- awful.spawn.once("nm-applet")
end

return autostart

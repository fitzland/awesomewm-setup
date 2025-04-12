-- modules/variables.lua
-- Global variables for AwesomeWM configuration

-- Default applications
terminal = "wezterm"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
browser = "firefox"
file_manager = "thunar"

-- Modifier key (Mod4 is usually the 'Super' or 'Windows' key)
modkey = "Mod4"

-- Commonly used paths
home = os.getenv("HOME")
config_dir = home .. "/.config/awesome/"
scripts_dir = config_dir .. "scripts/"  -- ~/.config/awesome/scripts/
wallpaper_dir = config_dir .. "wallpapers/"  -- ~/.config/awesome/wallpapers/

-- Theme settings
theme_name = "default"
theme_path = config_dir .. "themes/" .. theme_name .. "/theme.lua"

-- Default layout (full layouts defined in layouts.lua)
default_layout = awful.layout.suit.tile

-- Tag names (workspaces)
tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12" }

-- Media keys
volume_up_cmd = "pactl set-sink-volume @DEFAULT_SINK@ +5%"
volume_down_cmd = "pactl set-sink-volume @DEFAULT_SINK@ -5%"
volume_toggle_cmd = "pactl set-sink-mute @DEFAULT_SINK@ toggle"
brightness_up_cmd = "brightnessctl set +10%"
brightness_down_cmd = "brightnessctl set 10%-"

-- Return variables for direct access from other modules
return {
    -- Applications
    terminal = terminal,
    editor = editor,
    editor_cmd = editor_cmd,
    browser = browser,
    file_manager = file_manager,
    screenshot_cmd = screenshot_cmd,
    lock_screen_cmd = lock_screen_cmd,
    
    -- Keys
    modkey = modkey,
    
    -- Paths
    home = home,
    config_dir = config_dir,
    scripts_dir = scripts_dir,
    wallpaper_dir = wallpaper_dir,
    
    -- Theme
    theme_name = theme_name,
    theme_path = theme_path,
    
    -- Layout
    default_layout = default_layout,
    
    -- Tags
    tags = tags,
    
    -- Media commands
    volume_up_cmd = volume_up_cmd,
    volume_down_cmd = volume_down_cmd,
    volume_toggle_cmd = volume_toggle_cmd,
    brightness_up_cmd = brightness_up_cmd,
    brightness_down_cmd = brightness_down_cmd
}

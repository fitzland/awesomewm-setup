--------------------------------------------------------------------------------
-- Streamlined AwesomeWM Theme Configuration
-- This file defines the appearance of your Awesome window manager, including
-- fonts, colors, borders, gaps, icons, and more.
--------------------------------------------------------------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources   = require("beautiful.xresources")
local dpi          = xresources.apply_dpi

local gears        = require("gears")
local gfs          = require("gears.filesystem")
local themes_path  = gfs.get_themes_dir()

local theme = {}

--------------------------------------------------------------------------------
-- Fonts and Colors
--------------------------------------------------------------------------------
theme.font          = "Roboto Mono Nerd Font 12"

-- Background colors for different UI elements
theme.bg_normal     = "#00141D"   -- Normal background
theme.bg_focus      = "#4FC3F7"   -- Focused elements
theme.bg_urgent     = "#ff0000"   -- Urgent (alert) background
theme.bg_minimize   = "#40474A"   -- Minimized window background
theme.bg_systray    = theme.bg_normal

-- Foreground colors for text
theme.fg_normal     = "#d3dae3"   -- Normal text color
theme.fg_focus      = "#1a1a1a"   -- Focused text color
theme.fg_urgent     = "#ffffff"   -- Urgent text color
theme.fg_minimize   = "#9AABB3"   -- Minimized text color

--------------------------------------------------------------------------------
-- Window Borders and Gaps
--------------------------------------------------------------------------------
theme.useless_gap   = dpi(8)      -- Gap between windows
theme.border_width  = dpi(4)      -- Border width for windows
theme.border_normal = "#1a1a1a"   -- Border color for inactive windows
theme.border_focus  = "#4FC3F7"   -- Border color for focused windows
theme.border_marked = "#4FC3F7"   -- Border color for marked windows

--------------------------------------------------------------------------------
-- Taglist Squares (small icons for workspaces)
--------------------------------------------------------------------------------
local taglist_square_size = dpi(4)
theme.taglist_squares_sel   = theme_assets.taglist_squares_sel(taglist_square_size, theme.fg_normal)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(taglist_square_size, theme.fg_normal)

--------------------------------------------------------------------------------
-- Menu Settings
--------------------------------------------------------------------------------
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(18)
theme.menu_width  = dpi(100)

--------------------------------------------------------------------------------
-- Titlebar Buttons
--------------------------------------------------------------------------------
theme.titlebar_close_button_normal       = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus        = themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal    = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus     = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active    = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active     = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active     = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active      = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active     = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active      = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active     = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active      = themes_path.."default/titlebar/maximized_focus_active.png"

--------------------------------------------------------------------------------
-- Wallpaper (Optional)
--------------------------------------------------------------------------------
-- Uncomment and set the path to use your custom wallpaper:
-- theme.wallpaper = "~/.config/backgrounds/your_wallpaper.png"

--------------------------------------------------------------------------------
-- Layout Icons
--------------------------------------------------------------------------------
theme.layout_fairh         = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv         = themes_path.."default/layouts/fairvw.png"
theme.layout_floating      = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier     = themes_path.."default/layouts/magnifierw.png"
theme.layout_max           = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen    = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom    = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft      = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile          = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop       = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral        = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle       = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw      = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne      = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw      = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse      = themes_path.."default/layouts/cornersew.png"

--------------------------------------------------------------------------------
-- Awesome Icon
--------------------------------------------------------------------------------
-- Generate a default Awesome icon for the menu. You can customize the size or colors.
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.bg_focus, theme.fg_focus)

--------------------------------------------------------------------------------
-- Application Icon Theme
--------------------------------------------------------------------------------
-- Specify an icon theme for your applications (set to nil to use system defaults)
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

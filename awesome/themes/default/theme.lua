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

-- GitHub theme colors
theme.gh_fg        = "#d0d7de"   -- Foreground text
theme.gh_bg        = "#0d1117"   -- Background
theme.gh_comment   = "#8b949e"   -- Comments/muted text
theme.gh_red       = "#ff7b72"   -- Error, deletion
theme.gh_green     = "#3fb950"   -- Success, addition
theme.gh_yellow    = "#d29922"   -- Warning, modified
theme.gh_blue      = "#539bf5"   -- Info, links
theme.gh_magenta   = "#bc8cff"   -- Variables, prop names
theme.gh_cyan      = "#39c5cf"   -- Tags, tokens
theme.gh_selection = "#415555"   -- Selection background
theme.gh_highlight = "#4DFFDA"   -- Highlighted text
theme.gh_caret     = "#58a6ff"   -- Cursor/caret color
theme.gh_invisibles = "#2f363d"  -- Invisible characters

-- Background colors for different UI elements (using GitHub colors)
theme.bg_normal     = theme.gh_bg        -- Normal background
theme.bg_focus      = theme.gh_blue      -- Focused elements
theme.bg_urgent     = theme.gh_red       -- Urgent (alert) background
theme.bg_minimize   = theme.gh_invisibles -- Minimized window background
theme.bg_systray    = theme.gh_bg        -- System tray background

-- Foreground colors for text (using GitHub colors)
theme.fg_normal     = theme.gh_fg        -- Normal text color
theme.fg_focus      = theme.gh_bg        -- Focused text color
theme.fg_urgent     = theme.gh_fg        -- Urgent text color
theme.fg_minimize   = theme.gh_comment   -- Minimized text color

--------------------------------------------------------------------------------
-- Window Borders and Gaps
--------------------------------------------------------------------------------
theme.useless_gap   = dpi(8)             -- Gap between windows
theme.border_width  = dpi(4)             -- Border width for windows
theme.border_normal = theme.gh_invisibles -- Border color for inactive windows
theme.border_focus  = theme.gh_blue      -- Border color for focused windows
theme.border_marked = theme.gh_magenta   -- Border color for marked windows

--------------------------------------------------------------------------------
-- Taglist Squares (small icons for workspaces)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Taglist Squares (small icons for workspaces)
--------------------------------------------------------------------------------
theme.taglist_squares_sel = nil
theme.taglist_squares_unsel = nil

-- Set taglist colors with enhanced contrast
theme.taglist_fg_focus = theme.gh_caret      -- Active tag text color (using highlight color for more contrast)
theme.taglist_bg_focus = "transparent"            -- Active tag background (transparent)

theme.taglist_fg_occupied = theme.gh_fg           -- Occupied tag text color
theme.taglist_bg_occupied = "transparent"         -- Occupied tag background (transparent)

theme.taglist_fg_empty = theme.gh_comment .. "80" -- Empty tag text color with 50% opacity for even lower visibility
theme.taglist_bg_empty = "transparent"            -- Empty tag background (transparent)

theme.taglist_fg_urgent = theme.gh_red     -- Urgent tag text color
theme.taglist_bg_urgent = "transparent"    -- Urgent tag background (transparent)

-- Keep the original spacing between tags
theme.taglist_spacing = dpi(6)             -- Space between tags

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
-- Systray Settings
--------------------------------------------------------------------------------
theme.systray_icon_spacing = 5

--------------------------------------------------------------------------------
-- Awesome Icon
--------------------------------------------------------------------------------
-- Generate a default Awesome icon for the menu using GitHub colors
theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.gh_blue, theme.gh_bg)

--------------------------------------------------------------------------------
-- Application Icon Theme
--------------------------------------------------------------------------------
-- Specify an icon theme for your applications (set to nil to use system defaults)
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

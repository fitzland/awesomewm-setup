-- modules/notifications.lua
-- Configure naughty with GitHub theme colors to match overall theme

local naughty = require("naughty")
local beautiful = require("beautiful")
local notifications = {}

function notifications.init()
    -- GitHub colors from your theme.lua
    local gh_bg = "#0d1117"       -- Background
    local gh_fg = "#d0d7de"       -- Foreground text
    local gh_blue = "#539bf5"     -- Info, links
    local gh_red = "#ff7b72"      -- Error, deletion
    local gh_yellow = "#d29922"   -- Warning, modified
    local gh_green = "#3fb950"    -- Success, addition
    local gh_comment = "#8b949e"  -- Comments/muted text
    
    -- Configure notification appearance
    naughty.config.defaults.timeout = 10
    naughty.config.defaults.position = "top_right"
    naughty.config.defaults.bg = gh_bg
    naughty.config.defaults.fg = gh_fg
    naughty.config.defaults.border_width = 2
    naughty.config.defaults.border_color = gh_blue
    naughty.config.defaults.width = 500
    naughty.config.defaults.font = beautiful.font or "Roboto Mono Nerd Font 12"
    naughty.config.defaults.margin = 10
    naughty.config.defaults.padding = 20
    
    -- Add icon paths
    naughty.config.icon_dirs = {
        "/usr/share/icons/Papirus/96x96/devices/",
        "/usr/share/icons/Papirus/48x48/status/",
        "/usr/share/icons/Papirus/96x96/apps/"
    }
    naughty.config.icon_formats = { "png", "svg" }
    
    -- Configure urgency presets
    naughty.config.presets = {
        low = {
            bg = gh_bg,
            fg = gh_comment,
            border_color = gh_blue,
            timeout = 10
        },
        normal = {
            bg = gh_bg,
            fg = gh_fg,
            border_color = gh_blue,
            timeout = 10
        },
        critical = {
            bg = gh_bg,
            fg = gh_fg,
            border_color = gh_red,
            timeout = 0
        }
    }
    
    print("GitHub-themed notifications configuration applied")
end

return notifications

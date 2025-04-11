local lain = require("lain")
local beautiful = require("beautiful")

local cpu_widget = lain.widget.cpu({
    settings = function()
        local usage = cpu_now.usage  -- Provided by Lain
        local markup = string.format("<span color='%s'>CPU:</span> %d%%",
                                       beautiful.fg_focus or "#ffffff", usage)
        widget:set_markup(markup)
    end
})

return cpu_widget

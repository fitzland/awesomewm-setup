local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

client.connect_signal("request::titlebars", function(c)
  local buttons = gears.table.join(
    awful.button({ }, 1, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      c:emit_signal("request::activate", "titlebar", {raise = true})
      awful.mouse.client.resize(c)
    end)
  )

  -- Create a vertical titlebar on the left, with a fixed size (adjust dpi(30) as needed)
  awful.titlebar(c, { position = "left", size = dpi(30) }):setup {
    {
      -- Top part: the window’s icon
      awful.titlebar.widget.iconwidget(c),
      layout = wibox.layout.fixed.vertical,
    },
    nil, -- Middle: you can optionally insert the window's title here, or leave it empty
    {
      -- Bottom part: standard buttons
      awful.titlebar.widget.floatingbutton(c),
      awful.titlebar.widget.maximizedbutton(c),
      awful.titlebar.widget.stickybutton(c),
      awful.titlebar.widget.ontopbutton(c),
      awful.titlebar.widget.closebutton(c),
      layout = wibox.layout.fixed.vertical,
    },
    layout = wibox.layout.align.vertical
  }
end)

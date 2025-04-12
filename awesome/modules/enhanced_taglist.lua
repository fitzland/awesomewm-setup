-- Enhanced taglist with application icons
-- Add this to your wibar.lua or create a new module

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

-- Function to create the enhanced taglist
local function create_enhanced_taglist(s)
    -- Create a taglist widget
    local taglist = awful.widget.taglist {
        screen = s,
        filter = function(t) 
            -- Only show occupied tags and the active tag
            return #t:clients() > 0 or t.selected 
        end,
        buttons = gears.table.join(
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
        ),
        widget_template = {
            {
                {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                {
                    id = 'app_icons',
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 2,
                },
                layout = wibox.layout.fixed.vertical,
            },
            id = 'background_role',
            widget = wibox.container.background,
            
            -- Add app icons to the tag
            create_callback = function(self, tag, index, tags)
                -- Update the tag text (usually the tag name/number)
                local text_widget = self:get_children_by_id('text_role')[1]
                text_widget:set_text(tag.name)
                
                -- This function updates the application icons
                local update_app_icons = function()
                    local app_icons = self:get_children_by_id('app_icons')[1]
                    app_icons:reset()
                    
                    -- Get clients in the tag
                    local clients = tag:clients()
                    
                    -- Icon size limit (adjust as needed)
                    local icon_size = 16
                    local max_icons = 5  -- Show at most 5 icons per tag
                    
                    -- Add an icon for each client (up to max_icons)
                    for i, c in ipairs(clients) do
                        if i <= max_icons then
                            local icon = wibox.widget.imagebox()
                            icon.forced_width = icon_size
                            icon.forced_height = icon_size
                            
                            -- Try to get client icon or use default
                            local client_icon = c.icon or beautiful.awesome_icon
                            if client_icon then
                                icon:set_image(gears.surface(client_icon))
                            end
                            
                            -- Add tooltip to show client name on hover
                            local tooltip = awful.tooltip({ 
                                objects = { icon },
                                delay_show = 1,
                            })
                            tooltip:set_text(c.name or "Unknown")
                            
                            app_icons:add(icon)
                        end
                    end
                    
                    -- If we have more clients than max_icons, add an ellipsis
                    if #clients > max_icons then
                        local more = wibox.widget.textbox("+" .. (#clients - max_icons))
                        more.font = beautiful.font
                        app_icons:add(more)
                    end
                end
                
                -- Initial update
                update_app_icons()
                
                -- Update when clients change in the tag
                tag:connect_signal("property::clients", update_app_icons)
                
                -- Clean up signal connection when widget is removed
                self.update_app_icons = update_app_icons
            end,
            
            update_callback = function(self, tag, index, tags)
                -- Update the background based on tag state
                local bg_widget = self:get_children_by_id('background_role')[1]
                if tag.selected then
                    bg_widget.bg = beautiful.taglist_bg_focus or "#5294e2"
                elseif #tag:clients() > 0 then
                    bg_widget.bg = beautiful.taglist_bg_occupied or "#3e4451"
                else
                    bg_widget.bg = beautiful.taglist_bg_empty or "#2f343f"
                end
                
                -- Update application icons
                if self.update_app_icons then
                    self.update_app_icons()
                end
            end,
            
            -- Clean up signals when widget is removed
            remove_callback = function(self, tag, index, tags)
                tag:disconnect_signal("property::clients", self.update_app_icons)
                self.update_app_icons = nil
            end,
        },
    }
    
    return taglist
end

-- Example usage in your wibar setup
local function setup_enhanced_taglist(s)
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })
    
    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            create_enhanced_taglist(s),
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end

return {
    create_enhanced_taglist = create_enhanced_taglist,
    setup_enhanced_taglist = setup_enhanced_taglist
}

-- Enhanced taglist with multiple app icons
-- Replace your current widgets.create_taglist function with this

function widgets.create_taglist(s)
    return awful.widget.taglist {
        screen = s,
        filter = function(t) 
            -- Only show occupied tags and the active tag
            return #t:clients() > 0 or t.selected 
        end,
        buttons = awful.button.join(
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ variables.modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ variables.modkey }, 3, function(t)
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
                    -- Standard tag text
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    left = 7,
                    right = 7,
                    widget = wibox.container.margin
                },
                -- Container for app icons
                {
                    id = 'app_icons',
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 2,
                },
                spacing = 4,
                layout = wibox.layout.fixed.horizontal,
            },
            id = 'background_role',
            widget = wibox.container.background,
            
            -- Add app icons to the tag
            create_callback = function(self, tag, index, tags)
                -- This function updates the application icons
                local update_app_icons = function()
                    local icon_container = self:get_children_by_id('app_icons')[1]
                    icon_container:reset()
                    
                    -- Get clients in the tag
                    local clients = tag:clients()
                    local icon_size = 16  -- Icon size (adjust as needed)
                    
                    -- Add an icon for each client
                    for _, c in ipairs(clients) do
                        local icon = wibox.widget.imagebox()
                        icon.forced_width = icon_size
                        icon.forced_height = icon_size
                        
                        -- Try to get client icon or use default
                        local client_icon = c.icon
                        if client_icon then
                            icon:set_image(gears.surface(client_icon))
                        else
                            -- Use a default icon if client icon is not available
                            -- Commenting out default icon to avoid empty space
                            -- icon:set_image(beautiful.awesome_icon)
                            icon.forced_width = 0
                        end
                        
                        -- Add tooltip to show client name on hover
                        local tooltip = awful.tooltip({ 
                            objects = { icon },
                            delay_show = 1,
                        })
                        tooltip:set_text(c.name or "Unknown")
                        
                        icon_container:add(icon)
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
                -- Update application icons
                if self.update_app_icons then
                    self.update_app_icons()
                end
            end,
            
            -- Clean up signals when widget is removed
            remove_callback = function(self, tag, index, tags)
                if self.update_app_icons then
                    tag:disconnect_signal("property::clients", self.update_app_icons)
                    self.update_app_icons = nil
                end
            end,
        },
    }
end

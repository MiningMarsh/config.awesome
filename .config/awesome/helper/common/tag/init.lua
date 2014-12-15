awful = require("awful")

return {focused = function(self)
            local screen
            if client.focus then
                screen = client.focus.screen
            else
                screen = mouse.screen
            end

            local selected = awful.tag.selected(screen)
            return awful.tag.getidx(selected), selected
        end,

        kill = function(self)
            local _, tag = self:focused()
            for _, client in pairs(tag:clients()) do
                client:kill()
            end
        end,

        focus = function(self, tag)
            awful.tag.viewonly(tag)
        end}



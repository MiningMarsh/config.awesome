local awful     = require("awful")
local common    = require("helper.common")
local decorator = require("helper.decorator")

return {idx = require("helper.tag.idx"),

        kill = decorator:savetagfocus(function(self, id)
            self:focus(id)
            common.tag:kill()
        end),

        focus = function(self, id)
            local tag
            if not client.focus then
                tag = awful.tag.gettags(mouse.screen)[id]
            else
                tag = awful.tag.gettags(client.focus.screen)[id]
            end
            awful.tag.viewonly(tag)
        end,

        focused = function(self)
            return common.tag:focused()
        end}


local awful     = require("awful")
local decorator = require("helper.decorator")
local common    = require("helper.common")

return {close = decorator:saveclientfocus(function(self, direction)
            local _, old = common.client:focused()
            self:focus(firection)
            local _, new = common.client:focused()
            if new and new ~= old then
                common.client:kill()
            end
        end),

        focus = function(self, direction)
            awful.client.focus.bydirection(direction)
            local focus = client.focus
            if focus then
                focus:raise()
            end
        end}

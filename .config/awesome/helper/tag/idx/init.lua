local awful     = require("awful")
local common    = require("helper.common")
local decorator = require("helper.decorator")

return {kill = decorator:savetagfocus(function(self, idx)
            self:focus(idx)
            common.tag:kill()
        end),

        focus = function(self, idx)
            local f
            if idx > 0 then
                f = awful.tag.viewnext
            else
                f = awful.tag.viewprev
                idx = idx * -1
            end

            while idx > 0 do
                f()
                idx = idx - 1
            end
        end}

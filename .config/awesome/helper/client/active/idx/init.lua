local awful = require("awful")
local tag = require("helper.tag")
local decorator = require("helper.decorator")
local common = require("helper.common")

return {focus = function(self, idx)
            awful.client.focus.byidx(idx)
        end,

        close = decorator:saveclientfocus(function(self, idx)
            local _, old = common.client:focused()
            self:focus(idx)
            local _, new = common.client:focused()
            if new ~= old then
                common.client:kill()
            end
        end),

        move = decorator:saveclientfocus(function(self, idx)
            local c = client.focus
            if c then
                tag.idx:focus(idx)
                local _, tag = tag:focused()
                awful.client.movetotag(tag, c)
            end
        end)}

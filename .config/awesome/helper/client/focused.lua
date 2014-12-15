local active = require("helper.client.active")
local awful     = require("awful")
local tag = require("helper.tag")
local decorator = require("helper.decorator")
local common = require("helper.common")

return {incsize = function(self, size)
            local _, focused = active:focused()
            local total = active:total()
            if focused == total then
                awful.client.incwfact(size)
            else
                awful.client.incwfact(size * -1)
            end
        end,

        move = decorator:moveclienttotag(function(self, id)
            tag:focus(id)
        end),

        swap = function(self, id)
            local _, focused = common.client:focused()
            active:get(id):swap(focused)
        end}

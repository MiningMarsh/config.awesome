local awful  = require("awful")
local common = require("helper.common")

return {direction = require("helper.client.active.direction"),
        idx       = require("helper.client.active.idx"),

        focused = common.client.focused,

        get = function(self, id)
            local master = common.client:master()
            local target = id - 1
            local numclients = self:total()
            if target < numclients then
                return awful.client.next(target, master)
            end
        end,

        kill = function(self, id)
            self:get(id):kill()
        end,

        focus = function(self, id)
            common.client:focus(self:get(id))
        end,

        total = function(self)
            -- Get the master client.
            local master = awful.client.getmaster()

            -- Get number of clients.
            local numclients = 1
            while master ~= awful.client.next(numclients, master) do
                numclients = numclients + 1
            end

            return numclients
        end}


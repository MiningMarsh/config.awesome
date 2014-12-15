local awful = require("awful")
local common = require("helper.common")

return {-- Decorates a function. That function will now restore the focused
        -- client after being run, even if it changed the focused client while
        -- running.
        saveclientfocus = function(self, f)

            -- Return the decorated function.
            return function(...)
                -- Save the focused client.
                local focused = client.focus

                -- Call the function, and save the values that it returns.
                local values = {f(...)}

                -- Focus the previously focused client.
                common.client:focus(focused)

                -- Return the values that the function returned.
                return unpack(values)
            end
        end,

        -- Decorates a function. That function will now restore the focused tag
        -- after being run, even if it changed the focused tag while running.
        savetagfocus = function(self, f)

            -- Return the decorated function.
            return function(...)

                -- Save the currently focused tag.
                local _, focused = common.tag:focused()

                -- Call the function, and save the values that it returns.
                local values = {f(...)}

                -- Focus the previously focused tag.
                common.tag:focus(focused)

                -- Return the values that the function returned.
                return unpack(values)
            end
        end,

        savefocus = function(self, f)
            return self:savetagfocus(self:saveclientfocus(f))
        end,

        moveclienttotag = function(self, f)
            -- Return the decorated function.
            return function(...)
                local _, focused = common.client:focused()

                -- Call the function, and save the values that it returns.
                local values = {f(...)}

                -- Focus the previously focused client.
                local _, tag = common.tag:focused()
                awful.client.movetotag(tag, focused)
                awful.tag.viewonly(tag)

                -- Return the values that the function returned.
                return unpack(values)
            end
        end}

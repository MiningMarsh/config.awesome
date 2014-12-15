return {focus = function(self, c)
            if c then
                client.focus = c
                c:raise()
            end
        end,

        master = function(self)
            return awful.client.getmaster()
        end,

        focused = function(self)
            -- Store the focused client.
            local focus = client.focus

            -- Get the master client.
            local master = awful.client.getmaster()

            -- Find out the position of the master relative to the focused
            -- client.
            local focusnum = 0
            while focus ~= awful.client.next(focusnum, master) do
                focusnum = focusnum + 1
            end

            return focusnum, client.focus
        end,

        kill = function(self)
            local _, c = self:focused()
            if c then
                c:kill()
            end
        end}

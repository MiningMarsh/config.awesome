local naughty = require("naughty")
local awful   = require("awful")

return function(self, args)
    local packet = {
        current = {
            client = self.current:client(),
            master = self.current:master(),
            screen = self.current:screen(),
            tag    = self.current:tag(),
        }
    }

    local response = args.movement(packet)

    if packet.current.client
    and packet.current.tag == awful.tag.selected() then
        client.focus = packet.current.client
        client.focus:raise()
    end

    awful.tag.viewonly(packet.current.tag)

    if response and not response.cancel then
        return args.command(packet)
    end
end

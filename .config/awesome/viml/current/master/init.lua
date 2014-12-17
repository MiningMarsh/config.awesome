local awful = require("awful")

return function(self)
    return awful.client.getmaster(self:screen())
end

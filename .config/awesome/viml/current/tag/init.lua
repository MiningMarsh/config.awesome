local awful = require("awful")

return function(self)
    return awful.tag.selected(self:screen())
end


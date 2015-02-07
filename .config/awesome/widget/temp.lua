local wibox = require("wibox")
local beautiful = require("beautiful")
-- Load our theme file.
beautiful.init(".config/awesome/theme.lua")

local widget = wibox.widget.textbox()

local update = function()
    local file = io.popen("temperature")
    widget:set_text(file:read("*n"))
    file:close()
end

update()

local timer = timer({timeout = 1})

timer:connect_signal("timeout", update)

timer:start()

return function()
    return widget
end

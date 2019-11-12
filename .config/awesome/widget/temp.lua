-- TODO: Eventually this file should be swapped out with something that uses the
-- 'cpu' monitor package instead of just doing it itself.
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Load our theme file.
beautiful.init(".config/awesome/theme.lua")

local widget = wibox.widget.textbox()

local update = function()
   local file = io.open('/sys/devices/platform/coretemp.0/hwmon/hwmon2/temp1_input')
   if not file then
      return
   end
   widget:set_text(file:read("*n") / 1000)
   file:close()
end

update()

local timer = timer({timeout = 1})

timer:connect_signal("timeout", update)

timer:start()

return function()
   return widget
end

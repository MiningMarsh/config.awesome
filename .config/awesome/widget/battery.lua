local battery_factory = require('monitor.battery')
local color           = require('gears.color')
local make_widget     = require('widget.make_widget')

-- A factory for creating battery widgets.
--
--
-- Optional Arguments:
--  width - The desired width of the widget.
--  height - The desired height of the widget. This may be ignored if the
--           drawing subsystem ignores this hint.
--  battery_path - The path to the battery status information of the battery we
--                 want to monitor. This defaults to a battery that most
--                 systems with a battery are expected to expose.
--
-- Returns:
--  The battery monitor for the requested battery.
function new(width, height, battery_path)

    -- Tracks the designed width and height of the widget.
    width = width or 20
    height = height or nil

    -- The battery object we are returning.
    local battery = nil

    -- If no path was given, use the default.
    if battery_path then
       battery = battery_factory(battery_path)
    else
       battery = battery_factory()
    end

    -- Create the widget.
    local battery_monitor = make_widget(width, height, 2)

    -- Initialize the charge state.
    local charge = battery:charge()

    -- Draws the widget.
    --
    -- Arguments:
    --  wibox - The wibox we are drawing the widget inside.
    --  cr - The cairo context to draw in.
    --  width - The width of the cairo context we were provided.
    --  height - The height of the cairo context we were provided.
    function battery_monitor:draw(cr, width, height)

      if charge <= 0.15 then
         cr:set_source(color("#ff0000"))
      end
      cr:rectangle(0, 1, (width - 3.5) * charge + 1, height - 1.5)
      cr:fill()

      cr:set_source(color("#7e9e7e"))
      cr:move_to(0, height - 0.5)
      cr:line_to(width - 2.5, height - 0.5)
      cr:line_to(width - 2.5, 0.5)
      cr:line_to(0.5, 0.5)
      cr:line_to(0.5 , height - 0.5)
      cr:move_to(width - 0.5, 2)
      cr:line_to(width - 0.5, height - 2)
      cr:move_to(width - 1.5, 2)
      cr:line_to(width - 1.5, height - 2)
      cr:stroke()
   end

   function battery_monitor:update()
      charge = battery:charge()
   end

   function battery_monitor:drawable()
      if battery:on_ac() then
         return charge < 0.95
      else
         return charge < 0.33
      end
   end

   return battery_monitor
end

return new

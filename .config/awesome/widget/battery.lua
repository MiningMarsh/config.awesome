local make_widget = require("widget.make_widget")
local color = require("gears.color")
local battery_factory = require("monitor.battery")

function new(width, height, battery_path)

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
    local battery_monitor = make_widget(width, height, 60)

    -- Initialize the charge state.
    local charge = battery:charge()
    -- Draws the widget.
    function battery_monitor:draw(wibox, cr, width, height)

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

        cr:rectangle(0, 1, math.floor((width - 3.5) * charge + 1), height - 1.5)

        cr:fill()
    end

    function battery_monitor:update()
        charge = battery:charge()
    end

    return battery_monitor
end

return new

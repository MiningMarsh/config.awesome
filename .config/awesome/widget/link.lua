local make_widget = require("widget.make_widget")
local link_factory = require("monitor.link")
local graphic = require("graphic")

function new(width, height, physical_interface, wireless_interface)

    width = width or 20
    height = height or nil

    -- The battery object we are returning.
    local link = {}

    -- Create our link monitor.
    link = link_factory(physical_interface, wireless_interface)

    -- Create the widget.
    local link_monitor = make_widget(width, height, 1)

    -- Initialize the charge state.
    local quality = link:quality()

    -- Draws the widget.
    function link_monitor:draw(cr, width, height)
        local triangle = graphic.polygon(cr)
        local h = height - height * quality
        local e = width * quality

        cr:move_to(0.5, height - 0.5)
        cr:line_to(width - 0.5, height - 0.5)
        cr:line_to(width - 0.5, 0)
        cr:stroke()

        triangle:add_point(0.5, height - 0.5)
        triangle:add_point(e - 0.5, height - 0.5)
        triangle:add_point(e - 0.5, h)
        triangle:draw()
        cr:fill()
    end

    function link_monitor:drawable()
        return link:on_wireless() and not link:on_ethernet()
    end

    function link_monitor:update()
        quality = link:quality()
    end

    return link_monitor
end

return new

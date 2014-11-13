local make_widget = require("widget.make_widget")
local link_factory = require("monitor.link")

function new(width, height, interface)

    width = width or 20
    height = height or nil

    -- The battery object we are returning.
    local link = {}

    -- If no path was given, use the default.
    if interface then
        link = link_factory(interface)
    else
        link = link_factory()
    end

    -- Create the widget.
    local link_monitor = make_widget(width, height, 5)

    -- Initialize the charge state.
    local quality = link:quality()

    -- Draws the widget.
    function link_monitor:draw(wibox, cr, width, height)
        cr:move_to(0 , height - 0.5)
        cr:line_to(width - 0.5, height - 0.5)
        cr:line_to(width - 0.5,  0)
        cr:line_to(0.5,  height - 0.5)
        cr:stroke()

        for i=1,width*quality do
            cr:move_to(i - 0.5, height - 0.5)
            cr:line_to(i - 0.5, ((height - 0.5) * (1 - (i/width))))
        end
        cr:stroke()
    end

    function link_monitor:update()
        quality = link:quality()
    end

    return link_monitor
end

return new

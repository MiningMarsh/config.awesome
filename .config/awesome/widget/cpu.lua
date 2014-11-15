local cpu_factory = require("monitor.cpu")
local graph_factory = require("struct.graph")
local make_widget = require("widget.make_widget")

function new(width, height)

    widget_width = widget_width or 20
    widget_height = widget_height or nil

    local cpu = cpu_factory()

    local graph = graph_factory(width + 10)

    -- Create the widget.
    local cpu_monitor = make_widget(width, height, 0.5)

    -- Draws the widget.
    function cpu_monitor:draw(wibox, cr, width, height)

        local function h(i)
            return height - (height * graph:peek(width - i + 1)) + 0.5
        end

        cr:move_to(0, height - 0.5)
        cr:line_to(width, height - 0.5)

        cr:move_to(0.5, height)
        cr:line_to(0.5, h(1))

        cr:move_to(width - 0.5, height)
        cr:line_to(width - 0.5, h(width))

        cr:move_to(0, h(1))
        for i = 2, width do
            cr:line_to(i - 0.5, h(i))
            cr:line_to(i - 0.5, height)
            cr:line_to(i - 0.5, h(i))
        end

        cr:stroke()
    end

    function cpu_monitor:update()
        graph:push(cpu:usage())
    end

    return cpu_monitor
end

return new

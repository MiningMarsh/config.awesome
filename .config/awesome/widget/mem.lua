local mem_factory = require("monitor.mem")
local graph_factory = require("struct.graph")
local make_widget = require("widget.make_widget")

function new(width, height)

    widget_width = width or 20
    widget_height = height or nil

    local mem = mem_factory()

    local graph = graph_factory(widget_width + 10)

    -- Create the widget.
    local mem_monitor = make_widget(widget_width, widget_height, 0.1)

    -- Draws the widget.
    function mem_monitor:draw(cr, width, height)

        local function h(i)
            return height - (height * graph:peek(width - i + 1)) + 0.5
        end

        --cr:move_to(0, height - 0.5)
        --cr:line_to(width, height - 0.5)

        cr:move_to(0.5, height)
        cr:line_to(0.5, h(1))

        cr:move_to(width - 0.5, height)
        cr:line_to(width - 0.5, h(width))

        cr:move_to(0, h(1))
        for i = 2, width do
            cr:line_to(i - 0.5, h(i))
        end

        cr:stroke()
    end

    function mem_monitor:update()
        graph:push(mem:usage())
    end

    function mem_monitor:drawable()
        for i = 1, width do
            if graph:peek(i) > 0.25 then
                return true
            end
        end

        return false
    end

    return mem_monitor
end

return new

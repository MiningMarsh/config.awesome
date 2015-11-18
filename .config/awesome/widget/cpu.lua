local cpu_factory = require("monitor.cpu")
local graph_factory = require("struct.graph")
local make_widget = require("widget.make_widget")
local graphic = require("graphic")

function new(width, height)

    widget_width = widget_width or 20
    widget_height = widget_height or nil

    local cpu = cpu_factory()

    local graph = graph_factory(width + 10)

    -- Create the widget.
    local cpu_monitor = make_widget(width, height, 0.5)

    -- Draws the widget.
    function cpu_monitor:draw(wibox, cr, width, height)

        cr:move_to(0, height - 0.5)
        cr:line_to(width, height - 0.5)
        cr:stroke()

        local function h(i)
            return height - (height * graph:peek(width - i + 1))
        end

        local g = graphic.polygon(cr)
        g:add_point(width, height)
        g:add_point(0, height)
        for i = 0, width do
            g:add_point(i, h(i))
        end
        g:draw()
        cr:fill()

    end

    function cpu_monitor:update()
        graph:push(cpu:usage())
    end

    function cpu_monitor:drawable()
        for i = 1, width do
            if graph:peek(i) > 0.25 then
                return true
            end
        end

        return false
    end

    return cpu_monitor
end

return new

local cpu_factory = require("monitor.cpu")
local graph_factory = require("struct.graph")
local make_widget = require("widget.make_widget")
local graphic = require("graphic")

function new(width, height, firstcpu, lastcpu)

    lastcpu = lastcpu or firstcpu

    widget_width = widget_width or 20
    widget_height = widget_height or nil

    local cpus = {}
    for i = firstcpu, lastcpu do
        cpus[i] = cpu_factory(i)
    end

    local function usage()
        local run = 0
        for _, cpu in ipairs(cpus) do
            run = run + cpu:usage()
        end

        return run / (lastcpu - firstcpu + 1)
    end

    local graph = graph_factory(width + 10)

    -- Create the widget.
    -- Used to be half a second.
    local cpu_monitor = make_widget(width, height, 0.3)

    -- Draws the widget.
    function cpu_monitor:draw(wibox, cr, width, height)

        --cr:move_to(0, height - 0.5)
        --cr:line_to(width, height - 0.5)
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
        graph:push(usage())
    end

    local last = false
    function cpu_monitor:drawable()
        for i = 1, width do
            if graph:peek(i) > 0.8 then
                return true
            end
        end

        return true
    end

    return cpu_monitor
end

return new

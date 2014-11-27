local struct = require("struct")

function new(cairo)
    -- Holds the list of points.
    local queue = struct.queue()
    local polygon = {}

    -- Push a new point to the polygon
    function polygon:add_point(x, y)
        queue:add({x = x, y = y})
    end

    function polygon:draw()
        if not queue:empty() then
            local point = queue:remove()
            cairo:move_to(point.x, point.y)

            while not queue:empty() do
                local point = queue:remove()
                cairo:line_to(point.x, point.y)
            end

            cairo:line_to(point.x, point.y)
            cairo:close_path()
        end
    end

    return polygon
end

return new

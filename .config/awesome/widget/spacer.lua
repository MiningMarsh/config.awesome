local make_widget = require("widget.make_widget")

function new(width)

    -- Create the widget.
    local spacer = make_widget(0, 8, nil, width)

    -- Draws the widget.
    function spacer:draw(wibox, cr, width, height)
    end

    -- We never want to be drawm.
    function drawable()
        return false
    end

    return spacer
end

return new

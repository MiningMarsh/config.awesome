local make_widget = require("widget.make_widget")

function new(width)

    -- Create the widget.
    local spacer = make_widget(width, 8)

    -- Draws the widget.
    function spacer:draw(wibox, cr, width, height)
    end

    return spacer
end

return new

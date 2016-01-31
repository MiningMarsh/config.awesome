local make_widget = require("widget.make_widget")

function new(width)

    -- Create the widget.
    local spacer = make_widget(0, 8, nil, width)

    function spacer:fit(w, h)
        return 0, h
    end

    return spacer
end

return new

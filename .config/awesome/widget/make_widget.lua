local cairo = require("lgi")
cairo = cairo.cairo
local base = require("wibox.widget.base")
local color = require("gears.color")

local function new(width, height, interval, seperator_width)

    seperator_width = seperator_width and seperator_width or 5

    -- Create the base widget that does custom drawing handling.
    local metatable = setmetatable({}, {__index = base.make_widget()})

    -- Create the widget to return.
    local widget = setmetatable({}, metatable)

    -- Widget interface is used so that the widget can be
    -- modified, but methods will still be called from
    -- the base widget.
    local widget_interface = setmetatable({}, widget)

    -- Make the assignments to the custom widget.
    function widget:__newindex(key, value)
        widget[key] = value
    end

    -- When indexing, return from the metatables before the interface.
    function widget:__index(key)
        if metatable[key] then
            return metatable[key]
        end

        return rawget(widget, key)
    end

    function metatable:fit(awidth, aheight)
        -- If the widget declares it cannot be drawn, we return 0 width.
        local drawable = rawget(widget, "drawable")
        if drawable then
            if not drawable() then
                return 0, aheight
            end
        end

        local raw = rawget(widget, "fit")
        if raw then
            -- Otherwise, we append the seperator width.
            local rawwidth, rawheight = raw(widget_interface, awidth, aheight)
            return rawwidth + seperator_width, rawheight
        else
            local retwidth, retheight
            retwidth = width and width or awidth
            retheight = height and height or aheight
            return width + seperator_width, height
        end
    end

    function metatable:draw(wibox, cr, awidth, aheight)

        -- If we were given no actual drawble region, assume we can't be drawn.
        if awidth <= 0 then
            return
        end

        -- Find out how much padding to give the widget.
        local padding = 0
        local passed_height = aheight

        -- If the widget has a fixed height, pad it.
        if height then
            padding = height > aheight and 0 or (aheight - height) / 2
            -- Figure out the height to report to the widget.
            passed_height = height > aheight and aheight or height
        end

        -- The context to pass to the widget.
        local surface = cairo.ImageSurface.create('ARGB32', width, passed_height)
        local newcr = cairo.Context.create(surface)

        -- Initialize the new cairo context's state.
        newcr:set_line_width(1)
        newcr:set_source(color("#7e9e7e"))

        -- Have the widget draw to the new context.
        local fn = rawget(widget, "draw")
	if fn then
	   fn(widget_interface, wibox, newcr, width, passed_height)
	end

        -- Paint the new context onto the actual context.
        cr:set_source_surface(surface, seperator_width, padding)
        cr:paint()
    end

    function metatable:update()
        local raw = rawget(widget, "update")
        if raw then
            raw(widget_interface)
        end
        widget_interface:emit_signal("widget::updated")
    end

    -- If an update interval was specified.
    if interval then
        -- Update the charge state every interval.
        local update_timer = timer({timeout = interval})
        update_timer:connect_signal("timeout", function()
            widget_interface:update()
        end)
        update_timer:start()
    end

    return widget_interface
end

return new

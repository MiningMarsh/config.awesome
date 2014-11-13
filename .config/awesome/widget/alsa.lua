local make_widget = require("widget.make_widget")
local alsa_factory = require("monitor.alsa")

local metatable = {}
local object = setmetatable({}, metatable)
local instances = setmetatable({}, {__mode = "v"})

function object:update()
    for k, alsa in pairs(instances) do
        alsa:update()
    end
end

function object:new(width, height)

    width = width or 20
    height = height or nil

    -- The battery object we are returning.
    local alsa = {}

    -- If no path was given, use the default.
    if interface then
        alsa = alsa_factory(interface)
    else
        alsa = alsa_factory()
    end

    -- Create the widget.
    local alsa_monitor = make_widget(width, height)

    -- Initialize the charge state.
    local volume = alsa:volume()

    -- Draws the widget.
    function alsa_monitor:draw(wibox, cr, width, height)

        local top = height - 2
        local bottom = 2
        cr:move_to(0.5, bottom)
        cr:line_to(0.5, top)
        if alsa:muted() then
            -- Draw a muted speaker icon.
            cr:stroke()
            cr:rectangle(1, bottom, 1, 1)
            cr:rectangle(2, bottom - 1, 1, 1)
            cr:rectangle(3, bottom - 2, 1, 1)
            cr:rectangle(1, top - 1, 1, 1)
            cr:rectangle(2, top, 1, 1)
            cr:rectangle(3, top + 1, 1, 1)
            cr:fill()
        else
            -- Draw a filled speaker icon.
            cr:move_to(1.5, bottom)
            cr:line_to(1.5, top)
            cr:move_to(2.5, bottom - 1)
            cr:line_to(2.5, top + 1)
            cr:move_to(3.5, 0)
            cr:line_to(3.5, height)
        end
        cr:move_to(4.5, 0)
        cr:line_to(4.5, height)

        volume = alsa:volume()

        -- Draw underline.
        cr:move_to(7, height - 1.5)
        cr:line_to(width, height - 1.5)

        if math.floor(7 + (width - 7) * volume) ~= 7 then
            for i = 7, 7 + (width - 7) * volume do
                local twidth = width - 7
                cr:move_to(i - 0.5, height - 1)
                cr:line_to(i - 0.5, height - 1.5 - (height - 2.5) * ((i - 7)/twidth))
            end
        end

        cr:stroke()
    end

    instances[#instances + 1] = alsa_monitor

    return alsa_monitor
end

metatable.__call = function(self, width, height) return object:new(width, height) end

return object

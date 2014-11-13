

function new(name)
    -- The name of the interface we are grabbing.
    name = name or "wlan0"
    -- The link object we are returning.
    local link = {}

    -- Return quality of this link.
    function link:quality()
        local file = assert(io.open("/proc/net/wireless"))

        assert(file:read("*line"))
        assert(file:read("*line"))
        assert(file:read(7))
        assert(file:read("*number"))

        return assert(file:read("*number")) / 100
    end

    return link
end

return new

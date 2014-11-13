local function new()
    local mem = {}

    function mem:usage()
        local file = assert(io.open("/proc/meminfo"))

        assert(file:read(9))
        local total = assert(file:read("*number"))
        assert(file:read("*line"))

        assert(file:read(8))
        local free = assert(file:read("*number"))
        assert(file:read("*line"))

        assert(file:read("*line"))

        assert(file:read(8))
        free = free + assert(file:read("*number"))
        assert(file:read("*line"))

--        assert(file:read(7))
--        free = free + assert(file:read("*number"))

        file:close()

        return 1 - free / total
    end

    return mem
end

return new

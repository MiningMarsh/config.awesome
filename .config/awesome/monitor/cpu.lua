local function new()
    local cpu = {}
    local last = {}
    last.idle = 0
    last.working = 0

    function cpu:usage()
        local stat = io.open("/proc/stat")
        -- Skip header
        stat:read(5)

        local working = 0
        local idle = 0

        local function next()
            return stat:read("*number")
        end

        working = next() + next() + next()
        idle = next()
        working = working + next() + next() + next() + next() + next() + next()

        local between = {}
        between.idle = idle - last.idle
        between.working = working - last.working

        last.idle = idle
        last.working = working

        stat:close()
        return between.working / (between.working + between.idle)
    end

    function cpu:temperature()
        local file = io.popen("temperature")
        local temperature = file:read("*n")
        file:close()
        return temperature
    end

    return cpu
end

return new

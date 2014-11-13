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
        local file = assert(io.popen(" sensors | grep 'Core 0' | awk '{print $3;}' | cut -d'+' -f2 | cut -d'.' -f 1"))
        local percent = assert(file:read("*number")) / 90
        file:close()
        return percent
    end

    return cpu
end

return new

function new(name)
    -- The name of the interface we are grabbing.
    name = name or "wlan0"
    -- The link object we are returning.
    local link = {}

    local checklink = function(interface)
        local state = io.open("/sys/class/net/" .. interface .. "/operstate")
        if state and state:read("*l") == "up" then
        	state = io.open("/sys/class/net/" .. interface .. "/carrier")
        	if state and state:read("*n") == 1 then
                state:close()
        		return true
        	end
        end

        if state then
            state:close()
        end

        return false
    end

    -- Returns whether we are on ethernet
    function link:on_ethernet()
        return checklink("enp4s0")
    end

    -- Returns whether we are on a wireless connection.
    function link:on_wireless()
        return checklink("wlp5s0")
    end

    -- Return quality of this link.
    function link:quality()
        if link:on_ethernet() then
            return 100
        end

        local file = assert(io.open("/proc/net/wireless"))

        file:read("*line")
        file:read("*line")
        file:read(7)
        file:read("*number")

        local num = file:read("*number")

        file:close()

        if num then
            return num / 100
        else
            return 0
        end
    end

    return link
end

return new

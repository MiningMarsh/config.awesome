local actions = require("actions")

local function new()
    local alsa = {}

    function alsa:volume()
        return actions.volume:get()
    end

    function alsa:muted()
        return actions.volume:muted()
    end

    return alsa
end

return new

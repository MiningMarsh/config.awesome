local function new()
    local alsa = {}

    function alsa:volume()
        local file = assert(io.popen("amixer get Master | grep -oE '[0-9]+[%]' | head -n1 | cut -d'%' -f1"))
        local percent = assert(file:read("*number")) / 100
        file:close()
        return percent
    end

    function alsa:muted()
        local file = assert(io.popen("amixer get Master | grep -Eo 'off|on' | tail -n1"))
        local muted = assert(file:read("*all")) == "off\n"
        file:close()
        return muted
    end

    return alsa
end

return new

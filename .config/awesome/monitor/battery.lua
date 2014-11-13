local io = require("io")

local function new(battery_path)
    local path = {base = battery_path or "/sys/class/power_supply/BAT1/",
                  full = "charge_full",
                  now = "charge_now",
                  full_design = "charge_full_design"}

    local battery = {}

    function battery:property(property)
        property = io.open(
                       path.base .. (path[property] or property),
                       "r"
                   )
        if property then
            local prop = property:read("*number")
            property:close()
            return prop
        else
            return nil
        end
    end

    function battery:charge()
        local full = battery:property("full")
        if full then
            return
                battery:property("now")
                / full
        else
            return 0
        end
    end

    return battery
end

return new

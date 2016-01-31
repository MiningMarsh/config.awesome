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

    function battery:string_property(property)
        property = io.open(
                       path.base .. (path[property] or property),
                       "r"
                   )
        if property then
            local prop = property:read("*l")
            property:close()
            return prop
        else
            return nil
        end
    end

    function battery:on_ac()
        if not battery:exists() then
            return true
        end

        local status = battery:string_property("status")
        if not status then
            return true
        end

        if status == "Discharging" then
            return false
        end

        return true
    end

    function battery:exists()
        local full = battery:property("full")
        return full ~= nil
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

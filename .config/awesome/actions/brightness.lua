-- The brightness API object.
local brightness = {}

-- Internal DBUS API wrapper object we use for manipulating the brightness dbus
-- value.
local dbus = {
   -- The qdbus command prefix for manipulating brightness.
   prefix = "qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement/Actions/BrightnessControl"
}

-- Get a dbus property.
function dbus:get(value)

   -- Instaniate a dbus call to get the property.
   local dbus = io.popen(self.prefix .. " " .. value)

   -- Read the returned value.
   local value = dbus:read()

   -- Close the process.
   dbus:close()

   -- Return the found value.
   return value
end

-- Set the dbus brightness to the given value.
function dbus:set(value)

   -- Make sure the value is not a float.
   value = math.floor(value)

   -- Instantiate the creation process.
   local dbus = io.popen(self.prefix .. " setBrightness " .. tostring(value))

   -- Close the DBUS process.
   dbus:close()
end

-- Return the current brightness value.
local function current()
   return tonumber(dbus:get("brightness"))
end

-- Return the max allowed brightness value.
local function max()
   return tonumber(dbus:get("brightnessMax"))
end

-- Return the current brightness percentage.
function brightness:get()
   return current() / max()
end

-- Set the current brightness percentage.
function brightness:set(value)

   -- Make sure that the value is below 100%
   if value > 1 then
      value = 1
   end

   -- Make sure the value is above 0%
   if value < 0 then
      value = 0
   end

   -- Set new brightness value, as percentage of max value.
   dbus:set(value * max())
end

-- Increase the brightness by value.
function brightness:increase(value)
   self:set(self:get() + value)
end

-- Decrease the brightness by value.
function brightness:decrease(value)
   self:set(self:get() - value)
end

return brightness

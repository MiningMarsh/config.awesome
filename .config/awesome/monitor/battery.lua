local io = require('io')

-- Creates a battery monitoring object, for querying the system battery for
-- information.
--
-- Optional Arguments:
--  battery_path - A path to the battery to monitor. This defaults to BAT0,
--                 which should be correct for most systems.
--
-- Returns:
--  A battery monitoring object.
local function new(battery_path)

   -- This map can be used to override the path of specific battery properties
   -- that are retreived using `open_property()`.
   local path = {
      base = battery_path or '/sys/class/power_supply/BAT0/',
      full = 'charge_full',
      now = 'charge_now',
      full_design = 'charge_full_design'
   }

   local battery = {}

   -- Returns the file object of the requested property, using overrides as
   -- specified in the top-level path variable.
   --
   -- Arguments:
   --  property - The name of the property to get the path for.
   --
   -- Returns:
   --  The file object of the requested property, or `nil` if the property could
   --  not be accessed.
   function open_property(property)

      -- Load the property file, using the override path if one was specified.
      return io.open(path.base .. (path[property] or property), 'r')
   end

   -- Reads a specific battery property, as a number.
   -- This method allows path overrides provided in the top-level path variable.
   --
   -- Arguments:
   --  property - The name of the property to read.
   --
   -- Returns:
   --  The number representing the value of the property. If no such property
   --  could be found, `nil` is returned.
   function number_property(property)

      -- Load the property file, using the override path if one was specified.
      property = open_property(property)

      -- Fail out if the property doesn't exist.
      if not property then
         return nil
      end

      -- Parse the property out the file as a number, then return that property.
      local value = property:read('*number')
      property:close()
      return value
   end

   -- Reads a specific battery property, as a string.
   -- This method allows path overrides provided in the top-level path variable.
   --
   -- Arguments:
   --  property - The name of the property to read.
   --
   -- Returns:
   --  The number representing the value of the property. If no such property
   --  could be found, `nil` is returned.
   function string_property(property)

      -- Load the property file, using the override path if one was specified.
      property = open_property(property)

      -- Fail out if the property is not found.
      if not property then
         return nil
      end

      -- Read out and return the property value.
      local value = property:read("*l")
      property:close()
      return value
   end

   --
   function battery:on_ac()
      if not battery:exists() then
         return false
      end

      local status = string_property('status')
      if not status then
         return false
      end

      if status == 'Discharging' then
         return false
      end

      return true
   end

   -- Check if the specified battery path exists at all.
   --
   -- Returns:
   --  `true` if the battery exists, `false` otherwise.
   function battery:exists()

      -- We just arbitrarily choose a property every battery uses, and just
      -- checks if it exists.
      local full = number_property('full')

      -- Simply check if the property existed.
      return full ~= nil
   end

   -- Return the battery charge.
   --
   -- Returns:
   --  A percentage of battery charge between 0-1.
   function battery:charge()

      -- Get the properties needed to calculate the charge.
      local full = number_property('full')
      local now = number_property('now')

      -- Die if one of the properties couldn't be found.
      if not full or not now then
	 return 0
      end

      -- Calculate the battery charge.
      return now / full
   end

   -- Return the new battery monitor.
   return battery
end

-- Return the battery monitor factory.
return new

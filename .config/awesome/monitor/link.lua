function new(physical_interface, wireless_interface)

   -- The name of the interface we are grabbing.
   wireless_name = wireless_interface or "wlan0"
   wired_name = physical_interface or "eth0"

   -- The link object we are returning.
   local link = {}

   local function checklink (interface)
      local state = io.open("/sys/class/net/" .. interface .. "/operstate")
      if state and state:read("*l") == "up" then
	 state:close()
	 state = io.open("/sys/class/net/" .. interface .. "/carrier")
	 if state and state:read("*n") == 1 then
	    state:close()
	    return true
	 end
	 state = nil
      end

      if state then
	 state:close()
      end

      return false
   end

   -- Returns whether we are on ethernet
   function link:on_ethernet()
      return checklink(wired_name)
   end

   -- Returns whether we are on a wireless connection.
   function link:on_wireless()
      return checklink(wireless_name)
   end

   -- Return quality of this link.
   function link:quality()
      if link:on_ethernet() then
	 return 100
      end

      local file = assert(io.open("/proc/net/wireless"))

      file:read("*line")
      file:read("*line")
      file:read(string.len(wireless_name) + 1)
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

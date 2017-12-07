--local naughty = require("naughty")

local volume = {}

local func

local function getSink()
   local cmd = io.popen("pactl info | grep 'Default Sink' | awk '{print $3}'")

   local control = cmd:read()
   cmd:close()

   return control
end

local function getVolumeCommand()
    local sink = getSink()

    if not sink then
        return nil
    end

    return "pactl list sinks | grep 'Name: " .. sink .. "' -a10 | grep Volume | egrep -oE '[0-9]+%' | egrep -oE '[0-9]+' | head -n1"
end

local function setVolumeCommand(value)
    local sink = getSink()

    if not sink then
        return nil
    end

    return "pactl set-sink-volume " .. sink .. " " .. tostring(value) .. "%"
end

local function get()
    local get = getVolumeCommand()
    if not get then
        return nil
    end

   local cmd = io.popen(get)
   local result = cmd:read()
   cmd:close()

   return result
end

local function set(new)
    local set = setVolumeCommand(new)
    if not set then
        return nil
    end

   local cmd = io.popen(set)
   cmd:close()
end

local function sanitize(value)
   if value > 1 then
      return 1
   end

   if value < 0 then
      return 0
   end

   return value
end

local function nil0(value)
   local num = tonumber(value)

   if not num then
      return 1.0
   end

   return num
end

function volume:get()
   return sanitize(get() / 100)
end

function volume:set(value)
   set(math.floor(sanitize(value) * 100))
end

function volume:increase(value)
   self:set(self:get() + value)

end

function volume:decrease(value)
   self:increase(-1 * value)
end

function volume:muted()
  return get("mute") == "true"
end

function volume:toggle()
   set("mute", not self:muted())
end

return volume

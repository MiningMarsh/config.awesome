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

local function getMutedCommand()
    local sink = getSink()

    if not sink then
        return nil
    end

    return "pactl list sinks | grep 'Name: " .. sink .. "' -a10 | grep Mute | awk '{print $2}'"
end

local function setVolumeCommand(value)
    local sink = getSink()

    if not sink then
        return nil
    end

    return "pactl set-sink-volume " .. sink .. " " .. tostring(value) .. "%"
end

local function setMutedCommand(value)
    local sink = getSink()

    if not sink then
        return nil
    end

    return "pactl set-sink-mute " .. sink .. " " .. (value and "yes" or "no")
end

local function runCommand(command)
    if not command then
        return nil
    end

    local cmd = io.popen(command)
    local result = cmd:read()
    cmd:close()

    return result
end

local function muted()
    return runCommand(getMutedCommand()) == "yes"
end

local function get()
    return runCommand(getVolumeCommand())
end

local function mute(new)
    runCommand(setMutedCommand(new))
end

local function set(new)
    runCommand(setVolumeCommand(new))
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
  return muted()
end

function volume:toggle()
	mute(not muted())	
end

return volume

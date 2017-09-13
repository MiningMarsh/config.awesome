local naughty = require("naughty")

local volume = {}

local function getControlDevice()
   local cmd = io.popen("qdbus org.kde.kmix /Mixers org.kde.KMix.MixSet.currentMasterControl")

   local control = cmd:read()
   cmd:close()

   return control
end

local function getControlCmd(value)
   local control = getControlDevice()
   if not control then
       return nil
   end

   return "qdbus org.kde.kmix /Mixers/PulseAudio__Playback_Devices_1/" .. control:gsub("[.-]", "_")
end

local function getKMixCmd()
    local cmd = getControlCmd()

    if not cmd then
        return nil
    end

    return getControlCmd() .. " org.kde.KMix.Control."
end

local function get(value)
    local kmix = getKMixCmd()
    if not kmix then
        return nil
    end

   local cmd = io.popen(kmix .. tostring(value))
   local result = cmd:read()
   cmd:close()

   return result
end

local function set(value, new)
    local kmix = getKMixCmd()
    if not kmix then
        return nil
    end

   local cmd = io.popen(kmix .. tostring(value) .. " ".. tostring(new))
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
   return sanitize(
      nil0(get("absoluteVolume"))
      / nil0(get("absoluteVolumeMax")))
end

function volume:set(value)
   set(
      "absoluteVolume",
      math.floor(sanitize(value) * nil0(get("absoluteVolumeMax")))
   )
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

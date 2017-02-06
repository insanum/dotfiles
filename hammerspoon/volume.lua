
--local mash       = {"cmd", "alt", "ctrl"}
--local mash_shift = {"cmd", "alt", "ctrl", "shift"}
local mash       = {"cmd", "ctrl"}
local mash_shift = {"cmd", "ctrl", "shift"}

local VOLUME_MIN  = 0
local VOLUME_MAX  = 100
local VOLUME_STEP = 10

local function volumeAlert(name, volume)
  local numBars = math.floor(volume / VOLUME_STEP)
  local numSpaces = (100 / VOLUME_STEP) - numBars
  hs.alert(name .. ": " ..
           string.rep('||', numBars) ..
           string.rep('..', numSpaces))
end

local function toggleMute()
  local device = hs.audiodevice.defaultOutputDevice()
  local wasMuted = device:muted()
  device:setMuted(not wasMuted)
  volumeAlert(device:name(), wasMuted and device:volume() or 0)
end

local function incVolume()
  local device = hs.audiodevice.defaultOutputDevice()
  local volume = math.min(device:volume() + VOLUME_STEP, VOLUME_MAX)
  device:setMuted(false)
  device:setVolume(volume)
  volumeAlert(device:name(), volume)
end

local function decVolume()
  local device = hs.audiodevice.defaultOutputDevice()
  local volume = math.max(device:volume() - VOLUME_STEP, VOLUME_MIN)
  device:setMuted(false)
  device:setVolume(volume)
  volumeAlert(device:name(), volume)
end

hs.hotkey.bind(mash_shift, 'Return', function() toggleMute() end)
hs.hotkey.bind(mash_shift, 'Up',     function() incVolume()  end)
hs.hotkey.bind(mash_shift, 'Down',   function() decVolume()  end)


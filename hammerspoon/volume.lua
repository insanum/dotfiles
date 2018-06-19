
local volume_step = 10

local function volumeAlert(name, volume)
    local numBars = math.floor(volume / volume_step)
    local numSpaces = (100 / volume_step) - numBars
    hs.alert(name .. ": " ..
             string.rep("||", numBars) ..
             string.rep("..", numSpaces))
end

local function toggleMute()
    local device = hs.audiodevice.defaultOutputDevice()
    local wasMuted = device:muted()
    device:setMuted(not wasMuted)
    volumeAlert(device:name(), wasMuted and device:volume() or 0)
end

local function incVolume()
    local device = hs.audiodevice.defaultOutputDevice()
    local volume = math.min(device:volume() + volume_step, 100)
    device:setMuted(false)
    device:setVolume(volume)
    volumeAlert(device:name(), volume)
end

local function decVolume()
    local device = hs.audiodevice.defaultOutputDevice()
    local volume = math.max(device:volume() - volume_step, 0)
    device:setMuted(false)
    device:setVolume(volume)
    volumeAlert(device:name(), volume)
end

hs.hotkey.bind(kb_ctrl_shift, "Return", "Volume mute",
function()
    toggleMute()
end)

hs.hotkey.bind(kb_ctrl_shift, "Up", "Volume step up "..volume_step.."%",
function()
    incVolume()
end)

hs.hotkey.bind(kb_ctrl_shift, "Down", "Volume step down "..volume_step.."%",
function()
    decVolume()
end)



local volume_step = 10

local function volumeAlert(name, volume)
    local font = { name = "Hack Nerd Font", size = 16 }

    local numBars = math.floor(volume / volume_step)
    local numSpaces = (100 / volume_step) - numBars

    local msg = hs.styledtext.new(name .. ": ",
                                  {
                                    font  = font,
                                    color = { hex = "#ffffff" }
                                  }) ..
                hs.styledtext.new(string.rep("||", numBars),
                                  {
                                    font  = font,
                                    color = { hex = "#ff0000" }
                                  }) ..
                hs.styledtext.new(string.rep("..", numSpaces),
                                  {
                                    font  = font,
                                    color = { hex = "#ff8c00" }
                                  })

    hs.alert(msg, { radius = 0, atScreenEdge = 2 }, 2)

    print("Volume alert: "..msg:getString())
    hs.console.printStyledtext(msg)
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

hs.hotkey.bind(CMD_CTRL_SHIFT, "Return", "Volume mute",
function()
    toggleMute()
end)

hs.hotkey.bind(CMD_CTRL_SHIFT, "Up", "Volume step up "..volume_step.."%",
function()
    incVolume()
end)

hs.hotkey.bind(CMD_CTRL_SHIFT, "Down", "Volume step down "..volume_step.."%",
function()
    decVolume()
end)


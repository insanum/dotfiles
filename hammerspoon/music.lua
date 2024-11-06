
local window = require("hs.window")

local am      = "/Users/edavis/am"
local am_proc = nil

local function amCmd(...)
    local args = { ... }
    local last_win = window.focusedWindow()

    local cmd_args = { }
    local cmd_txt = "Music"
    for i,v in ipairs(args) do
        table.insert(cmd_args, args[i])
        cmd_txt = cmd_txt .. " " .. v
    end

    local function amDone(exitCode, stdOut, stdErr)
        local alert_loc = { radius = 0, atScreenEdge = 2 }
        local res = " done!"

        if exitCode ~= 0 then
            res = " failed!"
        end

        hs.alert(cmd_txt .. res , alert_loc, 4)
        print(cmd_txt .. res)
    end

    if not am_proc or not am_proc:isRunning() then
        am_proc = hs.task.new(am, amDone, cmd_args)
        am_proc:start()
    end

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

hs.hotkey.bind(kb_ctrl, "r", "Music run",
function()
    amCmd("run")
end)

hs.hotkey.bind(kb_ctrl, "s", "Music stop",
function()
    amCmd("stop")
end)

hs.hotkey.bind(kb_ctrl, "p", "Music playpause",
function()
    amCmd("playpause")
end)

hs.hotkey.bind(kb_ctrl, ".", "Music next",
function()
    amCmd("next")
end)

hs.hotkey.bind(kb_ctrl, ",", "Music prev",
function()
    amCmd("prev")
end)

hs.hotkey.bind(kb_ctrl, "f", "Music shuffle on",
function()
    amCmd("shuffle", "on")
end)

hs.hotkey.bind(kb_ctrl_shift, "f", "Music shuffle off",
function()
    amCmd("shuffle", "off")
end)

hs.hotkey.bind(kb_ctrl, "Up", "Music volume up",
function()
    amCmd("volume", "up")
end)

hs.hotkey.bind(kb_ctrl, "Down", "Music volume down",
function()
    amCmd("volume", "down")
end)

hs.hotkey.bind(kb_ctrl, "Left", "Music seek backward",
function()
    amCmd("seek", "backward")
end)

hs.hotkey.bind(kb_ctrl, "Right", "Music seek forward",
function()
    amCmd("seek", "forward")
end)

-- make shuffle a toggle
-- add support for repeat (make it a toggle sequence)
-- playlist dialogue and selection


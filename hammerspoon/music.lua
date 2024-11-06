
local window  = require("hs.window")
local chooser = require("hs.chooser")
local x11_clr = require("hs.drawing").color.x11

local am      = "/Users/edavis/.bin/am"
local am_proc = nil

local function print_alert(msg)
    local alert_loc = { radius = 0, atScreenEdge = 2 }
    hs.alert(msg, alert_loc, 4)
    print(msg)
end

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
        local res = " done!"

        if exitCode ~= 0 then
            res = " failed!"
        end

        print_alert(cmd_txt .. res)
    end

    local function amStatusDone(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            print_alert("Music failed to get status!")
            return
        end

        local status = stdOut:gsub("^%s*(.-)%s*$", "%1")
        print_alert(status)
    end

    local function amPlaylistsDone(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            print_alert("Music failed to get playlists!")
            return
        end

        local playlists = { }
        for s in string.gmatch(stdOut, "[^\n]+") do
            table.insert(playlists, { text = s })
        end

        local chooser_cbk = function(selection)
            if selection ~= nil then
                amCmd("playlist", selection.text)
            end
        end

        local ch = chooser.new(chooser_cbk)
        ch:choices(playlists)
        --ch:rows(#playlists)
        ch:rows(15)
        ch:width(40)
        ch:bgDark(true)
        ch:fgColor(x11_clr.orange)
        ch:subTextColor(x11_clr.chocolate)
        ch:show()
    end

    local function amShuffleDone(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            print_alert("Music failed to get shuffle state!")
            return
        end

        local state = stdOut:gsub("^%s*(.-)%s*$", "%1")
        if state == "false" then
            amCmd("shuffle", "on")
        else
            amCmd("shuffle", "off")
        end
    end

    local function amRepeatDone(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            print_alert("Music failed to get repeat state!")
            return
        end

        local state = stdOut:gsub("^%s*(.-)%s*$", "%1")
        if state == "off" then
            amCmd("repeat", "one")
        elseif state == "one" then
            amCmd("repeat", "all")
        else
            amCmd("repeat", "off")
        end
    end

    local done_func = amDone
    if args[1] == "status" then
        done_func = amStatusDone
    elseif args[1] == "playlists" then
        done_func = amPlaylistsDone
    elseif args[1] == "shuffle" and args[2] == "state" then
        done_func = amShuffleDone
    elseif args[1] == "repeat" and args[2] == "state" then
        done_func = amRepeatDone
    end

    if not am_proc or not am_proc:isRunning() then
        am_proc = hs.task.new(am, done_func, cmd_args)
        am_proc:start()
    end

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

hs.hotkey.bind(kb_ctrl_shift, "r", "Music run",
function()
    amCmd("run")
end)

hs.hotkey.bind(kb_ctrl_shift, "s", "Music stop",
function()
    amCmd("stop")
end)

hs.hotkey.bind(kb_ctrl, "s", "Music status",
function()
    amCmd("status")
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

hs.hotkey.bind(kb_ctrl, "f", "Music shuffle toggle",
function()
    amCmd("shuffle", "state")
end)

hs.hotkey.bind(kb_ctrl, "r", "Music repeat toggle",
function()
    amCmd("repeat", "state")
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

hs.hotkey.bind(kb_ctrl, "l", "Music select playlist",
function()
    amCmd("playlists")
end)


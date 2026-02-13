
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

    local volume_up = true
    if args[1] == "volume" and (args[2] == "up" or args[2] == "down") then
        if args[2] == "down" then
            volume_up = false
        end
        args[2] = "state"
    end

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

    local function amVolumeDone(exitCode, stdOut, stdErr)
        if exitCode ~= 0 then
            print_alert("Music failed to get volume state!")
            return
        end

        local state = stdOut:gsub("^%s*(.-)%s*$", "%1")
        if volume_up then
            amCmd("volume", tostring(state + 5))
        else
            amCmd("volume", tostring(state - 5))
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
    elseif args[1] == "volume" and args[2] == "state" then
        done_func = amVolumeDone
    end

    if not am_proc or not am_proc:isRunning() then
        am_proc = hs.task.new(am, done_func, cmd_args)
        am_proc:start()
    end

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

local music_modal = NewModalKey(CMD_CTRL, 'u', 'Modal Music')

music_modal:bind({}, "m", "Music Run",
function()
    music_modal:exit()
    amCmd("run")
end)

music_modal:bind({}, "s", "Music Stop",
function()
    music_modal:exit()
    amCmd("stop")
end)

music_modal:bind({}, "t", "Music Status",
function()
    music_modal:exit()
    amCmd("status")
end)

music_modal:bind({}, "p", "Music Toggle Play/Pause",
function()
    music_modal:exit()
    amCmd("playpause")
end)

music_modal:bind({}, ".", "Music Next Track",
function()
    music_modal:exit()
    amCmd("next")
end)

music_modal:bind({}, ",", "Music Previous Track",
function()
    music_modal:exit()
    amCmd("prev")
end)

music_modal:bind({}, "f", "Music Toggle Shuffle",
function()
    music_modal:exit()
    amCmd("shuffle", "state")
end)

music_modal:bind({}, "r", "Music Toggle Repeat",
function()
    music_modal:exit()
    amCmd("repeat", "state")
end)

music_modal:bind({}, "Up", "Music Volume Up",
function()
    music_modal:exit()
    amCmd("volume", "up")
end)

music_modal:bind({}, "Down", "Music Volume Down",
function()
    music_modal:exit()
    amCmd("volume", "down")
end)

music_modal:bind({}, "Left", "Music Seek Backward",
function()
    music_modal:exit()
    amCmd("seek", "backward")
end)

music_modal:bind({}, "Right", "Music Seek Forward",
function()
    music_modal:exit()
    amCmd("seek", "forward")
end)

music_modal:bind({}, "l", "Music Select Playlist",
function()
    music_modal:exit()
    amCmd("playlists")
end)


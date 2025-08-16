
local window = require("hs.window")
local dialog = require("hs.dialog")

local mdtodo = "/Users/edavis/.cargo/bin/mdtodo"
local file   = "/Volumes/work/notes/INBOX.md"

local function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

local function mdtodoNewTask()
    local last_win = window.focusedWindow()

    if not file_exists(mdtodo) then
        hs.alert("ERROR: mdtodo command does not exist!",
                 { radius = 0, atScreenEdge = 2 }, 4)
        return
    end

    if not file_exists(file) then
        hs.alert("ERROR: INBOX.md does not exist!",
                 { radius = 0, atScreenEdge = 2 }, 4)
        return
    end

    hs.focus() -- make sure hammerspoon dialog is focused
    local clicked, message = dialog.textPrompt("New INBOX Task",
                                               "", "", "Save", "Cancel")
    if clicked == "Cancel" then
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end

        return
    end

    out, status = hs.execute(mdtodo .. " -f " .. file ..
                             " -n \"" .. message .. "\"")

    if status ~= true then
        hs.alert("ERROR: Failed to create INBOX Task!",
                 { radius = 0, atScreenEdge = 2 }, 4)
    else
        hs.alert("INBOX Task created!",
                 { radius = 0, atScreenEdge = 2 }, 4)
    end

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

mod_key:bind("", "i", "New INBOX Task",
function()
    mod_key:exit()
    mdtodoNewTask()
end)


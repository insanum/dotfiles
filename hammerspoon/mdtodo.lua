
local window = require("hs.window")
local dialog = require("hs.dialog")

local mdtodo = "/Users/edavis/.cargo/bin/mdtodo"
local file   = "/Users/edavis/notes/INBOX.md"

local function mdtodoNewTask()
    local last_win = window.focusedWindow()

    hs.focus() -- make sure hammerspoon dialog is focused
    local clicked, message = dialog.textPrompt("New Task", "", "",
                                               "Save", "Cancel")
    if clicked == "Cancel" then
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end

        return
    end

    os.execute(mdtodo .. " -f " .. file .. " -n \"" .. message .. "\"")
end

hs.hotkey.bind(kb_ctrl, "0", "New task via mdtodo",
function()
    mdtodoNewTask()
end)



local window = require("hs.window")
local dialog = require("hs.dialog")

local mdtodo = "/Users/edavis/.cargo/bin/mdtodo"
local file   = "/Users/edavis/notes/INBOX.md"

local function mdtodoNewTask()
    local last_win = window.focusedWindow()

    hs.focus() -- make sure hammerspoon dialog is focused
    local clicked, message = dialog.textPrompt("New Obsidian INBOX Task", "", "",
                                               "Save", "Cancel")
    if clicked == "Cancel" then
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end

        return
    end

    out, status = hs.execute(mdtodo .. " -f " .. file .. " -n \"" .. message .. "\"")

    if status ~= true then
        hs.alert("Failed to create Obsidian INBOX Task!", { radius = 0, atScreenEdge = 2 }, 4)
    else
        hs.alert("Obsidian INBOX Task created!", { radius = 0, atScreenEdge = 2 }, 4)
    end

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

hs.hotkey.bind(kb_ctrl, "0", "New Obsidian INBOX Task via mdtodo",
function()
    mdtodoNewTask()
end)


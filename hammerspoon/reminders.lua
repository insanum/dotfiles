
local window = require("hs.window")
local dialog = require("hs.dialog")

-- XXX Change this to native hs.osascript and get rid of the wrapper...
-- https://gist.github.com/n8henrie/c3a5bf270b8200e33591

-- brew install keith/formulae/reminders-cli
local reminders = os.getenv("HOME").."/.hammerspoon/reminders_wrap"

local function createReminder()
    local last_win = window.focusedWindow()

    hs.focus() -- make sure hammerspoon dialog is focused
    local clicked, message = dialog.textPrompt("New Apple Reminder", "", "",
                                               "Create", "Cancel")
    if clicked == "Cancel" then
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end

        return
    end

    -- https://github.com/Hammerspoon/hammerspoon/issues/2384
    -- 1: tccutil reset All org.hammerspoon.Hammerspoon
    -- 2: Run the following to get Hammerspoon permission to Reminders
    --hs.execute('osascript -e \'tell application "Reminders" to return default account\'')

    local cmd = reminders .. " \"" .. message .. "\""
    print("Reminder: " .. cmd)
    out, status = hs.execute(cmd)

    if status ~= true then
        hs.alert("Failed to create Apple Reminder!", { radius = 0, atScreenEdge = 2 }, 4)
    else
        hs.alert("Apple Reminder created!", { radius = 0, atScreenEdge = 2 }, 4)
    end

    print("Reminder out: " .. out)

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

Mod_Key:bind("", "r", "New Apple Reminder",
function()
    Mod_Key:exit()
    createReminder()
end)


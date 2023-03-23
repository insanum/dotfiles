
local window = require("hs.window")
local dialog = require("hs.dialog")

local curl     = "/usr/bin/curl"
local pushover = nil

local function fslurp(path)
    local f = io.open(path, "r")
    local s = f:read("*all")
    f:close()
    return s
end

local config = hs.json.decode(fslurp(os.getenv("HOME").."/.priv/pushover.json"))

local function pushoverDone(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        hs.alert("Pushover message failed!", { radius = 0, atScreenEdge = 2 }, 4)
        print("Pushover message failed!")
        return
    end

    hs.alert("Pushover message sent!", { radius = 0, atScreenEdge = 2 }, 4)
    print("Pushover message sent!")
end

local function pushoverSend()
    local last_win = window.focusedWindow()

    hs.focus() -- make sure hammerspoon dialog is focused
    local clicked, message = dialog.textPrompt("Pushover Message", "", "",
                                               "Send", "Cancel")
    if clicked == "Cancel" then
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end

        return
    end

    local curl_args = {
                        "-s", config.url,
                        "--form-string", "token=" .. config.task.token,
                        "--form-string", "user=" .. config.user_key,
                        "--form-string", "message=" .. message,
                      }
    if not pushover or not pushover:isRunning() then
        pushover = hs.task.new(curl, pushoverDone, curl_args)
        pushover:start()
    end

    if last_win ~= nil then
        last_win:focus() -- focus last window
    end
end

hs.hotkey.bind(kb_ctrl, "p", "Send message to Pushover",
function()
    pushoverSend()
end)


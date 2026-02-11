
Cmd                = { "cmd "}
Ctrl               = { "ctrl "}
Alt                = { "alt "}
Shift              = { "shift "}
Cmd_ctrl           = { "cmd", "ctrl" }
Cmd_alt            = { "cmd", "alt" }
Cmd_shift          = { "cmd", "shift" }
Cmd_ctrl_alt       = { "cmd", "ctrl", "alt" }
Cmd_ctrl_shift     = { "cmd", "ctrl", "shift" }
Cmd_ctrl_shift_alt = { "cmd", "ctrl", "shift", "alt" }
Cmd_alt_shift      = { "cmd", "alt", "shift" }

hs.hotkey.alertDuration = 0

hs.console.consoleFont({ name = "Hack Nerd Font", size = 14 })
hs.console.darkMode(true)
hs.console.outputBackgroundColor({ white = 0 })
hs.console.consolePrintColor({ white = 1 })
hs.console.consoleCommandColor({ green = 1 })

local function show_help(help)
    local help_alert_loc = { radius = 0, textSize = 16, atScreenEdge = 0 }
    hs.alert(help, help_alert_loc, 5)
end

local modal_alert_loc = { radius = 0, atScreenEdge = 0 }
local modal_alert = nil

local function modal_enter(msg)
    -- delete existing alert if present
    if modal_alert then
        hs.alert.closeAll(1)
    end

    modal_alert = hs.alert(msg, modal_alert_loc, 'infinite')
end

local function modal_exit()
    -- remove the alert indicator
    if modal_alert then
        hs.alert.closeAll(1)
        modal_alert = nil
    end
end

local function modal_help(m)
    local key_list = ''

    for i = 1,#m.keys do
        if i == 1 then
            key_list = m.keys[i].msg
        else
            key_list = key_list .. '\n' .. m.keys[i].msg
        end
    end

    show_help(key_list)
end

function New_Modal_Key(mods, key, msg)
    local m = hs.hotkey.modal.new(mods, key, msg)
    function m:entered() modal_enter(msg) end
    function m:exited() modal_exit() end
    m:bind('', 'q', 'Show help', function() modal_help(m) end)
    m:bind('', 'escape', function() m:exit() end)
    return m
end

Mod_Key = New_Modal_Key(Cmd_ctrl, 'k', 'Modal Misc')

local function loadit(module)
    print("----> require " .. module)
    require(module)
end

-- notification manager
-- # this is broken as the mouse move doesn't activate the x/close button
--loadit("notifications")

-- volume commands
-- # with Voyager keyboard layers, no longer need this
--loadit("volume")

-- audio device switcher
loadit("audiodevice")

-- window management
loadit("window")

-- application launcher (like spotlight)
--loadit("launcher")

-- mpd client
--loadit("mpc")

-- gpmdp client
--loadit("gpmdp")

-- Apple Music client
loadit("music")

-- stock quotes
--loadit("intrinio")
--loadit("alphavantage")
loadit("finnhub")

-- Pomodoro timer
--loadit("pomodoro")

-- input logger
--loadit("ilog")

-- send Pushover messages
--loadit("pushover")

-- add a new task to the Obsidian INBOX note
loadit("mdtodo")

-- create a new Apple Reminder
loadit("reminders")

-- window screenshots
loadit("wincapture")

-- focus applications
loadit("appfocus")

-- Ghostty hacks
loadit("ghostty")

hs.hotkey.bind(Cmd_ctrl, "q", "Show help",
function()
    local keys = hs.hotkey.getHotkeys()
    local key_list = ''

    for i = 1,#keys do
        if i == 1 then
            key_list = keys[i].msg
        else
            key_list = key_list .. '\n' .. keys[i].msg
        end
    end

    show_help(key_list)
end)


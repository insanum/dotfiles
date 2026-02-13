
CMD                = { "cmd "}
CTRL               = { "ctrl "}
ALT                = { "alt "}
SHIFT              = { "shift "}
CMD_CTRL           = { "cmd", "ctrl" }
CMD_ALT            = { "cmd", "alt" }
CMD_SHIFT          = { "cmd", "shift" }
CMD_CTRL_ALT       = { "cmd", "ctrl", "alt" }
CMD_CTRL_SHIFT     = { "cmd", "ctrl", "shift" }
CMD_CTRL_ALT_SHIFT = { "cmd", "ctrl", "alt", "shift" }
CMD_ALT_SHIFT      = { "cmd", "alt", "shift" }

hs.hotkey.alertDuration = 0

hs.console.consoleFont({ name = "Hack Nerd Font", size = 14 })
hs.console.darkMode(true)
hs.console.outputBackgroundColor({ white = 0 })
hs.console.consolePrintColor({ white = 1 })
hs.console.consoleCommandColor({ green = 1 })

local function loadit(module)
    print("----> require " .. module)
    require(module)
end

-- keybind help
loadit("help")

-- modal init
loadit("modal")

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


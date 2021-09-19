
kb_ctrl       = { "cmd", "ctrl" }
kb_ctrl_shift = { "cmd", "ctrl", "shift" }
kb_alt        = { "cmd", "alt" }
kb_alt_shift  = { "cmd", "alt", "shift" }

hs.hotkey.alertDuration = 0

hs.console.consoleFont({ name = "Hack Nerd Font", size = 14 })
hs.console.darkMode(true)
hs.console.outputBackgroundColor({ white = 0 })
hs.console.consolePrintColor({ white = 1 })
hs.console.consoleCommandColor({ green = 1 })

-- notification manager
require("notifications")

-- volume commands
require("volume")

-- window management
require("window")

-- application launcher (like spotlight)
--require("launcher")

-- mpd client
--require("mpc")

-- gpmdp client
--require("gpmdp")

-- stock quotes
--require("intrinio")
--require("alphavantage")
require("finnhub")

-- pomodoro timer
require("pomodoro")

-- input logger
--require("ilog")

-- send pushover messages
require("pushover")

-- reload config
hs.hotkey.bind(kb_ctrl_shift, "r", "Reload Hammerspoon config",
function()
    hs.notify.show("Hammerspoon", "Reloading configuration...", "");
    hs.reload()
end)

hs.hotkey.bind(kb_ctrl, "q", "Show help",
function()
    local last_win = hs.window.focusedWindow()
    local keys     = hs.hotkey.getHotkeys()

    local chooser_cbk = function(selection)
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end
    end

    local help = { }
    for i = 1,#keys do
        table.insert(help, { text = keys[i].msg })
    end

    chooser = hs.chooser.new(chooser_cbk)
    chooser:choices(help)
    --chooser:rows(#help)
    chooser:rows(15)
    chooser:width(40)
    chooser:bgDark(true)
    chooser:fgColor(hs.drawing.color.x11.orange)
    chooser:subTextColor(hs.drawing.color.x11.chocolate)
    chooser:show()
end)

hs.hotkey.bind(kb_ctrl, "e", "Launch Finder",
function()
    local finder = hs.application.open("Finder")
    local wins = finder:allWindows()
    if #wins == 1 and wins[1]:isStandard() == false then
        finder:selectMenuItem({ "File", "New Finder Window" })
    end
    finder:activate()
end)


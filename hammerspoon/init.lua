
--local mash       = {"cmd", "alt", "ctrl"}
--local mash_shift = {"cmd", "alt", "ctrl", "shift"}
local mash       = {"cmd", "ctrl"}
local mash_shift = {"cmd", "ctrl", "shift"}

-- trigger notification
function hsNotify(msg)
    hs.notify.new({title="Hammerspoon", informativeText=msg}):send()
end

-- reload config
hs.hotkey.bind(mash_shift, "r", function()
    hsNotify("Reloading configuration...")
    hs.reload()
end)

-- maximize window
hs.hotkey.bind(mash, "f", function()
    local win = hs.window.focusedWindow()
    win:maximize()
end)

local function winMove(win, x, y, w, h)
    local f = win:frame()
    f.x = x
    f.y = y
    f.w = w
    f.h = h
    win:setFrame(f)
end

-- center window
hs.hotkey.bind(mash, "c", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w * .10)),
                 (max.y + (max.h * .10)),
                 (max.w - (max.w * .20)),
                 (max.h - (max.h * .20)))
end)

-- window left half of screen
hs.hotkey.bind(mash, "h", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w / 2),
                 (max.h    ))
end)

-- window right half of screen
hs.hotkey.bind(mash, "l", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h              ))
end)

-- window top half of screen
hs.hotkey.bind(mash, "k", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w    ),
                 (max.h / 2))
end)

-- window bottom half of screen
hs.hotkey.bind(mash, "j", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w              ),
                 (max.h / 2          ))
end)

-- window upper left quadrant screen
hs.hotkey.bind(mash_shift, "h", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x     ),
                 (max.y     ),
                 (max.w / 2 ),
                 (max.h / 2 ))
end)

-- window lower left quadrant screen
hs.hotkey.bind(mash_shift, "j", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window lower right quadrant screen
hs.hotkey.bind(mash_shift, "k", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window upper right quadrant screen
hs.hotkey.bind(mash_shift, "l", function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- move a window to next monitor

function moveWindowMonitor(direction)
    local win = hs.window.focusedWindow()
    if direction == "west" then
        win = win:moveOneScreenWest()
    else -- direciton == "east"
        win = win:moveOneScreenEast()
    end
end

hs.hotkey.bind(mash_shift, "n", function() moveWindowMonitor("west") end)
hs.hotkey.bind(mash_shift, "m", function() moveWindowMonitor("east") end)

-- hack to move a window left/right between spaces

function moveWindowSpace(direction)
    local mouseOrigin = hs.mouse.getAbsolutePosition()
    local win = hs.window.focusedWindow()
    local clickPoint = win:zoomButtonRect()

    clickPoint.x = clickPoint.x + clickPoint.w + 5
    clickPoint.y = clickPoint.y + (clickPoint.h / 2)

    -- fix for Chrome
    if win:application():title() == 'Google Chrome' then
        clickPoint.y = clickPoint.y - clickPoint.h
    end

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
    hs.timer.usleep(150000)

    hs.eventtap.event.newKeyEvent({"ctrl"}, direction, true):post()
    hs.timer.usleep(150000)

    hs.eventtap.event.newKeyEvent({"ctrl"}, direction, false):post()
    hs.timer.usleep(150000)

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()
    hs.timer.usleep(150000)

    hs.mouse.setAbsolutePosition(mouseOrigin)
end

hs.hotkey.bind(mash, "n", function() moveWindowSpace("left")  end)
hs.hotkey.bind(mash, "m", function() moveWindowSpace("right") end)

require('launcher')

-- watch for space changes (broken, always "-1")
--[[
spaceWatch = hs.spaces.watcher.new(function(space)
    hsNotify("space changed: " .. space)
end)
spaceWatch:start()
--]]

-- watch for screen changes (on mouse click, not movement)
--[[
screenWatch = hs.screen.watcher.newWithActiveScreen(function()
    hsNotify("screen changed")
end)
screenWatch:start()
--]]

-- grid stuff

hs.grid.setGrid('4x4')
hs.hotkey.bind(mash, "g", function() hs.grid.toggleShow() end)
hs.hotkey.bind(mash, "w", function() hs.grid.pushWindowUp(hs.window.focusedWindow())    end)
hs.hotkey.bind(mash, "a", function() hs.grid.pushWindowLeft(hs.window.focusedWindow())  end)
hs.hotkey.bind(mash, "s", function() hs.grid.pushWindowDown(hs.window.focusedWindow())  end)
hs.hotkey.bind(mash, "d", function() hs.grid.pushWindowRight(hs.window.focusedWindow()) end)


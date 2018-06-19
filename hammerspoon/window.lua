
local function winMove(win, x, y, w, h)
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local f = win:frame()
    f.x = x
    f.y = y
    f.w = w
    f.h = h
    win:setFrame(f)

    hs.window.animationDuration = ad
end

-- maximize window
hs.hotkey.bind(kb_ctrl, "f", "Maximize window",
function()
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local win = hs.window.frontmostWindow()
    win:maximize()

    hs.window.animationDuration = ad
end)

-- center window
hs.hotkey.bind(kb_ctrl, "c", "Center window",
function()
    local win = hs.window.frontmostWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w * .10)),
                 (max.y + (max.h * .10)),
                 (max.w - (max.w * .20)),
                 (max.h - (max.h * .20)))
end)

-- window left half of screen
hs.hotkey.bind(kb_ctrl, "h", "Move/Resize window left half of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w / 2),
                 (max.h    ))
end)

-- window right half of screen
hs.hotkey.bind(kb_ctrl, "l", "Move/Resize window right half of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h              ))
end)

-- window top half of screen
hs.hotkey.bind(kb_ctrl, "k", "Move/Resize window top half of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w    ),
                 (max.h / 2))
end)

-- window bottom half of screen
hs.hotkey.bind(kb_ctrl, "j", "Move/Resize window bottom half of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w              ),
                 (max.h / 2          ))
end)

-- window upper left quadrant screen
hs.hotkey.bind(kb_ctrl_shift, "h", "Move/Resize window upper left of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x     ),
                 (max.y     ),
                 (max.w / 2 ),
                 (max.h / 2 ))
end)

-- window lower left quadrant screen
hs.hotkey.bind(kb_ctrl_shift, "j", "Move/Resize window lower left of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window lower right quadrant screen
hs.hotkey.bind(kb_ctrl_shift, "k", "Move/Resize window lower right of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window upper right quadrant screen
hs.hotkey.bind(kb_ctrl_shift, "l", "Move/Resize window upper right of screen",
function()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- move a window to next monitor

function moveWindowMonitor(direction)
    local win = hs.window.frontmostWindow()
    if direction == "west" then
        win = win:moveOneScreenWest()
    else -- direciton == "east"
        win = win:moveOneScreenEast()
    end
end

hs.hotkey.bind(kb_ctrl_shift, "n", "Move window to the right monitor",
function()
    moveWindowMonitor("west")
end)

hs.hotkey.bind(kb_ctrl_shift, "m", "Move window to the left monitor",
function()
    moveWindowMonitor("east")
end)

-- hack to move a window left/right between spaces

function moveWindowSpace(direction)
    local mouseOrigin = hs.mouse.getAbsolutePosition()
    local win = hs.window.frontmostWindow()
    local clickPoint = win:zoomButtonRect()

    clickPoint.x = clickPoint.x + clickPoint.w + 5
    clickPoint.y = clickPoint.y + (clickPoint.h / 2)

    -- fix for Chrome
    if win:application():title() == "Google Chrome" then
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

hs.hotkey.bind(kb_ctrl, "n", "Move window one space to the left",
function()
    moveWindowSpace("left")
end)

hs.hotkey.bind(kb_ctrl, "m", "Move window one space to the right",
function()
    moveWindowSpace("right")
end)

-- watch for space changes (broken, always "-1")
--[[
spaceWatch = hs.spaces.watcher.new(function(space)
    hs.notify.show("Hammerspoon", "space changed: "..space, "");
end)
spaceWatch:start()
--]]

-- watch for screen changes (on mouse click, not movement)
--[[
screenWatch = hs.screen.watcher.newWithActiveScreen(function()
    hs.notify.show("Hammerspoon", "screen changed", "");
end)
screenWatch:start()
--]]

-- grid stuff

hs.grid.setGrid("4x4")

hs.hotkey.bind(kb_ctrl, "g", "Show window grid",
function()
    hs.grid.toggleShow()
end)

hs.hotkey.bind(kb_ctrl, "w", "Move window up on grid",
function()
    hs.grid.pushWindowUp(hs.window.focusedWindow())
end)

hs.hotkey.bind(kb_ctrl, "a", "Move window left on grid",
function()
    hs.grid.pushWindowLeft(hs.window.focusedWindow())
end)

hs.hotkey.bind(kb_ctrl, "s", "Move window down on grid",
function()
    hs.grid.pushWindowDown(hs.window.focusedWindow())
end)

hs.hotkey.bind(kb_ctrl, "d", "Move window right on grid",
function()
    hs.grid.pushWindowRight(hs.window.focusedWindow())
end)


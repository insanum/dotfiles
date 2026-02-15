
local win_modal = NewModalKey(CMD_CTRL, 'i', 'Modal Window')

--[[
------------------------------------------------------------------------------
-- window stuff

-- maximize window
win_modal:bind(NONE, "f", "Maximize window",
function()
    win_modal:exit()
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local win = hs.window.frontmostWindow()
    win:maximize()

    hs.window.animationDuration = ad
end)

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

-- center window
win_modal:bind(NONE, "c", "Center window",
function()
    win_modal:exit()
    local win = hs.window.frontmostWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w * .10)),
                 (max.y + (max.h * .10)),
                 (max.w - (max.w * .20)),
                 (max.h - (max.h * .20)))
end)

-- window left half of screen
win_modal:bind(NONE, "h", "Move/Resize window left half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w / 2),
                 (max.h    ))
end)

-- window right half of screen
win_modal:bind(NONE, "l", "Move/Resize window right half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h              ))
end)

-- window top half of screen
win_modal:bind(NONE, "k", "Move/Resize window top half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w    ),
                 (max.h / 2))
end)

-- window bottom half of screen
win_modal:bind(NONE, "j", "Move/Resize window bottom half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w              ),
                 (max.h / 2          ))
end)

-- window upper left quadrant screen
win_modal:bind(CTRL, "h", "Move/Resize window upper left of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x     ),
                 (max.y     ),
                 (max.w / 2 ),
                 (max.h / 2 ))
end)

-- window lower left quadrant screen
win_modal:bind(CTRL, "j", "Move/Resize window lower left of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window lower right quadrant screen
win_modal:bind(CTRL, "k", "Move/Resize window lower right of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window upper right quadrant screen
win_modal:bind(CTRL, "l", "Move/Resize window upper right of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)
--]]

--[[
------------------------------------------------------------------------------
-- monitor stuff

-- move a window to next monitor
function moveWindowMonitor(direction)
    local win = hs.window.frontmostWindow()
    if direction == "west" then
        win = win:moveOneScreenWest()
    else -- direciton == "east"
        win = win:moveOneScreenEast()
    end
end

win_modal:bind(CTRL, "n", "Move window to the right monitor",
function()
    win_modal:exit()
    moveWindowMonitor("west")
end)

win_modal:bind(CTRL, "m", "Move window to the left monitor",
function()
    win_modal:exit()
    moveWindowMonitor("east")
end)
--]]

--[[
------------------------------------------------------------------------------
-- spaces stuff

-- hack to move a window left/right between spaces
function moveWindowSpace(direction)
    local mouseOrigin = hs.mouse.absolutePosition()
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

    -- hack adding "fn" required for Mojave...
    hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, true):post()
    hs.timer.usleep(150000)

    -- hack adding "fn" required for Mojave...
    hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, false):post()
    hs.timer.usleep(150000)

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()
    hs.timer.usleep(150000)

    hs.mouse.absolutePosition(mouseOrigin)
end

win_modal:bind(NONE, "n", "Move window one space to the left",
function()
    win_modal:exit()
    moveWindowSpace("left")
end)

win_modal:bind(NONE, "m", "Move window one space to the right",
function()
    win_modal:exit()
    moveWindowSpace("right")
end)
--]]

------------------------------------------------------------------------------
-- grid stuff

hs.grid.setGrid("6x6") -- make sure even numbers
hs.grid.ui.textSize = 32
hs.grid.ui.showExtraKeys = false
hs.grid.setMargins(hs.geometry({ 10, 10 }))

win_modal:bind(NONE, "g", "Show Window Grid",
function()
    win_modal:exit()
    hs.grid.show()
end)

win_modal:bind(NONE, "s", "Snap Window",
function()
    win_modal:exit()
    hs.grid.snap(hs.window.focusedWindow())
end)

win_modal:bind(SHIFT, "s", "Snap All Windows",
function()
    win_modal:exit()
    local screen = hs.screen.mainScreen()

    for _, win in ipairs(hs.window.allWindows()) do
        if win:isStandard() and win:isVisible() and win:screen() == screen then
            hs.grid.snap(win)
        end
    end
end)

win_modal:bind(NONE, "f", "Maximize Window",
function()
    win_modal:exit()
    hs.grid.maximizeWindow(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "h", "Move Window Left",
function()
    --win_modal:exit()
    hs.grid.pushWindowLeft(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "j", "Move Window Down",
function()
    --win_modal:exit()
    hs.grid.pushWindowDown(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "k", "Move Window Up",
function()
    --win_modal:exit()
    hs.grid.pushWindowUp(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "l", "Move Window Right",
function()
    --win_modal:exit()
    hs.grid.pushWindowRight(hs.window.focusedWindow())
end)

win_modal:bind(SHIFT, "j", "Resize Window Height",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if r.h == g.h then
        r = hs.geometry.rect(r.x, (r.y + 1), r.w, (r.h - 1))
    elseif r.y == 0 then
        r = hs.geometry.rect(r.x, r.y, r.w, (r.h + 1))
    elseif (r.y + r.h) == g.h then
        if r.h == 2 then return end
        r = hs.geometry.rect(r.x, (r.y + 1), r.w, (r.h - 1))
    else
        -- window not on a top or bottom edge, so shrink in both directions
        if r.h == 2 then return end
        local d = 2
        if r.h == 3 then d = 1 end
        r = hs.geometry.rect(r.x, (r.y + 1), r.w, (r.h - d))
    end

    hs.grid.set(win, r)
end)

win_modal:bind(SHIFT, "k", "Resize Window Height",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if (r.h == g.h) then
        r = hs.geometry.rect(r.x, r.y, r.w, (r.h - 1))
    elseif r.y == 0 then
        if r.h == 2 then return end
        r = hs.geometry.rect(r.x, r.y, r.w, (r.h - 1))
    elseif (r.y + r.h) == g.h then
        r = hs.geometry.rect(r.x, (r.y - 1), r.w, (r.h + 1))
    else
        -- window not on a top or bottom edge, so grow in both directions
        local d = 2
        if (r.h + 1) == g.h then d = 1 end
        r = hs.geometry.rect(r.x, (r.y - 1), r.w, (r.h + d))
    end

    hs.grid.set(win, r)
end)

win_modal:bind(SHIFT, "h", "Resize Window Width",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if (r.w == g.w) then
        r = hs.geometry.rect(r.x, r.y, (r.w - 1), r.h)
    elseif r.x == 0 then
        if r.w == 2 then return end
        r = hs.geometry.rect(r.x, r.y, (r.w - 1), r.h)
    elseif (r.x + r.w) == g.w then
        r = hs.geometry.rect((r.x - 1), r.y, (r.w + 1), r.h)
    else
        -- window not on a right or left edge, so shrink in both directions
        if r.w == 2 then return end
        local d = 2
        if r.w == 3 then d = 1 end
        r = hs.geometry.rect((r.x + 1), r.y, (r.w - d), r.h)
    end

    hs.grid.set(win, r)
end)

win_modal:bind(SHIFT, "l", "Resize Window Width",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if r.w == g.w then
        r = hs.geometry.rect((r.x + 1), r.y, (r.w - 1), r.h)
    elseif r.x == 0 then
        r = hs.geometry.rect(r.x, r.y, (r.w + 1), r.h)
    elseif (r.x + r.w) == g.w then
        if r.w == 2 then return end
        r = hs.geometry.rect((r.x + 1), r.y, (r.w - 1), r.h)
    else
        -- window not on a right or left edge, so grow in both directions
        local d = 2
        if (r.w + 1) == g.w then d = 1 end
        r = hs.geometry.rect((r.x - 1), r.y, (r.w + d), r.h)
    end

    hs.grid.set(win, r)
end)

win_modal:bind(NONE, "1", "Window Top Left",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, 0, (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "2", "Window Top Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, 0, g.w, (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "3", "Window Top Right",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect((g.w - (g.w / 2)), 0, (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "6", "Window Right Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect((g.w - (g.w / 2)), 0, (g.w / 2), g.h)
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "9", "Window Botttom Right",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect((g.w / 2), (g.h / 2), (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "8", "Window Bottom Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, (g.h - (g.h / 2)), g.w, (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "7", "Window Botttom Left",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, (g.h / 2), (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "4", "Window Left Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, 0, (g.w / 2), g.h)
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "5", "Window Center",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(1, 1, (g.w - 2), (g.h - 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)


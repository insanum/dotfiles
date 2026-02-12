
--local win_modal = NewModalKey(CMD_CTRL, 'w', 'Modal Window')

--[[
-- maximize window
win_modal:bind({}, "f", "Maximize window",
function()
    win_modal:exit()
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local win = hs.window.frontmostWindow()
    win:maximize()

    hs.window.animationDuration = ad
end)
--]]

--[[
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
win_modal:bind({}, "c", "Center window",
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
win_modal:bind({}, "h", "Move/Resize window left half of screen",
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
win_modal:bind({}, "l", "Move/Resize window right half of screen",
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
win_modal:bind({}, "k", "Move/Resize window top half of screen",
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
win_modal:bind({}, "j", "Move/Resize window bottom half of screen",
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

-- XXX Hack adding "fn" required for Mojave...
    hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, true):post()
    hs.timer.usleep(150000)

-- XXX Hack adding "fn" required for Mojave...
    hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, false):post()
    hs.timer.usleep(150000)

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()
    hs.timer.usleep(150000)

    hs.mouse.absolutePosition(mouseOrigin)
end

win_modal:bind({}, "n", "Move window one space to the left",
function()
    win_modal:exit()
    moveWindowSpace("left")
end)

win_modal:bind({}, "m", "Move window one space to the right",
function()
    win_modal:exit()
    moveWindowSpace("right")
end)
--]]

--[[
-- watch for space changes (broken, always "-1")
spaceWatch = hs.spaces.watcher.new(function(space)
    hs.notify.show("Hammerspoon", "space changed: "..space, "");
end)
spaceWatch:start()
--]]

--[[
-- watch for screen changes (on mouse click, not movement)
screenWatch = hs.screen.watcher.newWithActiveScreen(function()
    hs.notify.show("Hammerspoon", "screen changed", "");
end)
screenWatch:start()
--]]

--[[
-- grid stuff
hs.grid.setGrid("10x10")
hs.grid.ui.textSize = 60

win_modal:bind({}, "g", "Show window grid",
function()
    win_modal:exit()
    hs.grid.toggleShow()
end)
--]]

--[[
win_modal:bind({}, "w", "Move window up on grid",
function()
    win_modal:exit()
    hs.grid.pushWindowUp(hs.window.focusedWindow())
end)

win_modal:bind({}, "a", "Move window left on grid",
function()
    win_modal:exit()
    hs.grid.pushWindowLeft(hs.window.focusedWindow())
end)

win_modal:bind({}, "s", "Move window down on grid",
function()
    win_modal:exit()
    hs.grid.pushWindowDown(hs.window.focusedWindow())
end)

win_modal:bind({}, "d", "Move window right on grid",
function()
    win_modal:exit()
    hs.grid.pushWindowRight(hs.window.focusedWindow())
end)
--]]

------------------------------------------------------------------------------

-- mkdir .hammerspoon/Spoons; cd .hammerspoon/Spoons
-- git clone https://github.com/mogenson/PaperWM.spoon

local pwm = hs.loadSpoon("PaperWM")

pwm.window_gap = 16
pwm.window_ratios = { 0.25, 0.50, 0.75, 0.90 }

pwm.lift_window = CMD_SHIFT
--pwm.drag_window = CMD_ALT
pwm.scroll_window = CMD_ALT
pwm.scroll_gain = 30

pwm.window_filter:rejectApp("Stickies")

pwm:start()

local pwm_a = pwm.actions.actions()

local pwm_modal = NewModalKey(CMD, 'return', 'Modal PWM')

pwm_modal:bind({}, "w", "PWM cycle width", pwm_a.cycle_width)
pwm_modal:bind(SHIFT, "w", "PWM cycle height", pwm_a.cycle_height)

pwm_modal:bind({}, "h", "PWM focus left", pwm_a.focus_left)
pwm_modal:bind({}, "j", "PWM focus down", pwm_a.focus_down)
pwm_modal:bind({}, "k", "PWM focus up", pwm_a.focus_up)
pwm_modal:bind({}, "l", "PWM focus right", pwm_a.focus_right)

pwm_modal:bind(CTRL, "h", "PWM move window left", pwm_a.swap_left)
pwm_modal:bind(CTRL, "j", "PWM move window down", pwm_a.swap_down)
pwm_modal:bind(CTRL, "k", "PWM move window up", pwm_a.swap_up)
pwm_modal:bind(CTRL, "l", "PWM move window right", pwm_a.swap_right)

pwm_modal:bind(CMD, "h", "PWM switch space left", function()
    pwm_modal:exit()
    pwm_a.switch_space_l()
end)

pwm_modal:bind(CMD, "l", "PWM switch space right", function()
    pwm_modal:exit()
    pwm_a.switch_space_r()
end)

pwm_modal:bind(CMD, "1", "PWM switch space 1", function()
    pwm_modal:exit()
    pwm_a.switch_space_1()
end)

pwm_modal:bind(CMD, "2", "PWM switch space 2", function()
    pwm_modal:exit()
    pwm_a.switch_space_2()
end)

pwm_modal:bind(CMD, "3", "PWM switch space 3", function()
    pwm_modal:exit()
    pwm_a.switch_space_3()
end)

pwm_modal:bind(ALT, "1", "PWM move window space 1", function()
    pwm_modal:exit()
    pwm_a.move_window_1()
end)

pwm_modal:bind(ALT, "2", "PWM move window space 2", function()
    pwm_modal:exit()
    pwm_a.move_window_2()
end)

pwm_modal:bind(ALT, "3", "PWM move window space 3", function()
    pwm_modal:exit()
    pwm_a.move_window_3()
end)

pwm_modal:bind({}, "c", "PWM window center", function()
    pwm_modal:exit()
    pwm_a.center_window()
end)

pwm_modal:bind({}, "f", "PWM window full width", function()
    pwm_modal:exit()
    pwm_a.full_width()
end)

pwm_modal:bind(CMD, "i", "PWM slurp in", function()
    pwm_modal:exit()
    pwm_a.slurp_in()
end)

pwm_modal:bind(CMD, "o", "PWM barf out", function()
    pwm_modal:exit()
    pwm_a.barf_out()
end)

pwm_modal:bind(Shift, "r", "PWM refresh windows", function()
    pwm_modal:exit()
    pwm_a.refresh_windows()
end)

pwm_modal:bind({}, "t", "PWM toggle floating", function()
    pwm_modal:exit()
    pwm_a.toggle_floating()
end)

pwm_modal:bind(Shift, "t", "PWM focus floating", function()
    pwm_modal:exit()
    pwm_a.focus_floating()
end)


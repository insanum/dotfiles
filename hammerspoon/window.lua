
local w_modal = New_Modal_Key(Cmd_ctrl, 'w', 'Modal Window')

-- maximize window
w_modal:bind({}, "f", "Maximize window",
function()
    w_modal:exit()
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local win = hs.window.frontmostWindow()
    win:maximize()

    hs.window.animationDuration = ad
end)

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
w_modal:bind({}, "c", "Center window",
function()
    w_modal:exit()
    local win = hs.window.frontmostWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w * .10)),
                 (max.y + (max.h * .10)),
                 (max.w - (max.w * .20)),
                 (max.h - (max.h * .20)))
end)

-- window left half of screen
w_modal:bind({}, "h", "Move/Resize window left half of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w / 2),
                 (max.h    ))
end)

-- window right half of screen
w_modal:bind({}, "l", "Move/Resize window right half of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h              ))
end)

-- window top half of screen
w_modal:bind({}, "k", "Move/Resize window top half of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w    ),
                 (max.h / 2))
end)

-- window bottom half of screen
w_modal:bind({}, "j", "Move/Resize window bottom half of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w              ),
                 (max.h / 2          ))
end)

-- window upper left quadrant screen
w_modal:bind(Ctrl, "h", "Move/Resize window upper left of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x     ),
                 (max.y     ),
                 (max.w / 2 ),
                 (max.h / 2 ))
end)

-- window lower left quadrant screen
w_modal:bind(Ctrl, "j", "Move/Resize window lower left of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window lower right quadrant screen
w_modal:bind(Ctrl, "k", "Move/Resize window lower right of screen",
function()
    w_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window upper right quadrant screen
w_modal:bind(Ctrl, "l", "Move/Resize window upper right of screen",
function()
    w_modal:exit()
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

w_modal:bind(Ctrl, "n", "Move window to the right monitor",
function()
    w_modal:exit()
    moveWindowMonitor("west")
end)

w_modal:bind(Ctrl, "m", "Move window to the left monitor",
function()
    w_modal:exit()
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

w_modal:bind({}, "n", "Move window one space to the left",
function()
    w_modal:exit()
    moveWindowSpace("left")
end)

w_modal:bind({}, "m", "Move window one space to the right",
function()
    w_modal:exit()
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

-- grid stuff
hs.grid.setGrid("10x10")
hs.grid.ui.textSize = 60

w_modal:bind({}, "g", "Show window grid",
function()
    w_modal:exit()
    hs.grid.toggleShow()
end)

--[[
w_modal:bind({}, "w", "Move window up on grid",
function()
    w_modal:exit()
    hs.grid.pushWindowUp(hs.window.focusedWindow())
end)

w_modal:bind({}, "a", "Move window left on grid",
function()
    w_modal:exit()
    hs.grid.pushWindowLeft(hs.window.focusedWindow())
end)

w_modal:bind({}, "s", "Move window down on grid",
function()
    w_modal:exit()
    hs.grid.pushWindowDown(hs.window.focusedWindow())
end)

w_modal:bind({}, "d", "Move window right on grid",
function()
    w_modal:exit()
    hs.grid.pushWindowRight(hs.window.focusedWindow())
end)
--]]

------------------------------------------------------------------------------

-- mkdir .hammerspoon/Spoons; cd .hammerspoon/Spoons
-- git clone https://github.com/mogenson/PaperWM.spoon

hs.loadSpoon("PaperWM")

spoon.PaperWM.window_gap = 16
spoon.PaperWM.window_ratios = { 0.25, 0.50, 0.75, 0.90 }

--spoon.PaperWM.drag_window = Cmd_alt
--spoon.PaperWM.lift_window = Cmd_ctl
spoon.PaperWM.scroll_window = Cmd_alt
spoon.PaperWM.scroll_gain = 30

spoon.PaperWM.window_filter:rejectApp("Stickies")

spoon.PaperWM:bindHotkeys(spoon.PaperWM.default_hotkeys)

local pwm_modal = New_Modal_Key(Cmd, 'return', 'Modal PWM')

local actions = spoon.PaperWM.actions.actions()

pwm_modal:bind({}, "w", "PWM cycle width", actions.cycle_width)
pwm_modal:bind(Shift, "w", "PWM cycle height", actions.cycle_height)

pwm_modal:bind({}, "h", "PWM focus left", actions.focus_left)
pwm_modal:bind({}, "j", "PWM focus down", actions.focus_down)
pwm_modal:bind({}, "k", "PWM focus up", actions.focus_up)
pwm_modal:bind({}, "l", "PWM focus right", actions.focus_right)

pwm_modal:bind(Ctrl, "h", "PWM move window left", actions.swap_left)
pwm_modal:bind(Ctrl, "j", "PWM move window down", actions.swap_down)
pwm_modal:bind(Ctrl, "k", "PWM move window up", actions.swap_up)
pwm_modal:bind(Ctrl, "l", "PWM move window right", actions.swap_right)

pwm_modal:bind(Cmd, "h", "PWM switch space left", function()
    pwm_modal:exit()
    actions.switch_space_l()
end)

pwm_modal:bind(Cmd, "l", "PWM switch space right", function()
    pwm_modal:exit()
    actions.switch_space_r()
end)

pwm_modal:bind(Cmd, "1", "PWM switch space 1", function()
    pwm_modal:exit()
    actions.switch_space_1()
end)

pwm_modal:bind(Cmd, "2", "PWM switch space 2", function()
    pwm_modal:exit()
    actions.switch_space_2()
end)

pwm_modal:bind(Cmd, "3", "PWM switch space 3", function()
    pwm_modal:exit()
    actions.switch_space_3()
end)

pwm_modal:bind(Alt, "1", "PWM move window space 1", function()
    pwm_modal:exit()
    actions.move_window_1()
end)

pwm_modal:bind(Alt, "2", "PWM move window space 2", function()
    pwm_modal:exit()
    actions.move_window_2()
end)

pwm_modal:bind(Alt, "3", "PWM move window space 3", function()
    pwm_modal:exit()
    actions.move_window_3()
end)

pwm_modal:bind({}, "c", "PWM window center", function()
    pwm_modal:exit()
    actions.center_window()
end)

pwm_modal:bind({}, "f", "PWM window full width", function()
    pwm_modal:exit()
    actions.full_width()
end)

pwm_modal:bind(Cmd, "i", "PWM slurp in", function()
    pwm_modal:exit()
    actions.slurp_in()
end)

pwm_modal:bind(Cmd, "o", "PWM barf out", function()
    pwm_modal:exit()
    actions.barf_out()
end)

pwm_modal:bind(Shift, "r", "PWM refresh windows", function()
    pwm_modal:exit()
    actions.refresh_windows()
end)

pwm_modal:bind({}, "t", "PWM toggle floating", function()
    pwm_modal:exit()
    actions.toggle_floating()
end)

pwm_modal:bind(Shift, "t", "PWM focus floating", function()
    pwm_modal:exit()
    actions.focus_floating()
end)

--[[
    -- figure out a way to dynamic start/stop PaperWM
    stop_events          = { { "alt", "cmd", "shift" }, "q" },
--]]

spoon.PaperWM:start()


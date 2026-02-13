
--local win_modal = NewModalKey(CMD_CTRL, 'w', 'Modal Window')

--[[
------------------------------------------------------------------------------
-- window stuff

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
------------------------------------------------------------------------------
-- grid stuff

hs.grid.setGrid("10x10")
hs.grid.ui.textSize = 60

win_modal:bind({}, "g", "Show window grid",
function()
    win_modal:exit()
    hs.grid.toggleShow()
end)

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
pwm.window_filter:rejectApp("Finder")
pwm.window_filter:setAppFilter("Google Chrome Beta", { rejectTitles = "Bitwarden" })

pwm:start()

local pwm_a = pwm.actions.actions()

local pwm_modal = NewModalKey(CMD, 'return', 'Modal PWM')

pwm_modal:bind({}, "w", "PWM Cycle Width", pwm_a.cycle_width)
pwm_modal:bind(SHIFT, "w", "PWM Cycle Height", pwm_a.cycle_height)

pwm_modal:bind({}, "h", "PWM Focus Left", pwm_a.focus_left)
pwm_modal:bind({}, "j", "PWM Focus Down", pwm_a.focus_down)
pwm_modal:bind({}, "k", "PWM Focus Up", pwm_a.focus_up)
pwm_modal:bind({}, "l", "PWM Focus Right", pwm_a.focus_right)

pwm_modal:bind(CTRL, "h", "PWM Window Move Left", pwm_a.swap_left)
pwm_modal:bind(CTRL, "j", "PWM Window Move Down", pwm_a.swap_down)
pwm_modal:bind(CTRL, "k", "PWM Window Move Up", pwm_a.swap_up)
pwm_modal:bind(CTRL, "l", "PWM Window Move Right", pwm_a.swap_right)

pwm_modal:bind(ALT, "1", "PWM Window Move Space 1", function()
    pwm_modal:exit()
    pwm_a.move_window_1()
end)

pwm_modal:bind(ALT, "2", "PWM Window Move Space 2", function()
    pwm_modal:exit()
    pwm_a.move_window_2()
end)

pwm_modal:bind(ALT, "3", "PWM Window Move Space 3", function()
    pwm_modal:exit()
    pwm_a.move_window_3()
end)

pwm_modal:bind({}, "c", "PWM Window Center", function()
    pwm_modal:exit()
    pwm_a.center_window()
end)

pwm_modal:bind({}, "f", "PWM Window Full Width", function()
    pwm_modal:exit()
    pwm_a.full_width()
end)

pwm_modal:bind({}, "i", "PWM Slurp In", function()
    pwm_modal:exit()
    pwm_a.slurp_in()
end)

pwm_modal:bind({}, "o", "PWM Barf Out", function()
    pwm_modal:exit()
    pwm_a.barf_out()
end)

pwm_modal:bind({}, "r", "PWM Refresh Windows", function()
    pwm_modal:exit()
    pwm_a.refresh_windows()
end)

pwm_modal:bind({}, "t", "PWM Toggle Floating", function()
    pwm_modal:exit()
    pwm_a.toggle_floating()
end)

pwm_modal:bind(SHIFT, "t", "PWM Focus Floating", function()
    pwm_modal:exit()
    pwm_a.focus_floating()
end)

pwm_modal:bind(CMD, "h", "PWM Switch Space Left", function()
    pwm_modal:exit()
    pwm_a.switch_space_l()
end)

pwm_modal:bind(CMD, "l", "PWM Switch Space Right", function()
    pwm_modal:exit()
    pwm_a.switch_space_r()
end)

pwm_modal:bind(CMD, "1", "PWM Switch Space 1", function()
    pwm_modal:exit()
    pwm_a.switch_space_1()
end)

pwm_modal:bind(CMD, "2", "PWM Switch Space 2", function()
    pwm_modal:exit()
    pwm_a.switch_space_2()
end)

pwm_modal:bind(CMD, "3", "PWM Switch Space 3", function()
    pwm_modal:exit()
    pwm_a.switch_space_3()
end)

------------------------------------------------------------------------------

local eventtap = require("hs.eventtap")
local eventTypes = eventtap.event.types

local armed = false
local clickWatcher = nil

local function printWindowInfo(win)
    if not win then
        print("No window found under cursor.")
        return
    end

    local app = win:application()

    local info = {
        id           = win:id(),
        title        = win:title(),
        role         = win:role(),
        subrole      = win:subrole(),
        frame        = win:frame(),
        isStandard   = win:isStandard(),
        isFullScreen = win:isFullScreen(),

        appName      = app and app:name() or "N/A",
        bundleID     = app and app:bundleID() or "N/A",
        pid          = app and app:pid() or "N/A",

        screen       = win:screen() and win:screen():name() or "N/A",
    }

    print("----- Window Info -----")
    print(hs.inspect(info))
    print("-----------------------")
end

local function disarm()
    armed = false

    if clickWatcher then
        clickWatcher:stop()
        clickWatcher = nil
    end

    print("Window inspector: done")
end

local function arm()
    armed = true

    clickWatcher = eventtap.new({ eventTypes.leftMouseDown }, function(event)
        local pos = hs.mouse.absolutePosition()
        local geo = hs.geometry.point(pos.x, pos.y)

        for _, win in ipairs(hs.window.allWindows()) do
            if geo:inside(win:frame()) then
                printWindowInfo(win)
                break
            end
        end

        disarm()
        return false -- don't block the click
    end)

    clickWatcher:start()

    print("Window inspector: click a window...")
end

hs.hotkey.bind(CMD_CTRL_SHIFT, "i", "Window Info", function()
    if armed then
        disarm()
    else
        arm()
    end
end)


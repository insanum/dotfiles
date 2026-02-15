
-- mkdir .hammerspoon/Spoons; cd .hammerspoon/Spoons
-- git clone https://github.com/mogenson/PaperWM.spoon

local pwm = hs.loadSpoon("PaperWM")

pwm.window_gap = 16
pwm.window_ratios = { 0.25, 0.50, 0.75, 0.90 }
pwm.screen_margin = 4

pwm.lift_window = CMD_SHIFT
--pwm.drag_window = CMD_ALT
pwm.scroll_window = CMD_ALT
pwm.scroll_gain = 30

pwm.window_filter:rejectApp("Stickies")
pwm.window_filter:rejectApp("Finder")
pwm.window_filter:setAppFilter("Google Chrome Beta", { rejectTitles = "Bitwarden" })
--pwm.window_filter:setAppFilter("Microsoft Word", { rejectTitles = "" })

pwm:start()

local pwm_a = pwm.actions.actions()

local pwm_modal = NewModalKey(CMD, 'return', 'Modal PWM')

pwm_modal:bind(NONE, "w", "PWM Cycle Width", pwm_a.cycle_width)
pwm_modal:bind(SHIFT, "w", "PWM Cycle Height", pwm_a.cycle_height)

pwm_modal:bind(NONE, "h", "PWM Focus Left", pwm_a.focus_left)
pwm_modal:bind(NONE, "j", "PWM Focus Down", pwm_a.focus_down)
pwm_modal:bind(NONE, "k", "PWM Focus Up", pwm_a.focus_up)
pwm_modal:bind(NONE, "l", "PWM Focus Right", pwm_a.focus_right)

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

pwm_modal:bind(NONE, "c", "PWM Window Center", function()
    pwm_modal:exit()
    pwm_a.center_window()
end)

pwm_modal:bind(NONE, "f", "PWM Window Full Width", function()
    pwm_modal:exit()
    pwm_a.full_width()
end)

pwm_modal:bind(NONE, "i", "PWM Slurp In", function()
    pwm_modal:exit()
    pwm_a.slurp_in()
end)

pwm_modal:bind(NONE, "o", "PWM Barf Out", function()
    pwm_modal:exit()
    pwm_a.barf_out()
end)

pwm_modal:bind(NONE, "r", "PWM Refresh Windows", function()
    pwm_modal:exit()
    pwm_a.refresh_windows()
end)

pwm_modal:bind(NONE, "t", "PWM Toggle Floating", function()
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


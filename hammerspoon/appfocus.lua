
-- focus the app
--   if not running then start it
--   if running and with just one window, focus that
--   if running and with multiple windows, focus one on current space
local function focus_or_launch_app(appName)
    local app = hs.application.find(appName)
    if app then
        local all_wins = app:allWindows()
        if #all_wins == 0 then
            app:activate()
            return
        end

        local cur_space = hs.spaces.focusedSpace()
        local win_on_cur_space = nil

        for _, win in ipairs(all_wins) do
            if win:isVisible() and not win:isMinimized() then
                local win_spaces = hs.spaces.windowSpaces(win)
                if win_spaces and hs.fnutils.contains(win_spaces, cur_space) then
                    win_on_cur_space = win
                    break
                end
            end
        end

        if win_on_cur_space then
            win_on_cur_space:focus()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus(appName)
    end
end

-- MISC_MODAL:bind('', 'a', 'Focus Alacritty', function()
--     MISC_MODAL:exit()
--     focus_or_launch_app('Alacritty')
-- end)

-- MISC_MODAL:bind('', 'c', 'Focus Chrome', function()
--     MISC_MODAL:exit()
--     focus_or_launch_app('Chrome')
-- end)

MISC_MODAL:bind('', 'e', 'Focus Finder', function()
    MISC_MODAL:exit()
    local finder = hs.application.open("Finder")
    local wins = finder:allWindows()
    if #wins == 1 and wins[1]:isStandard() == false then
        finder:selectMenuItem({ "File", "New Finder Window" })
    end
    finder:activate()
end)

-- MISC_MODAL:bind('', 'f', 'Focus Firefox', function()
--     MISC_MODAL:exit()
--     focus_or_launch_app('Firefox')
-- end)

MISC_MODAL:bind('', 'g', 'Focus Ghostty', function()
    MISC_MODAL:exit()
    focus_or_launch_app('Ghostty')
end)

MISC_MODAL:bind('', 'h', 'Focus Helium', function()
    MISC_MODAL:exit()
    focus_or_launch_app('Helium')
end)

MISC_MODAL:bind('', 'k', 'Focus Kitty', function()
    MISC_MODAL:exit()
    focus_or_launch_app('Kitty')
end)

MISC_MODAL:bind('', 'p', 'Focus PDF Expert', function()
    MISC_MODAL:exit()
    focus_or_launch_app('PDF Expert')
end)

MISC_MODAL:bind('', 's', 'Focus Stickies', function()
    MISC_MODAL:exit()
    focus_or_launch_app('Stickies')
end)

MISC_MODAL:bind('', 'z', 'Focus Zoom', function()
    MISC_MODAL:exit()
    focus_or_launch_app('Zoom')
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

MISC_MODAL:bind('', 'x', 'Window Info', function()
    MISC_MODAL:exit()
    if armed then
        disarm()
    else
        arm()
    end
end)


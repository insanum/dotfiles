
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

Mod_Key:bind('', 'c', 'Focus Chrome', function()
    Mod_Key:exit()
    focus_or_launch_app('Chrome')
end)

Mod_Key:bind('', 'e', 'Focus Finder', function()
    Mod_Key:exit()
    local finder = hs.application.open("Finder")
    local wins = finder:allWindows()
    if #wins == 1 and wins[1]:isStandard() == false then
        finder:selectMenuItem({ "File", "New Finder Window" })
    end
    finder:activate()
end)

Mod_Key:bind('', 'f', 'Focus Firefox', function()
    Mod_Key:exit()
    focus_or_launch_app('Firefox')
end)

Mod_Key:bind('', 'g', 'Focus Ghostty', function()
    Mod_Key:exit()
    focus_or_launch_app('Ghostty')
end)

Mod_Key:bind('', 'p', 'Focus PDF Expert', function()
    Mod_Key:exit()
    focus_or_launch_app('PDF Expert')
end)

Mod_Key:bind('', 's', 'Focus Stickies', function()
    Mod_Key:exit()
    focus_or_launch_app('Stickies')
end)

Mod_Key:bind('', 'z', 'Focus Zoom', function()
    Mod_Key:exit()
    focus_or_launch_app('Zoom')
end)


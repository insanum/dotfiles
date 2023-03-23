
-- hack to clear the top showing notification

function clearNotification(doubleClick)
    local mouseOrigin = hs.mouse.absolutePosition()
    local win = hs.window.focusedWindow()

    local pmon = hs.screen.primaryScreen():frame()
    local clickPoint = { x=0, y=0 }

    -- MacBook 16"
    if (pmon.w == 1792) and (pmon.h == 1095) then
        clickPoint = { x=1440, y=47 }
    -- Dell U3818DW 3840x1600
    elseif (pmon.w == 3840) and (pmon.h == 1575) then
        clickPoint = { x=3485, y=47 }
    -- Samsung S34J55x 3440x1440
    elseif (pmon.w == 3440) and (pmon.h == 1415) then
        clickPoint = { x=3085, y=47 }
    else
        print("Unknown monitor (size w="..pmon.w.." h="..pmon.h..")")
        return
    end

    hs.mouse.absolutePosition(clickPoint)
    hs.timer.usleep(500000) -- .5s

    -- click the "close" button on the notification
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

    -- the double click is for clearing a group of similar notifications
    if (doubleClick) then
        hs.timer.usleep(1000) -- 1ms
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()
    end

    -- move the mouse pointer back to the original location
    hs.mouse.absolutePosition(mouseOrigin)

    -- (re)focus the original window the pointer was over
    win:focus()
end

--hs.hotkey.bind(kb_ctrl, "o", "Clear the top notification",
hs.hotkey.bind({ "cmd", "ctrl" }, "o", "Clear the top notification",
function()
    -- Uncomment the following to print current mouse location to console.
    if (false) then
        print("Mouse location: x=" .. hs.mouse.absolutePosition().x ..
                             " y=" .. hs.mouse.absolutePosition().y)
    else
        clearNotification(false)
    end
end)

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "o", "Clear the top notification group",
function()
    clearNotification(true)
end)


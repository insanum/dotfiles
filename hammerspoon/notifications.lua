
-- hack to clear the top showing notification

function clearNotification(doubleClick)
    local mouseOrigin = hs.mouse.absolutePosition()
    local win = hs.window.focusedWindow()

    local pmon = hs.screen.primaryScreen():frame()
    local clickPoint = { x=0, y=0 }

    -- DELL U3818DW 3840x1600
    if (pmon.w == 3840) and (pmon.h == 1575) then
        clickPoint = { x=3485, y=47 }
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
    clearNotification(false)
end)

hs.hotkey.bind({ "cmd", "ctrl", "shift" }, "o", "Clear the top notification group",
function()
    clearNotification(true)
end)


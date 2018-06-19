
-- hack to clear the top showing notification

function clearNotification()
    local mouseOrigin = hs.mouse.getAbsolutePosition()
    local win = hs.window.focusedWindow()

    local max = hs.screen.primaryScreen():frame()
    local clickPoint = { x=(max.w - (max.w * .03)), y=(max.h * .05) }

    -- click the "close" button on the notification
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()

    -- move the mouse pointer back to the original location
    hs.mouse.setAbsolutePosition(mouseOrigin)

    -- (re)focus the original window the pointer was over
    win:focus()
end

--hs.hotkey.bind(kb_ctrl, "o", "Clear the top notification",
hs.hotkey.bind({ "cmd" }, "o", "Clear the top notification",
function()
    clearNotification()
end)


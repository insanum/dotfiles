
local pomo = {
    bar_height     = 0.1, -- ratio of the height of the menubar (0..1)
    bar_alpha      = 0.6,
    bar_past_clr   = hs.drawing.color.x11.blue,
    bar_past       = nil,
    bar_future_clr = hs.drawing.color.x11.orange,
    bar_future     = nil,

    -- 52x17
    --def_work_secs = 52 * 60,
    --def_rest_secs = 17 * 60,
    -- 25x5
    --def_work_secs = 25 * 60,
    --def_rest_secs = 5 * 60,
    -- 30x5
    def_work_secs = 30 * 60,
    def_rest_secs = 5 * 60,

    is_active     = false,
    disable_count = 0,
    work_count    = 0,
    cur_state     = "work", -- {"work", "rest"}
    time_left     = 0,
    max_time_sec  = 0,
    menu          = nil,
    timer         = nil
}

-- draw the pomodoro bar
function pomo_draw_bar(time_left, max_time)
    local screen_usable = hs.screen.mainScreen():frame()
    local screen_full   = hs.screen.mainScreen():fullFrame()

    local future_width  = math.ceil(screen_full.w * (time_left / max_time))
    local past_width    = (screen_full.w - future_width)

    local draw = function(bar, offset, width)
        -- get the height in pixels as a percentage of the non-usable menu
        -- space at the top of the current screen
        local height = (pomo.bar_height * (screen_usable.y - screen_full.y))

        bar:setSize(hs.geometry.rect((screen_full.x + offset),
                                     screen_full.y,
                                     width,
                                     height))
        bar:setTopLeft(hs.geometry.point((screen_full.x + offset),
                                         screen_full.y))
        bar:show()
    end

    draw(pomo.bar_past, 0, past_width)
    draw(pomo.bar_future, past_width, future_width)
end

-- update the pomodoro display
local function pomo_update_display()
    local time_min = math.floor(pomo.time_left / 60)
    local time_sec = (pomo.time_left - (time_min * 60))

    local str = string.format ("%s %02d:%02d #%02d",
                               pomo.cur_state,
                               time_min,
                               time_sec,
                               pomo.work_count)

    local font = { name = "Hack Nerd Font", size = 12 }

    local color = hs.drawing.color.x11.dimgray
    if pomo.is_active then
        color = hs.drawing.color.x11.magenta
    elseif pomo.disable_count == 1 then
        color = hs.drawing.color.x11.red
    end

    pomo.menu:setTitle(hs.styledtext.new("[",
                                         {
                                           font  = font,
                                           color = hs.drawing.color.x11.white
                                         }) ..
                       hs.styledtext.new(str,
                                         {
                                           font  = font,
                                           color = color
                                         }) ..
                       hs.styledtext.new("]",
                                         {
                                           font  = font,
                                           color = hs.drawing.color.x11.white
                                         })
                      )

    if pomo.is_active then
        pomo_draw_bar(pomo.time_left, pomo.max_time_sec)
    end
end

-- stop the pomodoro timer
--  * first disable will pause the pomodoro
--  * second disable will reset the pomodoro and hide the bar
local function pomo_disable()
    pomo.is_active = false

    if (pomo.disable_count == 0) then
        -- stop the pomodoro timer
        if (pomo.timer ~= nil) then
            pomo.timer:stop()
            pomo.timer = nil
        end

        pomo.disable_count = 1

        -- update the display
        pomo_update_display()

        return
    end

    if (pomo.disable_count == 1) then
        -- reset the pomodoro state
        pomo.work_count   = 0;
        pomo.time_left    = pomo.def_work_secs
        pomo.max_time_sec = pomo.def_work_secs
        pomo.cur_state    = "work"

        -- delete the past bar
        pomo.bar_past:delete()
        pomo.bar_past = nil

        -- delete the future bar
        pomo.bar_future:delete()
        pomo.bar_future = nil

        pomo.disable_count = 2

        -- update the display
        pomo_update_display()

        return
    end
end

-- send a pomodoro state completion notification
local function pomo_notify(msg)
    local n = hs.notify.new({
        title     = msg,
        subTitle  = "Completed at " .. os.date("%H:%M"),
        soundName = "Hero"
    })
    print("Pomodoro: "..n:title().." "..n:subTitle())
    n:autoWithdraw(false)
    n:hasActionButton(true)
    n:send()
end

-- update the pomodoro state
local function pomo_update_state()
    if (pomo.is_active == false) then
        return
    end

    pomo.time_left = (pomo.time_left - 1)

    if (pomo.time_left > 0 ) then
        return
    end

    if (pomo.cur_state == "work") then
        pomo_notify("Work completed!")
        pomo.work_count   = (pomo.work_count + 1)
        pomo.cur_state    = "rest"
        pomo.time_left    = pomo.def_rest_secs
        pomo.max_time_sec = pomo.def_rest_secs
    else -- (pomo.cur_state == "rest")
        pomo_notify("Get back to work!")
        pomo.cur_state    = "work"
        pomo.time_left    = pomo.def_work_secs
        pomo.max_time_sec = pomo.def_work_secs
    end
end

-- timer function to update the pomodoro state and display (menu and bar)
local function pomo_update()
    pomo_update_state()
    pomo_update_display()
end

-- create the pomodoro display (menu and bar)
local function pomo_create_display()
    if (pomo.menu == nil) then
        pomo.menu = hs.menubar.new()
    end

    local init_bar = function(bar, color)
        bar:setFill(true)
        bar:setFillColor(color)
        bar:setAlpha(pomo.bar_alpha)
        bar:setLevel(hs.drawing.windowLevels.overlay)
        bar:setStroke(false)
        bar:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    end

    if (pomo.bar_past == nil) then
        pomo.bar_past = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
        init_bar(pomo.bar_past, pomo.bar_past_clr)
    end

    if (pomo.bar_future == nil) then
        pomo.bar_future = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
        init_bar(pomo.bar_future, pomo.bar_future_clr)
    end
end

-- start the pomodoro timer
local function pomo_enable()
    pomo.disable_count = 0

    if (pomo.is_active) then
        return
    end

    pomo_create_display()
    pomo.is_active = true

    pomo.timer = hs.timer.new(1, pomo_update)
    pomo.timer:start()
end

-- initialize the pomodoro state and display
pomo.time_left    = pomo.def_work_secs
pomo.max_time_sec = pomo.def_work_secs
pomo_create_display()
pomo.menu:setMenu(
    {
        { title = "Start", fn = pomo_enable  },
        { title = "Stop",  fn = pomo_disable },
        { title = "Reset", fn = function() pomo_disable(); pomo_disable() end }
    })
pomo_update()

hs.hotkey.bind(CMD_CTRL, "9", "Pomodoro Enable",  pomo_enable)
hs.hotkey.bind(CMD_CTRL, "0", "Pomodoro Disable", pomo_disable)


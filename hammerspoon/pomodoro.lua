
--local mash       = {"cmd", "alt", "ctrl"}
--local mash_shift = {"cmd", "alt", "ctrl", "shift"}
local mash       = {"cmd", "ctrl"}
local mash_shift = {"cmd", "ctrl", "shift"}

local commands = {}
local pomo     = {}

pomo.bar = {
    height     = 0.1, -- ratio of the height of the menubar (0..1)
    alpha      = 0.6,
    clr_future = hs.drawing.color.green,
    clr_past   = hs.drawing.color.red,
    future     = nil,
    past       = nil
}

pomo.time = {
    -- 52.17
    work_secs = 52 * 60,
    rest_secs = 17 * 60
    -- 25.5
    --work_secs = 25 * 60,
    --rest_secs = 5 * 60
}

pomo.var = {
    is_active     = false,
    disable_count = 0,
    work_count    = 0,
    cur_state     = "work", -- {"work", "rest"}
    time_left     = pomo.time.work_secs,
    max_time_sec  = pomo.time.work_secs,
    menu          = nil,
    timer         = nil
}

-- draw the pomodoro bar
function pomo_draw_bar(time_left, max_time)
    local main_screen = hs.screen.mainScreen()
    local screeng     = main_screen:fullFrame()
    local time_ratio  = (time_left / max_time)
    local width       = math.ceil(screeng.w * time_ratio)
    local left_width  = (screeng.w - width)

    local draw = function(bar, screen, offset, width, fill_color)
        local screeng                  = screen:fullFrame()
        local screen_frame_height      = screen:frame().y
        local screen_full_frame_height = screeng.y
        local height_delta             = (screen_frame_height -
                                          screen_full_frame_height)
        local height                   = (pomo.bar.height * (height_delta))

        bar:setSize(hs.geometry.rect((screeng.x + offset),
                                     screen_full_frame_height,
                                     width,
                                     height))
        bar:setTopLeft(hs.geometry.point((screeng.x + offset),
                                         screen_full_frame_height))
        bar:setFillColor(fill_color)
        bar:setFill(true)
        bar:setAlpha(pomo.bar.alpha)
        bar:setLevel(hs.drawing.windowLevels.overlay)
        bar:setStroke(false)
        bar:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
        bar:show()
    end

    draw(pomo.bar.future,
         main_screen,
         left_width,
         width,
         pomo.bar.clr_future)
    draw(pomo.bar.past,
         main_screen,
         0,
         left_width,
         pomo.bar.clr_past)
end

-- update the pomodoro display
local function pomo_update_display()
    local time_min = math.floor(pomo.var.time_left / 60)
    local time_sec = (pomo.var.time_left - (time_min * 60))
    local str = string.format ("[ %s %02d:%02d #%02d ]",
                               pomo.var.cur_state,
                               time_min,
                               time_sec,
                               pomo.var.work_count)
    pomo.var.menu:setTitle(str)

    if (pomo.var.is_active) then
        pomo_draw_bar(pomo.var.time_left, pomo.var.max_time_sec)
    end
end

-- stop the pomodoro timer
--  * first disable will pause the pomodoro
--  * second disable will reset the pomodoro and hide the bar
local function pomo_disable()
    pomo.var.is_active = false

    if (pomo.var.disable_count == 0) then
        -- stop the pomodoro timer
        if (pomo.var.timer ~= nil) then
            pomo.var.timer:stop()
            pomo.var.timer = nil
        end

        pomo.var.disable_count = 1
        return
    end

    if (pomo.var.disable_count == 1) then
        -- reset the pomodoro state
        pomo.var.time_left    = pomo.time.work_secs
        pomo.var.max_time_sec = pomo.time.work_secs
        pomo.var.cur_state    = "work"

        -- update the display
        pomo_update_display()

        -- delete the future bar
        pomo.bar.future:delete()
        pomo.bar.future = nil

        -- delete the past bar
        pomo.bar.past:delete()
        pomo.bar.past = nil

        pomo.var.disable_count = 2
        return
    end
end

-- send a pomodoro state completion notification
local function pomo_notify(msg)
    local n = hs.notify.new({
        title           = msg,
        informativeText = 'Completed at ' .. os.date('%H:%M'),
        soundName       = 'Hero'
    })
    n:autoWithdraw(false)
    n:hasActionButton(false)
    n:send()
end

-- update the pomodoro state
local function pomo_update_state()
    if (pomo.var.is_active == false) then
        return
    end

    pomo.var.time_left = (pomo.var.time_left - 1)

    if (pomo.var.time_left > 0 ) then
        return
    end

    if (pomo.var.cur_state == "work") then
        pomo_notify('Work completed!')
        pomo.var.work_count   = (pomo.var.work_count + 1)
        pomo.var.cur_state    = "rest"
        pomo.var.time_left    = pomo.time.rest_secs
        pomo.var.max_time_sec = pomo.time.rest_secs
    else -- (pomo.var.cur_state == "rest")
        pomo_notify('Get back to work!')
        pomo.var.cur_state    = "work"
        pomo.var.time_left    = pomo.time.work_secs
        pomo.var.max_time_sec = pomo.time.work_secs
    end
end

-- timer function to update the pomodoro state and display (menu and bar)
local function pomo_update()
    pomo_update_state()
    pomo_update_display()
end

-- create the pomodoro display (menu and bar)
local function pomo_create_display()
    if (pomo.var.menu == nil) then
        pomo.var.menu = hs.menubar.new()
    end

    if (pomo.bar.future == nil) then
        pomo.bar.future = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
        pomo.bar.past   = hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
    end
end

-- start the pomodoro timer
local function pomo_enable()
    pomo.var.disable_count = 0

    if (pomo.var.is_active) then
        return
    end

    pomo_create_display()
    pomo.var.is_active = true

    pomo.var.timer = hs.timer.new(1, pomo_update)
    pomo.var.timer:start()
end

-- initialize the pomodoro state and display
pomo_create_display()
pomo_update()

hs.hotkey.bind(mash, '9', pomo_enable)
hs.hotkey.bind(mash, '0', pomo_disable)


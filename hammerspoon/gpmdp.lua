
local timer   = require("hs.timer")
local image   = require("hs.image")
local notify  = require("hs.notify")
local alert   = require("hs.alert")
local menubar = require("hs.menubar")
local window  = require("hs.window")
local chooser = require("hs.chooser")
local hotkey  = require("hs.hotkey")
local stext   = require("hs.styledtext")
local app     = require("hs.application")
local x11_clr = require("hs.drawing").color.x11
local cprint  = require("hs.console").printStyledtext

gpmdp_app_name = "Google Play Music Desktop Player"
gpmdp_proxy    = "socks5://127.0.0.1:9999"
gpmdp_rc       = "/Users/edavis/src/gpmdp_rc/target/debug/gpmdp_rc"

local gpmdp = {
    image           = image.imageFromPath("gmusic.png"),
    work_ok         = false,
    work_id         = 0,
    working         = false,
    work            = { },
    status_worker   = nil,
    status          = { },
    menu_table      = nil,
    menu            = nil,
    playlist_name   = nil,
    playlist_tracks = { },
    playlists       = { },
    notifications   = true,
    halt            = false,
    font            = "Hack",
    fsize_default   = 16,
    fsize_menu      = 12,
    fsize_console   = 12
}

local gpmdp_get_status, gpmdp_reset

local function st(txt, color, fsize)
    local font = { font = gpmdp.font, size = gpmdp.fsize_default }
    if (fsize ~= nil) then
        font.size = fsize
    end

    return stext.new(txt, {
                            font  = font,
                            color = { hex = color }
                          })
end

local function st_red(txt, fsize)    return st(txt, "#ff0000", fsize) end
local function st_green(txt, fsize)  return st(txt, "#00ff00", fsize) end
local function st_blue(txt, fsize)   return st(txt, "#0000ff", fsize) end
local function st_orange(txt, fsize) return st(txt, "#ff8c00", fsize) end
local function st_white(txt, fsize)  return st(txt, "#ffffff", fsize) end
local function st_grey(txt, fsize)   return st(txt, "#696969", fsize) end

-- send a gpmdp notification
local function gpmdp_notify(subtitle, title, info)
    if (gpmdp.notifications == false) then
        return
    end
    local n = notify.new({
                           title           = "GPMDP",
                           subTitle        = subtitle,
                           informativeText = ""
                         })
    if (title ~= nil) then
        n:title(title)
    end
    if (info ~= nil) then
        n:informativeText(info)
    end
    print("GPMDP: " .. n:title() .. " " .. n:subTitle() .. " " .. n:informativeText())
    n:autoWithdraw(false)
    n:hasActionButton(true)
    n:send()
end

local function gpmdp_alert(msg)
    alert(msg, { radius = 0, atScreenEdge = 2 }, 4)
    print("GPMDP alert: " .. msg:getString())
    cprint(msg)
end

local function gpmdp_worker()
    if (gpmdp.working == true) then
        --print("GPMDP: already working")
        return
    else
        gpmdp.working = true
    end

    if (#gpmdp.work == 0) then
        print("GPMDP: no more work")
        gpmdp.working = false
        return
    end

    local wi = table.remove(gpmdp.work, 1)

    if (gpmdp.work_ok == false) then
        print("GPMDP: dropped command (" .. wi.id .. ")")
        if (wi.cbk_fail ~= nil) then
            wi.cbk_fail()
        end

        gpmdp.working = false
        timer.doAfter(0, gpmdp_worker)
        return
    end

    local cmd = wi.cbk(wi.cbk_args)
    if (cmd == nil) then
        print("GPMDP: 'nil' command (" .. wi.id .. ")")
        gpmdp.working = false
        timer.doAfter(0, gpmdp_worker)
        return
    end

    cprint(st_grey("GPMDP: executing command (" .. wi.id .. ")\n" .. cmd,
                   gpmdp.fsize_console))

    -- execute the command (synchronously)
    local output, status, type, rc = hs.execute(gpmdp_rc .. " " .. cmd)

    -- XXX fix gpmdp_rc to set return status code non-zero on error
    if (status == false) or output:match("^ERROR:%s+.*\n$") then
        cprint(st_red("ERROR", gpmdp.fsize_console))
        --gpmdp_notify("execute failed")
        if (wi.cbk_fail ~= nil) then
            wi.cbk_fail()
        end
    else
        if (wi.cbk_done ~= nil) then
            wi.cbk_done(output)
        end
    end

    gpmdp.working = false
    timer.doAfter(0, gpmdp_worker)
end

local function gpmdp_schedule_work(cbk, cbk_args, cbk_done, cbk_fail)
    if (gpmdp.halt == true) then
        return
    end

    gpmdp.work_id = gpmdp.work_id + 1
    print("GPMDP: scheduling command (" .. gpmdp.work_id .. ")")

    local cmd_tbl = {
                      id       = gpmdp.work_id,
                      cbk      = cbk,
                      cbk_args = cbk_args,
                      cbk_done = cbk_done,
                      cbk_fail = cbk_fail
                    }

    gpmdp.work[#gpmdp.work + 1] = cmd_tbl
    timer.doAfter(0, gpmdp_worker)
end

local function gpmdp_status()
    if (next(gpmdp.status) == nil) then
        gpmdp_notify("GPMDP: status is not available")
        gpmdp.status_worker:fire()
        return
    end

    if ((gpmdp.status.state == "stopped") and
        (tonumber(gpmdp.status.queue_length) == 0)) then
        gpmdp_notify("No playlist loaded")
        return
    end

    local msg = ""
    if (gpmdp.status.state == "playing") then
        msg = "[playing]"
    elseif (gpmdp.status.state == "paused") then
        msg = "[paused]"
    elseif (gpmdp.status.state == "stopped") then
        msg = "[stopped]"
    end

    local percentage   = "0%"
    local artist       = nil
    local title        = nil

    if (gpmdp.status.artist ~= nil) then
        artist = gpmdp.status.artist
    end
    if (gpmdp.status.title ~= nil) then
        title = gpmdp.status.title
    end

    if ((gpmdp.status.state ~= "stopped") and
        (tonumber(gpmdp.status.time_total_secs) ~= 0)) then
        percentage = tostring(math.ceil((math.ceil(tonumber(gpmdp.status.time_elapsed_secs)) /
                                         tonumber(gpmdp.status.time_total_secs)) * 100)) .. "%"
    end

    msg = msg .. " #" .. gpmdp.status.queue_track .. "/" .. gpmdp.status.queue_length
    msg = msg .. " " .. gpmdp.status.time_elapsed_fmt .. "/" .. gpmdp.status.time_total_fmt .. " (" .. percentage .. ")"

    if ((artist ~= nil) and (title ~= nil)) then
        gpmdp_notify(msg, artist .. " - " .. title)
    elseif (artist ~= nil) then
        gpmdp_notify(msg, artist .. " - (unknown)")
    elseif (title ~= nil) then
        gpmdp_notify(msg, "(unknown) - " .. title)
    else
        gpmdp_notify(msg)
    end
end

local function gpmdp_status_menu()
    if (next(gpmdp.status) == nil) then
        return
    end

    if ((gpmdp.status.state == "stopped") and
        (tonumber(gpmdp.status.queue_length) == 0)) then
        return st_grey("none", true)
    end

    local percentage = "0%"

    if ((gpmdp.status.state ~= "stopped") and
        (tonumber(gpmdp.status.time_total_secs) ~= 0)) then
        percentage = tostring(math.ceil((math.ceil(tonumber(gpmdp.status.time_elapsed_secs)) /
                                         tonumber(gpmdp.status.time_total_secs)) * 100)) .. "%"
    end

    msg = "#" .. gpmdp.status.queue_track .. "/" .. gpmdp.status.queue_length
    msg = msg .. " " .. gpmdp.status.time_elapsed_fmt .. "/" .. gpmdp.status.time_total_fmt .. " (" .. percentage .. ")"

    if (gpmdp.status.state == "playing") then
        return st_orange(msg, gpmdp.fsize_menu)
    else
        return st_grey(msg, gpmdp.fsize_menu)
    end
end

local function gpmdp_replay()
    local cbk = function()
        return "replay"
    end
    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_seek_backward()
    local cbk = function()
        return "seek backward" -- -10s
    end
    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_seek_forward()
    local cbk = function()
        return "seek forward" -- +10s
    end
    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_play_pause()
    local cbk = function()
        if (gpmdp.status.state == nil) then
            return nil
        end

        local play_pause = nil
        local cmd = nil
        if (gpmdp.status.state == "playing") then
            cmd = "pause"
            play_pause = st_orange("Paused")
        elseif (gpmdp.status.state == "paused") then
            cmd = "play"
            play_pause = st_green("Unpaused")
        elseif (gpmdp.status.state == "stopped") then
            cmd = "play"
            play_pause = st_green("Play")
        end

        gpmdp_alert(st_white("GPMDP ") .. play_pause)
        return cmd
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_shuffle()
    local cbk = function()
        if (gpmdp.status.shuffle == nil) then
            return nil
        end

        local on_off = nil
        local cmd = nil
        if (gpmdp.status.shuffle == "off") then
            cmd = "shuffle on"
            on_off = st_green("ON")
        else
            cmd = "shuffle off"
            on_off = st_red("OFF")
        end

        gpmdp_alert(st_white("GPMDP Shuffle ") .. on_off)
        return cmd
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_repeat()
    local cbk = function()
        if (gpmdp.status["repeat"] == nil) then
            return
        end

        local r = tonumber(gpmdp.status["repeat"])
        local s = tonumber(gpmdp.status.single)

        local cycle = nil
        local cmd = nil
        if (gpmdp.status["repeat"] == "off") then
            cmd = "repeat all"
            cycle = st_green("ALL")
        elseif (gpmdp.status["repeat"] == "all") then
            cmd = "repeat single"
            cycle = st_orange("SINGLE")
        else -- turn it off
            cmd = "repeat off"
            cycle = st_red("OFF")
        end

        gpmdp_alert(st_white("GPMDP Repeat ") .. cycle)
        return cmd
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_next()
    local cbk = function()
        gpmdp_alert(st_white("GPMDP ") .. st_orange("Next"))
        return "next"
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_previous()
    local cbk = function()
        gpmdp_alert(st_white("GPMDP ") .. st_orange("Previous"))
        return "prev"
    end

    -- XXX check the elapsed time for sending double "prev" commands

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

local function gpmdp_play_track()
    local last_win = window.focusedWindow()

    local chooser_cbk = function(selection)
        local cbk = function(args)
            return "play " .. args.idx
        end

        local cbk_done = function(data)
            if last_win ~= nil then
                last_win:focus() -- focus last window
            end
        end

        if selection == nil then
            if last_win ~= nil then
                last_win:focus() -- focus last window
            end

            return
        end

        gpmdp_schedule_work(cbk, { idx = selection.idx }, cbk_done)
        gpmdp_get_status()
    end

    if (#gpmdp.playlist_tracks == 0) then
        gpmdp_notify("Playlist is empty")
        return
    end

    local tracks = { }

    for i = 1,#gpmdp.playlist_tracks do
        tracks[#tracks + 1] =
            {
              text    = tostring(i) .. ": " ..
                        gpmdp.playlist_tracks[i].artist .. " - " ..
                        gpmdp.playlist_tracks[i].track,
              subText = gpmdp.playlist_tracks[i].album,
              idx     = gpmdp.playlist_tracks[i].idx,
              i       = i
            }
    end

    local ch = chooser.new(chooser_cbk)
    ch:choices(tracks)
    --ch:rows(#tracks)
    ch:rows(15)
    ch:width(40)
    ch:bgDark(true)
    ch:fgColor(x11_clr.orange)
    ch:subTextColor(x11_clr.chocolate)
    ch:searchSubText(true)
    ch:show()
end

local function gpmdp_get_queue()
    local cbk = function()
        return "queue"
    end

    local cbk_done = function(data)
        local album  = nil
        local artist = nil
        local track  = nil

        for t in data:gmatch("[^\r\n]+") do
            -- Note the '-' is the non-greedy '*' for lua regex
            local key, value = t:match("^(.-):%s+(.*)$")

            local artist, album, track = value:match("^(.-)%s|%s(.*)%s|%s(.*)$")

            if ((album ~= nil) and (artist ~= nil) and (track ~= nil)) then
                gpmdp.playlist_tracks[#gpmdp.playlist_tracks + 1] =
                    { artist = artist, album = album, track = track, idx = key }
                album  = nil
                artist = nil
                track  = nil
            end
        end

        gpmdp_notify("Retrieved tracks in queue")
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
end

local function gpmdp_get_playlists()
    local cbk = function()
        return "playlists"
    end

    local cbk_done = function(data)
        gpmdp.playlists = { }

        for p in data:gmatch("[^\r\n]+") do
            -- Note the '-' is the non-greedy '*' for lua regex
            local key, value = p:match("^(.-):%s+(.+)$")
            gpmdp.playlists[#gpmdp.playlists + 1] =
                { name = value, idx = key }
        end

        gpmdp_notify("Retrieved playlists")
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
end

local function gpmdp_load_playlist()
    local last_win = window.focusedWindow()

    local chooser_cbk = function(selection)
        local cbk = function(args)
            return "playlist " .. args.idx
        end

        local cbk_done = function(data)
            gpmdp.playlist_tracks = { }
            gpmdp.playlist_name = gpmdp.playlists[selection.i].name
            gpmdp_notify("Loaded playlist \"" .. gpmdp.playlist_name .. "\"")

            if last_win ~= nil then
                last_win:focus() -- focus last window
            end

            -- get a list of the tracks in the current playlist
            gpmdp_get_queue()
        end

        if selection == nil then
            if last_win ~= nil then
                last_win:focus() -- focus last window
            end

            return
        end

        gpmdp_schedule_work(cbk, { idx = selection.idx }, cbk_done)
        gpmdp_get_status()
    end

    local playlists = { }

    for i = 1,#gpmdp.playlists do
        playlists[#playlists + 1] =
            {
              text = tostring(i) .. ": " .. gpmdp.playlists[i].name,
              idx  = gpmdp.playlists[i].idx,
              i    = i
            }
    end

    if (#playlists == 0) then
        gpmdp_notify("No playlists available")
        return
    end

    local ch = chooser.new(chooser_cbk)
    ch:choices(playlists)
    --ch:rows(#playlists)
    ch:rows(15)
    ch:width(40)
    ch:bgDark(true)
    ch:fgColor(x11_clr.orange)
    ch:subTextColor(x11_clr.chocolate)
    ch:show()
end

local function gpmdp_clear()
    local cbk = function()
        return "clear"
    end

    local cbk_done = function(data)
        gpmdp.playlist_tracks = { }
        gpmdp_notify("Playlist cleared")
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
    gpmdp_get_status()
end

local function gpmdp_set_volume(args)
    if (gpmdp.status.volume == nil) then
        return nil
    end

    local volume = nil
    if (args.delta == nil) then
        volume = args.volume
    else
        volume = (tonumber(gpmdp.status.volume) + args.delta)
        if (volume < 0) then
            volume = 0
        elseif (volume > 100) then
            volume = 100
        end
    end

    gpmdp_alert(st_white("GPMDP Volume ") .. st_orange(volume .. "%"))
    return "volume " .. volume
end

local function gpmdp_volume_up()
    gpmdp_schedule_work(gpmdp_set_volume, { delta = 10 })
end

local function gpmdp_volume_down()
    gpmdp_schedule_work(gpmdp_set_volume, { delta = -10 })
end

local function gpmdp_thumbs_up()
    local cbk = function()
        return "thumbs up"
    end

    gpmdp_schedule_work(cbk)
end

local function gpmdp_thumbs_down()
    local cbk = function()
        return "thumbs down"
    end

    gpmdp_schedule_work(cbk)
end

-- defined as local at top of file
gpmdp_get_status = function()
    local cbk = function()
        return "status"
    end

    local cbk_done = function(data)
        local res = { }
        for s in data:gmatch("[^\r\n]+") do
            -- Note the '-' is the non-greedy '*' for lua regex
            local key, value = s:match("^(.-):%s+(.+)$")
            res[key] = value
        end

        -- check if the track changed
        local do_gpmdp_status = false
        if ((next(gpmdp.status) ~= nil) and (gpmdp.status.title ~= res.title)) then
            do_gpmdp_status = true
        end

        gpmdp.status = res

        if (do_gpmdp_status == true) then
            gpmdp_status()
        end

        local update_menu = false

        -- update the pause checked state in the menu
        if (gpmdp.status.state ~= nil) then
            local checked = gpmdp.menu_table[4].checked
            if (gpmdp.status.state == "paused") then
                gpmdp.menu_table[4].checked = true
            else
                gpmdp.menu_table[4].checked = false
            end
            if (checked ~= gpmdp.menu_table[4].checked) then
                update_menu = true
            end
        end

        -- update the shuffle checked state in the menu
        if (gpmdp.status.shuffle ~= nil) then
            local checked = gpmdp.menu_table[5].checked
            if (gpmdp.status.shuffle == "on") then
                gpmdp.menu_table[5].checked = true
            else
                gpmdp.menu_table[5].checked = false
            end
            if (checked ~= gpmdp.menu_table[5].checked) then
                update_menu = true
            end
        end

        -- update the repeat checked state in the menu
        if (gpmdp.status["repeat"] ~= nil) then
            local checked = gpmdp.menu_table[6].checked
            local title   = gpmdp.menu_table[6].title
            if (gpmdp.status["repeat"] == "off") then
                gpmdp.menu_table[6].checked = false
                gpmdp.menu_table[6].title = "Repeat"
            elseif (gpmdp.status["repeat"] == "all") then
                gpmdp.menu_table[6].checked = true
                gpmdp.menu_table[6].title = "Repeat All"
            elseif (gpmdp.status["repeat"] == "single") then
                gpmdp.menu_table[6].checked = true
                gpmdp.menu_table[6].title = "Repeat Single"
            end
            if ((checked ~= gpmdp.menu_table[6].checked) or
                (title ~= gpmdp.menu_table[6].title)) then
                update_menu = true
            end
        end

        if (update_menu == true) then
            gpmdp.menu:setMenu(gpmdp.menu_table)
        end

        -- update the menu title
        gpmdp.menu:setTitle(st_white("[", gpmdp.fsize_menu) ..
                            st_grey("GPMDP: ", gpmdp.fsize_menu) ..
                            gpmdp_status_menu() ..
                            st_white("]", gpmdp.fsize_menu))

        -- update the menu tooltip
        local tooltip = ""
        if (gpmdp.status.state == "playing") then
            local artist = "[unknown]"
            local title  = "[unknown]"
            if (gpmdp.status.artist ~= nil) then
                artist = gpmdp.status.artist
            end
            if (gpmdp.status.title ~= nil) then
                title = gpmdp.status.title
            end
            tooltip = artist .. " - " .. title
        end
        gpmdp.menu:setTooltip(tooltip)
    end

    local cbk_fail = function()
        gpmdp.playlist_name   = "GPMDP"
        gpmdp.playlist_tracks = { }
        gpmdp.playlists       = { }

        -- update the menu title
        gpmdp.menu:setTitle(st_white("[", gpmdp.fsize_menu) ..
                            st_grey("GPMDP: ", gpmdp.fsize_menu) ..
                            st_red("none", gpmdp.fsize_menu) ..
                            st_white("]", gpmdp.fsize_menu))
    end

    gpmdp_schedule_work(cbk, nil, cbk_done, cbk_fail)
end

local function gpmdp_notifications()
    local on_off = nil
    if (gpmdp.notifications == false) then
        gpmdp.notifications = true
        on_off = st_green("ON")
    else
        gpmdp.notifications = false
        on_off = st_red("OFF")
    end

    gpmdp_alert(st_white("GPMDP Notifications ") .. on_off)

    gpmdp.menu_table[17].checked = gpmdp.notifications
    gpmdp.menu:setMenu(gpmdp.menu_table)
end

local function gpmdp_halt()
    if (gpmdp.halt == false) then
        if (gpmdp.status_worker ~= nil) then
            gpmdp.status_worker:stop()
            gpmdp.status_worker = nil
        end

        gpmdp.halt = true

        gpmdp.menu:setTitle(st_white("[", gpmdp.fsize_menu) ..
                            st_grey("GPMDP: ", gpmdp.fsize_menu) ..
                            st_red("halted", gpmdp.fsize_menu) ..
                            st_white("]", gpmdp.fsize_menu))

        gpmdp.menu_table[18].checked = gpmdp.halt
        gpmdp.menu:setMenu(gpmdp.menu_table)

        gpmdp_alert(st_white("GPMDP ") .. st_red("HALTED"))
    else
        gpmdp.halt = false

        gpmdp.menu_table[18].checked = gpmdp.halt
        gpmdp.menu:setMenu(gpmdp.menu_table)

        gpmdp_alert(st_white("GPMDP ") .. st_red("RESET"))

        gpmdp_reset()
    end
end

-- defined as local at top of file
gpmdp_reset = function()
    if (gpmdp.menu == nil) then
        gpmdp.menu = menubar.new()
        gpmdp.menu:setIcon(gpmdp.image, false)
        gpmdp.menu:setTitle(st_white("[", gpmdp.fsize_menu) ..
                            st_grey("GPMDP", gpmdp.fsize_menu) ..
                            st_white("]", gpmdp.fsize_menu))
    end

    if (gpmdp.status_worker ~= nil) then
        gpmdp.status_worker:stop()
    end

    gpmdp.halt = false

    gpmdp.playlist_name   = "GPMDP"
    gpmdp.playlist_tracks = { }
    gpmdp.playlists       = { }
    gpmdp.alerts          = true

    gpmdp.menu:setMenu(gpmdp.menu_table)

    gpmdp.work_ok = true
    gpmdp.work_id = 0
    gpmdp.work    = { }

    gpmdp.status        = { }
    gpmdp.status_worker = timer.doEvery(10, gpmdp_get_status)

    gpmdp_get_playlists()
    gpmdp_get_queue()
end

gpmdp.menu_table =
    {
        { title = "GPMDP" },
        { title = "-" },
        { title = "Status",         fn = gpmdp_status },
        { title = "Play / Pause",   fn = gpmdp_play_pause, check = false },
        { title = "Shuffle",        fn = gpmdp_shuffle, checked = false },
        { title = "Repeat",         fn = gpmdp_repeat, checked = false },
        { title = "Replay",         fn = gpmdp_replay },
        { title = "Seek -10",       fn = gpmdp_seek_backward },
        { title = "Seek +10",       fn = gpmdp_seek_forward },
        { title = "Next",           fn = gpmdp_next },
        { title = "Previous",       fn = gpmdp_previous },
        { title = "Play Track",     fn = gpmdp_play_track },
        { title = "Load Playlist",  fn = gpmdp_load_playlist },
        { title = "Clear Playlist", fn = gpmdp_clear },
        { title = "Volume +10",     fn = gpmdp_volume_up },
        { title = "Volume -10",     fn = gpmdp_volume_down },
        { title = "Notifications",  fn = gpmdp_notifications, checked = true },
        { title = "Halt",           fn = gpmdp_halt, checked = false },
        { title = "Reset",          fn = gpmdp_reset }
    }

-- initialize the gpmdp state and display
gpmdp_reset()

hotkey.bind(kb_alt, "p", "GPMDP Play/Pause",
function()
    gpmdp_play_pause()
end)

hotkey.bind(kb_alt, ".", "GPMDP Next",
function()
    gpmdp_next()
end)

hotkey.bind(kb_alt, ",", "GPMDP Previous",
function()
    gpmdp_previous()
end)

hotkey.bind(kb_alt, "r", "GPMDP Repeat",
function()
    gpmdp_repeat()
end)

hotkey.bind(kb_alt, "]", "GPMDP Volume +10",
function()
    gpmdp_volume_up()
end)

hotkey.bind(kb_alt, "[", "GPMDP Volume -10",
function()
    gpmdp_volume_down()
end)

hotkey.bind(kb_alt, "b", "GPMDP Replay",
function()
    gpmdp_replay()
end)

hotkey.bind(kb_alt, "Left", "GPMDP Seek -10",
function()
    gpmdp_seek_backward()
end)

hotkey.bind(kb_alt, "Right", "GPMDP Seek +10",
function()
    gpmdp_seek_forward()
end)

hotkey.bind(kb_alt, "l", "GPMDP Load Playlist",
function()
    gpmdp_load_playlist()
end)

hotkey.bind(kb_alt, "t", "GPMDP Play Track",
function()
    gpmdp_play_track()
end)

hs.hotkey.bind(kb_alt, "Up", "GPMDP Thumbs Up",
function()
    gpmdp_thumbs_up()
end)

--hs.hotkey.bind(kb_alt, "Down", "GPMDP Thumbs Down",
--function()
--    gpmdp_thumbs_down()
--end)

hotkey.bind(kb_alt, "a", "GPMDP Notifications",
function()
    gpmdp_notifications()
end)

hotkey.bind(kb_alt, "h", "MPD Halt",
function()
    gpmdp_halt()
end)

hs.hotkey.bind(kb_alt_shift, "l", "GPMDP Launch",
function()
    local gpmdp_app = app.get(gpmdp_app_name)

    if gpmdp_app ~= nil then
        print("GPMDP: already running")
        return
    end

    print("GPMDP: starting application")
    if (gpmdp_proxe ~= nil) then
        hs.execute("open -a \"" .. gpmdp_app_name .. "\" " ..
                   "--args --proxy-server=\"" .. gpmdp_proxy .. "\"")
    else
        hs.execute("open -a \"" .. gpmdp_app_name .. "\"")
    end
end)


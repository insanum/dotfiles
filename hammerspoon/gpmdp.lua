
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
local webview = require("hs.webview")
local geo     = require("hs.geometry")
local dialog  = require("hs.dialog")
local x11_clr = require("hs.drawing").color.x11
local cprint  = require("hs.console").printStyledtext

gpmdp_app_name = "Google Play Music Desktop Player"
gpmdp_proxy    = "socks5://127.0.0.1:9999"
gpmdp_rc       = "/Users/edavis/src/gpmdp_rc/target/debug/gpmdp_rc"

local gpmdp = {
    task_launcher   = nil,
    task_worker     = nil,
    image           = image.imageFromPath("gmusic.png"),
    work_ok         = false,
    work_id         = 0,
    working         = false,
    work            = { },
    status_worker   = nil,
    status          = { },
    menu_table      = { { title = "GPMDP" }, { title = "-" } },
    menu            = nil,
    playlist_name   = nil,
    playlist_tracks = { },
    playlists       = { },
    notifications   = true,
    halt            = false,
    font            = "Hack",
    fsize_default   = 16,
    fsize_menu      = 12,
    fsize_console   = 12,
    lyrics_win_w    = 500,
    lyrics_win_h    = 800
}

local gpmdp_get_status
local menu_play_pause, menu_shuffle, menu_repeat, menu_notifications, menu_halt

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

local function gpmdp_hotkey_str(txt)
    local keys = hs.hotkey.getHotkeys()

    for i = 1,#keys do
        if keys[i].msg:find(txt, 1, true) then
            return keys[i].idx .. "  "
        end
    end

    return ""
end

local function gpmdp_bind_cmd(txt, prefix, shortcut, cbk, menu_checked)
    local bind_txt = "GPMDP " .. txt

    hotkey.bind(prefix, shortcut, bind_txt, cbk)

    gpmdp.menu_table[#gpmdp.menu_table + 1] =
        {
            title = gpmdp_hotkey_str(bind_txt) .. txt,
            fn = cbk,
            checked = menu_checked
        }
end

---------------------------------------------------------------------

local function gpmdp_worker()
    if (gpmdp.working == true) then
        --print("GPMDP: already working")
        return
    else
        gpmdp.working = true
    end

    if (#gpmdp.work == 0) then
        --print("GPMDP: no more work")
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
        --print("GPMDP: 'nil' command (" .. wi.id .. ")")
        gpmdp.working = false
        timer.doAfter(0, gpmdp_worker)
        return
    end

    cprint(st_grey("GPMDP: executing command (" .. wi.id .. ")\n" ..
                   hs.inspect(cmd), gpmdp.fsize_console))

    local task_worker_done = function(exitCode, stdOut, stdErr)
        if (exitCode ~= 0) or stdOut:match("^ERROR:%s+.*\n$") then
            print("GPMDP worker command failed!")
            if (wi.cbk_fail ~= nil) then
                wi.cbk_fail()
            end
        else
            if (wi.cbk_done ~= nil) then
                wi.cbk_done(stdOut)
            end
        end

        print("GPMDP: finished command (" .. wi.id .. ")")
        gpmdp.working = false
        timer.doAfter(0, gpmdp_worker)
    end

    -- execute the command (asynchronously)
    gpmdp.task_worker = hs.task.new(gpmdp_rc, task_worker_done, cmd)
    gpmdp.task_worker:start()
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

---------------------------------------------------------------------

local function gpmdp_play_pause()
    local cbk = function()
        if (gpmdp.status.state == nil) then
            return nil
        end

        local play_pause = nil
        local cmd = nil
        if (gpmdp.status.state == "playing") then
            cmd = { "pause" }
            play_pause = st_orange("Paused")
        elseif (gpmdp.status.state == "paused") then
            cmd = { "play" }
            play_pause = st_green("Unpaused")
        elseif (gpmdp.status.state == "stopped") then
            cmd = { "play" }
            play_pause = st_green("Play")
        end

        gpmdp_alert(st_white("GPMDP ") .. play_pause)
        return cmd
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Play / Pause", kb_alt, "p", gpmdp_play_pause, false)
menu_play_pause = #gpmdp.menu_table

---------------------------------------------------------------------

local function gpmdp_replay()
    local cbk = function()
        return { "replay" }
    end
    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Replay", kb_alt, "b", gpmdp_replay, false)

---------------------------------------------------------------------

local function gpmdp_seek_backward()
    local cbk = function()
        return { "seek", "backward" } -- -10s
    end
    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Seek -10", kb_alt, "Left", gpmdp_seek_backward, false)

---------------------------------------------------------------------

local function gpmdp_seek_forward()
    local cbk = function()
        return { "seek", "forward" } -- +10s
    end
    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Seek +10", kb_alt, "Right", gpmdp_seek_forward, false)

---------------------------------------------------------------------

local function gpmdp_lyrics()
    local cbk = function()
        return { "lyrics" }
    end

    local cbk_done = function(data)
        local wm = webview.windowMasks
        local screen_full = hs.screen.mainScreen():fullFrame()
        local lyrics_win =
            webview.new(geo.rect(((screen_full.w - gpmdp.lyrics_win_w) / 2),
                                 ((screen_full.h - gpmdp.lyrics_win_h) / 2),
                                 gpmdp.lyrics_win_w, gpmdp.lyrics_win_h))
        lyrics_win:html("<pre>"..data.."</pre>")
        lyrics_win:windowTitle("GPMDP Lyrics")
        lyrics_win:windowStyle(wm.titled | wm.closable |
                               wm.miniaturizable | wm.resizable |
                               wm.nonactivating)
        lyrics_win:bringToFront()
        lyrics_win:show()
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
end

gpmdp_bind_cmd("Lyrics", kb_alt, "y", gpmdp_lyrics, false)

---------------------------------------------------------------------

local function gpmdp_thumbs_up()
    local cbk = function()
        return { "thumbs", "up" }
    end

    gpmdp_schedule_work(cbk)
end

gpmdp_bind_cmd("Thumbs Up", kb_alt, "Up", gpmdp_thumbs_up, false)

---------------------------------------------------------------------

local function gpmdp_thumbs_down()
    local cbk = function()
        return { "thumbs", "down" }
    end

    gpmdp_schedule_work(cbk)
end

gpmdp_bind_cmd("Thumbs Down", kb_alt, "Down", gpmdp_thumbs_down, false)

---------------------------------------------------------------------

local function gpmdp_next()
    local cbk = function()
        gpmdp_alert(st_white("GPMDP ") .. st_orange("Next"))
        return { "next" }
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Next", kb_alt, ".", gpmdp_next, false)

---------------------------------------------------------------------

local function gpmdp_previous()
    local cbk = function()
        gpmdp_alert(st_white("GPMDP ") .. st_orange("Previous"))
        return { "prev" }
    end

    -- XXX check the elapsed time for sending double "prev" commands

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Previous", kb_alt, ",", gpmdp_previous, false)

---------------------------------------------------------------------

local function gpmdp_shuffle()
    local cbk = function()
        if (gpmdp.status.shuffle == nil) then
            return nil
        end

        local on_off = nil
        local cmd = nil
        if (gpmdp.status.shuffle == "off") then
            cmd = { "shuffle", "on" }
            on_off = st_green("ON")
        else
            cmd = { "shuffle", "off" }
            on_off = st_red("OFF")
        end

        gpmdp_alert(st_white("GPMDP Shuffle ") .. on_off)
        return cmd
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Shuffle", kb_alt, "f", gpmdp_shuffle, false)
menu_shuffle = #gpmdp.menu_table

---------------------------------------------------------------------

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
            cmd = { "repeat", "all" }
            cycle = st_green("ALL")
        elseif (gpmdp.status["repeat"] == "all") then
            cmd = { "repeat", "single" }
            cycle = st_orange("SINGLE")
        else -- turn it off
            cmd = { "repeat", "off" }
            cycle = st_red("OFF")
        end

        gpmdp_alert(st_white("GPMDP Repeat ") .. cycle)
        return cmd
    end

    gpmdp_schedule_work(cbk)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Repeat", kb_alt, "r", gpmdp_repeat, false)
menu_repeat = #gpmdp.menu_table

---------------------------------------------------------------------

local function gpmdp_clear_queue()
    local cbk = function()
        return { "clear" }
    end

    local cbk_done = function(data)
        gpmdp.playlist_tracks = { }
        gpmdp_notify("Queue cleared")
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
    gpmdp_get_status()
end

gpmdp_bind_cmd("Clear Queue", kb_alt, "c", gpmdp_clear_queue, false)

---------------------------------------------------------------------

local function gpmdp_get_queue()
    local cbk = function()
        return { "queue" }
    end

    local cbk_done = function(data)
        local album  = nil
        local artist = nil
        local track  = nil

        gpmdp.playlist_tracks = { }

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

        if (#gpmdp.playlist_tracks == 0) then
            gpmdp_notify("Playlist queue is empty")
        else
            gpmdp_notify("Retrieved " .. #gpmdp.playlist_tracks .. " tracks in queue")
        end
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
end

gpmdp_bind_cmd("Get Queue", kb_alt, "q", gpmdp_get_queue, false)

---------------------------------------------------------------------

local function gpmdp_get_playlists()
    local cbk = function()
        return { "playlists" }
    end

    local cbk_done = function(data)
        gpmdp.playlists = { }

        for p in data:gmatch("[^\r\n]+") do
            -- Note the '-' is the non-greedy '*' for lua regex
            local key, value = p:match("^(.-):%s+(.+)$")
            gpmdp.playlists[#gpmdp.playlists + 1] =
                { name = value, idx = key }
        end

        if (#gpmdp.playlists == 0) then
            gpmdp_notify("No playlists available")
        else
            gpmdp_notify("Retrieved " .. #gpmdp.playlists .. " playlists")
        end
    end

    gpmdp_schedule_work(cbk, nil, cbk_done)
end

gpmdp_bind_cmd("Get Playlists", kb_alt_shift, "l", gpmdp_get_playlists, false)

---------------------------------------------------------------------

local function gpmdp_select_track()
    local last_win = window.focusedWindow()

    local chooser_cbk = function(selection)
        local cbk = function(args)
            return { "play", args.idx }
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
        gpmdp_notify("Playlist queue is empty")
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

gpmdp_bind_cmd("Select Track", kb_alt, "t", gpmdp_select_track, false)

---------------------------------------------------------------------

local function gpmdp_select_playlist()
    local last_win = window.focusedWindow()

    local chooser_cbk = function(selection)
        local cbk = function(args)
            return { "playlist", args.idx }
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

gpmdp_bind_cmd("Select Playlist", kb_alt, "l", gpmdp_select_playlist, false)

---------------------------------------------------------------------

local function gpmdp_search()
    local last_win = window.focusedWindow()

    hs.focus() -- make sure hammerspoon dialog is focused
    local clicked, text = dialog.textPrompt("Search", "", "Search...",
                                            "Search", "Cancel")
    if clicked == "Cancel" then
        if last_win ~= nil then
            last_win:focus() -- focus last window
        end

        return
    end

    local search_cbk = function()
        return { "search", text }
    end

    local search_cbk_done = function(data)

        local results = { }

        for r in data:gmatch("[^\r\n]+") do
            -- Note the '-' is the non-greedy '*' for lua regex
            local key, value = r:match("^(.-):%s+(.*)$")

            results[#results + 1] =
                {
                    text = key .. ": " .. value,
                    idx  = key,
                    i    = i
                }
        end

        if (#results == 0) then
            gpmdp_notify("No search results available")
            if last_win ~= nil then
                last_win:focus() -- focus last window
            end

            return
        end

        local chooser_cbk = function(selection)
            local cbk = function(args)
                return { "results", args.idx }
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

        local ch = chooser.new(chooser_cbk)
        ch:choices(results)
        --ch:rows(#results)
        ch:rows(15)
        ch:width(40)
        ch:bgDark(true)
        ch:fgColor(x11_clr.orange)
        ch:subTextColor(x11_clr.chocolate)
        ch:show()
    end

    gpmdp_schedule_work(search_cbk, nil, search_cbk_done)
end

gpmdp_bind_cmd("Search", kb_alt, "s", gpmdp_search, false)

---------------------------------------------------------------------

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
    return { "volume", tostring(volume) }
end

local function gpmdp_volume_up()
    gpmdp_schedule_work(gpmdp_set_volume, { delta = 10 })
end

local function gpmdp_volume_down()
    gpmdp_schedule_work(gpmdp_set_volume, { delta = -10 })
end

gpmdp_bind_cmd("Volume +10", kb_alt, "]", gpmdp_volume_up, false)
gpmdp_bind_cmd("Volume -10", kb_alt, "[", gpmdp_volume_down, false)

---------------------------------------------------------------------

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

    gpmdp.menu_table[menu_notifications].checked = gpmdp.notifications
    gpmdp.menu:setMenu(gpmdp.menu_table)
end

gpmdp_bind_cmd("Notifications", kb_alt, "n", gpmdp_notifications, true)
menu_notifications = #gpmdp.menu_table

---------------------------------------------------------------------

local function gpmdp_reset()
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

    gpmdp.menu_table[menu_halt].checked = gpmdp.halt
    gpmdp.menu:setMenu(gpmdp.menu_table)

    gpmdp.work_ok = true
    gpmdp.work_id = 0
    gpmdp.work    = { }

    gpmdp.status        = { }
    gpmdp.status_worker = timer.doEvery(5, gpmdp_get_status)

    gpmdp_get_playlists()
    gpmdp_get_queue()
end

gpmdp_bind_cmd("Reset", kb_alt_shift, "r", gpmdp_reset, false)

---------------------------------------------------------------------

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

        gpmdp.menu_table[menu_halt].checked = gpmdp.halt
        gpmdp.menu:setMenu(gpmdp.menu_table)

        gpmdp_alert(st_white("GPMDP ") .. st_red("HALTED"))
    else
        gpmdp.halt = false

        gpmdp.menu_table[menu_halt].checked = gpmdp.halt
        gpmdp.menu:setMenu(gpmdp.menu_table)

        gpmdp_alert(st_white("GPMDP ") .. st_red("RESET"))

        gpmdp_reset()
    end
end

gpmdp_bind_cmd("Halt", kb_alt, "h", gpmdp_halt, false)

menu_halt = #gpmdp.menu_table

---------------------------------------------------------------------

local function gpmdp_launch()
    local gpmdp_app = app.get(gpmdp_app_name)

    if gpmdp_app ~= nil then
        gpmdp_notify("GPMDP: already running")
        return
    end

    gpmdp_notify("GPMDP: launching application")
    local gpmdp_args = nil

    if (gpmdp_proxy ~= nil) then
        gpmdp_args = { "-a", gpmdp_app_name,
                       "--args",
                       "--proxy-server=" .. gpmdp_proxy }
    else
        gpmdp_args = { "-a", gpmdp_app_name }
    end

    if not gpmdp.task_launcher or not gpmdp.task_launcher:isRunning() then
        gpmdp_halt()
        gpmdp.task_launcher = hs.task.new("/usr/bin/open", nil, gpmdp_args)
        gpmdp.task_launcher:start()

        timer.doAfter(20, function()
            gpmdp_reset()
        end)
    end
end

gpmdp_bind_cmd("Launch", kb_alt_shift, "g", gpmdp_launch, false)

---------------------------------------------------------------------

local function gpmdp_status_notify()
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

-- defined as local at top of file
gpmdp_get_status = function()
    local cbk = function()
        return { "status" }
    end

    local cbk_done = function(data)
        local res = { }
        for s in data:gmatch("[^\r\n]+") do
            -- Note the '-' is the non-greedy '*' for lua regex
            local key, value = s:match("^(.-):%s*(.+)$")
            res[key] = value
        end

        -- check if the track changed
        local do_status_notify = false
        if ((next(gpmdp.status) ~= nil) and (gpmdp.status.title ~= res.title)) then
            do_status_notify = true
        end

        gpmdp.status = res

        if (do_status_notify == true) then
            gpmdp_status_notify()
        end

        local do_status_menu = false

        -- update the pause checked state in the menu
        if (gpmdp.status.state ~= nil) then
            local checked = gpmdp.menu_table[menu_play_pause].checked
            if (gpmdp.status.state == "paused") then
                gpmdp.menu_table[menu_play_pause].checked = true
            else
                gpmdp.menu_table[menu_play_pause].checked = false
            end
            if (checked ~= gpmdp.menu_table[menu_play_pause].checked) then
                do_status_menu = true
            end
        end

        -- update the shuffle checked state in the menu
        if (gpmdp.status.shuffle ~= nil) then
            local checked = gpmdp.menu_table[menu_shuffle].checked
            if (gpmdp.status.shuffle == "on") then
                gpmdp.menu_table[menu_shuffle].checked = true
            else
                gpmdp.menu_table[menu_shuffle].checked = false
            end
            if (checked ~= gpmdp.menu_table[menu_shuffle].checked) then
                do_status_menu = true
            end
        end

        -- update the repeat checked state in the menu
        if (gpmdp.status["repeat"] ~= nil) then
            local checked = gpmdp.menu_table[menu_repeat].checked
            local title   = gpmdp.menu_table[menu_repeat].title
            if (gpmdp.status["repeat"] == "off") then
                gpmdp.menu_table[menu_repeat].checked = false
                gpmdp.menu_table[menu_repeat].title =
                    gpmdp_hotkey_str("Repeat") .. "Repeat"
            elseif (gpmdp.status["repeat"] == "all") then
                gpmdp.menu_table[menu_repeat].checked = true
                gpmdp.menu_table[menu_repeat].title =
                    gpmdp_hotkey_str("Repeat") .. "Repeat All"
            elseif (gpmdp.status["repeat"] == "single") then
                gpmdp.menu_table[menu_repeat].checked = true
                gpmdp.menu_table[menu_repeat].title =
                    gpmdp_hotkey_str("Repeat") .. "Repeat Single"
            end
            if ((checked ~= gpmdp.menu_table[menu_repeat].checked) or
                (title ~= gpmdp.menu_table[menu_repeat].title)) then
                do_status_menu = true
            end
        end

        if (do_status_menu == true) then
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

---------------------------------------------------------------------

-- initialize the gpmdp state and display
gpmdp_reset()


-- hs.http.websocket has some serious bugs and this will crash hammerspoon
-- when switching tracks. It appears the crash occurs when large sized
-- messages are received like with the playlist info. Also I don't think
-- there are websocket APIs to track if the socket is still connected or
-- handling asynchronous errors/disconnects.
--[[
local function callback(msg)
    local js = hs.json.decode(msg)
    if (js.channel == "time") then
        print("--> "..js.channel.." "..js.payload.current.."/"..js.payload.total)
    else
        print("--> "..js.channel)
        --print(hs.inspect(js))
    end
end

local url = "ws://127.0.0.1:5672"
local ws = hs.http.websocket(url, callback)

--ws:send(json_data)
--ws:close()
]]--


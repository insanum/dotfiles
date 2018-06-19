
local mpc = {
    image           = hs.image.imageFromPath("gmusic.png"),
    font            = { name = "Hack", size = 12 },
    sock_worker     = nil,
    sock            = nil,
    sock_attempts   = 0,
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
    alerts          = true,
    halt            = false
}

local mpc_get_status, mpc_reset

local function secs_to_time(secs)
    if secs <= 0 then
        --return "00:00:00"
        return "0:00"
    else
        h = string.format("%d", math.floor(secs / 3600))
        m = string.format("%d", math.floor((secs / 60) - (h * 60)))
        s = string.format("%02.f", math.floor(secs - (h * 3600) - (m * 60)))
        --return h..":"..m..":"..s
        return m..":"..s
    end
end

-- send a mpc notification
local function mpc_notify(subtitle, title, info)
    local n = hs.notify.new({
        title           = "MPD",
        subTitle        = subtitle,
        informativeText = ""
    })
    if (title ~= nil) then
        n:title(title)
    end
    if (info ~= nil) then
        n:informativeText(info)
    end
    print("MPD: "..n:title().." "..n:subTitle().." "..n:informativeText())
    n:autoWithdraw(false)
    n:hasActionButton(false)
    if (mpc.alerts == true) then
        n:send()
    end
end

local function mpc_worker()
    if (mpc.working == true) then
        print("MPD: already working")
        return
    else
        mpc.working = true
    end

    if (#mpc.work == 0) then
        print("MPD: no more work")
        mpc.working = false
        return
    end

    local wi = table.remove(mpc.work, 1)

    if (mpc.work_ok == false) then
        print("MPD: dropped command ("..wi.id..")")
        if (wi.cbk_fail ~= nil) then
            wi.cbk_fail()
        end

        mpc.working = false
        hs.timer.doAfter(0, mpc_worker)
        return
    end

    local cmd = wi.cbk(wi.cbk_args)
    if (cmd == nil) then
        print("MPD: 'nil' command ("..wi.id..")")
        mpc.working = false
        hs.timer.doAfter(0, mpc_worker)
        return
    end

    print("MPD: executing command ("..wi.id..")\n"..cmd:match("^(.*)\n"))

    local cmd_result = { }
    local error_msg  = nil
    local done       = false

    local read_cbk = function(line)
        if line:match("^ACK") then
            error_msg = line
            done = true
            return
        elseif (line == "OK\n") then
            done = true
            return
        end

        -- XXX support a wi.cbk_filter that can weed out unwanted keys
        cmd_result[#cmd_result + 1] = line

        mpc.sock:read("\n")
    end

    mpc.sock:setCallback(read_cbk)
    mpc.sock:write(cmd)
    mpc.sock:read("\n")

    local done_cbk = function()
        if (error_msg ~= nil) then
            mpc_notify(error_msg)
            if (wi.cbk_fail ~= nil) then
                wi.cbk_fail()
            end
        elseif (wi.cbk_done ~= nil) then
            wi.cbk_done(cmd_result)
        end

        print("MPD: finished command ("..wi.id..")")
        mpc.working = false
        hs.timer.doAfter(0, mpc_worker)
    end

    hs.timer.waitUntil(function() return (done == true) end, done_cbk, 0.1)
end

local function mpc_schedule_work(cbk, cbk_args, cbk_done, cbk_fail)
    if (mpc.halt == true) then
        return
    end

    mpc.work_id = mpc.work_id + 1
    print("MPD: scheduling command ("..mpc.work_id..")")

    local cmd_tbl = {
                      id       = mpc.work_id,
                      cbk      = cbk,
                      cbk_args = cbk_args,
                      cbk_done = cbk_done,
                      cbk_fail = cbk_fail
                    }

    mpc.work[#mpc.work + 1] = cmd_tbl
    hs.timer.doAfter(0, mpc_worker)
end

local function mpc_status()
    if (next(mpc.status) == nil) then
        mpc_notify("MPD: status is not available")
        mpc.status_worker:fire()
        return
    end

    if ((mpc.status.state == "stop") and
        (tonumber(mpc.status.playlistlength) == 0)) then
        mpc_notify("No playlist loaded")
        return
    end

    local msg = ""
    if (mpc.status.state == "play") then
        msg = "[playing]"
    elseif (mpc.status.state == "pause") then
        msg = "[paused]"
    elseif (mpc.status.state == "stop") then
        msg = "[stopped]"
    end

    local elapsed      = "0:00"
    local total_time   = "0:00"
    local percentage   = "0%"
    local track_idx    = "0"
    local total_tracks = "0"
    local artist       = nil
    local title        = nil

    if (mpc.status.elapsed ~= nil) then
        elapsed = secs_to_time(math.ceil(tonumber(mpc.status.elapsed)))
    end
    if (mpc.status.Time ~= nil) then
        total_time = secs_to_time(tonumber(mpc.status.Time))
    end
    if (mpc.status.nextsong ~= nil) then
        track_idx = mpc.status.nextsong
    end
    if (mpc.status.playlistlength ~= nil) then
        total_tracks = mpc.status.playlistlength
    end
    if (mpc.status.Artist ~= nil) then
        artist = mpc.status.Artist
    end
    if (mpc.status.Title ~= nil) then
        title = mpc.status.Title
    end

    if ((mpc.status.state ~= "stop") and
        (mpc.status.Time ~= nil) and
        (tonumber(mpc.status.Time) ~= 0)) then
        percentage = tostring(math.ceil((math.ceil(tonumber(mpc.status.elapsed)) /
                                         tonumber(mpc.status.Time)) * 100)).."%"
    end

    msg = msg.." #"..track_idx.."/"..total_tracks
    msg = msg.." "..elapsed.."/"..total_time.." ("..percentage..")"

    if ((artist ~= nil) and (title ~= nil)) then
        mpc_notify(msg, artist.." - "..title)
    elseif (artist ~= nil) then
        mpc_notify(msg, artist.." - (unknown)")
    elseif (title ~= nil) then
        mpc_notify(msg, "(unknown) - "..title)
    else
        mpc_notify(msg)
    end
end

local function mpc_status_menu()
    if (next(mpc.status) == nil) then
        return
    end

    if ((mpc.status.state == "stop") and
        (tonumber(mpc.status.playlistlength) == 0)) then
        return hs.styledtext.new("none",
                                 {
                                   font  = mpc.font,
                                   color = { hex = "#696969" }
                                 })
    end

    local elapsed      = "0:00"
    local total_time   = "0:00"
    local percentage   = "0%"
    local track_idx    = "0"
    local total_tracks = "0"

    if (mpc.status.elapsed ~= nil) then
        elapsed = secs_to_time(math.ceil(tonumber(mpc.status.elapsed)))
    end
    if (mpc.status.Time ~= nil) then
        total_time = secs_to_time(tonumber(mpc.status.Time))
    end
    if (mpc.status.nextsong ~= nil) then
        track_idx = mpc.status.nextsong
    end
    if (mpc.status.playlistlength ~= nil) then
        total_tracks = mpc.status.playlistlength
    end

    if ((mpc.status.state ~= "stop") and
        (mpc.status.Time ~= nil) and
        (tonumber(mpc.status.Time) ~= 0)) then
        percentage = tostring(math.ceil((math.ceil(tonumber(mpc.status.elapsed)) /
                                         tonumber(mpc.status.Time)) * 100)).."%"
    end

    msg = "#"..track_idx.."/"..total_tracks
    msg = msg.." "..elapsed.."/"..total_time.." ("..percentage..")"

    local color = { hex = "#696969" }
    if (mpc.status.state == "play") then
        color = { hex = "#ff8c00" }
    end

    return hs.styledtext.new(msg,
                             {
                               font  = mpc.font,
                               color = color
                             })
end

local function mpc_seek(args)
    if ((mpc.status.state == nil) or
        (mpc.status.state ~= "play") or
        (mpc.status.Time == nil)) then
        return nil
    end

    if (args.delta ~= nil) then
        return "seekcur "..args.delta..args.location.."\n"
    else
        if (args.location == "start") then
            return "seekcur 0\n"
        elseif (args.location == "end") then
            return "seekcur "..mpc.status.Time.."\n"
        elseif (args.location == "mhack") then
            local loc = math.floor(mpc.status.Time - 10)
            return "seekcur "..loc.."\n"
        else
            return "seekcur "..args.location.."\n"
        end
    end
end

local function mpc_seek_start()
    mpc_schedule_work(mpc_seek, { location = "start" })
    mpc_get_status()
end

local function mpc_seek_end()
    mpc_schedule_work(mpc_seek, { location = "end" })
    mpc_get_status()
end

local function mpc_seek_backward()
    mpc_schedule_work(mpc_seek, { location = 15, delta = "-" })
    mpc_get_status()
end

local function mpc_seek_forward()
    mpc_schedule_work(mpc_seek, { location = 15, delta = "+" })
    mpc_get_status()
end

-- hack to fix mopidy 'skipping' issue
local function mpc_mopidy_hack()
    mpc_schedule_work(mpc_seek, { location = "mhack" })
    mpc_get_status()
end

local function mpc_play()
    local cbk = function()
        if ((mpc.status.state ~= nil) and
            (mpc.status.state == "play")) then
            return nil
        end

        return "play\n"
    end

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_stop()
    local cbk = function()
        return "stop\n"
    end

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_pause()
    local cbk = function()
        if (mpc.status.state == nil) then
            return nil
        end

        local play_pause = nil
        local cmd = nil
        if (mpc.status.state == "play") then
            cmd = "pause 1\n"
            play_pause = "Paused"
        elseif (mpc.status.state == "pause") then
            cmd = "pause 0\n"
            play_pause = "Unpaused"
        elseif (mpc.status.state == "stop") then
            cmd = "play\n"
            play_pause = "Play"
        end

        hs.alert("MPD "..play_pause)
        return cmd
    end

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_random()
    local cbk = function()
        if (mpc.status.random == nil) then
            return nil
        end

        local on_off = nil
        local cmd = nil
        if (tonumber(mpc.status.random) == 0) then
            cmd = "random 1\n"
            on_off = "ON"
        else
            cmd = "random 0\n"
            on_off = "OFF"
        end

        hs.alert("MPD Random "..on_off)
        return cmd
    end

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_repeat()
    local cbk = function()
        if ((mpc.status["repeat"] == nil) or
            (mpc.status.single == nil)) then
            return
        end

        local r = tonumber(mpc.status["repeat"])
        local s = tonumber(mpc.status.single)

        local cmd = nil
        if ((r == 0) and (s == 0)) then
            hs.alert("MPD Repeat")
            cmd = "repeat 1\n"
        elseif ((r == 1) and (s == 0)) then
            hs.alert("MPD Repeat Single")
            cmd = "single 1\n"
        else -- turn them both off
            hs.alert("MPD Repeat Off")
            cmd = "command_list_begin\nrepeat 0\nsingle 0\ncommand_list_end\n"
        end

        return cmd
    end

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_next()
    local cbk = function()
        return "next\n"
    end

    mpc_mopidy_hack()

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_previous()
    local cbk = function()
        return "previous\n"
    end

    mpc_mopidy_hack()

    mpc_schedule_work(cbk, nil)
    mpc_get_status()
end

local function mpc_play_track()
    local last_win = hs.window.focusedWindow()

    local chooser_cbk = function(selection)
        local cbk = function(args)
            return "play "..args.idx.."\n"
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

        mpc_mopidy_hack()

        mpc_schedule_work(cbk, { idx = (selection.idx - 1) }, cbk_done)
        mpc_get_status()
    end

    if (#mpc.playlist_tracks == 0) then
        mpc_notify("Playlist is empty")
        return
    end

    local tracks = { }

    for i = 1,#mpc.playlist_tracks do
        tracks[#tracks + 1] =
            {
              text = tostring(i)..": "..mpc.playlist_tracks[i],
              idx  = i
            }
    end

    chooser = hs.chooser.new(chooser_cbk)
    chooser:choices(tracks)
    --chooser:rows(#tracks)
    chooser:rows(15)
    chooser:width(40)
    chooser:bgDark(true)
    chooser:fgColor(hs.drawing.color.x11.orange)
    chooser:subTextColor(hs.drawing.color.x11.chocolate)
    chooser:show()
end

local function mpc_get_playlist_tracks()
    local cbk = function()
        return "playlistinfo\n"
    end

    local cbk_done = function(data)
        local artist = nil
        local track  = nil

        for i = 1,#data do
            local key, value = data[i]:match("^(.*):%s+(.+)\n$")

            if (key == "file") then
                artist = nil
                track = nil
                goto continue
            end

            if (key == "Artist") then
                artist = value
            end

            if (key == "Title") then
                track = value
            end

            if ((artist ~= nil) and (track ~= nil)) then
                mpc.playlist_tracks[#mpc.playlist_tracks + 1] = artist.." - "..track
                artist = nil
                track = nil
            end

            ::continue::
        end
        mpc_notify("Retrieved tracks for \""..mpc.playlist_name.."\"")
    end

    mpc_schedule_work(cbk, nil, cbk_done)
end

local function mpc_get_playlists()
    local cbk = function()
        return "listplaylists\n"
    end

    local cbk_done = function(data)
        mpc.playlists = { }

        for i = 1,#data do
            local key, value = data[i]:match("^(.*):%s+(.+)\n$")
            if (key == "playlist") then
                mpc.playlists[#mpc.playlists + 1] = value
            end
        end

        mpc_notify("Retrieved playlists")
    end

    mpc_schedule_work(cbk, nil, cbk_done)
end

local function mpc_load_playlist()
    local last_win = hs.window.focusedWindow()

    local chooser_cbk = function(selection)
        local cbk = function(args)
            return "command_list_begin\nclear\nload "..args.idx.."\ncommand_list_end\n"
        end

        local cbk_done = function(data)
            mpc.playlist_name = mpc.playlists[selection.idx]
            mpc_notify("Loaded playlist \""..mpc.playlist_name.."\"")

            if last_win ~= nil then
                last_win:focus() -- focus last window
            end

            -- get a list of the tracks in the current playlist
            mpc_get_playlist_tracks()
        end

        if selection == nil then
            if last_win ~= nil then
                last_win:focus() -- focus last window
            end

            return
        end

        mpc_schedule_work(cbk, { idx = mpc.playlists[selection.idx] }, cbk_done)
        mpc_get_status()
    end

    local playlists = { }

    for i = 1,#mpc.playlists do
        playlists[#playlists + 1] =
            {
              text = tostring(i)..": "..mpc.playlists[i],
              idx  = i
            }
    end

    if (#playlists == 0) then
        mpc_notify("No playlists available")
        return
    end

    chooser = hs.chooser.new(chooser_cbk)
    chooser:choices(playlists)
    --chooser:rows(#playlists)
    chooser:rows(15)
    chooser:width(40)
    chooser:bgDark(true)
    chooser:fgColor(hs.drawing.color.x11.orange)
    chooser:subTextColor(hs.drawing.color.x11.chocolate)
    chooser:show()
end

local function mpc_clear()
    local cbk = function()
        return "clear\n"
    end

    local cbk_done = function(data)
        mpc.playlist_tracks = { }
    end

    mpc_schedule_work(cbk, nil, cbk_done)
    mpc_get_status()
end

local function mpc_set_volume(args)
    if (mpc.status.volume == nil) then
        return nil
    end

    local volume = nil
    if (args.delta == nil) then
        volume = args.volume
    else
        volume = (tonumber(mpc.status.volume) + args.delta)
        if ((args.delta < 0) and (volume < 0)) then
            volume = 0
        elseif ((args.delta > 0) and (volume > 100)) then
            volume = 100
        end

    end

    hs.alert("MPD Volume "..volume.."%")
    return "setvol "..volume.."\n"
end

local function mpc_volume_down()
    mpc_schedule_work(mpc_set_volume, { delta = -10 })
    mpc_get_status()
end

local function mpc_volume_up()
    mpc_schedule_work(mpc_set_volume, { delta = 10 })
    mpc_get_status()
end

-- defined as local at top of file
mpc_get_status = function()
    local cbk = function()
        return "command_list_begin\nidle\nnoidle\nstatus\ncurrentsong\ncommand_list_end\n"
    end

    local cbk_done = function(data)
        local res = { }
        for i = 1,#data do
            local key, value = data[i]:match("^(.*):%s+(.+)\n$")
            if (key == "changed") then
                print("MPD IDLE: "..value)
                if (value == "stored_playlist") then
                    -- get a list of the available playlists
                    mpc_get_playlists()
                end
            elseif (key ~= nil) then
                res[key] = value
            end
        end

        -- check if the file changed
        local do_mpc_status = false
        if ((next(mpc.status) ~= nil) and (mpc.status.file ~= res.file)) then
            do_mpc_status = true
        end

        mpc.status = res

        if (do_mpc_status == true) then
            mpc_status()
        end

        local update_menu = false

        -- update the pause checked state in the menu
        if (mpc.status.state ~= nil) then
            local pause_checked = mpc.menu_table[6].checked
            if (mpc.status.state == "pause") then
                mpc.menu_table[6].checked = true
            else
                mpc.menu_table[6].checked = false
            end
            if (pause_checked ~= mpc.menu_table[6].checked) then
                update_menu = true
            end
        end

        -- update the random checked state in the menu
        if (mpc.status.random ~= nil) then
            local random_checked = mpc.menu_table[7].checked
            if (tonumber(mpc.status.random) == 1) then
                mpc.menu_table[7].checked = true
            else
                mpc.menu_table[7].checked = false
            end
            if (randcom_checked ~= mpc.menu_table[7].checked) then
                update_menu = true
            end
        end

        -- update the repeat checked state in the menu
        if ((mpc.status["repeat"] ~= nil) and (mpc.status.single ~= nil)) then
            local repeat_checked = mpc.menu_table[8].checked
            local repeat_title   = mpc.menu_table[8].title
            local r = tonumber(mpc.status["repeat"])
            local s = tonumber(mpc.status.single)
            if ((r == 0) and (s == 0)) then
                mpc.menu_table[8].checked = false
                mpc.menu_table[8].title = "Repeat"
            elseif ((r == 1) and (s == 0)) then
                mpc.menu_table[8].checked = true
                mpc.menu_table[8].title = "Repeat"
            elseif ((r == 1) and (s == 1)) then
                mpc.menu_table[8].checked = true
                mpc.menu_table[8].title = "Repeat Single"
            end
            if ((repeat_checked ~= mpc.menu_table[8].checked) or
                (repeat_title ~= mpc.menu_table[8].title)) then
                update_menu = true
            end
        end

        if (update_menu == true) then
            mpc.menu:setMenu(mpc.menu_table)
        end

        -- update the menu title
        mpc.menu:setTitle(hs.styledtext.new("[",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ffffff" }
                                            }) ..
                          hs.styledtext.new("MPD: ",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#696969" }
                                            }) ..
                          mpc_status_menu() ..
                          hs.styledtext.new("]",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ffffff" }
                                            })
                         )

        -- update the menu tooltip
        local tooltip = ""
        if (mpc.status.state == "play") then
            local artist = "[unknown]"
            local title  = "[unknown]"
            if (mpc.status.Artist ~= nil) then
                artist = mpc.status.Artist
            end
            if (mpc.status.Title ~= nil) then
                title = mpc.status.Title
            end
            tooltip = artist.." - "..title
        end
        mpc.menu:setTooltip(tooltip)
    end

    local cbk_fail = function()
        mpc.playlist_name   = "MPD"
        mpc.playlist_tracks = { }
        mpc.playlists       = { }

        -- update the menu title
        mpc.menu:setTitle(hs.styledtext.new("[",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ffffff" }
                                            }) ..
                          hs.styledtext.new("MPD: ",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#696969" }
                                            }) ..
                          hs.styledtext.new("none",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ff0000" }
                                            }) ..
                          hs.styledtext.new("]",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ffffff" }
                                            })
                         )
    end

    mpc_schedule_work(cbk, nil, cbk_done, cbk_fail)
end

local function mpc_sock_connect()
    if (mpc.sock == nil) then
        mpc.sock = hs.socket.new()
    else
        if (mpc.sock:connected() == true) then
            return
        end

        mpc.sock:disconnect()

        if ((mpc.sock_attempts % 10) == 0) then
            print("MPD: Failed to connect (attempt="..mpc.sock_attempts..")")
        end
    end

    local connect_cbk = function()
        print("MPD: Connected!")
        mpc.sock_attempts = 0

        -- read the MPD welcome message and get things going
        mpc.sock:setCallback(function(data)
            print("MPD: "..data:match("^(.*)\n$"))
            mpc.work_ok = true

            -- get a list of the available playlists
            mpc_get_playlists()

            -- get a list of the tracks in the current playlist
            mpc_get_playlist_tracks()

            -- immediately fire the status worker
            mpc.status_worker:fire()
        end)

        mpc.sock:read("\n")
    end

    mpc.work_ok = false

    if ((mpc.sock_attempts % 10) == 0) then
        print("MPD: Attempting to connect (attempt="..mpc.sock_attempts..")")
    end

    mpc.sock_attempts = (mpc.sock_attempts + 1)
    mpc.sock:connect("127.0.0.1", 6600, connect_cbk)
end

local function mpc_alerts()
    local on_off = nil
    if (mpc.alerts == false) then
        mpc.alerts = true
        on_off = "ON"
    else
        mpc.alerts = false
        on_off = "OFF"
    end

    hs.alert("MPD Alerts "..on_off)

    mpc.menu_table[19].checked = mpc.checked
    mpc.menu:setMenu(mpc.menu_table)
end

local function mpc_halt()
    if (mpc.halt == false) then
        if (mpc.sock_worker ~= nil) then
            mpc.sock_worker:stop()
        end

        if (mpc.status_worker ~= nil) then
            mpc.status_worker:stop()
        end

        mpc.halt = true

        mpc.menu_table[20].checked = mpc.halt
        mpc.menu:setMenu(mpc.menu_table)
    else
        mpc.halt = false

        mpc.menu_table[20].checked = mpc.halt
        mpc.menu:setMenu(mpc.menu_table)

        mpc_reset()
    end
end

-- defined as local at top of file
mpc_reset = function()
    if (mpc.menu == nil) then
        mpc.menu = hs.menubar.new()
        mpc.menu:setIcon(mpc.image, false)
        mpc.menu:setTitle(hs.styledtext.new("[",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ffffff" }
                                            }) ..
                          hs.styledtext.new("MPD",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#696969" }
                                            }) ..
                          hs.styledtext.new("]",
                                            {
                                              font  = mpc.font,
                                              color = { hex = "#ffffff" }
                                            })
                         )
    end

    if (mpc.sock_worker ~= nil) then
        mpc.sock_worker:stop()
    end

    if (mpc.status_worker ~= nil) then
        mpc.status_worker:stop()
    end

    if (mpc.sock ~= nil) then
        mpc.sock:disconnect()
    end

    mpc.halt = false

    mpc.playlist_name   = "MPD"
    mpc.playlist_tracks = { }
    mpc.playlists       = { }
    mpc.alerts          = true

    mpc.menu:setMenu(mpc.menu_table)

    mpc.work_ok = false
    mpc.work_id = 0
    mpc.work    = { }

    mpc.sock          = nil
    mpc.sock_attempts = 0
    mpc.sock_worker   = hs.timer.doEvery(5, mpc_sock_connect)

    mpc.status        = { }
    mpc.status_worker = hs.timer.doEvery(5, mpc_get_status)
end

mpc.menu_table =
    {
        { title = "MPD" },
        { title = "-" },
        { title = "Status",         fn = mpc_status },
        { title = "Play",           fn = mpc_play },
        { title = "Stop",           fn = mpc_stop },
        { title = "Pause",          fn = mpc_pause, checked = false },
        { title = "Random",         fn = mpc_random, checked = false },
        { title = "Repeat",         fn = mpc_repeat, checked = false },
        { title = "Replay",         fn = mpc_seek_start },
        { title = "Seek -15",       fn = mpc_seek_backward },
        { title = "Seek +15",       fn = mpc_seek_forward },
        { title = "Next",           fn = mpc_next },
        { title = "Previous",       fn = mpc_previous },
        { title = "Play Track",     fn = mpc_play_track },
        { title = "Load Playlist",  fn = mpc_load_playlist },
        { title = "Clear Playlist", fn = mpc_clear },
        { title = "Volume -10",     fn = mpc_volume_down },
        { title = "Volume +10",     fn = mpc_volume_up },
        { title = "Alerts",         fn = mpc_alerts, checked = true },
        { title = "Halt",           fn = mpc_halt, checked = false },
        { title = "Reset",          fn = mpc_reset }
    }

-- initialize the mpc state and display
mpc_reset()

hs.hotkey.bind(kb_alt, "p", "MPD Play/Pause",
function()
    mpc_pause()
end)

hs.hotkey.bind(kb_alt, "s", "MPD Stop",
function()
    mpc_stop()
end)

hs.hotkey.bind(kb_alt, "n", "MPD Next",
function()
    mpc_next()
end)

hs.hotkey.bind(kb_alt, "r", "MPD Repeat",
function()
    mpc_repeat()
end)

hs.hotkey.bind(kb_alt, "Up", "MPD Volume +10",
function()
    mpc_volume_up()
end)

hs.hotkey.bind(kb_alt, "Down", "MPD Volume -10",
function()
    mpc_volume_down()
end)

hs.hotkey.bind(kb_alt, "Left", "MPD Seek -15",
function()
    mpc_seek_backward()
end)

hs.hotkey.bind(kb_alt, "Right", "MPD Seek +15",
function()
    mpc_seek_forward()
end)

hs.hotkey.bind(kb_alt, "l", "MPD Load Playlist",
function()
    mpc_load_playlist()
end)

hs.hotkey.bind(kb_alt, "t", "MPD Play Track",
function()
    mpc_play_track()
end)

hs.hotkey.bind(kb_alt, "a", "MPD Alerts",
function()
    mpc_alerts()
end)



Mod_Key:bind("", "a", "Show the audio device switcher", function()
    Mod_Key:exit()

    local last_win = hs.window.focusedWindow()

    local chooser_cbk = function(selection)
        local log_pfx = "Audio device set: "
        if selection == nil then
            print(log_pfx.."cancelled")
        else
            local dev = hs.audiodevice.findDeviceByName(selection.text)
            if dev ~= nil then
                print(log_pfx..selection.text)
                dev:setDefaultOutputDevice()
                dev:setDefaultEffectDevice()
                local alert_msg = "Audio device OUT: "..selection.text
                if selection.input then
                    dev:setDefaultInputDevice()
                    alert_msg = "Audio device IN/OUT: "..selection.text
                end
                hs.alert(alert_msg, { radius = 0, atScreenEdge = 2 }, 4)
            else
                print(log_pfx.."invalid '"..selection.text.."'")
            end
        end

        if last_win ~= nil then
            last_win:focus() -- focus last window
        end
    end

    local ocurrent = hs.audiodevice.current(false)
    local icurrent = hs.audiodevice.current(true)

    local odevs = hs.audiodevice.allOutputDevices()
    local dev_list = { }
    for i, odev in ipairs(odevs) do
        local subtext = "Output"
        local input = false
        local idev = hs.audiodevice.findInputByName(odev:name())
        if idev ~= nil then
            subtext = "Input / Output"
            input = true
        end
        if ocurrent.name == odev:name() then
            subtext = "[CURRENT OUT] "..subtext
        end
        if icurrent.name == odev:name() then
            subtext = "[CURRENT IN] "..subtext
        end
        dev_list[i] = {
            ["text"] = odev:name(),
            ["subText"] = subtext,
            ["input"] = input
        }
    end

    chooser = hs.chooser.new(chooser_cbk)
    chooser:choices(dev_list)
    chooser:rows(#dev_list)
    chooser:width(20)
    chooser:bgDark(true)
    chooser:fgColor(hs.drawing.color.x11.orange)
    chooser:subTextColor(hs.drawing.color.x11.chocolate)
    chooser:show()
end)


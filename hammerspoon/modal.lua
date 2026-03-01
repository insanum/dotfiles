
local modal_alert_loc = {
    radius = 0,
    textFont = "Hack",
    textSize = 32,
    atScreenEdge = 0
}

local modal_alert = nil

local function modal_enter(msg)
    if modal_alert then
        hs.alert.closeSpecific(modal_alert, 1)
    end

    modal_alert = hs.alert(msg, modal_alert_loc, 'infinite')
end

local function modal_exit()
    -- remove the alert indicator
    if modal_alert then
        hs.alert.closeSpecific(modal_alert, 1)
        modal_alert = nil
    end
end

local function modal_help(m)
    local key_list = ''

    for i = 1,#m.keys do
        if i == 1 then
            key_list = m.keys[i].msg
        else
            key_list = key_list .. '\n' .. m.keys[i].msg
        end
    end

    ShowHelp(key_list)
end

function NewModalKey(mods, key, msg)
    local m = hs.hotkey.modal.new(mods, key, msg)
    function m:entered() modal_enter(msg) end
    function m:exited() modal_exit() end
    m:bind('', 'q', 'Show help', function() modal_help(m) end)
    m:bind('', 'escape', function() m:exit() end)
    return m
end

MISC_MODAL = NewModalKey(HYPER, 'k', 'Modal Misc')



local app = hs.application
local alert = hs.alert
local et = hs.eventtap
local t = hs.timer

local ascii_dir = "figlet $(basename `pwd`) | lolcat"

local g = nil
local delay = 0.2

local function ghostty_tab_title_open(title)
    et.keyStroke({ 'ctrl' }, 's', g)
    et.keyStroke({}, 't', g)
end

local function ghostty_tab_title_set(title)
    et.keyStrokes(title, g)
    et.keyStroke({}, 'return', g)
end

local function ghostty_hsplit()
    et.keyStroke({ 'ctrl' }, 's', g)
    et.keyStroke({}, 'v', g)
end

local function ghostty_new_tab()
    et.keyStroke({ 'cmd' }, 't', g)
end

local function ghostty_goto_tab(tab_num)
    et.keyStroke({ 'cmd' }, tab_num, g)
end

local function ghostty_send_cmd(cmd)
    et.keyStrokes(cmd, g)
    et.keyStroke({}, 'return', g)
end

local ghostty_actions = {
    function() ghostty_new_tab() end, -- 2 test
    function() ghostty_new_tab() end, -- 3 uet-rdma-core
    function() ghostty_new_tab() end, -- 4 uet-ref-prov
    function() ghostty_new_tab() end, -- 5 libmrc
    function() ghostty_new_tab() end, -- 6 linux_kernels
    function() ghostty_new_tab() end, -- 7 csg_drivers

    function() ghostty_goto_tab('1') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('notes') end,
    function() ghostty_send_cmd('z notes') end,
    function() ghostty_send_cmd(ascii_dir) end,
    function() ghostty_hsplit() end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('notes') end,

    function() ghostty_goto_tab('2') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('test') end,
    function() ghostty_hsplit() end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('test') end,

    function() ghostty_goto_tab('3') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('uet-rdma-core') end,
    function() ghostty_send_cmd('z wt_uet') end,
    function() ghostty_send_cmd(ascii_dir) end,

    function() ghostty_goto_tab('4') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('uet-ref-prov') end,
    function() ghostty_send_cmd('z wt_pds') end,
    function() ghostty_send_cmd(ascii_dir) end,

    function() ghostty_goto_tab('5') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('libmrc') end,
    function() ghostty_send_cmd('z libmrc') end,
    function() ghostty_send_cmd(ascii_dir) end,

    function() ghostty_goto_tab('6') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('linux_kernels') end,
    function() ghostty_send_cmd('z linux_kernels') end,
    function() ghostty_send_cmd(ascii_dir) end,

    function() ghostty_goto_tab('7') end,
    function() ghostty_tab_title_open() end,
    function() ghostty_tab_title_set('csg_drivers') end,
    function() ghostty_send_cmd('z csg_drivers') end,
    function() ghostty_send_cmd(ascii_dir) end,

    function() ghostty_goto_tab('1') end,
}

local function ghostty_dispatch_actions()
    local i = 1

    local function next_step()
        if i > #ghostty_actions then
            return
        end

        ghostty_actions[i]()
        i = i + 1

        if i <= #ghostty_actions then
            t.doAfter(delay, next_step)
        end
    end

    next_step()
end

hs.hotkey.bind(CMD_CTRL_SHIFT, 'w', 'Ghostty Work',
function()
    g = app.find('Ghostty')
    if g == nil then
        alert.show('Ghostty not running!')
        return
    end

    g:activate()
    ghostty_dispatch_actions()
end)


--[[

local win = app:focusedWindow()

print("--> " .. app:name() .. " " .. win:tabCount())

local axui = hs.axuielement.windowElement(win)

local windowTabs = {}
local foundTabGroup = false

local children = axui:attributeValue("AXChildren")
print(#children)

if children then
    for _,child in ipairs(children) do
        local role = child:attributeValue("AXRole")

        if role == "AXTabGroup" then
            foundTabGroup = true
            local tabs = child:attributeValue("AXChildren")
            print(#tabs)
            if tabs then
                for j, tab in ipairs(tabs) do
                    print("--> " .. tab:attributeValue("AXRole") .. " " .. tab:attributeValue("AXTitle"))
                    local tabTitle = tab:attributeValue("AXTitle")
                    local tabSelected = tab:attributeValue("AXSelected")
                    table.insert(windowTabs, {
                        index = j,
                        title = tabTitle,
                        selected = tabSelected or false
                    })
                    local kids = tab:attributeValue("AXChildren")
                    if kids then
                        for _,k in ipairs(kids) do
                            print("----> " .. k:attributeValue("AXRole") .. " " .. (k:attributeValue("AXTitle") or ""))
                            local a = k:attributeNames()
                            for i,v in ipairs(a) do
                                print("------> " .. v)
                            end
                        end
                    end
                    print("")
                    local a = tab:attributeNames()
                    for i,v in ipairs(a) do
                        print(v)
                    end
                    print("")
                    local t = tab:attributeValue("AXTabPanel")
                    if t then
                        local panel = t:attributeValue("AXTabPanel")
                        local kids2 = panel:attributeValue("AXChildren")
                        if kids2 then
                            for _,k in ipairs(kids2) do
                                print("**--> " .. k:attributeValue("AXRole") .. " " .. (k:attributeValue("AXTitle") or ""))
                            end
                        end
                    else
                        print("no panel")
                    end
                end
            end

            break
        end
    end
end

if not foundTabGroup then
    print("no tab found")
    table.insert(windowTabs, {
        index = 1,
        title = win:title(),
        selected = true
    })
end

for _,v in ipairs(windowTabs) do
    print(string.format("Tab %d: %s %s", v.index, v.title, v.selected and "(selected)" or ""))
end

--]]


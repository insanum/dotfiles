
local eventtap = require("hs.eventtap")
local et_types = require("hs.eventtap.event").types
local menubar  = require("hs.menubar")
local stext    = require("hs.styledtext")
local x11_clr  = require("hs.drawing").color.x11
local cprint   = require("hs.console").printStyledtext

local ilog = {
    start_date_time = nil,
    menu_table      = nil,
    menu            = nil,
    et              = nil,
    key_count       = 0,
    mouse_count     = 0,
    mouse_distance  = 0,
    font            = "Hack Nerd Font",
    fsize_default   = 16,
    fsize_menu      = 12,
    fsize_console   = 12
}

local function st(txt, color, fsize)
    local font = { font = ilog.font, size = ilog.fsize_default }
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

local function ilog_count(e)
    local t = e:getType()

    for k, v in pairs(e:getFlags()) do
        ilog.key_count = ilog.key_count + 1
    end

    if ((t == et_types["keyDown"]) or
        (t == et_types["scrollWheel"])) then
        ilog.key_count = ilog.key_count + 1
    elseif ((t == et_types["leftMouseDown"]) or
            (t == et_types["rightMouseDown"]) or
            (t == et_types["otherMouseDown"])) then
        ilog.mouse_count = ilog.mouse_count + 1
    elseif (t == et_types["mouseMoved"]) then
        -- local l = e:location()
        -- ilog.mouse_distance = compute mouse distance moved...
    end

    if ((ilog.key_count % 10) == 0) then
        ilog.menu:setTitle(st_white("[", ilog.fsize_menu) ..
                           st_grey(ilog.key_count, ilog.fsize_menu) ..
                           st_white("]", ilog.fsize_menu))
    end

    return false
end

local function ilog_reset()
    if (ilog.menu == nil) then
        ilog.menu = menubar.new()
    end

    ilog.menu:setTitle(st_white("[", ilog.fsize_menu) ..
                       st_grey(0, ilog.fsize_menu) ..
                       st_white("]", ilog.fsize_menu))

    ilog.start_date_time = os.date("%x %X")
    ilog.key_count       = 0
    ilog.mouse_count     = 0
    ilog.mouse_distance  = 0

    ilog.menu:setMenu(ilog.menu_table)
    ilog.menu:setTooltip(ilog.start_date_time)

    if ((ilog.et ~= nil) and ilog.et:isEnabled()) then
        ilog.et:stop()
    end

    if (ilog.et == nil) then
        ilog.et = eventtap.new({
                                 et_types["keyDown"],
                                 --et_types["scrollWheel"],
                                 --et_types["leftMouseDown"],
                                 --et_types["rightMouseDown"],
                                 --et_types["otherMouseDown"],
                                 --et_types["mouseMoved"]
                               },
                               ilog_count)
    end

    ilog.et:start()
end

ilog.menu_table =
    {
        { title = "ILOG" },
        { title = "-" },
        { title = "Reset", fn = ilog_reset }
    }

-- initialize the input logger state and display
ilog_reset()


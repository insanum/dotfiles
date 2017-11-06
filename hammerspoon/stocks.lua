
--local mash       = {"cmd", "alt", "ctrl"}
--local mash_shift = {"cmd", "alt", "ctrl", "shift"}
local mash       = {"cmd", "ctrl"}
local mash_shift = {"cmd", "ctrl", "shift"}

local avgo = 'https://api.intrinio.com/data_point?identifier=AVGO&item=last_price,change,percent_change'

local curl    = "/usr/bin/curl"
local menubar = hs.menubar.new()
local stocks  = nil

local log = hs.logger.new('stocks','debug')

local STOCKS_UPDATE_TIMER = 30 -- minutes

local function fslurp(path)
    local f = io.open(path, "r")
    local s = f:read("*all")
    f:close()
    return s
end

local config = hs.json.decode(fslurp("intrinio.json"))

local function stocksUpdate(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        --hs.alert("Stock update failed!")
        return
    end

    local data = hs.json.decode(stdOut)

    menubar:setTitle("[ " ..
                     data.data[1].identifier    .. ": " .. -- name
                     data.data[1].value         .. " "  .. -- price
                     data.data[2].value         .. " "  .. -- change
                     (data.data[3].value * 100) .. "% " .. -- %change
                     " ]")
    --hs.alert("Stock quotes updated!")
end

local function doUpdate()
    local curl_args = { "-s", avgo, "-u", config.user .. ":" .. config.pass }
    if not stocks or not stocks:isRunning() then
        stocks = hs.task.new(curl, stocksUpdate, curl_args )
        stocks:start()
    end
end

-- XXX only execute the timer when the market is open (6am-1pm PST)
local stockUpdateTimer = hs.timer.doEvery((STOCKS_UPDATE_TIMER * 60), doUpdate)
doUpdate()

hs.hotkey.bind(mash_shift, "q", function()
    doUpdate()
end)

--local menubar = hs.menubar.new()
--menubar:setTitle(hs.styledtext.new("foo", { color = hs.drawing.color.x11.magenta }))
--local menubar2 = hs.menubar.new()
--menubar2:setTitle(hs.styledtext.new("bar", { color = hs.drawing.color.hammerspoon.osx_red }))



--local mash       = {"cmd", "alt", "ctrl"}
--local mash_shift = {"cmd", "alt", "ctrl", "shift"}
local mash       = {"cmd", "ctrl"}
local mash_shift = {"cmd", "ctrl", "shift"}

-- curl -s 'http://download.finance.yahoo.com/d/quotes.csv?s=AVGO,NVDA,LTRX&f=sl1c1p2' | sed 's/[",]/ /g'
local stock_url = 'http://download.finance.yahoo.com/d/quotes.csv?s=AVGO&f=sl1c1p2'
local curl      = "/usr/bin/curl"
local curl_args = { "-s", stock_url }
local menubar   = hs.menubar.new()
local stocks    = nil

local STOCKS_UPDATE_TIMER = 30 -- minutes

local function stocksUpdate(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        --hs.alert("Stock update failed!")
        return
    end

    local txt = ""
    for s in stdOut:gsub("[\",]", " "):gmatch("%S+") do
        txt = txt .. s .. " "
    end

    menubar:setTitle("[ " .. txt .. "]")
    --hs.alert("Stock quotes updated!")
end

local function doUpdate()
    if not stocks or not stocks:isRunning() then
        stocks = hs.task.new(curl, stocksUpdate, { "-s", stock_url })
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


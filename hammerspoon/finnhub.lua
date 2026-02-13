
local ticker  = "AVGO"
local finnhub = "https://www.finnhub.io/api/v1/quote?symbol=" .. ticker

local curl    = "/usr/bin/curl"
local menubar = hs.menubar.new()
local stocks  = nil

local STOCKS_UPDATE_TIMER      = 5  -- minutes
local STOCKS_UPDATE_HOUR_START = 5  -- 6am market open
local STOCKS_UPDATE_HOUR_END   = 14 -- 1pm market close

local function fslurp(path)
    local f = io.open(path, "r")
    local s = f:read("*all")
    f:close()
    return s
end

local config = hs.json.decode(fslurp(os.getenv("HOME").."/.priv/finnhub.json"))

local function stocksUpdate(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        --hs.alert("Stock update failed!")
        print("STOCK TICKER update failed!")
        menubar:setTooltip("ERROR: "..os.date("%x %X"))
        return
    end

    local data = hs.json.decode(stdOut)
    print(ticker .. " (finnhub) " .. hs.inspect(stdOut))

    local font = { name = "Hack Nerd Font", size = 12 }

    local round_decimal = function(value)
        return (math.floor((tonumber(value) * 100) + 0.5) / 100)
    end

    local ticker_text = function(ticker)
        --local color = hs.drawing.color.x11.green
        --local color = hs.drawing.color.x11.white
        local prfx = "+"
        local change = 0
        local percent = tonumber(data["dp"])
        if tonumber(data["c"]) >= tonumber(data["pc"]) then
            change = (tonumber(data["c"]) - tonumber(data["pc"]))
        else -- tonumber(data["c"]) < tonumber(data["pc"])
            --color = hs.drawing.color.x11.red
            --color = hs.drawing.color.x11.white
            prfx  = "-"
            change = (tonumber(data["pc"]) - tonumber(data["c"]))
        end

        return
        hs.styledtext.new(ticker .. ":",
                          {
                            font  = font,
                            --color = hs.drawing.color.x11.deepskyblue
                            --color = hs.drawing.color.x11.white
                          }) ..
        hs.styledtext.new(round_decimal(data["c"]),
                          {
                            font  = font,
                            --color = color
                          }) ..
        hs.styledtext.new("/",
                          {
                            font  = font,
                            --color = hs.drawing.color.x11.white
                          }) ..
        hs.styledtext.new(prfx .. round_decimal(change),
                          {
                            font  = font,
                            --color = color
                          }) ..
        hs.styledtext.new("/",
                          {
                            font  = font,
                            --color = hs.drawing.color.x11.white
                          }) ..
        hs.styledtext.new(round_decimal(percent) .. "%",
                          {
                            font  = font,
                            --color = color
                          })
    end

    menubar:setTitle(hs.styledtext.new("[",
                                       {
                                         font  = font,
                                         --color = hs.drawing.color.x11.white
                                       }) ..
                     ticker_text(ticker) ..
                     hs.styledtext.new("]",
                                       {
                                         font  = font,
                                         --color = hs.drawing.color.x11.white
                                       })
                    )
    menubar:setTooltip(os.date("%x %X"))

    --hs.alert("Stock quotes updated!")
    print("STOCK TICKER quotes updated!")
end

local forced_update = false

local function doUpdate()
    local cur_time = os.date("*t")

    print("STOCK TICKER update " .. cur_time.hour .. ":" .. cur_time.min)

    if forced_update then
        print("STOCK TICKER update **FORCED**")
        forced_update = false
    else
        -- only execute the update around when the market is open (6am-1pm PST)

        if cur_time.hour < STOCKS_UPDATE_HOUR_START or
           cur_time.hour > STOCKS_UPDATE_HOUR_END then
            print("STOCK TICKER update **SKIPPED**")
            return
        end
    end

    local curl_args = { "-s", finnhub .. "&token=" .. config.key }
    if not stocks or not stocks:isRunning() then
        stocks = hs.task.new(curl, stocksUpdate, curl_args)
        stocks:start()
    end
end

stock_updater = hs.timer.new((STOCKS_UPDATE_TIMER * 60), doUpdate, true):start()

forced_update = true
doUpdate()

hs.hotkey.bind(CMD_CTRL_SHIFT, "q", "Refresh Stock Ticker",
function()
    forced_update = true
    doUpdate()
end)


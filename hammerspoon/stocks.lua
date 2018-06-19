
-- local tickers  = { "AVGO", "QCOM", "NXP", "NVDA", "MLNX", "CAVM", "GOOG", "GOOGL", "AMZN", "AAPL", "MSFT", "FB", "CSCO", "JNPR", "INTC" }
local tickers  = { "AVGO" }
local intrinio = "https://api.intrinio.com/data_point?identifier=" .. table.concat(tickers,",") .. "&item=last_price,change,percent_change"

local curl    = "/usr/bin/curl"
local menubar = hs.menubar.new()
local stocks  = nil

local log = hs.logger.new("stocks","debug")

local STOCKS_UPDATE_TIMER      = 30 -- minutes
local STOCKS_UPDATE_HOUR_START = 6  -- 6am market open
local STOCKS_UPDATE_HOUR_END   = 13 -- 1pm market close

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

    local font = { name = "Hack", size = 12 }

    local ticker_value = function(ticker, item)
        for i = 1, #data.data, 1 do
            if data.data[i].identifier == ticker and
               data.data[i].item == item then
               if data.data[i].value == "na" then
                   return 0
               end
               return data.data[i].value
           end
        end
    end

    local ticker_up = function(ticker)
        local change = ticker_value(ticker, "change")
        if change >= 0 then
            return true
        end
        return false
    end

    local ticker_text = function(ticker)
        local color = hs.drawing.color.x11.red
        local prfx = ""
        if ticker_up(ticker) then
            color = hs.drawing.color.x11.green
            prfx  = "+"
        end

        return
        hs.styledtext.new(ticker .. ": ",
                          {
                            font  = font,
                            color = hs.drawing.color.x11.deepskyblue
                          }) ..
        hs.styledtext.new(ticker_value(ticker, "last_price") .. " " ..
                          prfx .. ticker_value(ticker, "change") .. " " ..
                          prfx .. (ticker_value(ticker, "percent_change") * 100) .. "%",
                          {
                            font  = font,
                            color = color
                          })
    end

    menubar:setTitle(hs.styledtext.new("[",
                                       {
                                         font  = font,
                                         color = hs.drawing.color.x11.white
                                       }) ..
                     ticker_text(tickers[1]) ..
                     hs.styledtext.new("]",
                                       {
                                         font  = font,
                                         color = hs.drawing.color.x11.white
                                       })
                    )

    if #tickers > 1 then
        local submenu = { }
        for i = 2, #tickers, 1 do
            table.insert(submenu, { title = ticker_text(tickers[i]) })
        end
        menubar:setMenu(submenu)
    end

    --hs.alert("Stock quotes updated!")
end

local forced_update = false

local function doUpdate()
    -- only execute the update around when the market is open (6am-1pm PST)
    if forced_update then
        print("STOCK TICKER update forced")
        forced_update = false
    else
        local cur_time = os.date("*t")

        if cur_time.hour < STOCKS_UPDATE_HOUR_START or
           cur_time.hour > STOCKS_UPDATE_HOUR_END then
            print("STOCK TICKER update **SKIPPED** (hour=" .. cur_time.hour .. ")")
            return
        end

        print("STOCK TICKER update (hour=" .. cur_time.hour .. ")")
    end

    local curl_args = { "-s", intrinio, "-u", config.user .. ":" .. config.pass }
    if not stocks or not stocks:isRunning() then
        stocks = hs.task.new(curl, stocksUpdate, curl_args )
        stocks:start()
    end
end

local stockUpdateTimer = hs.timer.doEvery((STOCKS_UPDATE_TIMER * 60), doUpdate)

forced_update = true
doUpdate()

hs.hotkey.bind(kb_ctrl_shift, "q", "Refresh stock ticker",
function()
    forced_update = true
    doUpdate()
end)


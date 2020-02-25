
-- local tickers  = { "AVGO", "QCOM", "NXP", "NVDA", "MLNX", "CAVM", "GOOG", "GOOGL", "AMZN", "AAPL", "MSFT", "FB", "CSCO", "JNPR", "INTC" }
local tickers  = { "AVGO" }
local intrinio = "https://api.intrinio.com/data_point?identifier=" .. table.concat(tickers,",") .. "&item=last_price,change,percent_change"

local curl    = "/usr/bin/curl"
local menubar = hs.menubar.new()
local stocks  = nil

local STOCKS_UPDATE_TIMER      = 15 -- minutes
local STOCKS_UPDATE_HOUR_START = 5  -- 6am market open
local STOCKS_UPDATE_HOUR_END   = 14 -- 1pm market close

local function fslurp(path)
    local f = io.open(path, "r")
    local s = f:read("*all")
    f:close()
    return s
end

local config = hs.json.decode(fslurp(os.getenv("HOME").."/.priv/intrinio.json"))

local function stocksUpdate(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
        --hs.alert("Stock update failed!")
        print("STOCK TICKER update failed!")
        menubar:setTooltip("ERROR: "..os.date("%x %X"))
        return
    end

    local data = hs.json.decode(stdOut)

    local font = { name = "Hack Nerd Font", size = 12 }

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
    menubar:setTooltip(os.date("%x %X"))

    if #tickers > 1 then
        local submenu = { }
        for i = 2, #tickers, 1 do
            table.insert(submenu, { title = ticker_text(tickers[i]) })
        end
        menubar:setMenu(submenu)
    end

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

    local curl_args = { "-s", intrinio, "-u", config.user .. ":" .. config.pass }
    if not stocks or not stocks:isRunning() then
        stocks = hs.task.new(curl, stocksUpdate, curl_args)
        stocks:start()
    end
end

stock_updater = hs.timer.new((STOCKS_UPDATE_TIMER * 60), doUpdate, true):start()

forced_update = true
doUpdate()

hs.hotkey.bind(kb_ctrl_shift, "q", "Refresh stock ticker",
function()
    forced_update = true
    doUpdate()
end)


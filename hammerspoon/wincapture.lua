
local screencap = "/usr/sbin/screencapture"

local function wincapture()
    local timeStamp = string.gsub(os.date("%Y-%m-%d_%T"), ":", ".")
    local fileName = os.getenv("HOME") .. "/Desktop/ss-" .. timeStamp .. ".png"
    local winId = hs.window.focusedWindow():id()
    hs.task.new(screencap, nil, {"-l" .. winId, fileName }):start()
end

hs.hotkey.bind(kb_shift, "1", "Task a screenshot of the current window",
function()
    wincapture()
end)


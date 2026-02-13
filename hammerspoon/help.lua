
local function format_two_columns(text)
    local gap = 4

    -- replace unicode modifiers with text equivalents
    text = text:gsub("⌘", "CMD-")
    text = text:gsub("⌃", "CTRL-")
    text = text:gsub("⌥", "ALT-")
    text = text:gsub("⇧", "SHFT-")

    local lines = {}
    local header = nil

    for line in text:gmatch("[^\n]+") do
        line = line:match("^%s*(.-)%s*$")

        if line ~= "" then
            local key, desc = line:match("^(.-):%s*(.*)")

            if key then
                table.insert(lines, {
                    key = key:match("^%s*(.-)%s*$"),
                    desc = desc
                })
            else
                header = line
            end
        end
    end

    local half = math.ceil(#lines / 2)

    local max_key = 0
    for _, l in ipairs(lines) do
        max_key = math.max(max_key, #l.key)
    end

    local function fmt(entry)
        return string.rep(" ", max_key - #entry.key) ..
               entry.key .. ": " .. entry.desc
    end

    local max_left = 0
    for i = 1, half do
        max_left = math.max(max_left, #fmt(lines[i]))
    end

    local result = {}
    if header then table.insert(result, header) end

    for i = 1, half do
        local left = fmt(lines[i])
        local out = left
        local j = half + i

        if j <= #lines then
            out = left .. string.rep(" ", max_left - #left + gap) ..
                  fmt(lines[j])
        end

        table.insert(result, out)
    end

    return table.concat(result, "\n")
end

local help_alert_loc = {
    radius = 0,
    textFont = "Hack Nerd Font",
    textSize = 16,
    atScreenEdge = 2
}

local help_alert = nil

function ShowHelp(help)
    if help_alert then
        hs.alert.closeSpecific(help_alert, 1)
    end

    help_alert = hs.alert(format_two_columns(help), help_alert_loc, 5)
end

hs.hotkey.bind(CMD_CTRL, "q", "Show Help",
function()
    local keys = hs.hotkey.getHotkeys()
    local key_list = ''

    for i = 1,#keys do
        if i == 1 then
            key_list = keys[i].msg
        else
            key_list = key_list .. '\n' .. keys[i].msg
        end
    end

    ShowHelp(key_list)
end)


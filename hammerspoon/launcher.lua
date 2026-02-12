
local apps =
{
    {
        ["text"] = "Alacritty",
        ["subText"] = "Hacker terminal",
        ["app"] = "Alacritty"
    },
    {
        ["text"] = "iTerm2",
        ["subText"] = "Hacker terminal",
        ["app"] = "iTerm"
    },
    {
        ["text"] = "VNC",
        ["subText"] = "VNC Viewer",
        ["app"] = "/usr/local/bin/vncviewer"
    },
    {
        ["text"] = "Chrome",
        ["subText"] = "Google Chrome web browser",
        ["app"] = "Google Chrome"
    },
    {
        ["text"] = "System Preferences",
        ["subText"] = "macOS system preferences",
        ["app"] = "System Preferences"
    },
    {
        ["text"] = "Activity Monitor",
        ["subText"] = "macOS system activity monitor",
        ["app"] = "Activity Monitor"
    },
    {
        ["text"] = "Console",
        ["subText"] = "macOS console and system logs",
        ["app"] = "Console"
    },
    {
        ["text"] = "System Information",
        ["subText"] = "macOS system information",
        ["app"] = "System Information"
    },
    {
        ["text"] = "App Store",
        ["subText"] = "Apple's application store",
        ["app"] = "App Store"
    },
    {
        ["text"] = "Safari",
        ["subText"] = "Apple Safari web browser",
        ["app"] = "Safari"
    },
    --[[
    {
        ["text"] = "Screenshot",
        ["subText"] = "macOS screenshot generator",
        ["app"] = "Grab"
    },
    --]]
}

hs.hotkey.bind(CMD_CTRL, "p", "Show application launcher",
function()
    local last_win = hs.window.focusedWindow()

    local chooser_cbk = function(selection)
        if selection == nil then
            if last_win ~= nil then
                last_win:focus() -- focus last window
            end
            selection = { ["text"] = "Launcher cancelled..." }
        end
        print("Launcher: "..selection.text)
        if selection.app ~= nil then
            hs.application.launchOrFocus(selection.app)
        end
    end

    chooser = hs.chooser.new(chooser_cbk)
    chooser:choices(apps)
    chooser:rows(#apps)
    chooser:width(40)
    chooser:bgDark(true)
    chooser:fgColor(hs.drawing.color.x11.orange)
    chooser:subTextColor(hs.drawing.color.x11.chocolate)
    chooser:show()
end)


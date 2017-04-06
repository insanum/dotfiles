
--local mash       = {"cmd", "alt", "ctrl"}
--local mash_shift = {"cmd", "alt", "ctrl", "shift"}
local mash       = {"cmd", "ctrl"}
local mash_shift = {"cmd", "ctrl", "shift"}

local lastWin = nil

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

local function launcher_cbk(selection)
  if selection == nil then
    if lastWin ~= nil then lastWin:focus() end -- focus last window
    selection = { ["text"] = "Launcher cancelled..." }
  end
  --hsNotify(selection.text)
  if selection.app ~= nil then
    hs.application.launchOrFocus(selection.app)
  end
end

local function launcher()
  chooser = hs.chooser.new(launcher_cbk)
  chooser:choices(apps)
  chooser:rows(#apps)
  chooser:width(40)
  chooser:bgDark(true)
  chooser:fgColor(hs.drawing.color.x11.orange)
  chooser:subTextColor(hs.drawing.color.x11.chocolate)
  chooser:show()
end

hs.hotkey.bind(mash, "p", function()
  lastWin = hs.window.focusedWindow()
  launcher()
end)


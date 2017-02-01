
local mash       = {"cmd", "alt", "ctrl"}
local mash_shift = {"cmd", "alt", "ctrl", "shift"}

-- reload config
hs.hotkey.bind(mash, "r", function()
  hs.notify.new({title="Hammerspoon",
                 informativeText="Reloading configuration..."}):send()
  hs.reload()
end)

-- maximize window
hs.hotkey.bind(mash, "m", function()
  local win = hs.window.focusedWindow()
  win:maximize()
end)

local function winMove(win, x, y, w, h)
  local f = win:frame()
  f.x = x
  f.y = y
  f.w = w
  f.h = h
  win:setFrame(f)
end

-- center window
hs.hotkey.bind(mash, "c", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x + (max.w * .10)),
               (max.y + (max.h * .10)),
               (max.w - (max.w * .20)),
               (max.h - (max.h * .20)))
end)

-- window left half of screen
hs.hotkey.bind(mash, "h", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x    ),
               (max.y    ),
               (max.w / 2),
               (max.h    ))
end)

-- window right half of screen
hs.hotkey.bind(mash, "l", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x + (max.w / 2)),
               (max.y              ),
               (max.w / 2          ),
               (max.h              ))
end)

-- window top half of screen
hs.hotkey.bind(mash, "k", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x    ),
               (max.y    ),
               (max.w    ),
               (max.h / 2))
end)

-- window bottom half of screen
hs.hotkey.bind(mash, "j", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x              ),
               (max.y + (max.h / 2)),
               (max.w              ),
               (max.h / 2          ))
end)

-- window upper left quadrant screen
hs.hotkey.bind(mash_shift, "h", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x     ),
               (max.y     ),
               (max.w / 2 ),
               (max.h / 2 ))
end)

-- window lower left quadrant screen
hs.hotkey.bind(mash_shift, "j", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x              ),
               (max.y + (max.h / 2)),
               (max.w / 2          ),
               (max.h / 2          ))
end)

-- window lower right quadrant screen
hs.hotkey.bind(mash_shift, "k", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x + (max.w / 2)),
               (max.y + (max.h / 2)),
               (max.w / 2          ),
               (max.h / 2          ))
end)

-- window upper right quadrant screen
hs.hotkey.bind(mash_shift, "l", function()
  local win = hs.window.focusedWindow()
  local max = win:screen():frame()
  winMove(win, (max.x + (max.w / 2)),
               (max.y              ),
               (max.w / 2          ),
               (max.h / 2          ))
end)

-- hack to move a window left/right between spaces

function moveWindowOneSpace(direction)
  local mouseOrigin = hs.mouse.getAbsolutePosition()
  local win = hs.window.focusedWindow()
  local clickPoint = win:zoomButtonRect()

  clickPoint.x = clickPoint.x + clickPoint.w + 5
  clickPoint.y = clickPoint.y + (clickPoint.h / 2)

  -- fix for Chrome
  if win:application():title() == 'Google Chrome' then
    clickPoint.y = clickPoint.y - clickPoint.h
  end

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint):post()
  hs.timer.usleep(150000)

  hs.eventtap.event.newKeyEvent({"ctrl"}, direction, true):post()
  hs.timer.usleep(150000)

  hs.eventtap.event.newKeyEvent({"ctrl"}, direction, false):post()
  hs.timer.usleep(150000)

  hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint):post()
  hs.timer.usleep(150000)

  hs.mouse.setAbsolutePosition(mouseOrigin)
end

hs.hotkey.bind(mash, "Left", function()
  moveWindowOneSpace("left")
end)

hs.hotkey.bind(mash, "Right", function()
  moveWindowOneSpace("right")
end)

require('launcher')


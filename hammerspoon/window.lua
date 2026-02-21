
local win_modal = NewModalKey(CMD_CTRL, 'i', 'Modal Window')

--[[
------------------------------------------------------------------------------
-- window stuff

-- maximize window
win_modal:bind(NONE, "f", "Maximize window",
function()
    win_modal:exit()
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local win = hs.window.frontmostWindow()
    win:maximize()

    hs.window.animationDuration = ad
end)

local function winMove(win, x, y, w, h)
    local ad = hs.window.animationDuration
    hs.window.animationDuration = 0

    local f = win:frame()
    f.x = x
    f.y = y
    f.w = w
    f.h = h
    win:setFrame(f)

    hs.window.animationDuration = ad
end

-- center window
win_modal:bind(NONE, "c", "Center window",
function()
    win_modal:exit()
    local win = hs.window.frontmostWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w * .10)),
                 (max.y + (max.h * .10)),
                 (max.w - (max.w * .20)),
                 (max.h - (max.h * .20)))
end)

-- window left half of screen
win_modal:bind(NONE, "h", "Move/Resize window left half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w / 2),
                 (max.h    ))
end)

-- window right half of screen
win_modal:bind(NONE, "l", "Move/Resize window right half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h              ))
end)

-- window top half of screen
win_modal:bind(NONE, "k", "Move/Resize window top half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x    ),
                 (max.y    ),
                 (max.w    ),
                 (max.h / 2))
end)

-- window bottom half of screen
win_modal:bind(NONE, "j", "Move/Resize window bottom half of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w              ),
                 (max.h / 2          ))
end)

-- window upper left quadrant screen
win_modal:bind(CTRL, "h", "Move/Resize window upper left of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x     ),
                 (max.y     ),
                 (max.w / 2 ),
                 (max.h / 2 ))
end)

-- window lower left quadrant screen
win_modal:bind(CTRL, "j", "Move/Resize window lower left of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x              ),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window lower right quadrant screen
win_modal:bind(CTRL, "k", "Move/Resize window lower right of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y + (max.h / 2)),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)

-- window upper right quadrant screen
win_modal:bind(CTRL, "l", "Move/Resize window upper right of screen",
function()
    win_modal:exit()
    local win = hs.window.focusedWindow()
    local max = win:screen():frame()
    winMove(win, (max.x + (max.w / 2)),
                 (max.y              ),
                 (max.w / 2          ),
                 (max.h / 2          ))
end)
--]]

--[[
------------------------------------------------------------------------------
-- monitor stuff

-- move a window to next monitor
function moveWindowMonitor(direction)
    local win = hs.window.frontmostWindow()
    if direction == "west" then
        win = win:moveOneScreenWest()
    else -- direciton == "east"
        win = win:moveOneScreenEast()
    end
end

win_modal:bind(CTRL, "n", "Move window to the right monitor",
function()
    win_modal:exit()
    moveWindowMonitor("west")
end)

win_modal:bind(CTRL, "m", "Move window to the left monitor",
function()
    win_modal:exit()
    moveWindowMonitor("east")
end)
--]]

--[[
------------------------------------------------------------------------------
-- spaces stuff

-- hack to move a window left/right between spaces
function moveWindowSpace(direction)
    local mouseOrigin = hs.mouse.absolutePosition()
    local win = hs.window.frontmostWindow()
    local clickPoint = win:zoomButtonRect()

    clickPoint.x = clickPoint.x + clickPoint.w + 5
    clickPoint.y = clickPoint.y + (clickPoint.h / 2)

    -- fix for Chrome
    if win:application():title() == "Google Chrome" then
        clickPoint.y = clickPoint.y - clickPoint.h
    end

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown,
                                    clickPoint):post()
    hs.timer.usleep(150000)

    -- hack adding "fn" required for Mojave...
    hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, true):post()
    hs.timer.usleep(150000)

    -- hack adding "fn" required for Mojave...
    hs.eventtap.event.newKeyEvent({"fn", "ctrl"}, direction, false):post()
    hs.timer.usleep(150000)

    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp,
                                    clickPoint):post()
    hs.timer.usleep(150000)

    hs.mouse.absolutePosition(mouseOrigin)
end

win_modal:bind(NONE, "n", "Move window one space to the left",
function()
    win_modal:exit()
    moveWindowSpace("left")
end)

win_modal:bind(NONE, "m", "Move window one space to the right",
function()
    win_modal:exit()
    moveWindowSpace("right")
end)
--]]

------------------------------------------------------------------------------
-- grid stuff

hs.window.animationDuration = 0.2

hs.grid.setGrid("8x8") -- make sure even numbers
hs.grid.ui.textSize = 32
hs.grid.ui.showExtraKeys = false
hs.grid.setMargins(hs.geometry({ 10, 10 }))

local function wins_with_cell_left_edge(col, row)
  local screen = hs.screen.mainScreen()
  local results = {}
  for _, win in ipairs(hs.window.allWindows()) do
    if win:screen() == screen then
      local cell = hs.grid.get(win)
      if cell and
         col == cell.x and
         row >= cell.y and
         row < cell.y + cell.h then
        table.insert(results, win)
      end
    end
  end
  return results
end

local function wins_with_cell_top_edge(col, row)
  local screen = hs.screen.mainScreen()
  local results = {}
  for _, win in ipairs(hs.window.allWindows()) do
    if win:screen() == screen then
      local cell = hs.grid.get(win)
      if cell and
         row == cell.y and
         col >= cell.x and
         col < cell.x + cell.w then
        table.insert(results, win)
      end
    end
  end
  return results
end

local function wins_with_cell_right_edge(col, row)
  local screen = hs.screen.mainScreen()
  local results = {}
  for _, win in ipairs(hs.window.allWindows()) do
    if win:screen() == screen then
      local cell = hs.grid.get(win)
      if cell and
         col == cell.x + cell.w - 1 and
         row >= cell.y and
         row < cell.y + cell.h then
        table.insert(results, win)
      end
    end
  end
  return results
end

local function wins_with_cell_bottom_edge(col, row)
  local screen = hs.screen.mainScreen()
  local results = {}
  for _, win in ipairs(hs.window.allWindows()) do
    if win:screen() == screen then
      local cell = hs.grid.get(win)
      if cell and
         row == cell.y + cell.h - 1 and
         col >= cell.x and
         col < cell.x + cell.w then
        table.insert(results, win)
      end
    end
  end
  return results
end

local function win_full_width(g, r)
    return r.w == g.w
end

local function win_full_height(g, r)
    return r.h == g.h
end

local function win_left_edge(g, r)
    return r.x == 0
end

local function win_top_edge(g, r)
    return r.y == 0
end

local function win_right_edge(g, r)
    return (r.x + r.w) == g.w
end

local function win_bottom_edge(g, r)
    return (r.y + r.h) == g.h
end

local function win_shrink_left_edge(r)
    if r.w == 2 then return r end
    return hs.geometry.rect((r.x + 1), r.y, (r.w - 1), r.h)
end

local function win_shrink_top_edge(r)
    if r.h == 2 then return r end
    return hs.geometry.rect(r.x, (r.y + 1), r.w, (r.h - 1))
end

local function win_shrink_right_edge(r)
    if r.w == 2 then return r end
    return hs.geometry.rect(r.x, r.y, (r.w - 1), r.h)
end

local function win_shrink_bottom_edge(r)
    if r.h == 2 then return r end
    return hs.geometry.rect(r.x, r.y, r.w, (r.h - 1))
end

local function win_shrink_width_both_edges(r)
    -- keep the window at least 2x grids wide
    if r.w == 2 then return r end
    local d = r.w == 3 and 1 or 2
    return hs.geometry.rect((r.x + 1), r.y, (r.w - d), r.h)
end

local function win_shrink_height_both_edges(r)
    local d = r.h == 3 and 2 or 1
    return hs.geometry.rect(r.x, (r.y + 1), r.w, (r.h - d))
end

local function win_grow_left_edge(g, r)
    if win_full_width(g, r) then return r end
    return hs.geometry.rect((r.x - 1), r.y, (r.w + 1), r.h)
end

local function win_grow_top_edge(g, r)
    if win_full_height(g, r) then return r end
    return hs.geometry.rect(r.x, (r.y - 1), r.w, (r.h + 1))
end

local function win_grow_right_edge(g, r)
    if win_full_width(g, r) then return r end
    return hs.geometry.rect(r.x, r.y, (r.w + 1), r.h)
end

local function win_grow_bottom_edge(g, r)
    if win_full_height(g, r) then return r end
    return hs.geometry.rect(r.x, r.y, r.w, (r.h + 1))
end

local function win_grow_width_both_edges(g, r)
    if win_full_width(g, r) then return r end
    local d = (r.w + 1) == g.w and 1 or 2
    return hs.geometry.rect((r.x - 1), r.y, (r.w + d), r.h)
end

local function win_grow_height_both_edges(g, r)
    if win_full_height(g, r) then return r end
    local d = (r.h + 1) == g.h and 1 or 2
    return hs.geometry.rect(r.x, (r.y - 1), r.w, (r.h + d))
end

local function resize_neighbors(focused_win, neighbors, resize_fn)
    if not neighbors then return end
    for _, w in ipairs(neighbors) do
        if w ~= focused_win then
            hs.grid.set(w, resize_fn(hs.grid.get(w)))
        end
    end
end

------------------------------------------------------------------------------

win_modal:bind(NONE, "g", "Show Window Grid",
function()
    win_modal:exit()
    hs.grid.show()
end)

win_modal:bind(NONE, "s", "Snap Window",
function()
    win_modal:exit()
    hs.grid.snap(hs.window.focusedWindow())
end)

win_modal:bind(SHIFT, "s", "Snap All Windows",
function()
    win_modal:exit()
    local screen = hs.screen.mainScreen()

    for _, win in ipairs(hs.window.allWindows()) do
        if win:isStandard() and win:isVisible() and win:screen() == screen then
            hs.grid.snap(win)
        end
    end
end)

win_modal:bind(NONE, "f", "Maximize Window",
function()
    win_modal:exit()
    hs.grid.maximizeWindow(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "h", "Move Window Left",
function()
    --win_modal:exit()
    hs.grid.pushWindowLeft(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "j", "Move Window Down",
function()
    --win_modal:exit()
    hs.grid.pushWindowDown(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "k", "Move Window Up",
function()
    --win_modal:exit()
    hs.grid.pushWindowUp(hs.window.focusedWindow())
end)

win_modal:bind(NONE, "l", "Move Window Right",
function()
    --win_modal:exit()
    hs.grid.pushWindowRight(hs.window.focusedWindow())
end)

win_modal:bind(SHIFT, "j", "Resize Window Height",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if win_full_height(g, r) then
        r = win_shrink_top_edge(r)
    elseif win_top_edge(g, r) then
        r = win_grow_bottom_edge(g, r)
        resize_neighbors(win,
            wins_with_cell_top_edge(r.x, ((r.y + r.h) - 1)),
            function(wr) return win_shrink_top_edge(wr) end)
    elseif win_bottom_edge(g, r) then
        r = win_shrink_top_edge(r)
        resize_neighbors(win,
            wins_with_cell_bottom_edge(r.x, (r.y - 2)),
            function(wr) return win_grow_bottom_edge(g, wr) end)
    else
        -- window not on a top or bottom edge, so shrink in both directions
        if r.h == 2 then return end
        r = win_shrink_height_both_edges(r)
    end

    hs.grid.set(win, r)
end)

win_modal:bind(SHIFT, "k", "Resize Window Height",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)
    if win_full_height(g, r) then

        r = win_shrink_bottom_edge(r)
    elseif win_top_edge(g, r) then
        r = win_shrink_bottom_edge(r)
        resize_neighbors(win,
            wins_with_cell_top_edge(r.x, ((r.y + r.h) + 1)),
            function(wr) return win_grow_top_edge(g, wr) end)
    elseif win_bottom_edge(g, r) then
        r = win_grow_top_edge(g, r)
        resize_neighbors(win,
            wins_with_cell_bottom_edge(r.x, r.y),
            function(wr) return win_shrink_bottom_edge(wr) end)
    else
        -- window not on a top or bottom edge, so grow in both directions
        r = win_grow_height_both_edges(g, r)
    end

    hs.grid.set(win, r)
end)

win_modal:bind(SHIFT, "h", "Resize Window Width",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if win_full_width(g, r) then
        r = win_shrink_right_edge(r)
    elseif win_left_edge(g, r) then
        r = win_shrink_right_edge(r)
        resize_neighbors(win,
            wins_with_cell_left_edge(((r.x + r.w) + 1), r.y),
            function(wr) return win_grow_left_edge(g, wr) end)
    elseif win_right_edge(g, r) then
        r = win_grow_left_edge(g, r)
        resize_neighbors(win,
            wins_with_cell_right_edge(r.x, r.y),
            function(wr) return win_shrink_right_edge(wr) end)
    else
        -- window not on a right or left edge, so shrink in both directions
        if r.w == 2 then return end
        r = win_shrink_width_both_edges(r)
    end

    hs.grid.set(win, r)
end)

win_modal:bind(SHIFT, "l", "Resize Window Width",
function()
    --win_modal:exit()
    local win = hs.window.focusedWindow()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(win)

    if win_full_width(g, r) then
        r = win_shrink_left_edge(r)
    elseif win_left_edge(g, r) then
        r = win_grow_right_edge(g, r)
        resize_neighbors(win,
            wins_with_cell_left_edge(((r.x + r.w) - 1), r.y),
            function(wr) return win_shrink_left_edge(wr) end)
    elseif win_right_edge(g, r) then
        r = win_shrink_left_edge(r)
        resize_neighbors(win,
            wins_with_cell_right_edge((r.x - 2), r.y),
            function(wr) return win_grow_right_edge(g, wr) end)
    else
        -- window not on a right or left edge, so grow in both directions
        r = win_grow_width_both_edges(g, r)
    end

    hs.grid.set(win, r)
end)

local function swap_window_horiz(find_fn, col, row)
    local win = hs.window.focusedWindow()
    local neighbors = find_fn(col, row)
    if not neighbors then return end

    for _, w in ipairs(neighbors) do
        if w ~= win then
            local r1 = hs.grid.get(win)
            local r2 = hs.grid.get(w)
            -- figure out who's left and who's right
            local left_r, right_r = r1, r2
            if r2.x < r1.x then left_r, right_r = r2, r1 end
            -- right window moves to where left was, left window moves right of it
            local new_left_x = left_r.x
            local new_right_x = left_r.x + right_r.w
            hs.grid.set(win, hs.geometry.rect(
                r1 == left_r and new_right_x or new_left_x,
                r1.y, r1.w, r1.h))
            hs.grid.set(w, hs.geometry.rect(
                r2 == left_r and new_right_x or new_left_x,
                r2.y, r2.w, r2.h))
            return
        end
    end
end

local function swap_window_vert(find_fn, col, row)
    local win = hs.window.focusedWindow()
    local neighbors = find_fn(col, row)
    if not neighbors then return end

    for _, w in ipairs(neighbors) do
        if w ~= win then
            local r1 = hs.grid.get(win)
            local r2 = hs.grid.get(w)
            -- figure out who's top and who's bottom
            local top_r, bot_r = r1, r2
            if r2.y < r1.y then top_r, bot_r = r2, r1 end
            -- bottom window moves to where top was, top window moves below it
            local new_top_y = top_r.y
            local new_bot_y = top_r.y + bot_r.h
            hs.grid.set(win, hs.geometry.rect(
                r1.x, r1 == top_r and new_bot_y or new_top_y,
                r1.w, r1.h))
            hs.grid.set(w, hs.geometry.rect(
                r2.x, r2 == top_r and new_bot_y or new_top_y,
                r2.w, r2.h))
            return
        end
    end
end

win_modal:bind(CTRL, "h", "Swap Window Left",
function()
    local r = hs.grid.get(hs.window.focusedWindow())
    if r.x == 0 then return end
    swap_window_horiz(wins_with_cell_right_edge, (r.x - 1), r.y)
end)

win_modal:bind(CTRL, "l", "Swap Window Right",
function()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(hs.window.focusedWindow())
    if (r.x + r.w) == g.w then return end
    swap_window_horiz(wins_with_cell_left_edge, (r.x + r.w), r.y)
end)

win_modal:bind(CTRL, "k", "Swap Window Up",
function()
    local r = hs.grid.get(hs.window.focusedWindow())
    if r.y == 0 then return end
    swap_window_vert(wins_with_cell_bottom_edge, r.x, (r.y - 1))
end)

win_modal:bind(CTRL, "j", "Swap Window Down",
function()
    local g = hs.grid.getGrid()
    local r = hs.grid.get(hs.window.focusedWindow())
    if (r.y + r.h) == g.h then return end
    swap_window_vert(wins_with_cell_top_edge, r.x, (r.y + r.h))
end)

win_modal:bind(NONE, "1", "Window Top Left",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, 0, (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "2", "Window Top Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, 0, g.w, (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "3", "Window Top Right",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect((g.w - (g.w / 2)), 0, (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "6", "Window Right Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect((g.w - (g.w / 2)), 0, (g.w / 2), g.h)
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "9", "Window Botttom Right",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect((g.w / 2), (g.h / 2), (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "8", "Window Bottom Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, (g.h - (g.h / 2)), g.w, (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "7", "Window Botttom Left",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, (g.h / 2), (g.w / 2), (g.h / 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "4", "Window Left Half",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(0, 0, (g.w / 2), g.h)
    hs.grid.set(hs.window.focusedWindow(), r)
end)

win_modal:bind(NONE, "5", "Window Center",
function()
    --win_modal:exit()
    local g = hs.grid.getGrid()
    local r = hs.geometry.rect(1, 1, (g.w - 2), (g.h - 2))
    hs.grid.set(hs.window.focusedWindow(), r)
end)


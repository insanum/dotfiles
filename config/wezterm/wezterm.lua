
local wezterm = require 'wezterm'
local wa = wezterm.action

local config = wezterm.config_builder()

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

config.front_end = 'WebGpu'

--config.default_prog = { '/opt/homebrew/bin/fish', '-l' }
config.default_cwd = wezterm.home_dir

config.font = wezterm.font('Hack Nerd Font')
config.font_size = 18
config.cell_width = 0.9
-- This won't work well on a dual screen setup. This is a temporary
-- solution to font rendering oddities on an external monitor.
-- https://github.com/wez/wezterm/issues/4096
--[[
wezterm.on('window-config-reloaded', function(window)
  if wezterm.gui.screens().active.name == 'S34J55x' then
    window:set_config_overrides({
      dpi = 109,
      font_size = 11,
      cell_width = 0.9,
    })
  end
end)
--]]

config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false

config.window_background_opacity = 0.9
config.text_background_opacity = 1
config.inactive_pane_hsb = {
  saturation = 0.7,
  brightness = 0.5,
}

config.window_decorations = 'RESIZE'
--config.macos_window_background_blur = 30

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
--config.use_resize_increments = true

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

config.color_scheme = 'Tokyo Night (Gogh)'
local clr_scheme = wezterm.get_builtin_color_schemes()[config.color_scheme]
local clr = {
  black          = 'black', --clr_scheme.ansi[1],
  red            = clr_scheme.ansi[2],
  green          = clr_scheme.ansi[3],
  yellow         = clr_scheme.ansi[4],
  blue           = clr_scheme.ansi[5],
  magenta        = clr_scheme.ansi[6],
  cyan           = clr_scheme.ansi[7],
  white          = 'white', --clr_scheme.ansi[8],
  black_bright   = clr_scheme.brights[1],
  red_bright     = clr_scheme.brights[2],
  green_bright   = clr_scheme.brights[3],
  yellow_bright  = clr_scheme.brights[4],
  blue_bright    = clr_scheme.brights[5],
  magenta_bright = clr_scheme.brights[6],
  cyan_bright    = clr_scheme.brights[7],
  bg             = clr_scheme.background,
  fg             = clr_scheme.foreground,
}

config.colors = {
  split = clr.yellow,

  selection_bg = clr.red,
  selection_fg = clr.black,

  -- In copy_mode, the color of the active text is:
  -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
  -- 2. selection_* otherwise
  copy_mode_active_highlight_bg = { Color = clr.red },
  copy_mode_active_highlight_fg = { Color = clr.black },
  copy_mode_inactive_highlight_bg = { Color = clr.blue },
  copy_mode_inactive_highlight_fg = { Color = clr.black },

  quick_select_label_bg = { Color = clr.yellow },
  quick_select_label_fg = { Color = clr.black },
  quick_select_match_bg = { Color = clr.red },
  quick_select_match_fg = { Color = clr.black },

  tab_bar = {
    background = clr.bg,
    new_tab = {
      bg_color = clr.bg,
      fg_color = clr.white,
    },
  },
}

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

local SOLID_LEFT_ROUND  = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ROUND = wezterm.nerdfonts.ple_right_half_circle_thick
local TASK_UNCHECKED    = wezterm.nerdfonts.md_checkbox_blank_outline
local TASK_CHECKED      = wezterm.nerdfonts.md_checkbox_marked

local function render_tab(fg_clr, bg_clr, text)
    return {
      { Background = { Color = clr.bg } },
      { Foreground = { Color = bg_clr } },
      { Text = SOLID_LEFT_ROUND },
      { Background = { Color = bg_clr } },
      { Foreground = { Color = fg_clr } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = text },
      { Background = { Color = clr.bg } },
      { Foreground = { Color = bg_clr } },
      { Text = SOLID_RIGHT_ROUND },
      { Text = ' '},
    }
end

wezterm.on('format-tab-title',
           function(tab, tabs, panes, config, hover, max_width)
  local title = tab.active_pane.title
  if tab.tab_title and #tab.tab_title > 0 then
    title = tab.tab_title
  else
    local function basename(s)
      return string.gsub(s, '(.*[/\\])(.*)', '%2')
    end
    title = basename(tab.active_pane.foreground_process_name)
  end

  if tab.is_active then
    return render_tab(clr.black, clr.red,
      TASK_CHECKED .. ' ' .. (tab.tab_index + 1) .. '.' .. title)
  else
    return render_tab(clr.black, clr.blue,
      TASK_UNCHECKED .. ' ' .. (tab.tab_index + 1) .. '.' .. title)
  end
end)

wezterm.on('update-status', function(window)
  local leader = '-'
  if window:leader_is_active() then
    leader = '+'
  end

  window:set_right_status(wezterm.format(
    render_tab(clr.black, clr.white, leader .. ' ' .. wezterm.hostname())
  ))
end)

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

config.keys = { }
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

local function key_cmd(key, mods, action)
  table.insert(config.keys, { key = key, mods = mods, action = action })
end

local function resize_pane(key, direction)
  return { key = key, action = wa.AdjustPaneSize({ direction, 5 }) }
end

config.key_tables = {
  resize_panes = {
    resize_pane('j', 'Down'),
    resize_pane('k', 'Up'),
    resize_pane('h', 'Left'),
    resize_pane('l', 'Right'),
  },
}

key_cmd('j', 'LEADER', wa.ActivatePaneDirection('Down'))
key_cmd('k', 'LEADER', wa.ActivatePaneDirection('Up'))
key_cmd('h', 'LEADER', wa.ActivatePaneDirection('Left'))
key_cmd('l', 'LEADER', wa.ActivatePaneDirection('Right'))

key_cmd('c', 'LEADER', wa.SpawnCommandInNewTab({
  cwd = wezterm.home_dir,
  domain = 'CurrentPaneDomain',
}))

key_cmd('v', 'LEADER', wa.SplitPane({
  command = {
    cwd = wezterm.home_dir,
    domain = 'CurrentPaneDomain',
  },
  direction = 'Right',
  size = { Percent = 50 },
}))

key_cmd('s', 'LEADER', wa.SplitPane({
  command = {
    cwd = wezterm.home_dir,
    domain = 'CurrentPaneDomain',
  },
  direction = 'Down',
  size = { Percent = 50 },
}))

key_cmd('r', 'LEADER', wa.ActivateKeyTable({
  name = 'resize_panes',
  one_shot = false,
  timeout_milliseconds = 1000,
}))

key_cmd('z', 'LEADER', wa.TogglePaneZoomState)
key_cmd('a', 'LEADER|CTRL', wa.ActivateLastTab)
key_cmd('p', 'LEADER', wa.ActivateTabRelative(-1))
key_cmd('Space', 'LEADER', wa.ActivateTabRelative(1))
key_cmd('j', 'LEADER|CTRL', wa.ActivateCopyMode)
key_cmd('a', 'LEADER', wa.SendKey({ key = 'a', mods = 'CTRL' }))

for i = 0,9 do
  key_cmd(tostring(i), 'LEADER', wa.ActivateTab(i - 1))
  key_cmd(tostring(i), 'LEADER|CTRL', wa.MoveTab(i))
end

-- set pane width to 90 for the active pane (furthest left/right panes only)
key_cmd('T', 'LEADER', wezterm.action_callback(function (window, pane)
  local tab = pane:tab()
  local d = pane:get_dimensions()
  if d.cols > 90 then
    if tab:get_pane_direction('Left') == nil then
      window:perform_action(wa.AdjustPaneSize({ 'Left', (d.cols - 90) }), pane)
    elseif tab:get_pane_direction('Right') == nil then
      window:perform_action(wa.AdjustPaneSize({ 'Right', (d.cols - 90) }), pane)
    end
  elseif d.cols < 90 then
    if tab:get_pane_direction('Left') == nil then
      window:perform_action(wa.AdjustPaneSize({ 'Right', (90 - d.cols) }), pane)
    elseif tab:get_pane_direction('Right') == nil then
      window:perform_action(wa.AdjustPaneSize({ 'Left', (90 - d.cols) }), pane)
    end
  end
end))

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

wezterm.on('gui-startup', function()
  local tab1, pane1, window1 = wezterm.mux.spawn_window({})
  window1:gui_window():maximize()
  wezterm.sleep_ms(1500) -- wait 1.5s for window to maximize

  tab1:set_title('Notes')
  pane1:split({ direction = 'Right', size = 0.5 })
  pane1:send_text('clear\n')
  pane1:send_text('figlet "Notes"\n')
  pane1:send_text('cd /Volumes/work/notes\n')
  pane1:send_text('git status\n')

  local tab2, pane2, window2 = window1:spawn_tab({})
  tab2:set_title('Cody')
  pane2:split({ direction = 'Right', size = 0.5 })
  pane2:send_text('clear\n')
  pane2:send_text('figlet "Cody"\n')
  pane2:activate()

  local tab3, pane3, window3 = window1:spawn_tab({})
  local d = tab3:get_size()
  local p = pane3:split({ direction = 'Right', size = (d.cols - 91) }) -- +1 for border
  pane3:split({ direction = 'Bottom', size = 0.5 })
  p:activate()
  p:send_text('ls\n')

  pane1:activate() -- final view of the window
end)

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

return config


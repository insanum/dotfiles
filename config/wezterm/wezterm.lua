
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_cwd = wezterm.home_dir

config.color_scheme = 'Tokyo Night'

config.font = wezterm.font 'Hack Nerd Font'
config.font_size = 16

config.enable_scroll_bar = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.hide_tab_bar_if_only_one_tab = false

config.window_background_opacity = 0.9
config.text_background_opacity = 1

config.window_decorations = 'RESIZE'
--config.macos_window_background_blur = 30

config.window_padding = { left = 0, right = 0, top = 0, bottom = 0, }
--config.use_resize_increments = true

local SOLID_LEFT_ROUND  = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ROUND = wezterm.nerdfonts.ple_right_half_circle_thick
local TASK_UNCHECKED    = wezterm.nerdfonts.md_checkbox_blank_outline
local TASK_CHECKED      = wezterm.nerdfonts.md_checkbox_marked

wezterm.on("format-tab-title",
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
    return {
      { Background = { Color = '#1a1b26' } },
      { Foreground = { Color = '#f7768e' } },
      { Text = SOLID_LEFT_ROUND },
      { Background = { Color = '#f7768e' } },
      { Foreground = { Color = '#1a1b26' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = TASK_CHECKED .. ' ' .. (tab.tab_index + 1) .. '.' .. title },
      { Background = { Color = '#1a1b26' } },
      { Foreground = { Color = '#f7768e' } },
      { Text = SOLID_RIGHT_ROUND },
      { Text = ' '},
    }
  else
    return {
      { Background = { Color = '#1a1b26' } },
      { Foreground = { Color = '#7aa2f7' } },
      { Text = SOLID_LEFT_ROUND },
      { Background = { Color = '#7aa2f7' } },
      { Foreground = { Color = '#1a1b26' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = TASK_UNCHECKED .. ' ' .. (tab.tab_index + 1) .. '.' .. title },
      { Background = { Color = '#1a1b26' } },
      { Foreground = { Color = '#7aa2f7' } },
      { Text = SOLID_RIGHT_ROUND },
      { Text = ' '},
    }
  end
end)

wezterm.on('update-status', function(window)
  local leader = { Text = '-' }
  if window:leader_is_active() then
    leader.Text = '+'
  end

  window:set_right_status(wezterm.format({
    { Background = { Color = '#1a1b26' } },
    { Foreground = { Color = '#a9b1d6' } },
    { Text = SOLID_LEFT_ROUND },
    { Background = { Color = '#a9b1d6' } },
    { Foreground = { Color = '#1a1b26' } },
    { Attribute = { Intensity = 'Bold' } },
    leader,
    { Text = ' ' .. wezterm.hostname() },
    { Background = { Color = '#1a1b26' } },
    { Foreground = { Color = '#a9b1d6' } },
    { Text = SOLID_RIGHT_ROUND },
  }))
end)

local function move_pane(key, direction)
  return {
    key = key, mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection(direction),
  }
end

local function resize_pane(key, direction)
  return {
    key = key,
    action = wezterm.action.AdjustPaneSize({ direction, 5 }),
  }
end

config.key_tables = {
  resize_panes = {
    resize_pane('j', 'Down'),
    resize_pane('k', 'Up'),
    resize_pane('h', 'Left'),
    resize_pane('l', 'Right'),
  },
}

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = 'c', mods = 'LEADER',
    action = wezterm.action.SpawnCommandInNewTab({
      cwd = wezterm.home_dir,
      domain = 'CurrentPaneDomain',
    }),
  },
  {
    key = 'v', mods = 'LEADER',
    action = wezterm.action.SplitHorizontal({
      cwd = wezterm.home_dir,
      domain = 'CurrentPaneDomain',
    }),
  },
  {
    key = 's', mods = 'LEADER',
    action = wezterm.action.SplitVertical({
      cwd = wezterm.home_dir,
      domain = 'CurrentPaneDomain',
    }),
  },
  move_pane('j', 'Down'),
  move_pane('k', 'Up'),
  move_pane('h', 'Left'),
  move_pane('l', 'Right'),
  {
    key = 'r', mods = 'LEADER',
    action = wezterm.action.ActivateKeyTable({
      name = 'resize_panes',
      one_shot = false,
      timeout_milliseconds = 1000,
    })
  },
  {
    key = 'z', mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  {
    key = 'a', mods = 'LEADER|CTRL',
    action = wezterm.action.ActivateLastTab,
  },
  {
    key = 'p', mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'Space', mods = 'LEADER',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'j', mods = 'LEADER|CTRL',
    action = wezterm.action.ActivateCopyMode,
  },
  {
    key = 'a', mods = 'LEADER',
    action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
  },
}

for i = 0,9 do
  table.insert(config.keys, {
    key = tostring(i), mods = 'LEADER',
    action = wezterm.action.ActivateTab(i - 1),
  })
  table.insert(config.keys, {
    key = tostring(i), mods = 'LEADER|CTRL',
    action = wezterm.action.MoveTab(i),
  })
end

wezterm.on('gui-startup', function()
  local tab1, pane1, window1 = wezterm.mux.spawn_window({})
  window1:gui_window():maximize()
  wezterm.sleep_ms(1000)

  pane1:split({ direction = 'Right' })
  pane1:split({ direction = 'Bottom' })

  local tab2, pane2, window2 = window1:spawn_tab({})
  tab2:set_title('Notes')
  pane2:split({ direction = 'Right' })
  pane2:send_text('figlet "Notes"\n')
  pane2:send_text('cd /Volumes/work/notes\n')
  pane2:send_text('git status\n')

  local tab3, pane3, window3 = window1:spawn_tab({})
  tab3:set_title('Cody')
  pane3:split({ direction = 'Right' })
  pane3:send_text('figlet "Cody"\n')

  pane2:activate()
end)

return config


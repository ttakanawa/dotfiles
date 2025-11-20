-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Enable macOS IME support and forward Ctrl key events to the IME
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = "CTRL"

-- Font
config.font = wezterm.font 'UDEV Gothic 35NF'

-- Split line color
config.colors = {
  split = 'white',
}

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.3,
}

-- Scrollback lines
config.scrollback_lines = 50000

-- This is where you actually apply your config choices
local act = wezterm.action
config.keys = {
  -- Move cursor
  { key = "LeftArrow", mods = "META", action = act.SendKey { key = "b", mods = "META" } },
  { key = "RightArrow", mods = "META", action = act.SendKey { key = "f", mods = "META" } },

  -- Switch panes
  { key = "h", mods = "CTRL|SHIFT", action = act.SplitPane {direction = "Left"} },
  { key = "l", mods = "CTRL|SHIFT", action = act.SplitPane {direction = "Right"} },
  { key = "k", mods = "CTRL|SHIFT", action = act.SplitPane {direction = "Up"} },
  { key = "j", mods = "CTRL|SHIFT", action = act.SplitPane {direction = "Down"} },

  -- Close pane
  { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane { confirm = true } },

  -- Shift + Enter to create a new line
  { key = 'Enter', mods = 'SHIFT', action = wezterm.action.SendString('\n') },
}

-- and finally, return the configuration to wezterm
return config
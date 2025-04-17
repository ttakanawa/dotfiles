-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

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
}

-- and finally, return the configuration to wezterm
return config
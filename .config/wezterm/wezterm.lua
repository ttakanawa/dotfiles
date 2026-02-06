-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Enable macOS IME support and forward Ctrl key events to the IME
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = "CTRL|SHIFT"

-- Window
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.97
config.macos_window_background_blur = 30

-- Transparent titlebar background
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

-- Hide new tab button in tab bar
config.show_new_tab_button_in_tab_bar = false

-- Color scheme
config.color_scheme = "Catppuccin Frappe"
config.colors = {
	compose_cursor = "#a6d189",
}

-- Font
config.font_size = 13
config.font = wezterm.font("UDEV Gothic 35NF")

-- Split line color
-- config.colors = { split = "white" }

-- Dim inactive panes
-- config.inactive_pane_hsb = {
-- 	saturation = 0.8,
-- 	brightness = 0.3,
-- }

-- tmux commands
local tmux_new_session = "tmux new -s $(uuidgen | cut -c 1-8)"
local tmux_attach_or_new = "tmux attach 2>/dev/null || " .. tmux_new_session

-- tmux session management
wezterm.on("gui-startup", function(cmd)
	local mux = wezterm.mux
	local windows = mux.all_windows()

	if #windows == 0 then
		-- On fresh wezterm startup: attach to existing session if available, otherwise create new
		mux.spawn_window({
			args = { "/bin/zsh", "-l", "-c", tmux_attach_or_new },
		})
	else
		-- When opening additional window (e.g., cmd+n): always create new session
		mux.spawn_window({
			args = { "/bin/zsh", "-l", "-c", tmux_new_session },
		})
	end
end)

-- Scrollback lines
config.scrollback_lines = 50000

-- This is where you actually apply your config choices
local act = wezterm.action
config.keys = {
	-- New window with new tmux session
	{
		key = "n",
		mods = "CMD",
		action = wezterm.action.SpawnCommandInNewWindow({
			args = { "/bin/zsh", "-l", "-c", tmux_new_session },
		}),
	},

	-- Move cursor
	{ key = "LeftArrow", mods = "META", action = act.SendKey({ key = "b", mods = "META" }) },
	{ key = "RightArrow", mods = "META", action = act.SendKey({ key = "f", mods = "META" }) },

	-- Switch panes
	-- { key = "h", mods = "CTRL|SHIFT", action = act.SplitPane({ direction = "Left" }) },
	-- { key = "l", mods = "CTRL|SHIFT", action = act.SplitPane({ direction = "Right" }) },
	-- { key = "k", mods = "CTRL|SHIFT", action = act.SplitPane({ direction = "Up" }) },
	-- { key = "j", mods = "CTRL|SHIFT", action = act.SplitPane({ direction = "Down" }) },

	-- Close pane
	-- { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },

	-- Close pane
	{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
	-- Shift + Enter to create a new line
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },

	-- Resize window (Option + Shift + H/J/K/L)
	{
		key = "j",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(window)
			local dim = window:get_dimensions()
			window:set_inner_size(dim.pixel_width, dim.pixel_height + 50)
		end),
	},
	{
		key = "k",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(window)
			local dim = window:get_dimensions()
			window:set_inner_size(dim.pixel_width, dim.pixel_height - 50)
		end),
	},
	{
		key = "l",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(window)
			local dim = window:get_dimensions()
			window:set_inner_size(dim.pixel_width + 50, dim.pixel_height)
		end),
	},
	{
		key = "h",
		mods = "ALT|SHIFT",
		action = wezterm.action_callback(function(window)
			local dim = window:get_dimensions()
			window:set_inner_size(dim.pixel_width - 50, dim.pixel_height)
		end),
	},
}

-- and finally, return the configuration to wezterm
return config

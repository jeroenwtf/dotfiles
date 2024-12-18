local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrains Mono NL")
config.font_size = 12
config.line_height = 1.2
config.color_scheme = "Tokyo Night"

config.keys = {
	{
		key = "Enter",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
}

config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 20,
}

return config

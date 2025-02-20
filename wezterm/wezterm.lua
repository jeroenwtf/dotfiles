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
	{
		key = "|",
		mods = "SHIFT|CTRL",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "n",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
}

config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 20,
}

wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return config

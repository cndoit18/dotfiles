local wezterm = require("wezterm")
local config = {}

config = {
	-- color scheme can be found here: https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/wezterm
	color_scheme = "Solarized Dark (Gogh)",
	font = wezterm.font("DroidSansM Nerd Font"),
	enable_tab_bar = true,
	use_fancy_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	tab_bar_at_bottom = false,
	use_ime = true,
	native_macos_fullscreen_mode = true,

	-- https://wezterm.org/config/lua/config/term.html
	term = "wezterm",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}

return config

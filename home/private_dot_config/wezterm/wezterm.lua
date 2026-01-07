local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- color scheme can be found here: https://github.com/mbadolato/iTerm2-Color-Schemes/tree/master/wezterm
config.color_scheme = "Solarized Dark (Gogh)"
config.font = wezterm.font("DroidSansM Nerd Font")
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.use_ime = true
config.native_macos_fullscreen_mode = true
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.leader = { key = "b", mods = "CTRL" }

require("wez-tmux.plugin").apply_to_config(config, {})
return config

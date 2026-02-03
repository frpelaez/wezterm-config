-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Maximize by default
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

local mykeys = {}
for i = 1, 9 do
	-- ALT + number to activate that tab
	table.insert(mykeys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

-- move tab

table.insert(
	mykeys,
	{ key = "s", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) }
)
-- table.insert(
-- 	mykeys,
-- 	{ key = "h", mods = "CTRL", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) }
-- )

config.keys = mykeys

-- This is where you actually apply your config choices.
config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }

-- For example, changing the initial geometry for new windows:
config.initial_cols = 80
config.initial_rows = 30

-- or, changing the font size and color scheme.
-- config.color_scheme = "tokyonight-storm"
config.color_scheme = "tokyonight"

-- Background
config.scrollback_lines = 3000
config.window_decorations = "RESIZE"

config.background = {
	{
		source = {
			File = "/Users/franp/.config/wezterm//mountain.jpg",
		},
		hsb = {
			hue = 1.0,
			saturation = 1.1,
			brightness = 0.25,
		},
		width = "100%",
		height = "100%",
	},
	{
		source = {
			Color = "#2b2d42",
		},
		width = "100%",
		height = "100%",
		opacity = 0.6,
	},
}

config.window_padding = {
	left = 5,
	right = 0,
	top = 0,
	bottom = 0,
}

config.use_fancy_tab_bar = false
config.automatically_reload_config = true
config.default_workspace = "home"
config.window_close_confirmation = "NeverPrompt"

-- for example, this selects a Bold, Italic font variant.
local weight = "Bold"
if weight == nil then
	config.font = wezterm.font("JetBrains Mono")
else
	config.font = wezterm.font("JetBrains Mono", { weight = weight })
end
config.font_size = 16

config.max_fps = 120
config.prefer_egl = true

-- Finally, return the configuration to wezterm:
return config

local wezterm = require("wezterm")

local config = wezterm.config_builder()

local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

-- Keymaps
local mykeys = {}
for i = 1, 9 do
	table.insert(mykeys, {
		key = tostring(i),
		mods = "ALT",
		action = wezterm.action.ActivateTab(i - 1),
	})
end
table.insert(mykeys, {
	key = "d",
	mods = "LEADER",
	action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
})
table.insert(mykeys, {
	key = "s",
	mods = "LEADER",
	action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
})
table.insert(mykeys, {
	key = "R",
	mods = "CTRL|SHIFT",
	action = wezterm.action.SpawnCommandInNewTab({
		args = { "wsl.exe", "-d", "Debian" },
	}),
})
table.insert(mykeys, { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") })
table.insert(mykeys, { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") })
table.insert(mykeys, { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") })
table.insert(mykeys, { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") })
table.insert(mykeys, {
	key = "r",
	mods = "LEADER",
	action = wezterm.action.ActivateKeyTable({
		name = "resize_pane",
		one_shot = false,
	}),
})
table.insert(mykeys, {
	key = "c",
	mods = "LEADER",
	action = wezterm.action.ActivateCopyMode,
})
table.insert(mykeys, {
	key = " ",
	mods = "LEADER",
	action = wezterm.action.QuickSelect,
})
table.insert(mykeys, {
	key = "n",
	mods = "LEADER",
	action = wezterm.action.PromptInputLine({
		description = " New tab name: ",
		action = wezterm.action_callback(function(window, _, line)
			if line then
				window:active_tab():set_title(line)
			end
		end),
	}),
})
config.keys = mykeys

-- Key tables
config.key_tables = {
	resize_pane = {
		{ key = "h", action = wezterm.action.AdjustPaneSize({ "Left", 4 }) },
		{ key = "l", action = wezterm.action.AdjustPaneSize({ "Right", 4 }) },
		{ key = "k", action = wezterm.action.AdjustPaneSize({ "Up", 4 }) },
		{ key = "j", action = wezterm.action.AdjustPaneSize({ "Down", 4 }) },
		{ key = "LeftArrow", action = wezterm.action.AdjustPaneSize({ "Left", 4 }) },
		{ key = "RightArrow", action = wezterm.action.AdjustPaneSize({ "Right", 4 }) },
		{ key = "UpArrow", action = wezterm.action.AdjustPaneSize({ "Up", 4 }) },
		{ key = "DownArrow", action = wezterm.action.AdjustPaneSize({ "Down", 4 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

-- Colors
config.colors = {
	tab_bar = {
		background = "rgba(0, 0, 0 ,0)",

		active_tab = {
			bg_color = "#cba6f7",
			fg_color = "#11111b",
		},

		inactive_tab = {
			bg_color = "#1e1e2e",
			fg_color = "#bac2de",
		},

		inactive_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
	},
}

-- Event right
wezterm.on("update-right-status", function(window, pane)
	local cells = {}

	if window:leader_is_active() then
		table.insert(cells, { text = " leader", color = "#f38ba8" })
	end

	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		local cwd = cwd_uri.file_path or ""
		local folder = cwd:match("([^/\\]+)[/\\]?$") or cwd
		table.insert(cells, { text = "  " .. folder, color = "#89b4fa" })
	end

	-- table.insert(cells, { text = " 󰒋 " .. wezterm.hostname(), color = "#a6adc8" })

	for _, b in ipairs(wezterm.battery_info()) do
		local charge = b.state_of_charge * 100
		local bat_icon = ""
		table.insert(cells, { text = string.format("%s %.0f%%", bat_icon, charge), color = "#a6e3a1" })
	end
	local date = wezterm.strftime("%d %b")
	local time = wezterm.strftime("%H:%M")
	table.insert(cells, {
		text = " " .. date .. " " .. time,
		color = "#cdd6f4",
	})

	local elements = {}
	local num_cells = 0
	for _, cell in ipairs(cells) do
		if num_cells > 0 then
			table.insert(elements, { Foreground = { Color = "#6c7086" } })
			table.insert(elements, { Text = "| " })
		end

		table.insert(elements, { Foreground = { Color = cell.color } })
		table.insert(elements, { Text = cell.text .. "  " })
		num_cells = num_cells + 1
	end

	window:set_right_status(wezterm.format(elements))
end)

-- Event left
wezterm.on("update-status", function(window, _)
	local mode = window:active_key_table()

	local text = ""
	local bg_color = ""

	if mode then
		text = " 󰌌 MODE: " .. string.upper(mode) .. " "
		bg_color = "#f9e2af"
		-- else
		-- 	text = " 󰇄 " .. window:active_workspace() .. " "
		-- 	bg_color = "#89b4fa"
	end

	window:set_left_status(wezterm.format({
		{ Background = { Color = bg_color } },
		{ Foreground = { Color = "#11111b" } },
		{ Text = text },

		{ Background = { Color = "rgba(0, 0, 0, 0)" } },
		{ Text = " " },
	}))
end)

-- Event tab titles
wezterm.on("format-tab-title", function(tab, _, _, _, _, _)
	local tab_index = tab.tab_index + 1
	local prefix = " " .. tab_index .. ": "

	if tab.tab_title and #tab.tab_title > 0 then
		return { { Text = prefix .. #tab .. tab.tab_title .. " " } }
	end

	local process_name = tab.active_pane.foreground_process_name
	local title = "Terminal"

	if process_name then
		process_name = process_name:match("([^/\\]+)$") or process_name
		process_name = process_name:gsub("%.exe$", "")

		if process_name == "pwsh" or process_name == "powershell" then
			title = "pwsh"
		elseif process_name == "nvim" then
			title = "NeoVim"
		elseif process_name == "git" then
			title = "Git"
		else
			title = process_name
		end
	end

	return { { Text = prefix .. title .. " " } }
end)

-- Options
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.default_prog = { "pwsh.exe" }
config.initial_cols = 80
config.initial_rows = 30
config.color_scheme = "Catppuccin Mocha"
config.scrollback_lines = 3000
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = false
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.default_workspace = "home"
config.window_close_confirmation = "NeverPrompt"
config.font = wezterm.font("JetBrains Mono", { weight = "Bold" })
config.font_size = 16
config.line_height = 0.995
config.max_fps = 120
config.prefer_egl = true
config.window_background_opacity = 1.0
config.win32_system_backdrop = "Disable"
config.automatically_reload_config = true

-- Background image
config.background = {
	{
		source = {
			File = "\\Users\\franp\\.config\\wezterm\\Blur_mountain.jpg",
		},
		hsb = {
			hue = 1.0,
			saturation = 1.0,
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
		opacity = 0.65,
	},
}

config.window_padding = {
	left = 20,
	right = 20,
	top = 20,
	bottom = 0,
}

return config

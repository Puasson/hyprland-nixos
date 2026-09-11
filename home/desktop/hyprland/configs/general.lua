hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 6,
		border_size = 0,
		layout = "dwindle",
		resize_on_border = true,
	},
	input = {
		kb_layout = "latam",
		follow_mouse = 1,
		sensitivity = 0,
		accel_profile = "flat",
		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			tap_to_click = true,
		},
	},
	dwindle = {
		preserve_split = true,
		smart_resizing = true,
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
		enable_swallow = true,
		swallow_regex = "^(kitty)$",
	},
})

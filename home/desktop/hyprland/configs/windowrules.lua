hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "flotante-pavucontrol",
	match = { class = "pavucontrol" },

	float = true,
	center = true,
	size = "50% 50%",
})

hl.window_rule({
	name = "flotante-nm-connection-editor",
	match = { class = "nm-connection-editor" },

	float = true,
	center = true,
	size = "50% 50%",
})

hl.window_rule({
	name = "flotante-qview",
	match = { class = "qview" },

	float = true,
	center = true,
	size = "60% 60%",
})

hl.window_rule({
	name = "ws-brave",
	match = { class = "brave-origin" },

	workspace = "1",
	no_initial_focus = true,
	suppress_event = "activate",
})

hl.window_rule({
	name = "ws-codium",
	match = { class = "vscodium" },

	workspace = "2",
	no_initial_focus = true,
	suppress_event = "activate",
})

hl.window_rule({
	name = "ws-obsidian",
	match = { class = "obsidian" },

	workspace = "3",
	no_initial_focus = true,
	suppress_event = "activate",
})

hl.window_rule({
	name = "ws-spotify",
	match = { class = "Spotify" },

	workspace = "9",
	no_initial_focus = true,
	suppress_event = "activate",
})

hl.window_rule({
	name = "ws-tauon",
	match = { class = "tauonmb" },

	workspace = "10",
	no_initial_focus = true,
	suppress_event = "activate",
})

hl.window_rule({
	name = "video-mpv-idle",
	match = { class = "mpv" },

	idle_inhibit = "focus",
})

hl.window_rule({
	name = "video-brave-fullscreen-idle",
	match = { class = "brave-origin", fullscreen = true },

	idle_inhibit = "fullscreen",
})

hl.window_rule({
	name = "video-brave-pip",
	match = { class = "brave-origin", title = "Picture in picture" },

	float = true,
	pin = true,
	keep_aspect_ratio = true,
	size = "480 270",
	move = "monitor_w-500 monitor_h-290",
})

hl.window_rule({
	name = "video-no-rounding-fullscreen",
	match = { fullscreen = true },

	rounding = 0,
})

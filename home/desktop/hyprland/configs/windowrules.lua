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

-- Helper: ventana flotante centrada con tamaño relativo.
local function float_center(name, class, size)
	hl.window_rule({
		name = name,
		match = { class = class },

		float = true,
		center = true,
		size = size,
	})
end

float_center("flotante-pavucontrol", "pavucontrol", "50% 50%")
float_center("flotante-nm-connection-editor", "nm-connection-editor", "50% 50%")
float_center("flotante-qview", "qview", "60% 60%")

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

-- SUPER+F (fullscreen real, estado interno 2 o 3): sin rounding para llegar a borde.
-- SUPER+M (maximized, estado interno 1) no entra aquí y conserva decoration.rounding.
hl.window_rule({
	name = "video-no-rounding-fullscreen",
	match = { fullscreen_state_internal = 2 },

	rounding = 0,
})

hl.window_rule({
	name = "video-no-rounding-fullscreen-max",
	match = { fullscreen_state_internal = 3 },

	rounding = 0,
})

hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("ease", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })
hl.curve("easeinout", { type = "bezier", points = { { 0.45, 0.0 }, { 0.55, 1.0 } } })
hl.curve("linear", { type = "bezier", points = { { 0.0, 0.0 }, { 1.0, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "ease", style = "popin 80%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "easeinout" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "linear" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "ease" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 2, bezier = "ease" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2, bezier = "overshot", style = "slidevert" })

hl.config({
	decoration = {
		rounding = 5,
		active_opacity = 0.9,
		inactive_opacity = 0.8,
	},
})

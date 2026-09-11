hl.monitor({
	output = "VGA-1",
	mode = "1600x900@60",
	position = "0x0",
	scale = 1,
})

-- Fallback para cualquier otro monitor / si VGA-1 no está presente
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

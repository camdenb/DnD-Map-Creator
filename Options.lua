-- If you want to change these values, I recommend making a backup, just in case.
-- reload game for changes to take effect

gridSnapRatio = 1 -- changes token snap behavior to snap in-between grid cells
panPercent = 0.15 -- percent of side of screen to trigger pan
panSpeed = 6 -- speed of camera
showDebugMessages = false -- show miscellaneous options, recommended is false
fogEnabled = false -- enables or disables fog
fogOpacity = 0 -- changes opacity of fog; leave this at 0 unless you want clients to see thru fog (servers see through fog by default)
tokenOpacityWhenHidden = 0 -- self-explanatory
limitFPS = true -- limits fps to ~60. When off, expect FPS of >200 depending on your machine
forceToServerMode = false -- also self-explanatory. Program defaults to client mode by default, so change this to force server mode
enableVsync = false -- self-explanatory

-- color palette!
colors = {
	{000, 000, 000, 255},
	{255, 255, 255},
	{150, 150, 150},
	{178, 34, 34},
	{255, 140, 0},
	{255, 215, 0},
	{139, 69, 19},
	{34, 139, 34},
	{135, 206, 250},
	{0, 0, 150},
	{148, 0, 211},
	{112, 128, 153}
}
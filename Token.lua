Token = Class{}

local currentID = 0

function Token:init(x, y, scale, color, name)

	print('New Token: ' .. name)

	self.x = x
	self.y = y
	self.scale = scale
	self.color = color
	self.name = name
	self.id = currentID
	currentID = currentID + 1
	
end
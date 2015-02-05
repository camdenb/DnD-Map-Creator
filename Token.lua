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

	self:hideIfInFog(Grid)
	
end

function Token:shouldBeHidden(grid)
	gridX = numToGrid(self.x)
	gridY = numToGrid(self.y)

	local numFogged = 0
	local hiddenThreshold = 0.5
	local maxFoggedToBeHidden = round(hiddenThreshold * (self.scale * self.scale))

	for x = 0, self.scale - 1, 1 do
		for y = 0, self.scale - 1, 1 do
			curCell = grid:getCell(gridX + x, gridY + y)
			if curCell.fogged then
				numFogged = numFogged + 1
			end
		end
	end

	if numFogged > maxFoggedToBeHidden then
		return true
	else
		return false
	end

end

function Token:hideIfInFog(grid)
	if self:shouldBeHidden(grid) then
		self.color[4] = 10
	else
		self.color[4] = 200
	end
end






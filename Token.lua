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

	if numFogged > maxFoggedToBeHidden and fog then
		return true
	else
		return false
	end

end

function Token:hideIfInFog(grid)
	self:removeFogInArea(grid)
	if self:shouldBeHidden(grid) then
		self.color[4] = 10
	else
		self.color[4] = 200
	end
end

function Token:removeFogInArea(grid)
	centerX = numToGrid(self.x) + round(self.scale / 2) - 1
	centerY = numToGrid(self.y) + round(self.scale / 2) - 1

	local radiusSquared = 49
	local searchRadius = 7

	for x = 0 - searchRadius, self.scale - 1 + searchRadius, 1 do
		for y = 0 - searchRadius, self.scale - 1 + searchRadius, 1 do
			curCell = grid:getCell(centerX + x, centerY + y)
			if distSquaredBetweenGridCells(curCell, grid:getCell(centerX, centerY)) < radiusSquared then
				curCell.fogged = false
			end
		end
	end
end





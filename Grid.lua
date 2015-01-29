Grid = class('Grid')

function Grid:initialize()
	print('Grid has been initialized')

	love.graphics.setLineWidth(3)
	love.graphics.setLineStyle('rough')
	love.graphics.setBackgroundColor(220, 220, 220)

	self.scale = 15
	self.gridSize = 50
	self.grid = {}
	self.bGridLines = true
	self.GRID_LOWERBOUND = -self.gridSize / 2
	self.GRID_UPPERBOUND = self.gridSize / 2 - 1

	self:initGrid()

end

function Grid:initGrid()
	for x = -self.gridSize / 2, self.gridSize / 2 - 1, 1 do

		self.grid[x] = {}

		for y = -self.gridSize / 2, self.gridSize / 2 - 1, 1 do

			self.grid[x][y] = false
			
		end
	end
end

function Grid:draw()
	for x = (-self.gridSize / 2) * self.scale, (self.gridSize / 2 - 1) * self.scale, self.scale do
		for y = (-self.gridSize / 2) * self.scale, (self.gridSize / 2 - 1) * self.scale, self.scale do
			local mouseX, mouseY = camera:mousepos()

			if math.floor(mouseX / self.scale) == math.floor(x / self.scale) and math.floor(mouseY / self.scale) == math.floor(y / self.scale) then
				love.graphics.setColor(255, 0, 0, 30)
				love.graphics.rectangle('fill', x, y, self.scale, self.scale)

			elseif self.grid[x / self.scale][y / self.scale] == true then
				love.graphics.setColor(50, 50, 50)
				love.graphics.rectangle('fill', x, y, self.scale, self.scale)

			elseif self.grid[x / self.scale][y / self.scale] == false and bGridLines then
				love.graphics.setColor(100, 100, 100, 10)
				love.graphics.rectangle('line', x, y, self.scale, self.scale)
				
			end
		end
	end
end

function Grid:getScale()
	return self.scale
end

function Grid:clearGrid()
	for x = (-self.gridSize / 2), (self.gridSize / 2 - 1), 1 do
		for y = (-self.gridSize / 2), (self.gridSize / 2 - 1), 1 do
			self.grid[x][y] = false
		end
	end
end

function Grid:setFilled(x, y, erase)
	erase = erase or false
	self.grid[x][y] = not erase
end


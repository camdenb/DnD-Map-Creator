Grid = class('Grid')
require 'Cell'

function Grid:initialize()
	print('Grid has been initialized')

	love.graphics.setLineWidth(3)
	love.graphics.setLineStyle('rough')
	love.graphics.setBackgroundColor(220, 220, 220)

	self.scale = 20
	self.gridSize = 150
	self.grid = {}
	self.bGridLines = true
	self.GRID_LOWERBOUND = 0
	self.GRID_UPPERBOUND = self.gridSize - 1

	self:initGrid()

end

function Grid:initGrid()
	for x = 0, self.gridSize - 1, 1 do

		self.grid[x] = {}

		for y = 0, self.gridSize - 1, 1 do

			self.grid[x][y] = Cell:new(x, y, 'none')
			
		end
	end
end

function Grid:draw()
	for x = 0, (self.gridSize - 1) * self.scale, self.scale do
		for y = 0, (self.gridSize - 1) * self.scale, self.scale do
			local mouseX, mouseY = camera:mousepos()

			if math.floor(mouseX / self.scale) == math.floor(x / self.scale) and math.floor(mouseY / self.scale) == math.floor(y / self.scale) then
				love.graphics.setColor(255, 0, 0, 30)
				love.graphics.rectangle('fill', x, y, self.scale, self.scale)

			elseif Grid:getState(x, y, true, true) == 1 then
				love.graphics.setColor(50, 50, 50)
				love.graphics.rectangle('fill', x, y, self.scale, self.scale)

			elseif Grid:getState(x, y, true, true) == 0 and self.bGridLines then
				love.graphics.setColor(100, 100, 100, 10)
				love.graphics.rectangle('line', x, y, self.scale, self.scale)
			end
		end
	end
end

function Grid:to_table()
	return self.grid
end

function Grid:getScale()
	return self.scale
end

function Grid:clearGrid()
	for x = 0, self.gridSize - 1, 1 do
		for y = 0, self.gridSize - 1, 1 do

			Grid:setState(x, y, 'none', false)
			
		end
	end
end

function Grid:setState(x, y, state, convertNumsToGrid)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end
	self.grid[x][y]:setState(state)
end

function Grid:getState(x, y, convertNumsToGrid, numForm)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end

	local state = self.grid[x][y]:getState(numForm)

	return state
end

function Grid:gridToString()
	local str = ''
	for x = 0, self.gridSize - 1, 1 do
		for y = 0, self.gridSize - 1, 1 do
			str = str .. Grid:getState(x, y, false, true)			
		end
	end
	return str
end





















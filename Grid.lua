require 'Cell'

Grid = Class{}

function Grid:init()
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

			self.grid[x][y] = Cell(x, y, 0)
			
		end
	end
end

function Grid:draw()
	love.graphics.setBackgroundColor(150, 150, 150)
	for x = 0, (self.gridSize - 1) * self.scale, self.scale do
		for y = 0, (self.gridSize - 1) * self.scale, self.scale do
			local mouseX, mouseY = camera:mousepos()

			local curCell = self:getCell(x, y, true)
			local state = Grid:getState(x, y, true)

			if curCell.fogged and fog then
				if state == 1 then
					local c = curCell.color
					love.graphics.setColor(c[1], c[2], c[3], fogOpacity)
					love.graphics.rectangle('fill', x, y, self.scale, self.scale)
				elseif state == 0 then
					
				end
			else
				if state == 1 then
					love.graphics.setColor(curCell.color)
					love.graphics.rectangle('fill', x, y, self.scale, self.scale)
				elseif state == 0 then
					love.graphics.setColor(255, 255, 255)
					love.graphics.rectangle('fill', x, y, self.scale, self.scale)
					if self.bGridLines then	
						love.graphics.setLineWidth(3)
						love.graphics.setLineStyle('smooth')
						love.graphics.setColor(255, 100, 100, 10)
						love.graphics.rectangle('line', x, y, self.scale, self.scale)
					end
				end
			end

			if math.floor(mouseX / self.scale) == math.floor(x / self.scale) and math.floor(mouseY / self.scale) == math.floor(y / self.scale) then
				love.graphics.setColor(255, 0, 0, 200)
				love.graphics.setLineWidth(2)
				love.graphics.setLineStyle('rough')
				love.graphics.rectangle('line', x + 1, y + 1, self.scale - 2, self.scale - 2)
			end

		end
	end
end

function Grid:getCell(x, y, convertNumsToGrid)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end
	return self.grid[x][y]
end

function Grid:paint(x, y, color, erase, convertNumsToGrid, sendOverNet)
	self:getCell(x, y, convertNumsToGrid):paint(color, erase, sendOverNet)
end

function Grid:to_table()
	return self.grid
end

function Grid:getScale()
	return self.scale
end

function Grid:clearGrid()
	netSendSimpleType(3)
	for x = 0, self.gridSize - 1, 1 do
		for y = 0, self.gridSize - 1, 1 do

			self:setState(x, y, 0, false)
			
		end
	end
end

function Grid:setState(x, y, state, convertNumsToGrid)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end
	return self.grid[x][y]:setState(state)
end

function Grid:getState(x, y, convertNumsToGrid)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end

	local state = self.grid[x][y]:getState()

	return state
end

function Grid:gridToString()
	local str = ''
	for x = 0, self.gridSize - 1, 1 do
		for y = 0, self.gridSize - 1, 1 do
			local state = self:getState(x, y, false, true)
			if state == 0 then
				str = str .. state .. '000000000000'
			elseif state == 1 then
				str = str .. state .. colorToString(self:getCell(x, y):getColor())
			end		
		end
	end
	return str
end

function Grid:saveGridAppend()
	local formatStr = '/maps/' .. os.date('%m-%d-%Y_%I%p-%M%S') .. '.txt'
	love.filesystem.write(formatStr, '')
	for x = 0, self.gridSize - 1, 1 do
		for y = 0, self.gridSize - 1, 1 do
			local state = self:getState(x, y, false, true)
			if state == 0 then
				love.filesystem.append(formatStr, state .. '000000000000')
			elseif state == 1 then
				love.filesystem.append(formatStr, state .. colorToString(self:getCell(x, y):getColor()))
			end		
		end
	end
end

function Grid:saveGridWithCoords()
	local formatStr = '/maps/' .. os.date('%m-%d-%Y_%I%p-%M%S') .. '.txt'
	love.filesystem.write(formatStr, '')
	for x = 0, self.gridSize - 1, 1 do
		for y = 0, self.gridSize - 1, 1 do
			local state = self:getState(x, y, false, true)
			if state == 1 then
				love.filesystem.append(formatStr, string.format('%04s', x) .. string.format('%04s', y) .. colorToString(self:getCell(x, y):getColor()))
			end
		end
	end
end



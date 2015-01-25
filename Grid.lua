Grid = class('Grid')

function Grid:initialize()
	print('Grid has been initialized')

	love.graphics.setLineWidth(1)
	love.graphics.setLineStyle('rough')
	love.graphics.setBackgroundColor(230, 230, 230)

	self.scale = 15
	self.gridWidth = 100
	self.gridHeight = 100
	self.grid = {}
	self.bGridLines = true

	self:initGrid()

end

function Grid:draw()
	for x = self.scale, self.gridWidth * self.scale, self.scale do
		for y = self.scale, self.gridHeight * self.scale, self.scale do
			if math.floor(love.mouse.getX() / self.scale) == math.floor(x / self.scale) and math.floor(love.mouse.getY() / self.scale) == math.floor(y / self.scale) then
				love.graphics.setColor(255, 0, 0, 30)
				love.graphics.rectangle('fill', x, y, self.scale, self.scale)
			elseif self.grid[x / self.scale][y / self.scale] == true then
				love.graphics.setColor(50, 50, 50)
				love.graphics.rectangle('fill', x, y, self.scale, self.scale)
			elseif self.grid[x / self.scale][y / self.scale] == false and bGridLines then
				love.graphics.setColor(100, 100, 100, 50)
				love.graphics.rectangle('line', x, y, self.scale, self.scale)
			end
		end
	end
end

function Grid:getScale()
	return self.scale
end

function Grid:addToScale(num)
	self.scale = self.scale + num
end

function Grid:initGrid()
	for x = 1, self.gridWidth, 1 do

		self.grid[x] = {}

		for y = 1, self.gridHeight, 1 do

			self.grid[x][y] = false
			
		end
	end
end
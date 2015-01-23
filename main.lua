local scale = 15;
local gridWidth = 100;
local gridHeight = 100;

local grid = {}

local bGridLines = true

local drawingMode = false
local draggingMode = false

local token1 = { x = scale * 10, y = scale * 10, scale = 2 }

love.graphics.setLineWidth(1)
love.graphics.setLineStyle('rough')
love.graphics.setBackgroundColor(230, 230, 230)

function love.load()
	initGrid()
end

function initGrid()
	for x = 1, gridWidth, 1 do

		grid[x] = {}

		for y = 1, gridHeight, 1 do

			grid[x][y] = false
			
		end
	end
end

function love.draw(dt)

	for x = scale, gridWidth * scale, scale do
		for y = scale, gridHeight * scale, scale do
			if math.floor(love.mouse.getX() / scale) == math.floor(x / scale) and math.floor(love.mouse.getY() / scale) == math.floor(y / scale) then
				love.graphics.setColor(255, 0, 0, 30)
				love.graphics.rectangle('fill', x, y, scale, scale)
			elseif grid[x / scale][y / scale] == true then
				love.graphics.setColor(50, 50, 50)
				love.graphics.rectangle('fill', x, y, scale, scale)
			elseif grid[x / scale][y / scale] == false and bGridLines then
				love.graphics.setColor(100, 100, 100, 50)
				love.graphics.rectangle('line', x, y, scale, scale)
			end
		end
	end

	love.graphics.setColor(100, 100, 255, 150)
	love.graphics.rectangle('fill', token1.x, token1.y, scale * token1.scale, scale * token1.scale)

end

function love.update(dt)

	if drawingMode then
		draw(love.mouse.getX(), love.mouse.getY(), false)
	end

	if love.keyboard.isDown('lshift') then

	end

	if love.keyboard.isDown('d') then
		draw(love.mouse.getX(), love.mouse.getY(), false)
	elseif love.keyboard.isDown('e') then
		draw(love.mouse.getX(), love.mouse.getY(), true)
	end

end

function love.keypressed(key, isrepeat)
	if key == 'g' then 
		bGridLines = not bGridLines
	elseif key == 'n' then
		clearGrid()
	elseif key == '-' and scale > 1 then
		scale = scale - 1
	elseif key == '=' then
		scale = scale + 1
	end
end

function clearGrid()
	for x = 1, gridWidth, 1 do

		grid[x] = {}

		for y = 1, gridHeight, 1 do

			grid[x][y] = false
			
		end
	end
end

function coordToGrid(x, y)
	if x < scale or y < scale then
		return nil
	end
	return grid[math.floor(x / scale)][math.floor(y / scale)]
end

function draw(x, y, erase)
	if coordToGrid(x, y) ~= nil then
		grid[math.floor(x / scale)][math.floor(y / scale)] = not erase
	end
end

function highlight(x, y)
	if coordToGrid(x, y) ~= nil then
		grid[math.floor(x / scale)][math.floor(y / scale)] = "highlighted"
	end
end

function love.mousepressed(x, y, button)
	if coordInRect(x, y, token1.x, token1.y, token1.scale * scale, token1.scale * scale) then
		draggingMode = true
		drawingMode = false
		print('IN')
	else
		draw(x, y)
		drawingMode = true
	end
end

function coordInRect(x, y, rx, ry, rw, rh)
	if x >= rx and x <= rx + rw and y >= ry and y <= ry + rh then
		return true
	else
		return false
	end
end

function love.mousereleased()
	drawingMode = false
	draggingMode = false
	print(draggingMode)
end




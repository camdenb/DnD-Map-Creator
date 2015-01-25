class = require 'lib/middleclass'

require 'Grid'
require 'Token'
require 'TokenFactory'



local drawingMode = false
local draggingMode = false

local selectedToken = nil

function love.load()
	Grid = Grid:new()
	TokenFactory = TokenFactory:new()
	TokenFactory:addToken(10, 100, 2, {255, 255, 0}, 'token1')
end



function love.draw(dt)

	Grid:draw()
	TokenFactory:draw(Grid)

end

function love.update(dt)

	if draggingMode then
		selectedToken.x = love.mouse.getX()
		selectedToken.y = love.mouse.getY()
	end

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
	elseif key == '-' and Grid:getScale() > 1 then
		Grid:addToScale(-1)
		realignTokens()
	elseif key == '=' then
		Grid:addToScale(1)
		realignTokens()
	end
end

function realignTokens()
	for i, token in ipairs(TokenFactory:getTokens()) do
		alignTokenToGrid(token)
	end
end

function alignTokenToGrid(token)
	token.x = roundToMultiple(token.x, Grid:getScale())
	token.y = roundToMultiple(token.y, Grid:getScale())
end

function clearGrid()
	for x = 1, Grid.gridWidth, 1 do

		Grid.grid[x] = {}

		for y = 1, Grid.gridHeight, 1 do

			Grid.grid[x][y] = false
			
		end
	end
end

function coordToGrid(x, y)
	if x < Grid:getScale() or y < Grid:getScale() then
		return nil
	end
	return Grid.grid[math.floor(x / Grid:getScale())][math.floor(y / Grid:getScale())]
end

function draw(x, y, erase)
	if coordToGrid(x, y) ~= nil then
		Grid.grid[math.floor(x / Grid:getScale())][math.floor(y / Grid:getScale())] = not erase
	end
end

function highlight(x, y)
	if coordToGrid(x, y) ~= nil then
		Grid.grid[math.floor(x / Grid:getScale())][math.floor(y / Grid:getScale())] = "highlighted"
	end
end

function love.mousepressed(x, y, button)
	for i,token in ipairs(TokenFactory:getTokens()) do
			if coordInRect(x, y, token.x, token.y, token.scale * Grid:getScale(), token.scale * Grid:getScale()) then
				selectedToken = token
				draggingMode = true
				drawingMode = false
				break
			end
		end
end

function love.mousereleased()
	drawingMode = false
	exitDraggingMode()
end

function exitDraggingMode()
	draggingMode = false
	if selectedToken ~= nil then
		alignTokenToGrid(selectedToken)
	end
end

function roundToMultiple(num, mult)
	return math.floor(num / mult) * mult
end

function coordInRect(x, y, rx, ry, rw, rh)
	if x >= rx and x <= rx + rw and y >= ry and y <= ry + rh then
		return true
	else
		return false
	end
end






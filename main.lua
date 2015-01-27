class = require 'lib/middleclass'
Camera = require 'lib/hump-master/camera'

require 'Grid'
require 'Token'
require 'TokenFactory'
require 'ModeManager'
require 'HelperFunctions'



local drawingMode = false
local draggingMode = false
local dragDiffX, dragDiffY = 0, 0

local selectedToken = nil
local hoveredToken = nil

function love.load()
	Grid = Grid:new()

	ModeManager = ModeManager:new()

	TokenFactory = TokenFactory:new()
	

	camera = Camera()

	TokenFactory:addToken(10, 20, 2, {255, 255, 0}, 'token1')
	TokenFactory:addToken(100, 200, 2, {0, 125, 0}, 'token2')

	realignTokens()

end

function love.draw(dt)

	camera:attach()

	Grid:draw()
	TokenFactory:draw(Grid)

	camera:detach()

	-----------------------------------------

	love.graphics.setColor(0, 0, 0)

	if hoveredToken ~= nil then
		love.graphics.print(hoveredToken.name, 10, 10)
	end

	love.graphics.print(MOUSE_X .. " " .. MOUSE_Y, 200, 10)


end

function love.update(dt)

	MOUSE_X, MOUSE_Y = camera:mousepos()

	getHoveredToken()

	if ModeManager:isMode('Dragging') then
		selectedToken.x = MOUSE_X - dragDiffX
		selectedToken.y = MOUSE_Y - dragDiffY
	end

	if ModeManager:isMode('Drawing') then
		draw(MOUSE_X, MOUSE_Y, false)
	end

	if love.keyboard.isDown('d') then
		draw(MOUSE_X, MOUSE_Y, false)
	elseif love.keyboard.isDown('e') then
		draw(MOUSE_X, MOUSE_Y, true)
	end

end

function love.keypressed(key, isrepeat)
	if key == 'g' then 
		bGridLines = not bGridLines
	elseif key == 'n' then
		clearGrid()
	elseif key == '-' then
		--camera:lookAt(camera:mousepos())
		camera:zoom(0.9)
	elseif key == '=' then
		--camera:lookAt(camera:mousepos())
		camera:zoom(1.1)
	end
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
	if getHoveredToken() ~= nil then
		selectedToken = getHoveredToken()
		enterDraggingMode(MOUSE_X, MOUSE_Y)
	end
end

function love.mousereleased()
	ModeManager:setMode('none')
	exitDraggingMode()
end

function enterDraggingMode(mouse_x, mouse_y)
	mouse_x = mouse_x or 0
	mouse_y = mouse_y or 0

	ModeManager:setMode('Dragging')

	dragDiffX = mouse_x - selectedToken.x
	dragDiffY = mouse_y - selectedToken.y
end

function exitDraggingMode()
	ModeManager:setMode('none')
	if selectedToken ~= nil then
		alignTokenToGrid(selectedToken)
	end
end








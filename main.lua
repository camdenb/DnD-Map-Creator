class = require 'lib/middleclass'
Camera = require 'lib/hump-master/camera'

require 'Grid'
require 'Token'
require 'TokenFactory'
require 'ModeManager'
require 'HelperFunctions'



local dragDiffX, dragDiffY = 0, 0

local selectedToken = nil
local hoveredToken = nil

function love.load()

	love.window.setMode(500, 500)
	love.window.setTitle('Dungeons & Dragons Map Explorer')

	Grid = Grid:new()

	ModeManager = ModeManager:new()

	TokenFactory = TokenFactory:new()
	

	camera = Camera(0, 0)

	TokenFactory:addToken(10, 10, 3, {255, 255, 0}, 'token1')
	TokenFactory:addToken(250, 250, 1, {0, 125, 0}, 'token2')

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

	hoveredToken = getHoveredToken()

	if ModeManager:isMode('Dragging') then
		selectedToken.x = MOUSE_X - dragDiffX
		selectedToken.y = MOUSE_Y - dragDiffY
	end

	if ModeManager:isMode('Drawing') then
		draw(MOUSE_X, MOUSE_Y, false)
	elseif ModeManager:isMode('Erasing') then
		draw(MOUSE_X, MOUSE_Y, true)
	end


	if love.keyboard.isDown('d') then
		--draw(MOUSE_X, MOUSE_Y, false)
	elseif love.keyboard.isDown('e') then
		--draw(MOUSE_X, MOUSE_Y, true)
	end

end

function love.keypressed(key, isrepeat)
	if key == 'g' then 
		bGridLines = not bGridLines
	elseif key == 'd' then
		ModeManager:setMode('Drawing')
	elseif key == 'e' then
		ModeManager:setMode('Erasing')
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

function love.keyreleased(key, isrepeat)
	if key == 'd' and not ModeManager:isMode('Dragging') then
		ModeManager:setMode('none')
	elseif key == 'e' then
		ModeManager:setMode('none')
	end
end


function draw(x, y, erase)
	if coordToGrid(x, y) ~= nil then
		Grid.grid[numToGrid(x)][numToGrid(y)] = not erase
	end
end

function highlight(x, y)
	if coordToGrid(x, y) ~= nil then
		Grid.grid[numToGrid(x)][numToGrid(y)] = "highlighted"
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








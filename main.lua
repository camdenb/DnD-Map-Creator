class = require 'lib/middleclass'
Camera = require 'lib/hump-master/camera'
Timer = require 'lib/hump-master/timer'

require 'Grid'
require 'Token'
require 'TokenFactory'
require 'ModeManager'
require 'HelperFunctions'
require 'ColorFunctions'

local startLine
local sX, sY

local dragDiffX, dragDiffY = 0, 0

local tokenSnapping = true
gridSnapRatio = 1

local selectedToken = nil
local hoveredToken = nil

local panPercent = 0.2 --percent of side of screen to trigger pan
local panSpeed = 7

local selectingFile = false
local currentFileIndex = 0
local availableMaps

currentColor = 1

colors = {
	{HSL(0, 0, 0)},
	{HSL(0, 200, 100)},
	{HSL(30, 255, 100)},
	{HSL(100, 200, 100)},
	{HSL(170, 200, 150)}
}

local colorOutlineWidth = 5

function love.load()


	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
	love.window.setTitle('Dungeons & Dragons Map Explorer')

	Grid = Grid:new()

	ModeManager = ModeManager:new()

	TokenFactory = TokenFactory:new()
	

	camera = Camera((Grid.gridSize / 2) * Grid:getScale(), (Grid.gridSize / 2) * Grid:getScale())

	TokenFactory:addToken(10, 10, 3, {255, 255, 0}, 'token1')
	TokenFactory:addToken(250, 250, 2, {0, 125, 0}, 'token2')


	if tokenSnapping then
		realignTokens()
	end

	print(colors[1], colors[2])

	availableMaps = love.filesystem.getDirectoryItems('/maps')
	currentFileIndex = #availableMaps

	takeScreenshot()


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

	love.graphics.print(math.floor(MOUSE_X) .. " " .. math.floor(MOUSE_Y), 200, 10)
	love.graphics.print(numToGrid(MOUSE_X) .. " " .. numToGrid(MOUSE_Y), 200, 25)

	if selectingFile then
		love.graphics.print(availableMaps[currentFileIndex], 10, WINDOW_HEIGHT - 20)
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', WINDOW_WIDTH - 20 - colorOutlineWidth, WINDOW_HEIGHT - 20 - colorOutlineWidth, 30 + colorOutlineWidth * 2, 30 + colorOutlineWidth * 2)
	love.graphics.setColor(colors[currentColor])
	love.graphics.rectangle('fill', WINDOW_WIDTH - 20, WINDOW_HEIGHT - 20, 30, 30)
end

function love.update(dt)

	MOUSE_X, MOUSE_Y = camera:mousepos()

	hoveredToken = getHoveredToken()

	if ModeManager:isMode('Dragging') then
		selectedToken.x = MOUSE_X - dragDiffX
		selectedToken.y = MOUSE_Y - dragDiffY
	end

	if ModeManager:isMode('Drawing') then
		paint(MOUSE_X, MOUSE_Y, false)
	elseif ModeManager:isMode('Erasing') then
		paint(MOUSE_X, MOUSE_Y, true)
	end

	if love.keyboard.isDown('lshift') then
		local camX, camY = camera:cameraCoords(MOUSE_X, MOUSE_Y)
		if camX < round(panPercent * WINDOW_WIDTH) then
			camera:move(-panSpeed, 0)
		elseif camX > round((1 - panPercent) * WINDOW_WIDTH) then
			camera:move(panSpeed, 0)
		end

		if camY < round(panPercent * WINDOW_HEIGHT) then
			camera:move(0, -panSpeed)
		elseif camY > round((1 - panPercent) * WINDOW_HEIGHT) then
			camera:move(0, panSpeed)
		end
	end



end

function love.keypressed(key, isrepeat)
	if key == 'g' then 
		bGridLines = not bGridLines
	elseif key == 'l' then
		if not startLine then
			startLine = true
			sX = MOUSE_X
			sY = MOUSE_Y
		else
			drawLine(sX, sY, MOUSE_X, MOUSE_Y)
			startLine = false
		end
	elseif key == 'k' then
		if not startLine then
			startLine = true
			sX = MOUSE_X
			sY = MOUSE_Y
		else
			drawRectangle(sX, sY, MOUSE_X, MOUSE_Y)
			startLine = false
		end
	elseif key == 'd' then
		ModeManager:setMode('Drawing')
	elseif key == 'c' then
		nextColor()
	elseif key == 'e' then
		ModeManager:setMode('Erasing')
	elseif key == 'n' then
		Grid:clearGrid()
	elseif key == 's' then
		saveGrid()
	elseif key == 'a' then
		if not selectingFile then
			selectingFile = true
		else
			if currentFileIndex <= 1 then
				currentFileIndex = #availableMaps
			else
				currentFileIndex = currentFileIndex - 1
			end
		end
	elseif key == 'return' then
		if selectingFile then
			loadGrid(availableMaps[currentFileIndex])
			selectingFile = false
			currentFileIndex = #availableMaps
		end
	elseif key == 'm' then
		tokenSnapping = not tokenSnapping
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


function paint(x, y, erase)
	if coordToGrid(x, y) ~= nil then
		Grid:paint(x, y, colors[currentColor], erase, true)
	end
end

function highlight(x, y)
	if coordToGrid(x, y) ~= nil then
		Grid:setState(x, y, not erase, true)
	end
end

function love.mousepressed(x, y, button)
	
	if love.keyboard.isDown('lshift') then
		local xx, yy = camera:pos()
		camera:move(MOUSE_X - xx, MOUSE_Y - yy)
	elseif getHoveredToken() ~= nil then
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
	if selectedToken ~= nil and tokenSnapping then
		alignTokenToGrid(selectedToken)
	end
end








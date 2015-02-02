Class = require 'lib/hump-master/class'
Camera = require 'lib/hump-master/camera'
Timer = require 'lib/hump-master/timer'
Lube = require 'lib/lube/lube'

require 'lib/Tserial'

require 'Grid'
require 'Token'
require 'TokenFactory'
require 'ModeManager'
require 'HelperFunctions'
require 'ColorFunctions'
require 'Networking'
require 'NetworkFunctions'
require 'Client'
require 'Server'

-- print(separateTablesFromString('{1,2,3}{2,3,14,1412}')[2][4])

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

mouseOldX, mouseOldY = nil, nil

currentColor = 1

colors = {
	{000, 000, 000, 254},
	{200, 100, 100},
	{100, 200, 000},
	{100, 200, 200},
	{000, 100, 200}
}

local colorOutlineWidth = 5

function love.load(args)

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
	love.window.setTitle('Dungeons & Dragons Map Explorer')

	Network = Network('localhost', 9999, tonumber(args[2]) or 0)
	Network:load()
	Network:connect()

	Grid = Grid()

	ModeManager = ModeManager()

	TokenFactory = TokenFactory()
	

	camera = Camera((Grid.gridSize / 2) * Grid:getScale(), (Grid.gridSize / 2) * Grid:getScale())

	TokenFactory:addToken(10, 10, 3, {255, 200, 0}, 'token1')
	TokenFactory:addToken(10, 250, 2, {125, 125, 0}, 'token2')
	TokenFactory:addToken(10, 250, 4, {255, 125, 0}, 'Goldar the Behemoth')


	if tokenSnapping then
		realignTokens()
	end

	availableMaps = love.filesystem.getDirectoryItems('/maps')
	currentFileIndex = #availableMaps

	takeScreenshot()

end

function love.update(dt)

	Network:update(dt)

   if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
   end

	MOUSE_X, MOUSE_Y = camera:mousepos()

	hoveredToken = getHoveredToken()

	if ModeManager:isMode('Dragging') then
		selectedToken.x = MOUSE_X - dragDiffX
		selectedToken.y = MOUSE_Y - dragDiffY
	end

	if ModeManager:isMode('Drawing') then
		paint(MOUSE_X, MOUSE_Y, false)
		if mouseOldX == nil or mouseOldY == nil then
			mouseOldX = MOUSE_X
			mouseOldY = MOUSE_Y
		elseif numToGrid(mouseOldX) ~= numToGrid(MOUSE_X) and numToGrid(mouseOldY) ~= numToGrid(MOUSE_Y) then
			netDrawLine(mouseOldX, mouseOldY, MOUSE_X, MOUSE_Y)
			drawLine(mouseOldX, mouseOldY, MOUSE_X, MOUSE_Y)
			mouseOldX = MOUSE_X
			mouseOldY = MOUSE_Y
		end
	elseif ModeManager:isMode('Erasing') then
		paint(MOUSE_X, MOUSE_Y, true)
		if mouseOldX == nil or mouseOldY == nil then
			mouseOldX = MOUSE_X
			mouseOldY = MOUSE_Y
		end
			drawLine(mouseOldX, mouseOldY, MOUSE_X, MOUSE_Y, true)
			mouseOldX = MOUSE_X
			mouseOldY = MOUSE_Y
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

	if Network:isServer() == 1 then
		love.graphics.print('server', 0, 0)
	else
		love.graphics.print('client', 0, 0)
	end



	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', WINDOW_WIDTH - 20 - colorOutlineWidth, WINDOW_HEIGHT - 20 - colorOutlineWidth, 30 + colorOutlineWidth * 2, 30 + colorOutlineWidth * 2)
	love.graphics.setColor(colors[currentColor])
	love.graphics.rectangle('fill', WINDOW_WIDTH - 20, WINDOW_HEIGHT - 20, 30, 30)
end


function love.keypressed(key, isrepeat)
	if key == 'g' then 
		Grid.bGridLines = not Grid.bGridLines
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
		exitDraggingMode()
		ModeManager:setMode('Drawing')
	elseif key == 'c' then
		nextColor()
	elseif key == 'b' then
		Network:connect()
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
		mouseOldX = nil
		mouseOldY = nil
	elseif key == 'e' then
		ModeManager:setMode('none')
		mouseOldX = nil
		mouseOldY = nil
	end
end


function paint(x, y, erase)
	if coordToGrid(x, y) ~= nil and Grid:getState(x, y, true) ~= 1 then
		print('drawing!!!!')
		Grid:paint(x, y, colors[currentColor], erase, true)
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








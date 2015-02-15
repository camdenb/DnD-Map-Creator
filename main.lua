Class = require 'lib/hump-master/class'
Camera = require 'lib/hump-master/camera'
Timer = require 'lib/hump-master/timer'
Lube = require 'lib/LUBE/LUBE'

require 'lib/Tserial'
loveframes = require 'lib.loveframes'

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
require 'GUI'
require 'Message'
require 'Options'

local startLine
local sX, sY

local dragDiffX, dragDiffY = 0, 0

local tokenSnapping = true

local selectedToken = nil
local hoveredToken = nil


lastState = nil

availableMaps = {}

gamePaused = false

drawingFog = false

tokensGrouped = false

mouseOldX, mouseOldY = nil, nil

currentColor = 1

local colorOutlineWidth = 5

function love.load(args)

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	tokenFont = love.graphics.newFont('lib/SourceCodePro-Regular.otf', 20)
	messageFont = love.graphics.newFont('lib/SourceCodePro-Regular.otf', 15)
	debugFont = love.graphics.newFont(12)
	smallFont = love.graphics.newFont(9)

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=true, vsync=enableVsync, fsaa=0})

	Message = Message()

	Network = Network('localhost', 9999, tonumber(args[2]) or 0)
	if forceToServerMode then
		Network.isServerNum = 1
	end
	Network:load()
	Network:connect()

	local networkTypeString = ''
	if Network.isServerNum == 1 then
		networkTypeString = 'Server'
	else
		networkTypeString = 'Client'
	end

	love.window.setTitle('Dungeons & Dragons Map Explorer - ' .. networkTypeString)

	Grid = Grid()
	GUI = GUI()

	ModeManager = ModeManager()

	TokenFactory = TokenFactory()
	

	camera = Camera((Grid.gridSize / 2) * Grid:getScale(), (Grid.gridSize / 2) * Grid:getScale())

	-- TokenFactory:addToken(20, 20, 3, {255, 200, 0, 235}, 'Yorril', true)
	-- TokenFactory:addToken(100, 250, 3, {125, 125, 0, 235}, 'Kenneth', true)
	-- TokenFactory:addToken(300, 120, 3, {255, 125, 0, 235}, 'Goldar', true)
	-- TokenFactory:addToken(25, 255, 3, {0, 255, 125, 235}, 'Felyrn', true)
	-- TokenFactory:addToken(120, 150, 3, {200, 255, 125, 235}, 'Dasireth', true)

	-- TokenFactory:tokensToString()

	if tokenSnapping then
		realignTokens()
	end

	TokenFactory:updateTokenFogEvents(Grid)

	love.filesystem.setIdentity('Map Explorer')

	if not love.filesystem.exists('/maps') then
		love.filesystem.createDirectory('/maps')
	end

	availableMaps = love.filesystem.getDirectoryItems('/maps')

	if Network.isServerNum == 1 then
		fogOpacity = 150
		tokenOpacityWhenHidden = 70
	end



	if tonumber(args[3]) == 1 then
		takeScreenshot()
	end
end

function love.update(dt)

	Timer.update(dt)

	loveframes.update(dt)

	Network:update(dt)

	if limitFPS and dt < 1/60 then
		love.timer.sleep(1/60 - dt)
   	end

   	MOUSE_X, MOUSE_Y = camera:mousepos()

   	if not gamePaused then

		hoveredToken = getHoveredToken()

		if ModeManager:isMode('Dragging') then
			local newX = MOUSE_X - dragDiffX
			local newY = MOUSE_Y - dragDiffY
			if tokensGrouped then
				TokenFactory:movePlayerTokens(newX, newY)
			else
				selectedToken.x = newX
				selectedToken.y = newY
			end
		end

		if ModeManager:isMode('Drawing') then
			if not drawingFog then 
				paint(MOUSE_X, MOUSE_Y, false, 1)
			end
			if mouseOldX == nil or mouseOldY == nil then
				mouseOldX = MOUSE_X
				mouseOldY = MOUSE_Y
			elseif numToGrid(mouseOldX) ~= numToGrid(MOUSE_X) or numToGrid(mouseOldY) ~= numToGrid(MOUSE_Y) then
				drawLine(mouseOldX, mouseOldY, MOUSE_X, MOUSE_Y)
			end
				mouseOldX = MOUSE_X
				mouseOldY = MOUSE_Y
		elseif ModeManager:isMode('Erasing') then
			if not drawingFog then 
				paint(MOUSE_X, MOUSE_Y, true)
			end
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
end

function love.draw()


	camera:attach()

	Grid:draw()
	TokenFactory:draw(Grid)

	camera:detach()

	loveframes.draw()

	-----------------------------------------

	love.graphics.setColor(0, 0, 0)

	Message:drawMessages()

	love.graphics.setFont(debugFont)

	if hoveredToken ~= nil then
		printString(hoveredToken.name, 10, 10)
	end

	printString("FPS: "..tostring(love.timer.getFPS( )), 10, 30)

	printString(math.floor(MOUSE_X) .. " " .. math.floor(MOUSE_Y), 200, 10)
	printString(numToGrid(MOUSE_X) .. " " .. numToGrid(MOUSE_Y), 200, 25)

	if Network:isServer() == 1 then
		printString('server', 0, 0)
	else
		printString('client', 0, 0)
	end

	if ModeManager:isMode('Drawing') then
		printString('drawing', WINDOW_WIDTH - 200, 10)
	elseif ModeManager:isMode('Erasing') then
		printString('erasing', WINDOW_WIDTH - 200, 10)
	end

	love.graphics.setFont(messageFont)

	if drawingFog then
		printString('[Fog]', WINDOW_WIDTH - 60, 10, true)
	else
		printString('[Nrm]', WINDOW_WIDTH - 60, 10, true)
	end

	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle('fill', WINDOW_WIDTH - 20 - colorOutlineWidth, WINDOW_HEIGHT - 20 - colorOutlineWidth, 30 + colorOutlineWidth * 2, 30 + colorOutlineWidth * 2)
	love.graphics.setColor(colors[currentColor])
	love.graphics.rectangle('fill', WINDOW_WIDTH - 20, WINDOW_HEIGHT - 20, 30, 30)
end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.keypressed(key, isrepeat)

	loveframes.keypressed(key)

	if GUI.textDisabled then

	elseif key == 'a' then
		GUI:loadGridDialog()

	elseif key == 'b' then
		Network:connect()

	elseif key == 'c' then
		prevColor()

	elseif key == 'd' then
		exitDraggingMode()
		ModeManager:setMode('Drawing')
	
	elseif key == 'e' then
		ModeManager:setMode('Erasing')

	elseif key == 'f' then
		fogEnabled = not fogEnabled
	
	elseif key == 'g' then 
		Grid.bGridLines = not Grid.bGridLines
	
	elseif key == 'j' then
		if not startLine then
			startLine = true
			sX = MOUSE_X
			sY = MOUSE_Y
		else
			drawRectangle(sX, sY, MOUSE_X, MOUSE_Y, true)
			netDrawRectangle(sX, sY, MOUSE_X, MOUSE_Y, true)
			TokenFactory:updateTokenFogEvents(Grid)
			startLine = false
		end
	
	elseif key == 'k' then
		if not startLine then
			startLine = true
			sX = MOUSE_X
			sY = MOUSE_Y
		else
			drawRectangle(sX, sY, MOUSE_X, MOUSE_Y, false)
			netDrawRectangle(sX, sY, MOUSE_X, MOUSE_Y, false)
			TokenFactory:updateTokenFogEvents(Grid)
			startLine = false
		end
	
	elseif key == 'l' then
		if not startLine then
			startLine = true
			sX = MOUSE_X
			sY = MOUSE_Y
		else
			drawLine(sX, sY, MOUSE_X, MOUSE_Y)
			TokenFactory:updateTokenFogEvents(Grid)
			startLine = false
		end
	
	elseif key == 'm' then
		tokenSnapping = not tokenSnapping

	elseif key == 'n' then
		Grid:clearGrid()

	elseif key == 'r' then
		tokensGrouped = not tokensGrouped
		if tokensGrouped then
			Message:displayMessage('Tokens are now grouped')
		else
			Message:displayMessage('Tokens are now ungrouped')
		end

	elseif key == 's' then
		GUI:saveGridDialog()

	elseif key == 't' then
		GUI:newTokenDialog()

	elseif key == 'v' then
		nextColor()

	elseif key == 'y' then
		GUI:deleteTokenDialog()

	elseif key == 'z' then
		undo()

	elseif key == 'rshift' then
		drawingFog = not drawingFog
		netSetDrawingFog(drawingFog)
	
	elseif key == '-' then
		netSendSimpleType(12)
		zoomOut()
	
	elseif key == '=' then
		netSendSimpleType(11)
		zoomIn()
	end
end

function love.keyreleased(key, isrepeat)

	loveframes.keyreleased(key)

	if key == 'd' and not ModeManager:isMode('Dragging') then
		TokenFactory:updateTokenFogEvents(Grid)
		ModeManager:setMode('none')
		mouseOldX = nil
		mouseOldY = nil
	elseif key == 'e' then
		TokenFactory:updateTokenFogEvents(Grid)
		ModeManager:setMode('none')
		mouseOldX = nil
		mouseOldY = nil
	elseif key == 'lshift' then
		netSendCameraPosition(camera:worldCoords(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2))
	end
end

function love.textinput(text)
	loveframes.textinput(text)
end

function love.mousepressed(x, y, button)

	loveframes.mousepressed(x, y, button)
	
	if love.keyboard.isDown('lshift') then
		local xx, yy = camera:pos()
		camera:move(MOUSE_X - xx, MOUSE_Y - yy)
	elseif getHoveredToken() ~= nil then
		selectedToken = getHoveredToken()
		enterDraggingMode(MOUSE_X, MOUSE_Y)
	end
end

function love.mousereleased(x, y, button)

	loveframes.mousereleased(x, y, button)

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
		if tokensGrouped then
			TokenFactory:alignPlayersToGrid()
		else
			alignTokenToGrid(selectedToken)
		end
		TokenFactory:updateTokenFogEvents(Grid)
	end
end








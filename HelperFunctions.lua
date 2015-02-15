function takeScreenshot()
	Message:displayMessage('Took screenshot.', 1)
	scrot = love.graphics.newScreenshot()
	scrot:encode(os.date('%m-%d_%H-%M-%S') .. '.png', 'png')
end

function saveTokensAndGrid()
	local saveStr = Grid:gridToString() .. TokenFactory:tokensToString()
	love.filesystem.write('/maps/' .. os.date('%m-%d-%Y_%I%p-%M%S') .. '.txt', saveStr)
	Message:displayMessage('grid saved as: ' .. os.date('%m-%d-%Y_%I%p-%M%S') .. '.txt', 4)
end

function saveGrid(name)
	--love.filesystem.write('/maps/' .. os.date('%m-%d-%Y_%I%p-%M%S') .. '.txt', Grid:gridToString())
	Grid:saveGridWithCoords(name)
	Message:displayMessage('Grid saved as: ' .. name .. '.txt', 3)
	availableMaps = love.filesystem.getDirectoryItems('/maps')
end

function loadGrid(fileString, fromString)

	if string.sub(fileString, 1, 1) == '.' then
		return
	end

	if not fromString then
		fileString = tostring(fileString)
		Message:displayMessage('Loading ' .. fileString, 2)
		contents = love.filesystem.read('/maps/' .. fileString)
	else
		contents = fileString
	end

	local len = string.len(contents)

	Grid:clearGrid()

	for i = 1, len, 20 do
		local str = string.sub(contents, i, i + 19)
		local x = string.sub(str, 1, 4)
		local y = string.sub(str, 5, 8)
		local color = string.sub(str, 9, 20)

		Grid:paint(tonumber(x), tonumber(y), stringToColor(color))
	end
	if fromString then
		Message:displayMessage('Undid', 1)
	else
		Message:displayMessage('Loaded ' .. fileString, 2)
	end
end

function loadTokens(tokenString)

end

function realignTokens()
	for i, token in ipairs(TokenFactory:getTokens()) do
		alignTokenToGrid(token)
	end
end

function alignTokenToGrid(token)
	token.x = roundToMultiple(token.x, round(Grid:getScale() * gridSnapRatio))
	token.y = roundToMultiple(token.y, round(Grid:getScale() * gridSnapRatio))
	netUpdateTokenPosition(token.id, token.x, token.y)
end

function round(num)
	return roundToMultiple(num, 1)
end

function roundToMultiple(num, mult)
	return math.floor((num / mult) + 0.5) * mult
end

function coordInRect(x, y, rx, ry, rw, rh)
	if x >= rx and x <= rx + rw and y >= ry and y <= ry + rh then
		return true
	else
		return false
	end
end

function numToGrid(coordNum)
	
	return math.floor(coordNum / Grid:getScale())

end

function numFromGrid(gridNum)
	return Grid:getScale() * gridNum
end

function checkValidityOfPoint(x, y)
	if numToGrid(x) < Grid.GRID_LOWERBOUND or numToGrid(x) > Grid.GRID_UPPERBOUND or numToGrid(y) < Grid.GRID_LOWERBOUND or numToGrid(y) > Grid.GRID_UPPERBOUND then
		return nil
	else
		return true
	end
end

function getCellFromCoord(x, y)
	if numToGrid(x) < Grid.GRID_LOWERBOUND or numToGrid(x) > Grid.GRID_UPPERBOUND or numToGrid(y) < Grid.GRID_LOWERBOUND or numToGrid(y) > Grid.GRID_UPPERBOUND then
		return nil
	end
	return Grid:getCell(x, y, true)
end

function getHoveredToken()

	local smallestToken = nil
	local smallestTokenSize = 100

	for i,token in ipairs(TokenFactory:getTokens()) do
		if coordInRect(MOUSE_X, MOUSE_Y, token.x, token.y, token.scale * Grid:getScale(), token.scale * Grid:getScale()) then
			if smallestToken == nil or token.scale < smallestTokenSize then
				smallestToken = token
				smallestTokenSize = token.scale
			end
		end
	end

	return smallestToken
end
	
function getWorldCoords(num, str, limitToGrid)
	local x, y = camera:worldCoords(num, num)
	if str == 'X' then
		if limitToGrid then
			if numToGrid(x) >= Grid.gridSize then
				x = Grid.gridSize * Grid:getScale() - 1
			elseif x <= 10 then
				x = 10
			end
		end
		return x
	elseif str == 'Y' then
		if limitToGrid then
			if numToGrid(y) >= Grid.gridSize then
				y = Grid.gridSize * Grid:getScale() - 1
			elseif y <= 10 then
				y = 10
			end
		end
		return y
	end
end

function getCamCoords(num, str)
	local x, y = camera:cameraCoords(num, num)
	if str == 'X' then
		return x
	elseif str == 'Y' then
		return y
	end
end

function drawLine(sx, sy, ex, ey, erase, size)
	local size = size or 1

	-- for x = sx - numFromGrid(size - 1), sx + numFromGrid(size - 1), Grid:getScale() do
	-- 	for y = sy - numFromGrid(size - 1), sy + numFromGrid(size - 1), Grid:getScale() do
	-- 		drawLineBase(x, y, x, y, erase)
	-- 		-- Grid:paint(x, y, {255, 0, 0}, false, true)
	-- 		-- Grid:paint(endX, endY, {255, 255, 0}, false, true)
	-- 	end
	-- end

	if size ~= 1 then
		local tsx = sx - numFromGrid(size - 1)
		local tsy = sy - numFromGrid(size - 1)
		local tex = ex - numFromGrid(size - 1)
		local tey = ey - numFromGrid(size - 1)
		for i = 0, (size * 2 - 1) * 1, 1 do
			drawLineBase(tsx, tsy, tex, tey)
			tsx = tsx + Grid:getScale()
			tsy = tsy + Grid:getScale()
			tex = tex + Grid:getScale()
			tey = tey + Grid:getScale()
		end
	else
		drawLineBase(sx, sy, ex, ey, erase)
	end

	-- for x = ex - numFromGrid(size - 1), ex + numFromGrid(size - 1), Grid:getScale() do
	-- 	for y = ey - numFromGrid(size - 1), ey + numFromGrid(size - 1), Grid:getScale() do
	-- 		drawLineBase(x, y, ex + numFromGrid(size - 1), ey + numFromGrid(size - 1), erase)
	-- 		--Grid:paint(x, y, {255, 0, 0}, false, true)
	-- 	end
	-- end

end

function drawLineBase(sx, sy, ex, ey, erase)

	if not checkValidityOfPoint(sx, sy) or not checkValidityOfPoint(ex, ey) then
		return nil
	end


	local startX, startY = numToGrid(sx), numToGrid(sy)
	local endX, endY = numToGrid(ex), numToGrid(ey)

	local slopeX = endX - startX
	local slopeY = endY - startY


	if math.abs(slopeX) <= math.abs(slopeY) then
		slopeX = slopeX / math.abs(slopeY)
		slopeY = slopeY / math.abs(slopeY)
	else
		slopeY = slopeY / math.abs(slopeX)
		slopeX = slopeX / math.abs(slopeX)	
	end

	if math.abs(slopeX) <= math.abs(slopeY) then	
		local x = startX
		for y = startY, endY, slopeY do
			Grid:paint(round(x), round(y), colors[currentColor], erase)
			x = x + slopeX
		end
	else
		local y = startY
		for x = startX, endX, slopeX do
			Grid:paint(round(x), round(y), colors[currentColor], erase)
			y = y + slopeY
		end
	end
end

function drawRectangle(sx, sy, ex, ey, fill, erase)
	
	if not checkValidityOfPoint(sx, sy) or not checkValidityOfPoint(ex, ey) then
		return nil
	end

	xjump, yjump = 1, 1

	if(sx > ex) then
		xjump = -xjump
	end

	if(sy > ey) then
		yjump = -yjump
	end

	local startX, startY = numToGrid(sx), numToGrid(sy)
	local endX, endY = numToGrid(ex), numToGrid(ey)


	for x = startX, endX, xjump do
		for y = startY, endY, yjump do
	
			if not fill then		
				if x == startX or y == startY or x == endX or y == endY then
					Grid:paint(round(x), round(y), colors[currentColor], erase, false, false)
				end
			else
				Grid:paint(round(x), round(y), colors[currentColor], erase, false, false)
			end

		end
	end
end

function nextColor()
	if currentColor == #colors then
		currentColor = 1
	else
		currentColor = currentColor + 1
	end

	netSetCurrentColor(currentColor)
end

function prevColor()
	if currentColor == 1 then
		currentColor = #colors
	else
		currentColor = currentColor - 1
	end

	netSetCurrentColor(currentColor)
end

function separateTablesFromString(str)

	local tables = {}
	local beginIndex = 0

	for i = 1, string.len(str), 1 do
		substr = string.sub(str, i, i)
		if substr == '{' then
			beginIndex = i
		elseif substr == '}' then
			table.insert(tables, string.sub(str, beginIndex, i))
		end
	end

	for i,v in ipairs(tables) do
		--print(v)
		loadstring('newTable = ' .. v)()
		local t = newTable
		newTable = nil
		tables[i] = t
	end

	return tables
end

function distSquaredBetweenGridCells(c1, c2)

	--return math.abs(c1.x - c2.x) + math.abs(c1.y - c2.y)
	return math.pow(c1.x - c2.x, 2) + math.pow(c1.y - c2.y, 2)

end

function printString(str, x, y, ignoreHidden)
	if showDebugMessages or ignoreHidden then
		love.graphics.print(str, x, y)
	end
end

function undo()
	--loadGrid(lastState, true)
end

function paint(x, y, erase, size)
	if getCellFromCoord(x, y) ~= nil then
		Grid:paint(x, y, colors[currentColor], erase, true, nil, size)
	end
end

function zoomIn()
	camera:zoom(1.1)
end

function zoomOut()
	camera:zoom(0.9)
end








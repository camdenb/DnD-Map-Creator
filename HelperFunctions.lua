function takeScreenshot()
	print('Took screenshot.')
	scrot = love.graphics.newScreenshot()
	scrot:encode(os.date('%m-%d_%H-%M-%S') .. '.png', 'png')
	--love.filesystem.write('', scrot)
end

function saveGrid()
	love.filesystem.write('/maps/' .. os.date('%b-%d-%Y_%I%p-%M%S') .. '.txt', Grid:gridToString())
	print('grid saved as: ' .. os.date('%b-%d-%Y_%I%p-%M%S') .. '.txt')
end

function loadGrid(fileString)
	fileString = tostring(fileString)
	print('loading ' .. fileString)
	local contents = love.filesystem.read('/maps/' .. fileString)
	local len = string.len(contents)

	for i = 0, len - 1, 13 do
		local x = math.floor((i / 13) / Grid.gridSize)
		local y = (i / 13) % Grid.gridSize

		local state = Grid:setState(x, y, string.sub(contents, i + 1, i + 1), false)
		if state == 1 then
			Grid:paint(x, y, stringToColor(string.sub(contents, i + 2, i + 14)), false, false)
		end
	end
end

function realignTokens()
	for i, token in ipairs(TokenFactory:getTokens()) do
		alignTokenToGrid(token)
	end
end

function alignTokenToGrid(token)
	token.x = roundToMultiple(token.x, round(Grid:getScale() * gridSnapRatio))
	token.y = roundToMultiple(token.y, round(Grid:getScale() * gridSnapRatio))
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

function numToGrid(num)
	
	return math.floor(num / Grid:getScale())

end

function checkValidityOfPoint(x, y)
	if numToGrid(x) < Grid.GRID_LOWERBOUND or numToGrid(x) > Grid.GRID_UPPERBOUND or numToGrid(y) < Grid.GRID_LOWERBOUND or numToGrid(y) > Grid.GRID_UPPERBOUND then
		return nil
	else
		return true
	end
end

function coordToGrid(x, y)
	if numToGrid(x) < Grid.GRID_LOWERBOUND or numToGrid(x) > Grid.GRID_UPPERBOUND or numToGrid(y) < Grid.GRID_LOWERBOUND or numToGrid(y) > Grid.GRID_UPPERBOUND then
		return nil
	end
	return Grid.grid[numToGrid(x)][numToGrid(y)]
end

function getHoveredToken()

	for i,token in ipairs(TokenFactory:getTokens()) do
		if coordInRect(MOUSE_X, MOUSE_Y, token.x, token.y, token.scale * Grid:getScale(), token.scale * Grid:getScale()) then
			return token
		end
	end

	return nil
end

function getWorldCoords(num, str)
	local x, y = camera:worldCoords(num, num)
	if str == 'X' then
		return x
	elseif str == 'Y' then
		return y
	end
end

function drawLine(sx, sy, ex, ey, erase)

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

function drawRectangle(sx, sy, ex, ey, fill)
	
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
			
			if x == startX or y == startY or x == endX or y == endY then
				Grid:paint(round(x), round(y), colors[currentColor])
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
end




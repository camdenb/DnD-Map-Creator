function realignTokens()
	for i, token in ipairs(TokenFactory:getTokens()) do
		alignTokenToGrid(token)
	end
end

function alignTokenToGrid(token)
	token.x = roundToMultiple(token.x, Grid:getScale())
	token.y = roundToMultiple(token.y, Grid:getScale())
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

function coordToGrid(x, y)
	if numToGrid(x) < Grid.GRID_LOWERBOUND or numToGrid(x) > Grid.GRID_UPPERBOUND or numToGrid(y) < Grid.GRID_LOWERBOUND or numToGrid(y) > Grid.GRID_UPPERBOUND then
		return nil
	end
	return Grid.grid[numToGrid(x)][numToGrid(y)]
end

function getHoveredToken()

	for i,token in ipairs(TokenFactory:getTokens()) do
		if coordInRect(MOUSE_X, MOUSE_Y, token.x, token.y, token.scale * Grid:getScale(), token.scale * Grid:getScale()) then
			hoveredToken = token
			return token
		end
	end

	hoveredToken = nil
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






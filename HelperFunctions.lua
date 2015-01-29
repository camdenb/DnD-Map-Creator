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

function numToGrid(num, round)
	
	return math.floor(num / Grid:getScale())

	-- if num <= 0 then
	-- 	return math.floor(num / Grid:getScale())
	-- else
	-- 	return math.ceil(num / Grid:getScale())
	-- end

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

function drawLine(sx, sy, ex, ey)

end

function drawRectangle(sx, sy, ex, ey)
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
				Grid:setFilled(x, y, false)
			end

		end
	end
end






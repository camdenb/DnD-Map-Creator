TokenFactory = Class{}

function TokenFactory:init()
	print('TokenFactory has been initialized')

	self.tokens = {}

end



function TokenFactory:addToken(x, y, scale, color, name, isPlayer)

	x = getWorldCoords(x, 'X')
	y = getWorldCoords(y, 'Y')

	netAddToken(x, y, scale, color, name, isPlayer)

	local token = Token(x, y, scale, color, name, isPlayer)

	table.insert(self.tokens, token)

	return token

end

function TokenFactory:getTokens()
	return self.tokens
end

function TokenFactory:draw(grid)
	for i, token in ipairs(self.tokens) do
		love.graphics.setColor(token.color)
		--love.graphics.rectangle('fill', token.x, token.y, grid:getScale() * token.scale, grid:getScale() * token.scale)
		local halfScale = (grid:getScale() * token.scale) / 2
		love.graphics.circle('fill', token.x + halfScale, token.y + halfScale, halfScale)
		love.graphics.setColor(0, 0, 0, 150)
		love.graphics.setFont(tokenFont)
		if Network.isServerNum == 1 or not token:shouldBeHidden(grid) then
			love.graphics.printf(token.name, token.x, token.y + grid:getScale() * token.scale, grid:getScale() * token.scale, 'center')
		end
	end
end

function TokenFactory:tokensToString()
	local tokenStr = ''
	for i, token in ipairs(self.tokens) do
		tokenStr = tokenStr .. token.x .. ',' .. token.y .. ',' .. token.scale .. ',' .. token.color[1] .. ',' .. token.color[2] .. ','.. token.color[3] .. ','.. token.color[4] .. ',' .. token.name
		if i ~= #self.tokens then
			tokenStr = tokenStr .. ','
		end
	end
	print(tokenStr)
end

function TokenFactory:updateTokenFogEvents(grid)
	netSendSimpleType(7)
	for i, token in ipairs(self.tokens) do
		token:updateFogEvents(grid)
	end
end

function TokenFactory:getTokenByName(name)
	for i, token in ipairs(self.tokens) do
		if name == token.name then
			return token
		end
	end
end

function TokenFactory:getTokenByID(id)
	for i, token in ipairs(self.tokens) do
		if id == token.id then
			return token
		end
	end
end

function TokenFactory:updateTokenPos(id, x, y)
	local t = self:getTokenByID(id)
	if t then	
		t.x = x
		t.y = y
	end
end

function TokenFactory:deleteToken(token)

	netDeleteToken(token.id)

	for i = #self.tokens, 1, -1 do
		local t = self.tokens[i]
		if self:areTokensEqual(t, token) then
			table.remove(self.tokens, i)
			print('Token Deleted: ' .. token.name)
		end
	end
end

function TokenFactory:areTokensEqual(t1, t2)
	if t1.name == t2.name and t1.color == t2.color and t1.scale == t2.scale then
		return true
	else
		return false
	end
end

function TokenFactory:movePlayerTokens(x, y)
	for i,token in ipairs(self.tokens) do
		if token.isPlayer then
			token.x = x
			token.y = y
		end
	end
end

function TokenFactory:alignPlayersToGrid()
	for i,token in ipairs(self.tokens) do
		if token.isPlayer then
			alignTokenToGrid(token)
		end
	end
end
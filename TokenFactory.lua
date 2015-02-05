TokenFactory = Class{}

function TokenFactory:init()
	print('TokenFactory has been initialized')

	self.tokens = {}

end



function TokenFactory:addToken(x, y, scale, color, name)

	x = getWorldCoords(x, 'X')
	y = getWorldCoords(y, 'Y')

	local token = Token(x, y, scale, color, name)

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
		love.graphics.printf(token.name, token.x, token.y + grid:getScale() * token.scale, grid:getScale() * token.scale, 'center')
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

function TokenFactory:hideTokensIfInFog(grid)
	for i, token in ipairs(self.tokens) do
		token:hideIfInFog(grid)
	end
end














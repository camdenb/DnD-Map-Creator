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
		love.graphics.setColor(100, 100, 100)
		love.graphics.printf(token.name, token.x, token.y + grid:getScale() * token.scale, grid:getScale() * token.scale, 'center')
	end
end


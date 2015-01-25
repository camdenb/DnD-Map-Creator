TokenFactory = class('TokenFactory')

function TokenFactory:initialize()
	print('TokenFactory has been initialized')

	self.tokens = {}

end



function TokenFactory:addToken(x, y, scale, color, name)

	local token = Token:new(x, y, scale, color, name)

	table.insert(self.tokens, token)

	return token

end

function TokenFactory:getTokens()
	return self.tokens
end

function TokenFactory:draw(grid)
	for i, token in ipairs(self.tokens) do
		love.graphics.setColor(token.color)
		love.graphics.rectangle('fill', token.x, token.y, grid:getScale() * token.scale, grid:getScale() * token.scale)
	end
end
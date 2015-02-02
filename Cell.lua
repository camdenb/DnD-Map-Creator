Cell = Class{}

function Cell:init(x, y, state)
	self.x = x
	self.y = y
	self.state = state
	self.color = {0,0,0}
end

function Cell:getState()

	if self.state == 0 then
		return 0
	elseif self.state == 1 then
		return 1
	end

end

function Cell:setState(state)

	self.state = tonumber(state)
	return self.state
	
end

function Cell:paint(color, erase)
	if color ~= self.color and self.state ~= 1 then
		netPaint(self.x, self.y, erase, false)
	end
	self.color = color
	if erase then
		self.state = 0
	else
		self.state = 1
	end
end

function Cell:setColor(color)
	self.color = color
end

function Cell:getColor()
	return self.color
end


Cell = class('Cell')

function Cell:initialize(x, y, state)
	self.x = x
	self.y = y
	self.state = state
	self.color = {0,0,0}
end

function Cell:getState(numForm)

	if numForm == nil or false then
		return self.state
	end

	if numForm then
		if self.state == 'none' then
			return 0
		elseif self.state == 'filled' then
			return 1
		end
	end

	return self.state

end

function Cell:setState(state)

	if tonumber(state) == 0 then
		self.state = 'none'
	elseif tonumber(state) == 1 then
		self.state = 'filled'
	elseif state == false then
		self.state = 'none'
	elseif state == true then
		self.state = 'filled'
	else
		self.state = state
	end
end

function Cell:paint(color, erase)
	self.color = color
	if erase then
		self.state = 'none'
	else
		self.state = 'filled'
	end
end

function Cell:setColor(color)
	self.color = color
end

function Cell:getColor()
	return self.color
end


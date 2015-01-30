Cell = class('Cell')

function Cell:initialize(x, y, state)
	self.x = x
	self.y = y
	self.state = state
	self.color = nil
end

function Cell:getState()
	return self.state
end

function Cell:setState(state)
	if state == false then
		self.state = 'none'
	elseif state == true then
		self.state = 'filled'
	else
		self.state = state
	end
end
Cell = Class{}

function Cell:init(x, y, state)
	self.x = x
	self.y = y
	self.state = state
	self.color = {0,0,0}
	self.fogged = true
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
	if Network.connected then
		netPaint(self.x, self.y, erase, false, color)
	end
	if not drawingFog then
		self.color = color
		if erase then
			self.state = 0
		else
			self.state = 1
		end
	else
		if erase then
			self.fogged = false
		else
			self.fogged = true
		end
	end
end


function Cell:setColor(color)
	self.color = color
end

function Cell:getColor()
	return self.color
end


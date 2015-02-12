Message = Class{}

function Message:init()

	self.displayingMessage = false
	self.currentMessage = ''

end

function Message:displayMessage(str, seconds)
	self.displayingMessage = true
	self.currentMessage = str
	Timer.clear()
	Timer.add(seconds, function() self:cancelMessage() end)
end

function Message:cancelMessage()
	self.displayingMessage = false
end

function Message:drawMessages()
	if self.displayingMessage then
		love.graphics.setFont(messageFont)
		love.graphics.setColor(0,0,0)
		printString(self.currentMessage, 10, WINDOW_HEIGHT - 25, true)
	end
end
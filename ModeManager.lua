ModeManager = Class{}

function ModeManager:init()
	print('ModeManager has been initialized')

	self.modes = {
		Mode('none'),
		Mode('Drawing'),
		Mode('Dragging'),
		Mode('Erasing')
	}

	self.currentMode = self.modes[1]

end

function ModeManager:getCurrentMode()
	return self.currentMode.name
end

function ModeManager:isMode(nameOfMode)
	return self.currentMode == ModeManager:getModeByName(nameOfMode)
end

function ModeManager:setMode(name)
	local isSame = self.currentMode == ModeManager:getModeByName(name)
	if not isSame then
		self.currentMode = ModeManager:getModeByName(name)
	end
end

function ModeManager:getModeByName(name)
	for i, mode in pairs(self.modes) do
		if mode.name == name then
			return mode
		end
	end
end


-- ------------------------------------------ --

Mode = Class{}

function Mode:init(name)
	self.name = name
end


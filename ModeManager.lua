ModeManager = class('ModeManager')

function ModeManager:initialize()
	print('ModeManager has been initialized')

	self.modes = {
		Mode:new('none'),
		Mode:new('Drawing'),
		Mode:new('Dragging'),
		Mode:new('Erasing')
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
	self.currentMode = ModeManager:getModeByName(name)
	print('current mode: ' .. ModeManager:getCurrentMode())
end

function ModeManager:getModeByName(name)
	for i, mode in pairs(self.modes) do
		if mode.name == name then
			return mode
		end
	end
end


-- ------------------------------------------ --

Mode = class('Mode')

function Mode:initialize(name)
	self.name = name
end


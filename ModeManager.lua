ModeManager = class('ModeManager')

function ModeManager:initialize()
	print('ModeManager has been initialized')

	self.modes

end

-- ------------------------------------------ --

Mode = class('Mode')

function Mode:initialize(id, name)
	self.id = id
	self.name = name
end
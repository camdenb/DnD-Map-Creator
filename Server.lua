Server = Class{}

-- Server:include(Network)

function Server:init()
	self.server = Lube.tcpServer()
end

function Server:load(host, port)
	print('server loaded')
	self.port = port
	self.server.callbacks.recv = function(d, id) self:receive(d, id) end
	self.server.callbacks.connect = function(id) self:connected(id) end
	self.server.callbacks.disconnect = function(id) self:disconnected(id) end
	self.server.handshake = '11'
end

function Server:update(dt)
	self.server:update(dt)
end

function Server:receive(data, id)

end

function Server:connected(id)
	print(id)
	--love.graphics.setBackgroundColor(255,240,240)
end

function Server:disconnected(id)
	print(id)
	--love.graphics.setBackgroundColor(240,240,240)
end

function Server:listen()
	print('server is listening on port ' .. self.port)
	self.server:listen(self.port)
end
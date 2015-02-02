Network = Class{}

function Network:init(host, port, isServerNum)
	self.host = host
	self.port = port
	self.isServerNum = isServerNum
	self.connection = nil
	self.server = nil
	self.client = nil
end

function Network:load()
	if self.isServerNum == 1 then
		print('server!')
		self.connection = Server()
		self.server = self.connection
	else
		print('client!')
		self.connection = Client()
		self.client = self.connection
	end

	self.connection:load(self.host, self.port)

end

function Network:update(dt)
	self.connection:update(dt)
end

function Network:connect()
	if self.isServerNum == 1 then
		self.server:listen(self.port)
	else
		self.client:connect(self.host, self.port)
	end
end

function Network:isServer()
	return self.isServerNum
end

function Network:send(data)
	if self.isServerNum == 1 then
		self.server.server:send(data)
	end
end




Client = Class{}

-- Client:include(Network)

function Client:init()
	self.client = Lube.tcpClient()
end

function Client:load(host, port)
	print('client loaded')
	self.client.callbacks.recv = function(d) self:receive(d) end
	self.host = host
	self.port = port
	self.client.handshake = '11'
end

function Client:update(dt)
	self.client:update(dt)
end

function Client:connect()
	print('trying to connect to ' .. self.host .. ':' .. self.port)
	print(self.client:connect(self.host, self.port, true))
end

function Client:receive(data)

	print(data, #separateTablesFromString(data))
		
	for i = 1, #separateTablesFromString(data), 1 do
		d = separateTablesFromString(data)[i] 
		local typeOfData = d[1]

		if typeOfData == 1 then
			local erase = d[2]
			local x = d[3]
			local y = d[4]
			local colorR, colorG, colorB, colorA = d[5], d[6], d[7], d[8]
			Grid:paint(x, y, {colorR, colorG, colorB, colorA}, erase, false)
		elseif typeOfData == 2 then
			local sx = d[2]
			local sy = d[3]
			local ex = d[4]
			local ey = d[5]
			local fill = d[6]
			local erase = d[7]
			drawRectangle(sx, sy, ex, ey, fill, erase)
		elseif typeOfData == 3 then
			Grid:clearGrid()
		elseif typeOfData == 4 then
			local id = d[2]
			local x = d[3]
			local y = d[4]
			TokenFactory:updateTokenPos(id, x, y)
		elseif typeOfData == 5 then
			local cellX = d[2]
			local cellY = d[3]
			local fogged = d[4]
			Grid:getCell(cellX, cellY):setFogged(fogged)
		elseif typeOfData == 6 then
			local drawFog = d[2]
			drawingFog = drawFog
		elseif typeOfData == 7 then
			TokenFactory:updateTokenFogEvents(Grid)
		elseif typeOfData == 8 then
			local x = d[2]
			local y = d[3]
			local scale = d[4]
			local c1 = d[5]
			local c2 = d[6]
			local c3 = d[7]
			local c4 = d[8]
			local name = d[9]
			local isPlayer = d[10]
			local t = TokenFactory:addToken(x, y, scale, {c1, c2, c3, c4}, name, isPlayer)
			TokenFactory:updateTokenPos(t.id, x, y)
		elseif typeOfData == 9 then
			local id = d[2]
			TokenFactory:deleteToken(TokenFactory:getTokenByID(id))
		end
	end

	

end










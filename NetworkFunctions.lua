
function netPaint(x, y, erase, convertNumsToGrid, color)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end
	color = color or {0,0,0,0}
	Network:send( Tserial.pack({1, erase, x, y, color[1], color[2], color[3], color[4]}) )
end

function netDrawRectangle(sx, sy, ex, ey, fill, erase)
	Network:send( Tserial.pack( {2, sx, sy, ex, ey, fill, erase} ) )
end

function netUpdateTokenPosition(tokenID, newX, newY)
	Network:send( Tserial.pack({ 4, tokenID, newX, newY }) )
end

function netSetFogged(cellX, cellY, fogged)
	Network:send( Tserial.pack({ 5, cellX, cellY, fogged }) )
end

function netSendSimpleType(type)
	Network:send( Tserial.pack( {type} ))
end
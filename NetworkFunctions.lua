
function netPaint(x, y, erase, convertNumsToGrid)
	if convertNumsToGrid then
		x = numToGrid(x)
		y = numToGrid(y)
	end
	Network:send( Tserial.pack({1, erase, x, y}) )
end

function netDrawLine(sx, sy, ex, ey)
	Network:send( Tserial.pack( {2, sx, sy, ex, ey} ) )
end

function netSendSimpleType(type)
	Network:send( Tserial.pack( {type} ))
end
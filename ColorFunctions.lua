function HSL(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function colorToString(color)
    
    local str = ''

    str = str .. string.format('%03s', color[1]) .. string.format('%03s', color[2]) .. string.format('%03s', color[3])

    if #color == 4 then
        str = str .. string.format('%03s', color[4])
    else
        str = str .. '255'
    end

    return str

end

function stringToColor(str)

    local color = {}

    color[1] = tonumber(string.sub(str, 1, 3))
    color[2] = tonumber(string.sub(str, 4, 6))
    color[3] = tonumber(string.sub(str, 7, 9))
    color[4] = tonumber(string.sub(str, 10, 12))

    return color

end

function multiplyColors(c1, c2)
    local newColor = {}

    newColor[1] = math.floor((c1[1] * c2[1]) / 255)
    newColor[2] = math.floor((c1[2] * c2[2]) / 255)
    newColor[3] = math.floor((c1[3] * c2[3]) / 255)

    return newColor

end

function darkenColors(c1, c2)
    local newColor = {}

    newColor[1] = math.min(c1[1], c2[1])
    newColor[2] = math.min(c1[2], c2[2])
    newColor[3] = math.min(c1[3], c2[3])
    
    return newColor
end









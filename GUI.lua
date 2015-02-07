GUI = Class{}

function GUI:init()
	self.textDisabled = false
end

function GUI:newTokenDialog()

	gamePaused = true

	self.textDisabled = true

	local color = {0, 0, 0, 255}
	local newTokenTable = {}

	local frame = loveframes.Create("frame")
	frame:SetName("New Token")
	frame:SetSize(300, 150)
	frame:SetPos(WINDOW_WIDTH / 2 - 150, WINDOW_HEIGHT / 2 - 75)
	frame.OnClose = function(object)
		gamePaused = false
		self.textDisabled = false
	end
	     
	local textinput_name = loveframes.Create("textinput", frame)
	textinput_name:SetPlaceholderText('Token Name')
	textinput_name:SetPos(5, 30)
	textinput_name:SetWidth(90)

	local text_isPlayer = loveframes.Create('text', frame)
	text_isPlayer:SetText('Player?')
	text_isPlayer:SetPos(200, 35)

	local checkbox_isPlayer = loveframes.Create('checkbox', frame)
	checkbox_isPlayer:SetChecked(true)
	checkbox_isPlayer:SetPos(250, 32)

	local text_scale = loveframes.Create('text', frame)
	text_scale:SetPos(5, 65)
	text_scale:SetText('Scale:')

	local numBox_scale = loveframes.Create("numberbox", frame)
	numBox_scale:SetWidth(60)
	numBox_scale:SetMin(1)
	numBox_scale:SetValue(2)
	numBox_scale:SetPos(50, 60)

	local text_color = loveframes.Create('text', frame)
	text_color:SetPos(5, 95)
	text_color:SetText('Color:')

	local numBox_color_r = loveframes.Create("numberbox", frame)
	numBox_color_r:SetWidth(60)
	numBox_color_r:SetMin(0)
	numBox_color_r:SetMax(255)
	numBox_color_r:SetPos(50, 90)
	numBox_color_r.OnValueChanged = function(object, value) 
		color[1] = value
	end

	local numBox_color_g = loveframes.Create("numberbox", frame)
	numBox_color_g:SetWidth(60)
	numBox_color_g:SetMin(0)
	numBox_color_g:SetMax(255)
	numBox_color_g:SetPos(110, 90)
	numBox_color_g.OnValueChanged = function(object, value) 
		color[2] = value
	end

	local numBox_color_b = loveframes.Create("numberbox", frame)
	numBox_color_b:SetWidth(60)
	numBox_color_b:SetMin(0)
	numBox_color_b:SetMax(255)
	numBox_color_b:SetPos(170, 90)
	numBox_color_b.OnValueChanged = function(object, value) 
		color[3] = value
	end

	local button_colorRandom = loveframes.Create('button', frame)
	button_colorRandom:SetText('Random')
	button_colorRandom:SetPos(230, 90)
	button_colorRandom:SetWidth(55)
	button_colorRandom:SetHeight(20)
	button_colorRandom.OnClick = function(object)
		math.randomseed( os.time() )
		numBox_color_r:SetValue(math.random(1, 255))
		numBox_color_g:SetValue(math.random(1, 255))
		numBox_color_b:SetValue(math.random(1, 255))
	end

	local colorbox = loveframes.Create("panel", frame)
	colorbox:SetPos(230, 110)
	colorbox:SetSize(55, 20)
	colorbox.Draw = function(object)
		love.graphics.setColor(color)
		love.graphics.rectangle("fill", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
		love.graphics.setColor(143, 143, 143, 255)
		love.graphics.setLineWidth(1)
		love.graphics.setLineStyle("smooth")
		love.graphics.rectangle("line", object:GetX(), object:GetY(), object:GetWidth(), object:GetHeight())
	end

	local button = loveframes.Create('button', frame)
	button:SetPos(5, 120)
	button:SetText('Done')
	button.OnClick = function(object)
		frame:Remove()
		gamePaused = false
		self.textDisabled = false	
	    TokenFactory:addToken(100, 100, numBox_scale:GetValue(), color, textinput_name:GetText(), checkbox_isPlayer:GetChecked())
	end

	textinput_name:SetFont(love.graphics.newFont(12))

end

function GUI:deleteTokenDialog()

	gamePaused = true

	self.textDisabled = true

	local frame = loveframes.Create("frame")
	frame:SetName("Delete Token")
	frame:SetSize(260, 60)
	frame:SetPos(WINDOW_WIDTH / 2 - 150, WINDOW_HEIGHT / 2 - 40)
	frame.OnClose = function(object)
		gamePaused = false
		self.textDisabled = false
	end

	local multichoice = loveframes.Create("multichoice", frame)
	multichoice:SetPos(5, 30)
	multichoice:SetWidth(150)
         
	for i,v in ipairs(TokenFactory.tokens) do
	    multichoice:AddChoice(v.name)
	end
	multichoice:SetChoice(TokenFactory.tokens[1].name)

	local button_delete = loveframes.Create('button', frame)
	button_delete:SetText('Delete Selected')
	button_delete:SetWidth(90)
	button_delete:SetPos(165, 30)
	button_delete.OnClick = function(object)
		local t = TokenFactory:getTokenByName(multichoice:GetChoice())
		TokenFactory:deleteToken(t)
		multichoice:Clear()

		if #TokenFactory.tokens > 0 then
			multichoice:SetChoice(TokenFactory.tokens[1].name)
			for i,v in ipairs(TokenFactory.tokens) do
		    	multichoice:AddChoice(v.name)
			end
		end
	end


end






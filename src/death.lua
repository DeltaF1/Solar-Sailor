local death = {}

messages = {
	sun = "{fuelS}, you plummeted towards the surface of the great star. {passengerS}, the end came swiftly"
}

function death:onStart(type)

	t = {}

	if type == "sun" then
		print("Death by sun!")
		if player.resources.fuel == 0 then
			t.fuelS = "Your engines sputtering"
		elseif player.resources.fuel < 1 then
			t.fuelS = "Your engines running out of fuel"
		else
			t.fuelS = "Despite the plentiful amounts of fuel"
		end
		
		if player.resources.passengers == 0 then
			t.passengerS = "Carrying yourself into the inferno alone"
		elseif player.resources.passengers == 1 then
			t.passengerS = "Carrying yourself and one brave soul into the inferno"
		else
			t.passengerS = "Carrying {passengers} brave souls into the inferno with you"
		end
	end
	
	s = string.replace(messages.sun, t)
	
	local dis = (player.pos-sun.pos):len()
	
	local info = table.merge({dis=dis, rDis=math.floor(dis),sector=states.game:sector(dis)}, player.resources)
	
	s = string.replace(s, info)
	
	self.text = TextBox(s, nil, Vector2(800,100), {align="center"}):center()
	self.text.colours.default[4] = 0
	
	Sequence{
		[function() StartLerp(self.text.colours.default, 4, 0, 255, 3) end] = 0,
		[function() StartLerp(self.text.colours.default, 4, 255, 0, 3) end] = 8,
		[function() EndState("menu") end] = 13
	}:start()
	
end

function death:draw()
	--love.graphics.set
	self.text:draw()
end

return death
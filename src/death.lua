local death = {}

local messages = {
	sun = "{fuelS}, you plummeted towards the surface of the great star. {passengerS}, the end came swiftly.",
	asteroid = "{speedS}. The last vestiges of oxygen slipping into space, {passengerS}.",
	win = "{speedS}, you made it out of the system. The great star's expansion slowing, you made it to the nearest warp gate, {passengerS}."
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
			t.fuelS = "Despite the plentiful amounts of fuel in your engines"
		end
		
		if player.resources.passengers == 0 then
			t.passengerS = "Carrying yourself into the inferno alone"
		elseif player.resources.passengers == 1 then
			t.passengerS = "Carrying yourself and one brave soul into the inferno"
		else
			t.passengerS = "Carrying {passengers} brave souls into the inferno with you"
		end
	elseif type == "asteroid" then
		
		print("death by asteroid")
		
		local vel = player.vel:len()
		
		if vel <=player.maxVel/2 then
			t.speedS = "Drifting listlessly through space, a stray asteroid smashed into the side of your vessel"
		elseif vel <= player.maxVel * (3/4) then
			t.speedS = "Cruising through the system, your reflexes failed you for a moment, and a massive asteroid slammed into the ship"
		else
			t.speedS = "Hurtling through the cosmos at ludicrous speeds, your split second reaction wasn't enough"
		end
		
		local passengers = player.resources.passengers
		
		if passengers == 0 then
			t.passengerS = "you died alone on the vessel you once called home"
		elseif passengers == 1 then
			t.passengerS = "your one passenger was flung from the craft, leaving you to your fate"
		else
			t.passengerS = "{passengers} people huddle together in the cargo hold, awaiting the void deeper than space"
		end
		
	elseif type == "win" then
		print("you won!")
		
		local vel = player.vel:len()
		
		if vel <= player.maxVel/2 then
			t.speedS = "Your engines sputtering, and your fuel dwindling"
		else
			t.speedS = "Racing to escape the star's approach"
		end
		
		local passengers = player.resources.passengers
		
		if passengers == 0 then
			s.passengerS = "guilt at the lives you left behind weighing heavily on your mind"
		elseif passengers == 1 then
			s.passengerS = "with but one companion by your side"
		else
			s.passengerS = "{passengers} grateful souls in tow"
		end
	end
	
	s = string.replace(messages[type], t)
	
	local dis = (player.pos-sun.pos):len()
	
	local info = update({dis=dis, rDis=math.floor(dis),sector=states.game:sector(dis)},player.resources)
	
	s = string.replace(s, info)
	
	self.text = TextBox(s, nil, Vector2(800,100), {align="center"}):center()
	self.text.colours.default[4] = 0
	
	self.timers = Sequence{
		[function() StartLerp(self.text.colours.default, 4, 0, 255, 3) end] = 0,
		[function() StartLerp(self.text.colours.default, 4, 255, 0, 3) end] = 7,
		[function() EndState("menu") end] = 10
	}:start()
	
end

function death:draw()
	--love.graphics.set
	self.text:draw()
end

return death
local death = {}

local messages = {
	sun = "{fuelS}, you plummeted towards the surface of the great star. {passengerS}, the end came swiftly.",
	asteroid = "{speedS}. The last vestiges of oxygen slipping into space, {passengerS}.",
	win = "{speedS}, you made it out of the system. The great star's expansion slowing, your warp drive activated, {passengerS}."
}

function death:load()
	--self.boom = love.audio.newSource("assets/sounds/cinematic_impact.mp3", "static")
end

function death:onStart(type)

	GAMEMUSIC:stop()
	--self.boom:stop()
	--self.boom:play()
	t = {}
	
	self.time = 3
	
	if type == "sun" then
		--print("Death by sun!")
		if player.resources.fuel == 0 then
			t.fuelS = "Your engines sputtering"
		elseif player.resources.fuel <= 3.5 then
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
		
		--print("death by asteroid")
		
		self.time = self.time + 2
		
		local vel = player.vel:len()
		
		if vel <=player.maxVel/2 then
			t.speedS = "Drifting listlessly, a stray asteroid smashed into the side of your vessel"
		elseif vel <= player.maxVel * (3/4) then
			t.speedS = "Cruising through the system, your reflexes failed you for a moment, and a massive asteroid slammed into the ship"
		else
			t.speedS = "Hurtling through the cosmos at ludicrous speeds, your split second reaction wasn't enough to avoid the asteroid"
		end
		
		local passengers = player.resources.passengers
		
		if passengers == 0 then
			t.passengerS = "you died alone on the vessel you once called home"
		elseif passengers == 1 then
			t.passengerS = "your one passenger was flung from the craft, leaving you to your fate"
		else
			self.time = self.time + 2
			t.passengerS = "{passengers} people huddle together in the cargo hold, awaiting the void deeper than space"
		end
		
	elseif type == "win" then
		--print("you won!")
		
		local vel = player.vel:len()
		
		if vel <= player.maxVel/2 then
			t.speedS = "Your engines sputtering, and your fuel dwindling"
		else
			t.speedS = "Racing to escape the star's approach"
		end
		
		local passengers = player.resources.passengers
		
		if passengers == 0 then
			t.passengerS = "guilt at the lives you left behind weighing heavily on your mind"
		elseif passengers == 1 then
			t.passengerS = "with but one companion by your side"
		else
			t.passengerS = "{passengers} grateful souls in tow"
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
		[function() StartLerp(self.text.colours.default, 4, 255, 0, 3) end] = self.time+3,
		[function() EndState("menu") end] = self.time+6
	}:start()
	
end

function death:draw()
	--love.graphics.set
	self.text:draw()
end

return death
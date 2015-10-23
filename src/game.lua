local camera = libs["gamera"]
local markov = require "markov"
planet_chain = require "planets_chain"
name_chain = require "names_chain"

local game = {}

Entity = Class{}

function Entity:init(pos, vel, accel)
	self.pos = pos or Vector2()
	self.vel = vel or Vector2()
	self.accel = accel or Vector2()
	self.netForce = Vector2()
end

function Entity:applyForce(f)
	self.netForce = self.netForce + f
end

function Entity:update(dt)
	self.accel = self.netForce --/ (self.mass or 1) -- Divide by mass?
	
	self.vel = self.vel + self.accel * dt
	
	if self.maxVel then
		if self.vel:len() > self.maxVel then
			self.vel = self.vel:norm()*self.maxVel
		end
	end
	
	self.pos = self.pos + self.vel * dt
	
	self.netForce = Vector2()
end

Asteroid = Class{__includes = Entity}

Asteroid.images = {love.graphics.newImage("assets/img/Asteroid1.png")}

Asteroid.sound = love.audio.newSource("assets/sounds/asteroid_hit.wav", "static")

function Asteroid:init(pos, vel, accel)
	Entity.init(self, pos, vel, accel)
	self.img  = randomSelect(self.images)
	self.radius = 25
	self.rot = math.randomf(0, 2*math.pi)
	self.scale = (self.radius*2)/self.img:getWidth()
	self.ox = self.img:getWidth()/2
	self.oy = self.img:getHeight()/2
end

function Asteroid:update(dt)
	Entity.update(self, dt)
	
	local dis = (self.pos - player.pos):len()
	if dis >= game.asteroidRadius + game.asteroidBuffer then
		game.asteroids:remove(self)
	end
end

function Asteroid:draw()
	love.graphics.setColor(255,255,255)
	--love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 8)
	--love.graphics.draw(self.img, self.pos.x, self.pos.y, self.rot, self.scale, nil, self.ox, self.ox)
	love.graphics.draw(self.img, self.pos.x, self.pos.y, self.rot, self.scale, nil, self.ox, self.oy)
end

function Asteroid:onCollide(obj)
	if getmetatable(obj) ~= Asteroid then
		if obj == player then
			player:damage(1)
			self.sound:stop()
			self.sound:play()
		end
		game.asteroids:remove(self)
	end
end

Planet = Class{}

Planet.font = love.graphics.newFont(20)

function Planet:init(arg)
	self.pos = arg.pos or Vector2()
	self.radius = arg.radius or 50
	self.gravityForce = arg.gravityForce
	self.colour = arg.colour or {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.name = arg.name or markov.generate(planet_chain, math.random(4,9))
	--self.name = self.name:lower()
	self.quest = arg.quest
	self.width = self.font:getWidth(self.name)
	self.time = math.randomf(0,3)
end

function Planet:draw()
	if self.quest then
		love.graphics.setColor(0,0,100)
		if self.quest.send then
			love.graphics.setColor(0, 100, 200)
		elseif self.quest.receive then
			love.graphics.setColor(0,255,100)
		end
		
		local pulse = 5 + math.cos((game.time*10)+self.time) * 5
		love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius + pulse, 100)
	end
	
	love.graphics.setColor(self.colour)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
	
	love.graphics.setColor(255,255,255)
	love.graphics.setFont(self.font)
	love.graphics.print(self.name, self.pos.x-(self.width/2), self.pos.y - (self.radius+25))
end

function Planet:onCollide(obj)

	if obj == player then
		EndState("planet", self)
	end
end

sun = {
	pos = Vector2(),
	radius = 100,
	gravityForce = 5000
}

function sun:draw()
	love.graphics.setColor(200,112,0)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
end

function game:removePlanet(p)
	table.remove2(self.planets, p)
	
	local t = self.sectors[self:sector((p.pos-sun.pos):len())]
	table.remove2(t, p)
	
	table.remove2(player.quests, p)
	
	-- Add to death toll
	if p.quest then
		if p.quest.receive then
			game.death[p.name] = p.quest.receive.passengers
		elseif p.quest.survivors then
			game.death[p.name] = p.quest.survivors.passengers
		end
	end
	--print(Tserial.pack(game.death))
end

function sun:onCollide(obj)
	if obj == player then
		EndState("death", "sun")
	elseif getmetatable(obj) == Planet then
		--print("Collided with planet")
		game:removePlanet(obj)	
	end
end

function game:eulogy()
	local s = ""
	for k, v in pairs(self.death) do
		s = s ..k..":".."\n"
		for i = 1,v do
			s = s.."  "..markov.generate(name_chain, math.random(5,11)).."\n"
		end
	end
	
	return s
end

player = Entity(Vector2.rand()*500)

player.radius = 30

player.rotSpeed = 4

player.maxVel = 400

player.burnRate = 10

player.img = love.graphics.newImage("assets/img/player.png")
player.thruster = love.graphics.newImage("assets/img/thruster.png")

player.scale = 1.5

player.ox, player.oy = player.img:getWidth()/2, player.img:getHeight()/2

resources = {"fuel", "spare parts", "rations"}

weights = {fuel=100, passengers=0.1, ["spare parts"] = 0.1, rations=1}
player.resources = {passengers=0}

startingFuel = 25

for k, v in pairs(resources) do
	if not player.resources[v] then player.resources[v] = 0 end
	if not weights[v] then weights[v] = 1 end
end

--player.burnRate = 10
--player.burnDt = 0

-- Tracking quests for HUD?
--player.quests = {}

function player:update(dt)

	if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		self.rot = self.rot + (dt * self.rotSpeed)
	elseif love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		self.rot = self.rot - (dt * self.rotSpeed)
	end
	
	self.dir = Vector2(math.cos(self.rot), math.sin(self.rot))
	
	--[[
	dis = self.pos - sun.pos
	theta = math.atan2(dis.y, dis.x) - self.rot
	
	falloff = 1 / math.pow((dis:len() - sun.radius), 1)
	falloff=1
	angleFalloff = math.cos(theta)
	angleFalloff = 1
	self:applyForce(self.dir:norm() * falloff * angleFalloff)
	--]]
	
	if love.keyboard.isDown(" ") or love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		if self.resources.fuel > 0 then 
			self:applyForce(self.dir:norm() * 100)
			self.burnDt = self.burnDt + dt
			if self.burnDt >= self.burnRate then
				if self:addResources("fuel", -1) then
					self.burnDt = 0
				end
			end
			self.thrusting = true
		end
	else
		self.thrusting = false
	end
	
	Entity.update(self, dt)
end

function player:setWeight(w)
	self.weight = w or self:getWeight()
	self.mass = self.weight / 1000
end

function player:getWeight(t)
	local t = t or self.resources
	
	local w = 0
	
	for k,v in pairs(t) do
		w = w + (weights[k] * v)
	end
	
	return w
end

function player:addResources(resource, qt)
	val = self.resources[resource]
	if val + qt < 0 then
		return false
	end
	self.resources[resource] = self.resources[resource] + qt
	
	-- Update GUI
	passengerLabel:setText("Passengers: "..self.resources.passengers)
	passengerLabel:centerX()
	
	
	
	self:setWeight()
	-- set resourceText
	
	local s = ""
	
	for key, value in pairs(self.resources) do
		s = s .. key:capitalize() .. " : " .. value .. "\n"
	end
	s = s .. "\n" .. "Weight : ".. self.weight .. "\n"
	
	resourceText:setText(s)
	
	local _, count = s:gsub("\n","")
	resourceText.scale.y = count * resourceText.font:getHeight()
	resourceText:center()
	return true
end

function player:draw()
	love.graphics.setColor(255,255,255)
	
	
	
	love.graphics.push()
		
		
		love.graphics.translate(self.pos.x, self.pos.y)
		--love.graphics.scale(self.scale)
		love.graphics.rotate(self.rot+(math.pi/2))
		
		if self.thrusting then
			--love.graphics.scale(self.sclae)
			local pulse = remap((math.cos(game.time*10)), -1, 1, 0.9, 1.1)
			love.graphics.draw(self.thruster, -self.ox*self.scale, (-self.oy+50)*self.scale, 0, self.scale, self.scale*pulse)
		end
		
		love.graphics.draw(self.img, -self.ox*self.scale, -self.oy*self.scale, 0, self.scale)
		
		

	
	love.graphics.pop()
	
	--[[
	love.graphics.setColor(255,255,255)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.dir.x*10, self.pos.y+self.dir.y*10)
	love.graphics.setPointSize(5)
	love.graphics.point(self.pos.x, self.pos.y)
	]]--
end

function player:onCollide(obj)
	if obj == sun then
		--EndState("death")
	end
end

function player:damage(dmg)
	self.lives = self.lives - 1
	if self.lives <= 0 then
		EndState("death", "asteroid")
	end
end
function game:load()
	--self.asteroids = List()
	
	music =
	{
		volume = 1,
		songs = {},
		tweenVolume = 1,
		timer = require("humptimer")
	}
	
	music.songs.menu = love.audio.newSource("assets/music/On the Shore.mp3")
	music.songs.game = love.audio.newSource("assets/music/Dark Fog.mp3")
	
	function music:stop()
		self.playing:stop()
	end
	
	function music:play()
		self.playing:play()
	end
	
	function music:switchTo(name)
		local newPlaying = self.songs[name]
		if not newPlaying then return end
		
		if self.playing then self.playing:stop() end
		
		self.playing = newPlaying
		self.playing:play()
	end
	
	function music:fadeTo(name, length)
		local newPlaying = self.songs[name]
		
		if not newPlaying then return end
		local length = length or 1
		self.timer.tween(length, self, {tweenVolume = 0}, nil, function()
			self.playing:stop()
			self.playing = newPlaying
			self.playing:play()
			
			self.timer.tween(length, self, {tweenVolume=1})
		end)
	end
	
	function music:update(dt)
		print ("self.timer = "..tostring(self.timer))
		self.timer.update(dt)
		self.playing:setVolume(self.volume*self.tweenVolume)
	end
	
	asteroidRate = 0.7
	--asteroidDt = asteroidRate
	--self.time = 0
	
	player.burnRate = 5
	
	sunZone = 1500
	
	self.planets = {}
	--self.sectors = {[0]={},[1] = {}}
	self.secSize = 10
	self.orbitSize = 100
	self.densityFactor = 10
	
	self.genDistance = 6
	self.renderDistance = 5
	
	self.radarRadius = 5000
	self.radarDrawRadius = 200
	
	self.marker = love.graphics.newImage("assets/img/marker.png")
	self.markerCenter = self.marker:getWidth()/2
	
	self.sunMarker = love.graphics.newImage("assets/img/sunmarker.png")
	self.sunMarkerCenter = self.sunMarker:getWidth()/2
	
	--self.death = {}
	
	center = Vector2(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	
	--for k, key in resources do
	--	player:addResources(key, -(player.resources[key]))
	
	--end
	--player:setWeight()
	
	winTime = 150
	
	sunSpeed = 270
	
	--player.pos = Vector2:rand() * (sun.radius+sunZone+(sunSpeed))
	
	quests = {}
	QUEST_OFF = math.rad(15)
	
	local font = love.graphics.newFont(22)
	
	
	passengerLabel = Label("", Vector2(0,10), Vector2(1,1), {font=font}):centerX()
	speedLabel = Label("", Vector2(10, height-25), nil, {font=font})
	distanceLabel = Label("", Vector2(width/2, height-25), nil, {font=font}):centerX()
	
	resourceFrame = Frame(Vector2(0, 120), Vector2(160,135)):centerY()
	resourceFrame.colours.default = {50,50,50,100}
	
	local off = 2
	resourceText = resourceFrame:add(TextBox("nil", nil, resourceFrame.scale - Vector2(off*2,off*2))):center()
	resourceText.font = love.graphics.newFont(18)
	
	compassFrame = Frame(Vector2(), Vector2(100,150)):centerY()
	compassFrame.pos.x = width-compassFrame.scale.x
	compassFrame.colours.default = {50,50,50,100}
	
	-- Make it an Image?
	-- compassText = Label("Disatnce: ".." u")
	--compass = 
	
	self.gui = List{

		passengerLabel,
		speedLabel,
		resourceFrame,
		resourceText,
		distanceLabel,
		--compassText,
	}
	self.camSize = 300000
	self.camera = camera.new(0,0,1,1)
	
	oldGravity = self.gravity
	oldCollision = self.collisions
	
end

function game:setup()
	sun.radius = 100
	
	

	player.lives = 3
	player.burnDt = 0

	self.sectors = {[0]={},[1] = {}}
	
	-- Tracking quests for HUD?
	player.quests = {}

	self.asteroids = List()
	asteroidDt = asteroidRate
	self.time = 0

	self.death = {}
	quests = {}
	
	self.planets = {}
	self.sectors = {[0]={},[1] = {}}
	

	for key, _ in pairs(player.resources) do
		player.resources[key] = 0
	end
	player:addResources("fuel", startingFuel)
	
	
	player.pos = Vector2:rand() * (sun.radius+sunZone+(sunSpeed))
	oldPlayerPos = player.pos
	
	player.dir = player.pos:norm()
	player.rot = player.dir:angle()
	
	player.vel = player.dir:norm() * 70
	
	--print("player.pos = "..tostring(player.pos))
	
	self:updateCamera()
	
	
	self.camera:setPosition(player.pos.x, player.pos.y)
	self.camera:setScale(1/2)
	local l,t,w,h = self.camera:getVisible()
	
	--print("l,t,w,h = "..l..","..t..","..w..","..h)
	
	local dis = Vector2(player.pos.x-l, player.pos.y-t)
	
	local numStars = 100
	self.starBuffer = 500
	self.stars = {}
	
	
	local maxSize = 3
	for i = 1,numStars do
		
		local s = {pos = Vector2(math.randomf(l-self.starBuffer,l+w+self.starBuffer), math.randomf(t-self.starBuffer,t+h+self.starBuffer)), size = math.random(1,maxSize)}
		z = 10*(maxSize - s.size)
		if not self.stars[z] then self.stars[z] = {} end
		table.insert(self.stars[z], s)
		
	end
	
	self.starloop = math.sqrt((w*w)+(h*h))
	
	self.asteroidRadius =  dis:len() + 100
	self.asteroidBuffer = 200
	
	self.gravity = oldGravity
	self.collisions = oldCollision
	
	self.winning = nil
end

function game:onStart(p)
	if p then
		if type(p) == "table" then
			delta = p.pos - player.pos
			player.pos = p.pos + delta:norm()*(p.radius+(player.radius*2)+10)
			--player.vel = delta:norm()*150*player.vel:len()
		elseif type(p) == "string" then
			if p == "new" then
				self:setup()
				-- show tutorial thingy?
			end
		end
	end
	
	if music.playing ~= music.songs.game then music:fadeTo("game") end
end

function game:updateCamera()
	local w_l,w_t, w_w,w_h = self.camera:getWorld()

	local v_l,v_t, v_w,v_h = self.camera:getVisible()

	local buffer = 50
	
	if (v_l - w_l <= buffer) or (v_t - w_t <= buffer) or ( (w_l + w_w) - (v_l + v_w) <= buffer) or ( (w_t + w_h) - (v_t + v_h) <= buffer) then
		self.camera:setWorld(player.pos.x - self.camSize, player.pos.y - self.camSize, 2 * self.camSize, 2 * self.camSize)
	end
	
end

function game:drawPlanets(l,t,w,h)
	planetsDrawn = 0
	
	local planets = {}
	local sector = self:sector((player.pos):len()) 
	for i = -self.renderDistance, self.renderDistance do
		table.merge(planets, self.sectors[sector+i] or {})
	end
	
	for i, planet in ipairs(planets) do
		if planet.pos.x < l+w+planet.radius and planet.pos.x > l - planet.radius and
		  planet.pos.y < t + h + planet.radius and planet.pos.y > t - planet.radius then
		  planet:draw()
		  planetsDrawn = planetsDrawn + 1
		  planet.drawn = true
		else
			planet.drawn = false
		end
	end
end

function game:addQuestPlanet(origin, distance)
	local dir = origin.pos - sun.pos
	local angle = math.atan2(dir.y, dir.x)
	
	local sector = self:sector(dir:len()) + distance
	-- Make sure it's not generated already
	while self.sectors[sector] do
		sector = sector + 1
	end
	
	if not quests[sector] then quests[sector] = {} end
	
	q=copy(origin.quest.send)
	q.origin = origin.name
	q.quantity = - q.quantity
	table.insert(quests[sector], {angle=angle, name=q.name, quest={receive=q}}) -- Extra quest data goes here?
end

function game:generateSector(sector)
	if sector >= 0 then
		if not self.sectors[sector] then
			--print("Generating sector " + sector)
			self.sectors[sector] = {}
			local min, max = sector*(self.secSize*self.orbitSize),((sector+1)*((self.secSize)*self.orbitSize))-self.orbitSize
			--print("Generating from "+min+" to "+max+" distance from the sun")
			for o = min,max,self.orbitSize do
				for i = 1, math.floor(sector/self.densityFactor)+1 do
					local pos = Vector2:rand()*o
					local name = nil
					local colour = nil
					local quest = nil
					if quests[sector] then
						local angle = math.atan2(pos.y, pos.x)
						for i, planet in ipairs(quests[sector]) do
							if angle > planet.angle - QUEST_OFF and angle < planet.angle + QUEST_OFF then
								table.remove(quests[sector], i)
								name = planet.name
								--colour = {0,255,0} -- Debug
								quest = planet.quest
								break
							end
						end
						
					end
					if not name then
							if math.random() < 0.1 then
								quest = {send={name=markov.generate(planet_chain, math.random(4,9)),resource=randomSelect(resources),quantity=math.random(1,4)}}
								--colour = {255,0,0}
								--name=markov.generate(planet_chain, math.random(4,9))
								
							elseif math.random() < 0.4 then
								quest = {survivors = {passengers = math.random(10,50)}}
								--colour = {0,255,255}
							end
						end
					
					local p = (Planet{pos=pos, radius=math.random(50,60), gravityForce=math.random(100,1000), name=name, colour=colour, quest=quest})
					table.insert(self.planets, p)
					table.insert(self.sectors[sector], p)
					if p.quest then
						if p.quest.send then
							p.quest.send.passengers = math.random(1, 11)
						elseif p.quest.receive then
							table.insert(player.quests, p)
							p.quest.receive.passengers = math.random(10,20)
						elseif p.quest.survivors then
							p.quest.survivors.name = p.name
						end
						
					end
				end
			end
			if quests[sector] then
				if not quests[sector+1] then quests[sector+1] = {} end
				for _, q in ipairs(quests[sector]) do
					table.insert(quests[sector+1], q)
				end
				quests[sector] = nil
			end
			--self.sectors[sector] = true
		end
	end
end
dubgdraw = false
function game:update(dt)
	--layera = love.graphics.
--	parallax(layera, 0, 0)
	-- FPS limiter
	dt = math.min(dt, 1/3)
	sun.radius = sun.radius + sunSpeed * dt
	
	self.time = self.time + dt
	
	if self.time > winTime then
		--print("winning!")
		if not self.winning and player.resources.fuel > 0 and player.vel:len() > sunSpeed then
			self.gravity = function() end
			self.collision = function() end
			StartLerp(self, "winning", 0,255, 3)
			StartTimer(3, function() EndState("death", "win") end)
		end
	end
	
	asteroidDt = asteroidDt + dt
	
	if asteroidDt >= asteroidRate then
		self.asteroids:add(Asteroid(player.pos+(Vector2:rand()*self.asteroidRadius),(Vector2:rand()*50)))
		asteroidDt = 0
	end
	
	local affected = {player, unpack(self.asteroids.items)}
	--affected = {player}
	self:gravity(affected, {sun}, dt)
	player:update(dt)
	
	
	speedLabel:setText("Speed: "..math.floor(player.vel:len()).." u/s")
	
	self.asteroids:update(dt)
	
	-- Planet generation
	dir = player.pos:clone()
	dis = dir:len()
	
	local sec = self:sector(dis)
	
	for i = -self.genDistance, self.genDistance do
		local sector = sec + i
		self:generateSector(sector)
		
	end
	
	self.gui:update(dt)
	
	-- Camera
	self:updateCamera()
	self.camera:setPosition(player.pos.x, player.pos.y)
end

function game:sector(dis)
	return math.floor(dis / (self.secSize * self.orbitSize))
end

function drawStarsLayer(z, layer)
	love.graphics.setColor(150,150,150)
	for _, star in ipairs(layer) do
		
		love.graphics.setPointSize(star.size)
		
		--star.pos = star.pos + deltaPos
		
		 star.pos = star.pos + (deltaPos * z)
		
		if star.pos.x >= xMax then star.pos.x = xMin
		elseif star.pos.x < xMin then star.pos.x = xMax end
		
		if star.pos.y >= yMax then star.pos.y = yMin
		elseif star.pos.y < yMin then star.pos.y = yMax end
		
		
		
		love.graphics.point(star.pos.x,star.pos.y)
	end
end

function game:draw()
	self.camera:draw(function(l,t,w,h)
	
	
	deltaPos = (oldPlayerPos - player.pos)/100
	
	love.graphics.setColor(255,255,255)
	love.graphics.setPointStyle("rough")
	
	local buffer = self.starBuffer
	
	xMin = l-buffer
	xMax = l+w+buffer
	
	yMin = t-buffer
	yMax = t+h+buffer
	
	for z,layer in spairs(self.stars) do
		if z == 0 then
			self:drawPlanets(l,t,w,h)
			sun:draw()
			
			self.asteroids:draw()
			
			player:draw()
		end
		drawStarsLayer(z, layer)
		
	end
	
	
	end)
	
	local dir = (player.pos-sun.pos)
	local dis = dir:len()
	
	-- Draw radar HUD
	local seen = {}
	local sector = self:sector(dis)
	for i = -3, 3 do
		local planets = self.sectors[sector+i]
		if planets then
			for k, planet in ipairs(planets) do
				delta = planet.pos - player.pos
				if delta:len() <= self.radarRadius then
					table.insert(seen, planet)
				end
			end
		end
	end
	
	table.merge(seen, player.quests)
	
	for k, planet in ipairs(seen) do
		if not planet.drawn then

			
			
			
			local dir = planet.pos - player.pos
			local dis = dir:len()
			local pos = center+(dir:norm()*self.radarDrawRadius)
			--local a = remap(dis, 500, self.radarRadius, 255, 0, true)

			local scale = remap(dis, 500, self.radarRadius, 1.45, 1, true)
			if scale >= 1.44 then scale = 1.5 end
			----print("scale = "..scale)
			--scale = 1
			local r,g,b,a = 255,255,255,100
			
			if planet.quest then
				if planet.quest.send then
					g,b = 0,0
				elseif planet.quest.receive then
					r,b = 0,0
				end
			end

			love.graphics.draw(self.marker, pos.x, pos.y, math.atan2(dir.y, dir.x), scale, scale, self.markerCenter)
		end
	end
	
	--Draw Sun Marker
	local r,g,b,a = 255,0,0,100
	love.graphics.setColor(r,g,b,a)
	local dis = player.pos:len()
	local pos = center+(-dir:norm()*self.radarDrawRadius)
	local scale = remap(dis, 500, self.radarRadius, 1.45, 1, true)
	if scale >= 1.44 then scale = 1.5 end
	love.graphics.setColor(r,g,b,a)
	love.graphics.draw(self.sunMarker, pos.x, pos.y, math.atan2(player.pos.y, player.pos.x), scale, scale, self.sunMarkerCenter)
	distancefromsun = player.pos:len() - sun.radius
	distancefromsun = math.floor(distancefromsun+0.5)
	distanceLabel:setText("Distance: "..distancefromsun)
	distanceLabel:centerX()
	
	-- Draw gui
	self.gui:draw()
	
	love.graphics.setColor(255,255,255)
	
	for i = 1, player.lives do 
		love.graphics.draw(player.img, 15+(i-1)*50, 10, 0, 1.3)
	end
	
	-- Draw debug
	--love.graphics.print("#asteroids:"+#self.asteroids.items, 0, 75)
	--love.graphics.print("#planets:"+#self.planets, 0, 100)
	--love.graphics.print("#planetsDrawn:"+planetsDrawn, 0, 125)
	
	local dir = (player.pos-sun.pos)
	local dis = dir:len()
	dis = dis - sun.radius
	if dis <= (sunZone) then
		local a = math.max(remap(dis, 0, sunZone, 255, 0 ,true), 0)
		love.graphics.setColor(255,50,0,a)
		love.graphics.rectangle("fill", 0,0, width,height)
	end
	
	if self.winning then
		love.graphics.setColor(0,0,0,self.winning)
		love.graphics.rectangle("fill", 0,0,width, height)
	end
	
	oldPlayerPos = player.pos:clone()
end
--[[
function game:mousepressed(x, y, button)
	if button == "wu" then
		self.camera:setScale(self.camera:getScale()*2)
	elseif button == "wd" then
		self.camera:setScale(self.camera:getScale()/2)
	end

	local x,y = self.camera:toWorld(x,y)
	local v = Vector2(x,y)
	if button == "l" then
		self.asteroids:add(Asteroid(v, Vector2:rand()*100))
	elseif button == "r" then
		local r = math.random(50,150)
		local g = math.random(10000,1000000)
		local p = (Planet{pos=v, radius=r, gravityForce=g})
		table.insert(self.planets, p)
		table.insert(self.sectors[self:sector((v-sun.pos):len())], p)
	elseif button == "x1" then
		local sec = self:sector((v-sun.pos):len())
		if self.sectors[sec] then
			for _, planet in ipairs(self.sectors[sec]) do
			
				if (v - planet.pos):len() <= planet.radius then
					EndState("planet", planet)
					break
				end
			end
		end
	end
end


if key == "e" then
		--print(self:eulogy())
	elseif key == "-" then
		self.radarDrawRadius = self.radarDrawRadius - 10
	elseif key == "=" then
		self.radarDrawRadius = self.radarDrawRadius + 10
	else
--]]

function game:keypressed(key)
	if key == "escape" then
		EndState("pause")
	end
end

--[[
function circleCollision(a, b)
	
	local x = ((a.radius * b.pos.x) + (b.radius * a.pos.x)) / (a.radius + b.radius)
	local y = ((a.radius * b.pos.y) + (b.radius * a.pos.y)) / (a.radius + b.radius)
	
	return Vector2:new(x,y) -- + a.pos
	
end
]]
function game:gravity(affectedByGravity, constantAffectors, dt)
	sector = -1
	for i, affected in ipairs(affectedByGravity) do
		netForce = Vector2(0,0)
		local dis = (affected.pos - sun.pos):len()
		local sec = self:sector(dis)
		
		if sec ~= sector then
			gravityAffectors = {}
			table.merge(gravityAffectors, constantAffectors)
			for i = -1, 1 do
				table.merge(gravityAffectors, self.sectors[sec+i] or {})
			end
			sector = sec
		end
		
		for x, affector in ipairs(gravityAffectors) do
			delta = affector.pos - affected.pos
			dis = delta:len()
			if dis < affector.radius+1000 then
				dis = dis * dis
			--falloff = (affector.radius / dis)
				netForce = netForce + ((delta:norm() * affector.gravityForce)/dis)*100
			end
		end
		affected:applyForce(netForce)
	end
	local dis = (player.pos):len()
	local sec = self:sector(dis)
	if sec ~= sector then
		gravityAffectors = {}
		table.merge(gravityAffectors, constantAffectors)
		for i = -1, 1 do
			table.merge(gravityAffectors, self.sectors[sec+i] or {})
		end
		sector = sec
	end
	
	table.merge(gravityAffectors, self.sectors[self:sector(sun.radius)]or {})
	
	game:collisions(affectedByGravity, gravityAffectors)
	fps = 1/dt
end

function game:collisions(colliders1, colliders2)
	table.merge(colliders1, colliders2)
	for i = 1,#colliders1-1 do
		collider1 = colliders1[i]
		for j = i+1, #colliders1 do
			collider2 = colliders1[j]
			if collider2 ~= collider1 then
				local dis = (collider1.pos - collider2.pos):len()
				if collider1.radius == nil or collider2.radius == nil then
					--print("No Radius")
					return
				end
				if dis <= collider1.radius + collider2.radius then
					if(collider1.onCollide) then
						collider1:onCollide(collider2)
					end
					if(collider2.onCollide) then
						collider2:onCollide(collider1)
					end

					
				end
			end
		end
	end
end

function parallax(tiles, parralaxfactor, layeroffset)
	for z=1, depth do
		for y=1, height do
			for x=1, width do
				local tile = tiles[x][y]
				if tile.x + tile.width <= 0 + self.camera.pos then
					local dx = tile.x + tile.width
					tile.x = love.graphics.getWidth() - dx
				elseif tile.x >= love.graphics.getWidth() then
					local dx = tile.x - love.graphics.getWidth()
					tile.x = dx
				end
			end
		end
	end
end

return game

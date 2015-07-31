local camera = libs["gamera"]
local markov = require "markov"
planet_chain = require "planets_chain"

local game = {}

INITIAL_STATE = "game"

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
	self.accel = self.netForce / (self.mass or 1) -- Divide by mass?
	
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

function Asteroid:init(pos, vel, accel)
	Entity.init(self, pos, vel, accel)
	
	self.radius = 20
end

function Asteroid:draw()
	love.graphics.setColor(100,100,100)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 8)
end

function Asteroid:onCollide(obj)
	if getmetatable(obj) ~= Asteroid then
		game.asteroids:remove(self)
	end
end

Planet = Class{}

function Planet:init(arg)
	self.pos = arg.pos or Vector2()
	self.radius = arg.radius or 50
	self.gravityForce = arg.gravityForce
	self.colour = arg.colour or {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
	self.name = arg.name or markov.generate(planet_chain, math.random(4,9))
	self.quest = arg.quest
end

function Planet:draw()
	love.graphics.setColor(self.colour)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
	
	love.graphics.setColor(255,255,255)
	love.graphics.print(self.name, self.pos.x, self.pos.y - (self.radius+25))
end

function Planet:onCollide(obj)

	if obj == player then
		EndState("planet", self)
	end
end

sun = {
	pos = Vector2(),
	radius = 100,
	gravityForce = 1000000
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
end

function sun:onCollide(obj)
	if getmetatable(obj) == Planet then
		print("Collided with planet")
		game:removePlanet(obj)
	end
end

player = Entity(Vector2.rand()*500)
player.dir = Vector2()
player.rot = 0

player.rotSpeed = 4

player.maxVel = 400

player.radius = 10

weights = {fuel=100, passengers=0.1}

player.resources = {fuel=10, passengers=0}

player.burnRate = 10
player.burnDt = 0

-- Tracking quests for HUD?
player.quests = {}

function player:update(dt)

	if love.keyboard.isDown("d") then
		self.rot = self.rot + (dt * self.rotSpeed)
	elseif love.keyboard.isDown("a") then
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
	
	if love.keyboard.isDown(" ") then
		self:applyForce(self.dir:norm() * 100)
		self.burnDt = self.burnDt + dt
		if self.burnDt >= self.burnRate then
			if self:addResources("fuel", -0.1) then
				self.burnDt = 0
			end
		end
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
	
	self:setWeight()
	return true
end

function player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.dir.x*10, self.pos.y+self.dir.y*10)
	love.graphics.setPointSize(5)
	love.graphics.point(self.pos.x, self.pos.y)
end



function game:load()
	self.asteroids = List()
	self.planets = {}
	self.sectors = {[0]={},[1] = {}}
	self.secSize = 10
	self.orbitSize = 100
	self.densityFactor = 10
	
	self.genDistance = 6
	self.renderDistance = 5
	
	self.radarRadius = 5000
	self.marker = love.graphics.newImage("assets/img/marker.png")
	
	center = Vector2(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
	
	player:setWeight()
	
	sunSpeed = 40
	
	quests = {}
	QUEST_OFF = math.rad(15)
	
	testButton = Button(Vector2(), Vector2(200,50), {onClick = function() EndState("menu") end, texts = {default="END"}})
	
	self.gui = List{testButton}
	
	self.camSize = 300000
	self.camera = camera.new(0,0,1,1)
	self:updateCamera()
end

function game:onStart(p)
	if p then
		delta = p.pos - player.pos
		player.pos = p.pos + delta:norm()*(p.radius+(player.radius*2)+10)
		--player.vel = delta:norm()*150*player.vel:len()
	end
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
	local sector = self:sector((player.pos - sun.pos):len()) 
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
			print("Generating sector " + sector)
			self.sectors[sector] = {}
			local min, max = sector*(self.secSize*self.orbitSize),((sector+1)*((self.secSize)*self.orbitSize))-self.orbitSize
			print("Generating from "+min+" to "+max+" distance from the sun")
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
								colour = {0,255,0} -- Debug
								quest = planet.quest
								break
							end
						end
						
					end
					if not name then
							if math.random() < 0.1 then
								quest = {send={name=markov.generate(planet_chain, math.random(4,9)),resource="fuel",quantity=math.random(1,4)}}
								colour = {255,0,0}
								--name=markov.generate(planet_chain, math.random(4,9))
								
							elseif math.random() < 0.2 then
								quest = {survivors = {passengers = math.random(10,50)}}
								colour = {0,255,255}
							end
						end
					
					local p = (Planet{pos=pos, radius=math.random(50,60), gravityForce=math.random(10000,1000000), name=name, colour=colour, quest=quest})
					table.insert(self.planets, p)
					table.insert(self.sectors[sector], p)
					if p.quest then
						if p.quest.send then
							
						elseif p.quest.receive then
							table.insert(player.quests, p)
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
	-- FPS limiter
	dt = math.min(dt, 0.07)
	sun.radius = sun.radius + sunSpeed * dt
	
	local affected = {player, unpack(self.asteroids.items)}
	--affected = {player}
	self:gravity(affected, {sun}, dt)
	
	player:update(dt)
	self.asteroids:update(dt)
	
	-- Planet generation
	dir = player.pos - sun.pos
	dis = dir:len()
	
	local sec = self:sector(dis)
	
	for i = -self.genDistance, genDistance do
		local sector = sec + i
		self:generateSector(sector)
		
	end
	
	-- Camera
	self:updateCamera()
	self.camera:setPosition(player.pos.x, player.pos.y)
end

function game:sector(dis)
	return math.floor(dis / (self.secSize * self.orbitSize))
end

function game:draw()
	self.camera:draw(function(l,t,w,h)
	
	self:drawPlanets(l,t,w,h)
	sun:draw()
	
	self.asteroids:draw()
	
	player:draw()
	end)
	
	-- Draw radar HUD
	local seen = {}
	local sector = self:sector((player.pos-sun.pos):len())
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
			local pos = center+(dir:norm()*200)
			local a = remap(dis, self.radarRadius, 500, 100, 255, true)
			local r,g,b = 255,255,255
			
			if planet.quest then
				if planet.quest.send then
					g,b = 0,0
				elseif planet.quest.receive then
					r,b = 0,0
				end
			end
			love.graphics.setColor(r,g,b,a)
			love.graphics.draw(self.marker, pos.x, pos.y, math.atan2(dir.y, dir.x))
		end
	end
	
	-- Draw gui
	self.gui:draw()
	
	-- Draw debug
	love.graphics.print("FPS:"+fps, 0, 50)
	love.graphics.print("#asteroids:"+#self.asteroids.items, 0, 75)
	love.graphics.print("#planets:"+#self.planets, 0, 100)
	love.graphics.print("#planetsDrawn:"+planetsDrawn, 0, 125)
	love.graphics.print("speed:"+player.vel:len(), 0, 150)
	
	local i = 1
	for k,v in pairs(player.resources) do
		love.graphics.print(k..": "..v, 0, 150+(i*25))
		i = i + 1
	end
	love.graphics.print("Weight: "..player.weight, 0,  150+(i*25))
end

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
			if dis < 1000 then
				dis = dis * dis
			--falloff = (affector.radius / dis)
				netForce = netForce + ((delta:norm() * affector.gravityForce)/dis)*dt*100
			end
		end
		affected:applyForce(netForce)
	end
	local dis = (player.pos - sun.pos):len()
	local sec = self:sector(dis)
	if sec ~= sector then
		gravityAffectors = {}
		table.merge(gravityAffectors, constantAffectors)
		for i = -1, 1 do
			table.merge(gravityAffectors, self.sectors[sec+i] or {})
		end
			sector = sec
	end
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
					print("No Radius")
					return
				end
				if dis <= collider1.radius + collider2.radius then
					if(collider1.onCollide) then
						collider1:onCollide(collider2)
					end
					if(collider2.onCollide) then
						collider2:onCollide(collider1)
					end
					love.window.setTitle("Collided")
				end
			end
		end
	end
end

return game
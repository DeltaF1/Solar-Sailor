local camera = libs["camera"]

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
	self.accel = self.netForce -- Divide by mass?
	
	self.vel = self.vel + self.accel * dt
	self.pos = self.pos + self.vel * dt
	
	self.netForce = Vector2()
end

Asteroid = Class{__includes = Entity}

function Asteroid:draw()
	love.graphics.setColor(100,100,100)
	love.graphics.circle("fill", self.pos.x, self.pos.y, 10, 8)
end

sun = {
	pos = Vector2(50,100),
	radius = 100,
}

function sun:draw()
	love.graphics.setColor(200,112,0)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
end

player = Entity(Vector2(200,200))
player.dir = Vector2()
player.rot = 0


function player:update(dt)
	self.dir = Vector2(math.cos(self.rot), math.sin(self.rot))
	
	dis = self.pos - sun.pos
	theta = math.atan2(dis.y, dis.x) - self.rot
	
	falloff = 10 --/ math.pow((dis:len() - sun.radius), 1)
	
	self:applyForce(self.dir:norm() * math.cos(theta) * falloff)
	
	Entity.update(self, dt)
end


function player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.dir.x*10, self.pos.y+self.dir.y*10)
	love.graphics.setPointSize(5)
	love.graphics.point(self.pos.x, self.pos.y)
end



function game:load()
	self.asteroids = List()
	self.planets = List()
	self.sectors = {}
	self.secSize = 10
	self.orbitSize = 100
	
	testButton = Button(Vector2(), Vector2(200,50), {onClick = function() EndState("menu") end, texts = {default="END"}})
	
	self.gui = List{testButton}
	
	self.camera = camera()
end

function game:update(dt)
	-- FPS limiter
	  dt = math.min(dt, 0.07)
	  
	if love.keyboard.isDown("a") then
		player.rot = player.rot + dt
	elseif love.keyboard.isDown("d") then
		player.rot = player.rot - dt
	end
	
	local affected = {player, unpack(self.asteroids.items)}
	
	gravity(affected, self.planets.items, dt)
	
	player:update(dt)
	self.asteroids:update(dt)
	
	dir = player.pos - sun.pos
	dis = dir:len()
	
	local sec = math.floor(dis / (self.secSize * self.orbitSize))
	local drawDistance = 10
	
	for i = 0, drawDistance do
		local sector = sec + i
		if not self.sectors[sector] then
			print("Generating sector " + sector)
			local min, max = sector*(self.secSize*self.orbitSize),(sector+1)*(self.secSize*self.orbitSize)
			print("Generating from "+min+" to "+max+" distance from the sun")
			for o = min,max,self.orbitSize do
				
				self.planets:add(Planet(Vector2:rand()*o, math.random(50,60), math.random(10000,1000000)))
			end
			
			self.sectors[sector] = true
		end
	end
	
	
	self.camera:lookAt(player.pos.x, player.pos.y)
end

function game:draw()
	self.camera:attach()
	
	self.planets:draw()
	sun:draw()
	
	self.asteroids:draw()
	
	player:draw()
	self.camera:detach()
	
	-- Draw gui
	self.gui:draw()
end

function game:mousepressed(x, y, button)
	if button == "wu" then
		self.camera:zoom(2)
	elseif button == "wd" then
		self.camera:zoom(0.5)
	end

	local x,y = self.camera:mousepos()
	if button == "l" then
		self.asteroids:add(Asteroid(Vector2(x,y), Vector2:rand()*100))
	elseif button == "r" then
		local r = math.random(50,150)
		local g = math.random(10000,1000000)
		self.planets:add(Planet(Vector2(x,y), r, g))
	end
end

function gravity(affectedByGravity, gravityAffectors, dt)
	for i, affected in ipairs(affectedByGravity) do
		netForce = Vector2(0,0)
		for x, affector in ipairs(gravityAffectors) do
			assert(affected.pos, "affected has no pos!")
			assert(affector.pos, "affector has no pos!")
			delta = affector.pos - affected.pos
			dis = delta:len() * delta:len()
			--falloff = (affector.radius / dis)
			netForce = netForce + ((delta:norm() * affector.gravityForce)/dis)*dt*100
		end
		affected:applyForce(netForce)
	end
end

Planet = Class{}

function Planet:init(pos, radius, gravityForce)
	self.pos = pos
	self.radius = radius
	self.gravityForce = gravityForce
	self.colour = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
end

function Planet:draw()
	love.graphics.setColor(self.colour)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
end

return game
local game = {}

INITIAL_STATE = "game"

sun = {
	pos = Vector2(50,100),
	radius = 100,
}

function sun:draw()
	love.graphics.setColor(200,112,0)
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
end

player =
{
	pos = Vector2(200,200),
	acceleration = Vector2(),
	vel = Vector2(),
	dir = Vector2(),
	rot=0
}

function player:update(dt)
	self.dir = Vector2(math.cos(self.rot), math.sin(self.rot))
	-- Replace with an Entity super class that does this automatically? Entity.update(self, dt)?
	local newVel = self.vel + self.acceleration  * dt
	self.vel = newVel 
	self.pos = self.pos + self.vel * dt
	
	dis = self.pos - sun.pos
	theta = math.atan2(dis.y, dis.x) - self.rot
	
	falloff = 1 / math.pow((dis:len() - sun.radius), 1)
	
	self.acceleration = self.acceleration + self.dir:norm() * math.cos(theta) * falloff
end

function player:draw()
	love.graphics.setColor(255,255,255)
	love.graphics.line(self.pos.x, self.pos.y, self.pos.x+self.dir.x*10, self.pos.y+self.dir.y*10)
end



function game:load()

end

function game:update(dt)
	if love.keyboard.isDown("a") then
		player.rot = player.rot + dt
	elseif love.keyboard.isDown("d") then
		player.rot = player.rot - dt
	end
	player:update(dt)
end

function game:draw()
	sun:draw()
	player:draw()
end

function gravity(affectedByGravity, gravityAffectors, dt)
	for i, affected in ipairs(affectedByGravity) do
		netForce = Vector2(0,0)
		for x, affector in ipairs(gravityAffectors) do
			delta = affected.pos - affector.pos
			dis = delta:len() * delta:len()
			falloff = (dis / affector.radius)
			netForce = netForce + (delta:norm() * affector.gravityForce * falloff)
		end
		affected.acceleration = affected.acceleration + netForce * dt
	end
end

Planet = Class{}
function Planet:init(self, pos, radius, gravityForce)
	self.pos = pos
	self.radius = radius
	self.gravityForce = gravityForce
end

function Planet:draw()
	love.graphics.setColor(math.random(0, 255), math.random(0, 255), math.random(0, 255))
	love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius, 100)
end

return game
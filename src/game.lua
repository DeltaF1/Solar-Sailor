local game = {}



INITIAL_STATE = "game"

return game

Class = require "class"
require "vmath"
function game.load()

end

function game.update()

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
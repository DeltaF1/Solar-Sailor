local credits = {}

function credits:load()
	
	local info = require "creditinfo"
	
	self.Text = TextBox(info, nil, Vector2(love.graphics.getWidth(), 10), {align="center", font = love.graphics.newFont(18)})
	self.Text:centerX()
	self.speed = 25
	
	self.limit = -50
end

function credits:onStart()
	self.Text.pos.y = love.graphics.getHeight() + 10 
	
	self.fading = false
	
	self.Text.colours.default[4] = 255
end

function credits:draw()
	
	self.Text:draw()
end

function credits:update(dt)
	
	
	self.Text.pos = self.Text.pos + Vector2.Up * dt * self.speed
	
	
	if not self.fading and (self.Text.pos.y) <= self.limit then
		self.fading = true
		StartLerp(self.Text.colours.default, 4, 255,0,3)
		StartTimer(3, EndState, "menu")
	end
end

function credits:keypressed(key)
	if key ~= "m" then
		ClearLerpers()
		ClearTimers()
		EndState("menu")
	end
end

return credits
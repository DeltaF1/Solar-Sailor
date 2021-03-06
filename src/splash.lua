local splash = {}

function splash:load()
	self.images = {
		{t=-1},
		{image=love.graphics.newImage("assets/img/starhopper-splash.png"),t=1.5,},
		{image=love.graphics.newImage("assets/img/filecorrupted-splash.png"),t=1.5},
		{image=love.graphics.newImage("assets/img/love-splash2.png"),t=2,sound=nil},
	}
	for i, v in ipairs(self.images) do
		v.t = v.t + 1 -- Account for fade times
		self.images[i] = v
	end
	
	self.colour = {1,1,1,0}
	self.t = 0
	self.i = 1
	self.test = 0
	
	--RegLerper(self, "test", 0, 10, 10)
end	

function splash:onStart()
	
	self.width = love.window.getWidth()
	self.height = love.window.getHeight()
	
	self.center = Vector2(self.width/2, self.height/2)
	
	
	music:switchTo "menu"

end

function splash:update(dt)
	
	if self.t >= self.images[self.i].t then
		--print("Advancing splash!")
		self.i = self.i + 1
		
		if self.i > #self.images then
			EndState("menu")
			return
		end
		
		
		local s = Sequence({
			[function() StartLerp(self.colour, 4, 0, 1, 0.5) end]=0,
			[function() if self.images[self.i].sound then self.images[self.i].sound:play() end end]=0.5,
			[function() StartLerp(self.colour, 4, 1, 0, 0.5) end]=(self.images[self.i].t - 0.5),
		})
		s:start()
		self.t = 0
	end
	
	
	
	self.t = self.t + dt
	
	--print("[Splash] colour = "+self.colour[1]+","+self.colour[2]+","+self.colour[3]+","+self.colour[4])
end

function splash:keypressed()
	EndState "menu"
end

function splash:draw()
	love.graphics.setColor(self.colour)
	local image = self.images[self.i].image
	love.graphics.draw(image, self.center.x, self.center.y, 0, 1,1, image:getWidth()/2, image:getHeight()/2)
end

return splash
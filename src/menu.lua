local menu = {}

INITIAL_STATE = "menu"

function menu:load()
	
	--self.camera = 
	
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	
	self.frame = Frame(Vector2(), Vector2(width,height))
	
	local startbutton = self.frame:add(Button(Vector2(), Vector2(200,50), {onClick = function() EndState("game", "new") end}))
	  :center()
	startbutton.texts.default="Start"
	
	local socialFrame = self.frame:add(
		Frame(Vector2(), Vector2(150,200))
	)
	socialFrame.rPos.x = self.frame.scale.x - 48
	socialFrame:centerY()
	socialFrame.colours.default = {0, 100, 30}
	socialFrame.startPos = socialFrame.rPos:clone()
	socialFrame.offPos = socialFrame.rPos - Vector2(90,0)
	socialFrame.img = love.graphics.newImage("assets/img/social_tab2.png")
	function socialFrame:draw()
		love.graphics.draw(self.img, self.pos.x, self.pos.y)
	end
	
	local socialFadeTime = 0.2
	
	socialFrame.onDefault = function(self)
		print("entering frame.onDefault")
		if self.transition then EndLerp(self.transition) end
	
		self.transition = StartLerp(self.rPos, "x", self.rPos.x, self.startPos.x, socialFadeTime)
	end
	
	socialFrame.onOver = function(self)
		print("entering frame.onOver")
		if self.transition then EndLerp(self.transition) end
		
		self.transition = StartLerp(self.rPos, "x", self.rPos.x, self.offPos.x, socialFadeTime)
	end
	
	--]]
	self.gui = List{self.frame}
	self.gui:add(self.frame.children)
	self.gui:add(socialFrame.children)
	table.sort(self.gui.items,
	function(i, j)
		return (i.z or 1) < (j.z or 1)
	end
	)
end

function menu:draw()
	--self.camera:draw(function(l,t,w,h)
	self.gui:draw()
	--end)
end

function menu:update(dt)
	self.gui:update(dt)
end

return menu
local menu = {}

INITIAL_STATE = "menu"

local menuButton = Class{__includes=Button}

menuButton.defaultOptions = update(copy(Button.defaultOptions), {
	font = love.graphics.newFont("assets/fonts/Minecraftia.ttf", 44),
	colours = {
		default = {54,107,100},
		over = {68,183,168},
		down = {35,70,65},
	},
})

function menu:load()
	
	--self.camera = 
	
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	
	self.frame = Frame(Vector2(), Vector2(width,height))
	
	self.frame.draw = function() end
	
	local title = self.frame:add(Label("SOLAR SAILOR", Vector2(0, 25), nil, {font=love.graphics.newFont("assets/fonts/Minecraftia.ttf", 92)})):centerX()
	
	local startbutton = self.frame:add(menuButton(Vector2(0,195), Vector2(400,85), {onClick = function() EndState("game", "new") end}))
	startbutton.texts.default="Start Game"
	
	local creditsbutton = self.frame:add(menuButton(Vector2(0, 424), Vector2(283, 85), {onClick = function() EndState("credits") end}))
	creditsbutton.texts.default = "Credits"
	
	local exitbutton = self.frame:add(menuButton(Vector2(0, 652), Vector2(187, 85), {onClick = function() love.event.quit() end}))
	exitbutton.texts.default = "Exit"
	
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
	
	self.player = love.graphics.newImage("assets/img/player.png")
	self.playerPos = Vector2(700, 500)
	self.ox, self.oy = self.player:getWidth()/2, self.player:getHeight()/2
	self.fac = 0.005
	
	self.gui = List{self.frame}
	self.gui:add(self.frame.children)
	self.gui:add(socialFrame.children)
	table.sort(self.gui.items,
	function(i, j)
		return (i.z or 1) < (j.z or 1)
	end
	)
	
	local numStars = 10
	self.stars = {}
	self.off = 0
	self.loop = height + 50
	for i = 1, numStars do
		table.insert(self.stars, {size=math.random(2,5),x=math.random(width),y=math.random(self.loop-1)})
	end
end

function menu:draw()
	
	--draw stars
	love.graphics.setPointStyle "rough"
	for _, star in ipairs(self.stars) do
		love.graphics.setPointSize(star.size)
		love.graphics.point(star.x, ((star.y+(self.off*star.size))%self.loop) - 25)
	end
	
	local x,y = love.mouse.getX(), love.mouse.getY()
	love.graphics.draw(self.player, self.playerPos.x+(x*self.fac), self.playerPos.y+(y*self.fac), 0, 10, nil, self.ox, self.oy)
	self.gui:draw()
end

function menu:update(dt)
	self.gui:update(dt)
	
	self.off = self.off + (dt * 10)
end

return menu
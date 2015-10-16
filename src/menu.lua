local menu = {}

menuButton = Class{__includes=Button}

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
	
	self.Timer = require "humptimer"
	
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	
	self.frame = Frame(Vector2(), Vector2(width,height))
	
	self.frame.draw = function() end
	
	local title = self.frame:add(Label("SOLAR SAILOR", Vector2(0, 25), nil, {font=love.graphics.newFont("assets/fonts/Minecraftia.ttf", 92)})):centerX()
	
	local startY = 195
	local buttonDis = 150
	
	local startbutton = self.frame:add(menuButton(Vector2(0,startY), Vector2(400,85)))
	startbutton.texts.default="Start Game"
	
	startbutton.onClick = function()
		if love.filesystem.exists("startup.txt") then
			EndState("game", "new")
		else
			EndState("story")
		end
	end
	
	local creditsbutton = self.frame:add(menuButton(Vector2(0, startY+buttonDis*1), Vector2(283, 85), {onClick = function() EndState("credits") end}))
	creditsbutton.texts.default = "Credits"
	
	local exitbutton = self.frame:add(menuButton(Vector2(0, startY+buttonDis*3), Vector2(187, 85), {onClick = function() love.event.quit() end}))
	exitbutton.texts.default = "Exit"
	
	local optionsbutton = self.frame:add(menuButton(Vector2(0, startY+buttonDis*2), Vector2(210, 85), {onClick = function()
		--lerp frame
		self.Timer.tween(1, self, {frame={pos={x = self.frame.pos.x+self.frame.scale.x}}, optionsFrame={pos={x = self.optionsFrame.pos.x+self.optionsFrame.scale.x}}}, "in-out-quad")
	end}))
	optionsbutton.texts.default = "Options"
	
	
	local muteLabel = self.frame:add(Label("Press 'M' to mute music",nil,nil,{font=love.graphics.newFont("assets/fonts/Minecraftia.ttf", 11)}))
	muteLabel.rPos = Vector2(width-(muteLabel.font:getWidth(muteLabel.text)+10),height-20)
	
	-- Either add the twitter buttons, or leave this out
	
	self.optionsFrame = Frame(Vector2(-width), Vector2(width,height))
	
	self.optionsFrame.draw = function() end
	
	local backButton = self.optionsFrame:add(menuButton(nil, Vector2(187, 85), {onClick = function()
		self.Timer.tween(1, self, {frame={pos={x = self.frame.pos.x-self.frame.scale.x}}, optionsFrame={pos={x = self.optionsFrame.pos.x-self.optionsFrame.scale.x}}}, "in-out-quad")
	end}), Vector2(self.optionsFrame.scale.x-300, startY+buttonDis*3))
	backButton.texts.default = "Back"
	
	self.optionsFrame:add(Label("Colourblind Mode:", nil, nil, {font=love.graphics.newFont("assets/fonts/Minecraftia.ttf")}), Vector2(70, startY+buttonDis-20))
	
	local _draw = love.draw
	
	local types = {"off", "protanope", "deuteranope", "tritanope"}
	local cb = 0
	local cbButton = self.optionsFrame:add(menuButton(nil, Vector2(370, 85)), Vector2(70, startY+buttonDis))
	
	cbButton.onClick = function(self)
		cb = cb + 1
		if cb > #types then
			cb = 1
		end
		
		local type = types[cb]
		
		if type == "off" then
			love.draw = _draw
		else
			libs.colourblind.daltonize(type)
		end
		
		self.texts.default = type:upper()
		self.text = self.texts.default
	end
	cbButton:onClick()
	--cbButton.texts.default = "Daltonize"
	
	self.optionsFrame:add(Slider(nil, Vector2(250, 20), {min = 30, max = 50}), Vector2(50,200))
	
	self.optionsFrame:add(Label("OPTIONS", nil, nil, {font=title.font})):centerX()
	
	local socialFrame = --self.frame:add(
		Frame(Vector2(), Vector2(150,200))
	--)
	--socialFrame.rPos.x = self.frame.scale.x - 48
	socialFrame:centerY()
	socialFrame.colours.default = {0, 100, 30}
	--socialFrame.startPos = socialFrame.rPos:clone()
	--socialFrame.offPos = socialFrame.rPos - Vector2(90,0)
	socialFrame.img = love.graphics.newImage("assets/img/social_tab2.png")
	function socialFrame:draw()
		love.graphics.draw(self.img, self.pos.x, self.pos.y)
	end
	
	local socialFadeTime = 0.2
	
	socialFrame.onDefault = function(self)
		--print("entering frame.onDefault")
		if self.transition then EndLerp(self.transition) end
	
		self.transition = StartLerp(self.rPos, "x", self.rPos.x, self.startPos.x, socialFadeTime)
	end
	
	socialFrame.onOver = function(self)
		--print("entering frame.onOver")
		if self.transition then EndLerp(self.transition) end
		
		self.transition = StartLerp(self.rPos, "x", self.rPos.x, self.offPos.x, socialFadeTime)
	end
	
	--]]
	
	self.player = love.graphics.newImage("assets/img/player.png")
	self.playerPos = Vector2(700, 500)
	self.time = 0
	self.ox, self.oy = self.player:getWidth()/2, self.player:getHeight()/2
	self.fac = 2
	
	self.gui = List{self.frame}
	self.gui:add(self.frame.children)
	self.gui:remove(socialFrame)
	
	self.gui:add(self.optionsFrame)
	self.gui:add(self.optionsFrame.children)
	--self.gui:add(socialFrame.children)
	table.sort(self.gui.items,
	function(i, j)
		return (i.z or 1) < (j.z or 1)
	end
	)
	
	local numStars = 69
	self.stars = {}
	self.off = 0
	self.loop = height + 50
	for i = 1, numStars do
		table.insert(self.stars, {size=math.random(2,5),x=math.random(width),y=math.random(self.loop-1)})
	end
	
	self.gui:update()
end

function menu:onStart()
	ClearTimers()
	ClearLerpers()
	if not MENUMUSIC:isPlaying() then
		StartLerp(_G, "GAMEVOLUME", 1, 0, 1)
		StartTimer(1,function()
			MENUMUSIC:play()
			if MUTED then MENUMUSIC:pause() end
			StartLerp(_G, "MENUVOLUME", 0,1,1)
			GAMEMUSIC:stop()
		end)
	end
end

function menu:drawStars()
	love.graphics.setPointStyle "rough"
	for _, star in ipairs(self.stars) do
		love.graphics.setPointSize(star.size)
		love.graphics.point(star.x, ((star.y+(self.off*star.size))%self.loop) - 25)
	end
end

function menu:draw()
	
	--draw stars
	self:drawStars()
	
	
	love.graphics.draw(self.player, self.playerPos.x, self.playerPos.y+(math.cos(self.time)*self.fac), 0, 10, nil, self.ox, self.oy)

	self.gui:draw()
end

function menu:update(dt)
	self.gui:update(dt)
	
	self.Timer.update(dt)
	
	self.off = self.off + (dt * 10)
	self.time = self.time + dt
end

return menu
local menu = {}

INITIAL_STATE = "menu"

function menu:load()
	
	--self.camera = 
	
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()
	
	self.frame = Frame(Vector2(), Vector2(width,height))
	
	local startbutton = self.frame:add(Button(Vector2(), Vector2(200,50), {onClick = function() EndState("game") end}))
	  :center()
	startbutton.texts.default="Start"
	
	local frame = self.frame:add(
		Frame(Vector2(0,-90), Vector2(250,100))
		:centerX()
	)
	frame.colours.default = {0, 100, 30}
	frame.startPos = frame.rPos:clone()
	frame.offPos = frame.rPos + Vector2(0,90)
	frame.onDefault = function(self)
		print("entering frame.onDefault")
		if self.transition then EndLerp(self.transition) end
	
		self.transition = StartLerp(self.rPos, "y", self.rPos.y, self.startPos.y, 0.5)
	end
	
	frame.onOver = function(self)
		print("entering frame.onOver")
		if self.transition then EndLerp(self.transition) end
		
		self.transition = StartLerp(self.rPos, "y", self.rPos.y, self.offPos.y, 0.5)
	end
	
	local showOtherButton = frame:add(Button(Vector2(), Vector2(50,20)), Vector2(0,10))
	showOtherButton:centerX()
	showOtherButton.texts = {}
	showOtherButton.colours.default = {255,255,255}
	showOtherButton.onClick = function()
		otherFrame:show()
	end
	otherFrame = self.frame:add(
		Frame(Vector2(-100,0), Vector2(100,100))
	):centerY()
	otherFrame.colours.default = {0,0,100}
	
	function otherFrame:show()
		StartLerp(self.rPos, "x", self.rPos.x, self.rPos.x+100, 0.5)
	end
	
	self.gui = List({self.frame, unpack(frame.children.items), unpack(self.frame.children.items)})
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
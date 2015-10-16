--buttonClick = love.audio.newSource("sound/buttonClick.wav","static")

--Button(pos, scale, {})
--Button.onClick = function()

--Frame(pos, scale, options)
--Gui:update(dt)
--for i in children:
--	i.pos = self.pos+i.pos

--Frame:addElement(element)

--Frame:removeElement(element)

--[[

REWRITE AS A GUI LIBRARY, USING hump.class TO PROVIDE INHERITANCE

GUI
-pos
-scale
-center

GUI > FRAME 
-children

GUI > BUTTON
-onClick
-colours
-images
-texts --Maybe rewrite to use Labels instead?

GUI > LABEL
-text
--]]

Class = libs["class"]

Gui = Class{}

Gui.defaultOptions = {}

function Gui:init(pos, scale, options)
	self.pos=pos or self.pos or Vector2()
	self.scale=scale or self.scale or Vector2()
	self.z = 0
	
	options = options or {}
	
	self.options = copy(self.defaultOptions)
	update(self.options, options)
	
end

function Gui:setState(state)
	local state = state or "default"
	if state == self.state then
		--No change, return
		return
	end
	
	
	if self.colours then
		self.colour = self.colours[state] or self.colours["default"]
	end
	
	if self.images then
		self.image = self.images[state] or self.images["default"]
	end
	
	if self.texts then
		self.text = self.texts[state] or self.texts["default"]
	end
	
	local callbackName = "on" + state:capitalize()
	if self[callbackName] then
		self[callbackName](self)
	end
	
	self.state = state
end

function Gui:mousehover(x, y)
	if not self.rect then
		--print(self.name)
	end
	if self.rect:contains(Vector2:new(x,y)) then

		if (not self.down) then
			self:setState("over")
		end
	else

		self:setState()
		self.down = false
		
	end
end

function Gui:mousepressed(x, y, button)
	if self.rect:contains(Vector2:new(x,y)) then
		self:setState("down")
		self.down = true
	else
		self:setState()
	end
end

function Gui:mousereleased(x,y,button)
	if self.down then
		self:setState("over")
		
		if self.sound then
			self.sound:stop()
			self.sound:play()
		end
		
		if self.onClick then
			self.onClick(self, x,y,button)
		end
	else
		--We released outside the button
		self:setState()
	end
end

function Gui:update()
	self.rect = Rect:new(self.pos.x, self.pos.y, self.scale.x, self.scale.y)
end

function Gui:centerX()
	if self.parent then
		self.parent:centerX(self)
	else
		self.pos.x = (love.window.getWidth()/2) - (self.scale.x/2)
	end
	return self
end

function Gui:centerY()
	if self.parent then
		self.parent:centerY(self)
	else
		self.pos.y = (love.window.getHeight()/2) - (self.scale.y/2)
	end
	return self
end

function Gui:center()
	self:centerX()
	self:centerY()
	return self
end



Frame = Class{__includes=Gui}

Frame.defaultOptions = 
{
	children = {},
	colours = {
		default = {50,50,50}
	}
}

function Frame:init(pos, scale, options)
	Gui.init(self, pos, scale, options)
	
	self.colours = self.options.colours
	
	self.children = List(self.options.children)
end

function Frame:add(e, r)
	return self:addElement(e,r)
end

function Frame:addElement(element, rPos)
	self.children:add(element)
	element.parent = self
	element.rPos = rPos or element.pos - self.pos
	element.pos = self.pos + element.rPos
	return element
end

function Frame:removeElement(element)
	self.children:remove(element)
	return element
end

function Frame:centerX(element)
	if not element then
		Gui.centerX(self)
		return self
	else
		element.rPos.x = (self.scale.x/2) - (element.scale.x/2)
		return element
	end
end

function Frame:centerY(element)
	if not element then
		Gui.centerY(self)
		return self
	else
		element.rPos.y = (self.scale.y/2) - (element.scale.y/2)
		return element
	end
end

function Frame:center(element)
	self:centerX(element)
	self:centerY(element)
	if not element then return self end
	return element
end

function Frame:updatePositions()
	for i, child in ipairs(self.children.items) do
		child.pos = self.pos + child.rPos
	end
end

function Frame:update(dt)
	Gui.update(self)
	self:updatePositions()
end

function Frame:draw()
	love.graphics.setColor(self.colours.default)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.scale.x, self.scale.y)
end

-- Label class
---------------
-- Displays text

Label = Class{__includes=Gui}


Label.defaultOptions =
{
	font = love.graphics.newFont(12),
	colours = {
		default={255,255,255}
	}
}


function Label:init(text, pos, scale, options)
	Gui.init(self, pos, scale, options)
	
	self.text = text
	
	self.font = self.options.font
	
	self.scale = Vector2(self.font:getWidth(self.text), self.font:getHeight())
end

function Label:draw()
	love.graphics.setColor(self.options.colours.default)
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, self.pos.x, self.pos.y)--, 0, self.scale.x, self.scale.y)
end

function Label:setText(t)
	self.text = t
	self:updateScale()
end

function Label:updateScale()
	self.scale = Vector2(self.font:getWidth(self.text), self.font:getHeight())
end

-- TextBox class
----------------
-- displays large amounts of text, wrapped to scale

TextBox = Class{__includes=Gui}

TextBox.defaultOptions = 
{
	font = love.graphics.newFont(12),
	colours = {
		default={255,255,255}
	},
	backgrounds = {
		default = {0,0,0,0}
	},
	align = "left"
}

function TextBox:init(text, pos, scale, options)
	Gui.init(self, pos, scale, options)
	
	for _, i in ipairs({"images", "colours", "texts"}) do
	
		if self.options[i] then
			self[i] = self.options[i]
		end
		
	end
	
	self.text = text
	
	self.font = self.options.font
end

function TextBox:setText(t)
	self.text = t
end

function TextBox:draw()
	love.graphics.setColor(self.options.colours.default)
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, self.pos.x, self.pos.y, self.scale.x, self.options.align)
end

-- Slider Class
----------------
-- 

Slider = Class{__includes=Gui}

Slider.defaultOptions = {
	colours = {
		full = {0, 100, 200},
		empty = {0, 100, 130}
	}
}

function Slider:init(pos, scale, options)
	Gui.init(self, pos, scale, options)
	
	self.min = self.options.min
	self.max = self.options.max
	self.value = self.options.value or self.min+((self.max-self.min)/2)
	
	self.colours = self.options.colours
end

function Slider:draw()
	love.graphics.setColor(self.colours.empty)
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.scale.x, self.scale.y)
	
	love.graphics.setColor(self.colours.full)
	
	local percent = (self.value - self.min) / (self.max-self.min)
	
	love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.scale.x*percent, self.scale.y)
	love.graphics.setColor(255,255,255)
	love.graphics.print("value = "..self.value, self.pos.x, self.pos.y+4)
end

function Slider:onDown()	
	self.sliding = true
end

function Slider:update(dt)

	Gui.update(self, dt)
	
	if self.sliding then
	local pos = Vector2(love.mouse.getPosition())
	
	local percent = (pos.x-self.pos.x)/(self.scale.x)
	self.value = math.clamp(self.min + (percent * (self.max-self.min)), self.min, self.max)
	end
	
	if not love.mouse.isDown("l") then self.sliding = false end
	
end

-- Button class
----------------
-- Has a .onClick callback, called when mouse is released over button

Button = Class{__includes=Gui}

Button.defaultOptions = 
{
	colours=
	{
		default={100,0,100},
		over={100,0,120},
		down={90,0,90}
	},
	texts={
		default="blah"
	},
	onClick = false, -- Replace with function, or do button.onClick = function() ... end
	font = love.graphics.newFont(20)
}


function Button:init(pos, scale, options)
	
	Gui.init(self, pos, scale, options)
	
	self.onClick = self.options.onClick
	self.font = self.options.font
	self.sound = self.options.sound
	
	for _, i in ipairs({"images", "colours", "texts"}) do
	
		if self.options[i] then
			self[i] = self.options[i]
		end
		
	end
	
	self.rect = Rect:new(self.pos.x, self.pos.y, self.scale.x, self.scale.y)
end

--[[
function Button:new(pos, mousepressed, graphics, textobj, scale)
	local o = {}
	
	o.f = mousepressed

	o.pos = pos
	o.rect = Rect:new()
	o.textObj = textobj
	o.scale = scale or Vector2:new(1,1)
	o.type = "Button"
	--print("Scaling factors of "..o.scale.x.." and "..o.scale.y)
	

	
	o.rect = Rect:new(pos.x, pos.y, w*o.scale.x, h*o.scale.y)
	o.down = false
	
	if o.textObj then
		
		off = Vector2:new(o.textObj.width, o.textObj.height)/2
		o.textObj.pos = o.rect.center - off
		
	end
	
	--print("Created Button at point ")
	--print(o.pos)
	
	return setmetatable(o, self)
end
--]]

function Button:draw()
	
	local center = self.pos + (self.scale/2)
	
	if self.colour then
		love.graphics.setColor(self.colour)
		love.graphics.rectangle("fill", self.pos.x, self.pos.y, self.scale.x, self.scale.y)
	end
	
	if self.image then
		love.graphics.setColor(255,255,255)
		
		local pos = center
		local off = Vector2(self.image:getWidth(), self.image:getHeight())/2
		
		
		local scale = Vector2(self.scale.x/self.image:getWidth(), self.scale.y/self.image:getHeight())
		
		love.graphics.draw(self.image, pos.x, pos.y, 0, scale.x, scale.y, off.x, off.y)
	end
	
	if self.text then
		local width = self.font:getWidth(self.text)
		local height = self.font:getHeight()
		
		love.graphics.setFont(self.font)
		--replace with font colouring
		love.graphics.setColor(255,255,255)
		
		love.graphics.print(self.text, center.x, center.y, 0, 1,1, width/2, height/2)
	end
	
	--[[
	love.graphics.setColor(255,255,255)
	
	love.graphics.draw(self.graphic, self.pos.x, self.pos.y, 0, self.scale.x, self.scale.y)
	
	if self.textObj then
		
		self.textObj:draw()
		
	end
	--]]
end
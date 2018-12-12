


function genColor()
	return {love.math.random(0,1),love.math.random(0,1),love.math.random(0,1)}
end

GenericDrawable = {}

function GenericDrawable:new(pos, image, scale)
	local o = {}
	
	o.pos = pos
	o.image = image
	o.scale = scale or Vector2:new(1,1)
	
	self.__index = self
	return setmetatable(o, self)
end

function GenericDrawable:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.image, self.pos.x, self.pos.y, 0, self.scale.x, self.scale.y)
	
end

RectangleDrawable = {}

function RectangleDrawable:new(pos, scale, color)
	local o = {}

	o.pos = pos
	o.scale = scale
	o.color = color
	
	self.rect = Rect:new(pos.x,pos.y, scale.x,scale.y)
	
	self.__index = self
	return setmetatable(o, self)
end

function RectangleDrawable:draw()
	
	love.graphics.setColor(self.color)
	
	love.graphics.rectangle("fill", self.rect)
	
end

TextObject = {}

function TextObject:new(pos, text, font, wrapOptions, colour)
	local o = {}
	
	o.pos=pos
	
	
	
	
	o.text=text
	o.font=font
	o.wrap = wrapOptions
	
	o.color = colour or {1,1,1}
	
	o.width = o.font:getWidth(o.text)
	o.height = o.font:getHeight()
	
	self.__index = self
	return setmetatable(o, self)
end

function TextObject:draw(x, y)
	
	dx = x or self.pos.x

	dy = y or self.pos.y
	
	love.graphics.setFont(self.font)
	
	love.graphics.setColor(self.color)
	
	if self.wrap then
		love.graphics.printf(self.text, dx,dy, self.wrap.limit, self.wrap.align)
	else
		love.graphics.print(self.text, dx,dy)
	end
end

--Create "HoverBox" lerps scale when hovered over (mousehover) also, recalculate Rect

HoverBox = {}

function HoverBox:new(pos, content, scale1, scale2, center)
	
	local o = {}
	
	o.pos = pos
	o.origPos = pos
	o.content = content
	o.scale1 = scale1
	o.scale2 = scale2
	o.scale = scale1
	o.center = center or false
	
	o.rect = Rect:new(pos.x,pos.y, o.content:getWidth()*scale1.x, o.content:getHeight()*scale1.y)
	
	self.__index = self
	return setmetatable(o, self)
end

function HoverBox:mousehover(x,y)
	
	if self.rect:contains(x,y) then
		if self.scale == self.scale1 then
			self.scale = self.scale2
			
			newW = self.content:getWidth()*self.scale.x
			newH = self.content:getHeight()*self.scale.y
			
			if self.center then
				self.origPos = self.pos
				newPos = self.pos + Vector2:new(newW - self.content:getWidth(), newH - self.content:getHeight())
				self.pos = newPos
			end
			
			self.rect = Rect:new(self.pos.x,self.pos.y, newW, newH)
		end
	else
		if self.scale == self.scale2 then
			self.scale = self.scale1
			
			if self.center then
				self.pos = self.origPos
			end
			
			self.rect = Rect:new(self.pos.x,self.pos.y, self.content:getWidth()*self.scale.x, self.content:getHeight()*self.scale.y)
		end
	end
	
end

function HoverBox:draw()
	
	if self.content.draw then
		
		self.content:draw(self.pos, self.scale)
		
	
	else
		love.graphics.draw(self.content, self.pos.x, self.pos.y, 0, self.scale.x, self.scale.y)
	end
end
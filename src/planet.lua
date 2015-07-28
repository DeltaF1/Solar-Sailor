local planet = {}

function planet:load()
	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	
	self.frame = Frame(Vector2(), Vector2(200,400))
	self.frame:center()
	
	self.gui = List{self.frame}
end

function planet:draw()
	states["game"]:draw()
	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0,0, self.width, self.height)
	
	self.gui:draw()
end

function planet:update(dt)
	self.gui:update(dt)
end



function planet:onStart(p)
	print("starting state planet!")
	self.gui = List{self.frame}
	-- Show its name
	if not p.quest then
		-- Some flavor text?
		-- Exit button
	elseif p.quest.send then
		-- 'send' flavor text
		-- List current weight etc.
		-- show resource being loaded
		-- Accept and Decline buttons
	elseif p.quest.receive then
		-- 'receive' flavor text
		-- List curent weight etc.
		-- Show people being added
		-- Exit button
	elseif p.quest.people then
		-- 'stranded' flavor text
		-- List curent weight etc.
		-- Show people being added
		-- Exit button
	end
	
	l = self.frame:add(Label(p.name)):center()
	l:setText(p.name)
	self.gui:add(l)
end

function planet:keypressed(key)
	if key == "escape" then EndState("game") end
end

return planet
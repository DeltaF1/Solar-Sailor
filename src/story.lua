local story = {}

function story:load()
	local text = [[
	Welcome to Solar Sailor
	
	Your star system is dying.
	
	Billions of people fled its fiery reach in droves, but many more are left trapped, helpless in the face of the impending inferno. Your vessel has been commanded to aid in the rescue attempt. You can't save them all, and you must survive long enough to escape the system.
	
	
	
	
	
	
	
	
	Use 'a' and 'd' or left and right to rotate, and 'w', up, or space to thrust forwards. Red headings indicate quest-giving planets, green indicate the target of a quest. Avoid asteroids and the ever-expanding sun
	]]
	self.text = TextBox(text, nil, nil, {align="center", font=love.graphics.newFont(18)})
	local _, lines = self.text.font:getWrap(text, width/2)
	local height = self.text.font:getHeight()
	print("lines, height, lines*height = "..lines..", "..height..", "..lines*height)
	self.text.scale = Vector2(width/2, lines*height)
	self.text:center()
end

function story:onStart()
	love.filesystem.write("startup.txt", "Delete this file to see the instructions at the beginning again!")
	--self.text:center()
end

function story:draw()
	self.text:draw()
end

function story:keypressed()
	EndState("game", "new")
end

return story
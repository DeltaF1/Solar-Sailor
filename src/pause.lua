local pause = {}

function pause:load()
	
	self.frame = Frame(nil, Vector2(500,800)):center()
	self.frame.colours.default = {0,20/255,20/255}
	
	self.frame:add(Label("PAUSED", Vector2(0,50),nil, {font=love.graphics.newFont("assets/fonts/Minecraftia.ttf", 45)}):centerX())
	
	local menu = self.frame:add(menuButton(Vector2(), Vector2(150,85), {font=love.graphics.newFont("assets/fonts/Minecraftia.ttf", 30)})):center()
	menu.onClick = function() EndState("menu") end
	menu.texts.default = "Menu"
	
	self.gui = List{self.frame}
	self.gui:add(self.frame.children)
end

function pause:draw()
	
	states.menu:drawStars()
	
	self.gui:draw()
end

function pause:update(dt)
	self.gui:update(dt)
	states.menu:update(dt)
end

function pause:keypressed(key)
	if key == "escape" then
		EndState("game")
	end
end

return pause
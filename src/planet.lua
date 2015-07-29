local planet = {}

local fontName = ""

local planetLabel = Class{__includes=Label}

planetLabel.defaultOptions = 
{
	font = love.graphics.newFont(18),
	colours = {default={222,239,215}}
}

local planetButton = Class{__includes=Button}

planetButton.scale = Vector2(160,50)

planetButton.defaultOptions = 
update(copy(Button.defaultOptions),
	{
		colours = 
		{
			default = {75,102,64}
		}
	}
)

local Text = require "popo"

local planetTextBox = Class{__includes=TextBox}

function planetTextBox:init(text, pos, scale, options)
	Gui.init(self, pos, scale, options)
	
	self:setText(text)
end

function planetTextBox:setText(text)
	self.text = Text(self.pos.x, self.pos.y, text, {
		font = self.options.font,
		
		colour = function(dt, c, r, g, b, a)
			if not r then
				love.graphics.setColor(self.options.colours.default)
			else
				love.graphics.setColor(r,g,b,a)
			end
		end,
		
		wrap_width = self.scale.x
	})
end

function planetTextBox:update(dt)
	TextBox.update(self, dt)
	self.text:update(dt)
end

function planetTextBox:draw()
	love.graphics.setColor(self.options.colours.default)
	self.text:draw(self.pos.x, self.pos.y)
end

function planet:load()
	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	
	self.frame = Frame(Vector2(), Vector2(500,600),
	{
		colours={
			default = {107,126,99}
			}
	}
	)
	self.frame:center()
	
	self.nameLabel = self.frame:add(planetLabel("planet"), Vector2(10,10))
	self.descLabel = self.frame:add(planetLabel("desc"), Vector2(10, 40))
	self.acceptButton = self.frame:add(planetButton(nil, nil, {texts={default="Accept"}}), Vector2(25, 530))
	self.acceptButton.onClick = function()
		-- Do questy stuff
		-- p.quest = nil
		EndState("game")
	end
	
	self.declineButton = self.frame:add(planetButton(nil, nil, {texts={default="Decline"}}), Vector2(25, 530))
	self.declineButton.onClick = function()
		-- Do questy stuff
		-- p.quest = nil
		EndState("game")
	end
	
	local offX = 50
	self.declineButton.rPos.x = 50
	self.acceptButton.rPos.x = self.frame.scale.x - (50 + self.acceptButton.scale.x)
	
	-- local offX = something else
	self.messageFrame = self.frame:add(Frame(Vector2(), Vector2(self.frame.scale.x-(2*offX), 160)), Vector2(offX, 80))
	self.messageFrame.colours.default = planetButton.defaultOptions.colours.default
	
	local textborder = 10
	self.messageText = self.messageFrame:add(planetTextBox(("test "*30), nil, Vector2(self.messageFrame.scale.x-textborder, self.messageFrame.scale.y-textborder))):center()
	
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
	self.gui:add(self.frame.children)
	self.gui:add(self.messageFrame.children)
	--self.gui:add(self.manifestFrame.children)
	
	self.nameLabel:setText(p.name)
	-- Show its name
	if not p.quest then
		-- Some flavor text?
		-- Exit button
		 self.descLabel:setText(string.replace("A desolate world, {name} is bereft of life.", {name=p.name}))
		
	elseif p.quest.send then
		-- 'send' flavor text
		-- List current weight etc.
		-- show resource being loaded
		-- Accept and Decline buttons
		self.messageText:setText(
			string.replace("The planet [{name}](colour: 255,0,0)[ ](colour)is in desperate need of some [{resource}](colour: 0,100,255)[!](colour)",
			p.quest.send
			)
		)
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
end

function planet:keypressed(key)
	if key == "escape" then EndState("game") end
end

return planet
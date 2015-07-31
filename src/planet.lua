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
	Gui.update(self, dt)
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
	self.descLabel.font = love.graphics.newFont(12)
	
	self.sectorLabel = self.frame:add(planetLabel("Sector: "), Vector2(400, 10))
	
	self.acceptButton = self.frame:add(planetButton(nil, nil, {texts={default="Accept"}}), Vector2(25, 530))
	self.acceptButton.onClick = function()
		-- Do questy stuff
		-- p.quest = nil
		
		local p = self.planet
		
		if self.q then
			if p.quest.send then
				states["game"]:addQuestPlanet(p, 7)
			end
		
			if p.quest.send or p.quest.receive then
				player:addResources(p.quest[self.q].resource, p.quest[self.q].quantity)
			end
		end
		
		p.quest = nil
		
		EndState("game",self.planet)
	end
	
	self.declineButton = self.frame:add(planetButton(nil, nil, {texts={default="Decline"}}), Vector2(25, 530))
	self.declineButton.onClick = function()
		-- Do questy stuff
		-- p.quest = nil
		EndState("game",self.planet)
	end
	
	local offX = 50
	self.declineButton.rPos.x = 50
	self.acceptButton.rPos.x = self.frame.scale.x - (50 + self.acceptButton.scale.x)
	
	-- local offX = something else
	self.messageFrame = self.frame:add(Frame(Vector2(), Vector2(self.frame.scale.x-(2*offX), 160)), Vector2(offX, 80))
	self.messageFrame.colours.default = planetButton.defaultOptions.colours.default
	
	local textborder = 10
	self.messageText = self.messageFrame:add(planetTextBox(("test "*30), nil, Vector2(self.messageFrame.scale.x-textborder, self.messageFrame.scale.y-textborder))):center()
	
	self.manifestFrame = self.frame:add(Frame(Vector2(), Vector2(self.frame.scale.x-(2*offX), 190)), Vector2(offX, 260))
	self.manifestFrame.colours.default = planetButton.defaultOptions.colours.default
	
	self.manifestText = self.manifestFrame:add(planetTextBox(("test "*30), nil, Vector2(self.manifestFrame.scale.x-textborder,
	self.manifestFrame.scale.y-textborder))):center()
	
	
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

messages = require "planet_messages"

function planet:onStart(p)
	print("got "..Tserial.pack(p, tostring).." as an argument")
	self.planet = p
	print("starting state planet!")
	print("planet.name = "..self.planet.name)
	self.gui = List{self.frame}
	self.gui:add(self.frame.children)
	self.gui:add(self.messageFrame.children)
	self.gui:add(self.manifestFrame.children)
	
	self.nameLabel:setText(p.name)
	self.sectorLabel:setText("Sector: "+states["game"]:sector((p.pos-sun.pos):len()))
	
	local s = p.desc or string.replace(randomSelect(messages.desc), {name=p.name,adj=randomSelect(messages.adj),noun=randomSelect(messages.noun)})
	self.descLabel:setText(s)
	p.desc = s
	local s = ""
	local q = nil
	
	if not p.quest then
		-- Some flavor text?
		-- Exit button
		s = "NO DATA"
		
		self.manifestText:setText(" ")
	elseif p.quest.send then
		-- 'send' flavor text
		-- List current weight etc.
		-- show resource being loaded
		-- Accept and Decline buttons
		q = "send"
		

	elseif p.quest.receive then
		-- 'receive' flavor text
		-- List curent weight etc.
		-- Show people being added
		-- Exit button
		
		q = "receive"
		
	elseif p.quest.survivors then
		-- 'stranded' flavor text
		-- List curent weight etc.
		-- Show people being added
		-- Exit button
		q = "survivors"
	end
	if q then
		s = p.text or randomSelect(messages[q])

		s = string.replace(s, p.quest[q])
		
		quantity = p.quest[q].quantity
		
		self.manifestText:setText(p.quest[q].resource+(quantity > 0 and "+" or "-" )+math.abs(quantity))
	end
	
	self.messageText:setText(s)
	
	p.text = s
	-- update manifest
	
	self.q = q
end

function planet:keypressed(key)
	if key == "escape" then EndState("game") end
end

return planet
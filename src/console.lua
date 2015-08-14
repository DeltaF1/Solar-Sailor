local console = {}

function console:load()
	console.prompt = ">"
	console.text = ""
	console.output = {}
	console.outputLimit = 10

	console.history = {}
	console.historyIndex = 1
	console.inHistory = false
	
	console.macros = {}
	console.backspacing = false
	console.backrepeating = false
	console.backRepeat = 0.05
	console.backWait = 0.1
	console.t = 0
	
	console.font = love.graphics.newFont(12)
	
	--_--print = --print
	
	function consolePrint(...)
		console:addOutput(tostring(...))
		--_--print(tostring(...))
	end
end

function console:onStart(state)
	console.prevstate = state
	console.width = love.window.getWidth()
	console.height = love.window.getHeight()
	bottom = (console.height / 4) - 20
end

function console:update(dt)
	--client:update(dt)
	if console.backspacing then
		console.t = console.t + dt
		if not console.backrepeating and console.t >= console.backWait then
			console.backrepeating = true
			console.t = 0
		end

		if console.backrepeating then
			if console.t >= console.backRepeat then
				console.text = console.text:sub(1, #console.text - 1)
				console.t = 0
			end
		end
	end
	
	
end

function console:addOutput(text)
	if not text then return end

	table.insert(self.output ,1, text)
	
	if #self.output > self.outputLimit then
		table.remove(self.output, self.outputLimit+1)
	end
end

function console:draw()
	local prevState = states[console.prevstate]:draw()

	love.graphics.setColor(0,0,0,100)
	love.graphics.rectangle("fill", 0,0,console.width, console.height/4)
	
	love.graphics.setFont(console.font)
	love.graphics.setColor(255,255,255)
	love.graphics.print(console.prompt..console.text, 50, bottom)
	
	for i, text in ipairs(console.output) do
		love.graphics.print(text, 50, bottom - (i * 15) )
	end
	
end

function console:keypressed(key)

	if (key == "v" or key == "c") and love.keyboard.isDown("rctrl", "lctrl", "rgui", "lgui") then
		if key == "v" then
			console.text = love.system.getClipboardText()
		elseif key == "c" then
			love.system.setClipboardText(console.text)
		end
		
		return
	end

	if key == "`" or key == "escape" then
		EndState(console.prevstate)
	elseif key == "up" then
		console.text = console.history[console.historyIndex] or ""
		
		console.inHistory = true
		
		if console.inHistory then
			console.historyIndex = console.historyIndex + 1
		end

		
	elseif key == "return" then
		
		parts = split(console.text)
		
		if console.macros[parts[1]] then
			console.text = console.macros[parts[1]]
		end
		
		if console.text == "quit" then
			love.event.quit()
		else
			--print = consolePrint
			local status, err = pcall(loadstring(console.text))
			--print = _--print
			
			if not status then
				console:addOutput(err)
			end
		end	
		--console:addHistory(console.text)
		table.insert(console.history, 1, console.text)
		console.text = ""
	elseif key == "backspace" then
		console.backspacing = true
		console.text = console.text:sub(1, #console.text - 1)
	end

	if key ~= "up" then
		console.historyIndex = 1
		console.inHistory = false
	end
	
	
end

function console:keyreleased(key)
	if key == "backspace" then
		--print("Backspace released!!!!")
		console.backspacing = false
		console.backrepeating = false
		console.t = 0
	end
end

function console:textinput(t)
	--To avoid typing ` everytime we start the console...
	if t == "`" then
		return
	end
	
	if type(t) == 'table' then
		for _, v in ipairs(t) do
			console.text = console.text..v
		end
	else
		console.text = console.text..t
	end
end

return console
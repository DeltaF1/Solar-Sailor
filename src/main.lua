req = require("project")

--LIBRARIES Start
	
	--Table to hold return values of libraries
	libs = {}

	libraries = req.libs

	for _, v in ipairs(libraries) do
		print("Importing library \""..v.."\"")
		libs[v]=require(v)
		if v == "class" then
			Class = libs["class"]
		end
	end

	control = libs["control"]
	--loveframes = libs["loveframes"]
	--UI = require("ui.UI")
	--Theme = require("theme")
	
--LIBRARIES End

--STATES Start
	modules = req.states

	STATE = ""

	DEFAULT_STATE = ""
	INITIAL_STATE = ""

	states = {}

	function RegState(state, mod)
		print("New state registered: "..state)
		states[state]=mod
	end

	function RegDefaultState(state)
		DEFAULT_STATE = state
	end

	function RegInitialState(state)
		INITIAL_STATE = state
	end

	function EndState(state, args)
		if not state then
			state = DEFAULT_STATE
		end
		
		PREVSTATE = STATE
		STATE = state
		
		states[STATE].prevstate = PREVSTATE
		
		--loveframes.SetState(STATE)
		
		if states[STATE].onStart then
			states[STATE]:onStart(args)
		end
	end


	--require modules here

	stateOrder = {}

	for _, v in ipairs(modules) do
		table.insert(stateOrder, v)
		states[v] = require(v)
	end


--STATES End

--CONSTANTS Start
Constants = {}

	function SetConst(name, val)
		Constants[name] = val
	end

	function GetConst(name)
		return Constants[name]
	end

--CONSTANTS End

--TIMERS Start
timers = {}

function RegTimer(length, f, args, loop)
	
	print("Registered Timer in state "..STATE)
	
	_t = Timer:new(length, f, args, loop)
	
	if(timers[STATE]) then
		timers[STATE]:add(_t)
	else
		timers[STATE] = List({_t})
	end
	
	return _t
end

function DelTimer(t)
	
	timers[_state or STATE]:remove(t)
	
end

function ClearTimers()
	timers[STATE] = List()
end

--TIMERS End

--LERPING Start

lerpers = {}

function RegLerper(...)
	
	_l = Lerper:new(...)
	--print("Starting lerper with path "+_l.path)
	if lerpers[STATE] then
		lerpers[STATE]:add(_l)
	else
		lerpers[STATE] = List({_l})
	end
	
	return _l
end

function StartLerp(...)
	return RegLerper(...)
end

function DelLerper(l)
	
	lerpers[STATE]:remove(l)
	
end

function EndLerp(...)
	DelLerper(...)
end

function ClearLerpers()
	lerpers[STATE] = List()
end


--LERPING End

function love.load()
	
	--Set up Constants like the Player, and other graphical entities
	
	--UI.registerEvents()
	
	for _, name in ipairs(stateOrder) do
		
		STATE = name
		v = states[STATE]
		print("Loading "..name)
		if v.load then
			--loveframes.SetState(STATE)
			--print("loveframes.state="+loveframes.GetState())
			v:load()
		end
	end
	
	STATE = INITIAL_STATE
	
	--loveframes.SetState(STATE)
	
	if states[STATE].onStart then
		states[STATE]:onStart()
	end
	
	
end

function love.update(dt)
	_state = STATE
	--main updating
	if(timers[_state]) then
		timers[_state]:update(dt)
	end
	
	if lerpers[_state] then
		lerpers[_state]:update(dt)
	end
	
	if states[_state].update then
		states[_state]:update(dt)
	end
	
	if states[_state].gui then
		local x,y = love.mouse.getPosition()
		states[_state].gui:mousehover(x,y)
	end
	
	--loveframes.update(dt)
	
end

function love.draw()
	--TLfres.transform()
	if states[STATE].draw then
		states[STATE]:draw()
	end
	
	--loveframes.draw()
	--TLfres.letterbox()
end

function love.keypressed(key, isRepeat)
	
	if key == "`" then
		if states["console"] and STATE ~= "console" then
			EndState("console", STATE)
			return
		end
	end
	
	control.keypressed(key, isRepeat)
	
	if states[STATE].keypressed then
		print("Entering keypressed of "..STATE)
		states[STATE]:keypressed(key)
	end
	
	--loveframes.keypressed(key, isRepeat)
end

function love.keyreleased(key)
	
	if states[STATE].keyreleased then
		states[STATE]:keyreleased(key)
	end
	
	--loveframes.keyreleased(key)
end

function love.mousepressed(x,y,button)

	control.mousepressed(x,y,button)
	
	if states[STATE].gui then
		states[STATE].gui:mousepressed(x,y,button)
	end
	
	if states[STATE].mousepressed then
		states[STATE]:mousepressed(x,y,button)
	end
	
	--loveframes.mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)

	if states[STATE].gui then
		states[STATE].gui:mousereleased(x,y,button)
	end
	
	if states[STATE].mousereleased then
		states[STATE]:mousereleased(x,y,button)
	end
	
	
	--loveframes.mousereleased(x,y,button)
end

function love.textinput(t)
	
	if states[STATE].textinput then
		states[STATE]:textinput(t)
	end
	
	--loveframes.textinput(t)
end

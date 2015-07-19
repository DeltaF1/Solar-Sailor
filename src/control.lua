local c =
{
	
	devices =
	{
		k=
		{
			isDown=love.keyboard.isDown
		},
		m=
		{
			isDown=love.mouse.isDown
		}
	},
	map = {binds={}, k={}, m={}},
	enabled = true,
	callbacks =
	{
		keypressed = {},
		keyreleased = {},
		mousepressed = {},
		mousereleased = {}
	}
}

function c.setMap(m)
	c.map = m
end

function c.enable()
	c.enabled = true
end

function c.disable()
	c.enabled = false
end

function c.toggle()
	c.enabled = not c.enabled
end

function c.bind(name, device, button)
	
	c.map.binds[name]={device, button}
	c.map[device][button]=name
	
end

function c.keypressed(key, isRepeat)
	
	if not c.enabled then return false end
	
	local name = c.map.k[key]
	
	if not name then 
		name = key
	end
	
	for i, f in ipairs(c.callbacks["keypressed"]) do
		
		f(name, isRepeat)
		
	end
	
end

function c.mousepressed(x, y, button)
	
	if not c.enabled then return false end
	
	local name = c.map.m[button]
	
	if not name then return false end
	
	for i, f in ipairs(c.callbacks["mousepressed"]) do
		
		f(x, y, name)
		
	end
	
end

function c.setCallback(callback, f)
	table.insert(c.callbacks[callback], f)
end

function c.isDown(name)
	if not c.enabled then return false end
	local result = c.map.binds[name]
	
	if not result then return false end
	
	device = result[1]
	code = result[2]
	
	if type(code) == 'table' then
		-- There are multiple buttons that would make this true
		for _, v in ipairs(code) do
			if c.devices[device].isDown(v) then
				return true
			end
		end
	else
		return c.devices[device].isDown(code)
	end
	
	return false
end

return c
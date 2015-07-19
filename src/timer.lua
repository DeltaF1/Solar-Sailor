
Timer = {}

Timer.__index = Timer

function Timer:new(length, f, args, loop)
	local n={}
	
	
	n.t = 0
	n.length = length
	n.f = f
	n.args = args
	n.loop = loop or false
	return setmetatable(n,self)
end

function Timer:update(dt)

	self.t = self.t + dt
	
	if self.t >= self.length then
	
		--time reached!
		self.f(self.args)
		
		if self.loop then
			self.t = 0
		else
			
			DelTimer(self)
		end
		
	end

end

Sequence = {}

Sequence.__index = Sequence

setmetatable(Sequence, {__call = function(_, ...) return Sequence:new(...) end})

function Sequence:new(t)
	local o = {}
	
	o.table = t
	
	return setmetatable(o, self)
end

function Sequence:start()
	
	local timers = {}
	
	for func, t in pairs(self.table) do
		
		table.insert(timers, RegTimer(t, func))
		
	end
	
	return timers
end
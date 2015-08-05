Lerper = {}

Lerper.__index = Lerper

function Lerper:new(t, path, min, max, max2, lock, f)
	local o = {}
	
	t = t or _G
	
	if type(path) == 'table' then
	
		while #path > 1 do
			
			local newt = t[table.remove(path,1)]
			if newt then
				t = newt
			end
			
		end
		
		path = path[1]
	end
	
	o = {}
	
	o.table = t
	o.path = path
	
	o.min = min
	o.max = max
	
	o.f = f
	
	--rename
	o.max2 = max2
	
	o.lock = lock
	
	if lock == nil then o.lock = true end
	
	o.t = 0
	
	return setmetatable(o, self)
end

function Lerper:update(dt)
	local t = self.t
	
	if self.f then
		t = self.f(t)
	end
	
	self.table[self.path] = remap(t, 0, self.max2, self.min, self.max, self.lock)
	
	self.t = self.t + dt
	
	if self.t > self.max2 then
		if self.lock then
			DelLerper(self)
		end
	end
	
end
List = Class{}

function List:init(items)
	
	self.items=items or {}

end

--[[
function List.__index(self, index)
	
	if type(index) == 'number' then
		
		return self.items[index]
	else
		return nil
	end
	
end
]]--

function List.__len(self)
	
	return #self.items
	
end

function List:add(item)
	table.insert(self.items, item)
	return item
end

function List:remove(item)

	for i = #self.items, 1, -1 do
		if self.items[i]==item then
			table.remove(self.items, i)
			
		end
	end

end

function List:update(dt)
	for _, v in ipairs(self.items) do

		if v.update then
			v:update(dt)
		end

	end
end

function List:draw(dx, dy)
	for _, v in ipairs(self.items) do
		if v.draw then
			v:draw(dx, dy)
		end
	end
end

function List:call(f, args)
	
	for _, v in ipairs(self.items) do
	
		v[f](v, args)
	
	end
	
end

function List:get(f, args)
	local newitems = {}
	for i, item in ipairs(self.items) do
		if f(item, args) == true then
			table.insert(newitems, item)
		end
	end
	
	return List:new(newitems)
end

function contains(t, i)
	
	if getmetatable(t) == List then
		t = t.items
	end
	
	for _, item in ipairs(t) do
		if item == i then return true end
	end
	return false
end

function List:mousehover(x,y)
	
	for _, v in ipairs(self.items) do
		
		if v.mousehover then
			v:mousehover(x,y)
		end
	end
	
end

function List:mousepressed(x,y,button)
	
	for _, v in ipairs(self.items) do
		
		if v.mousepressed then
			v:mousepressed(x,y,button)
		end

	end
	
end

function List:mousereleased(x,y,button)
	
	for _, v in ipairs(self.items) do
		
		if v.mousereleased then
			v:mousereleased(x,y,button)
		end

	end
	
end

function containsK(t, i)
	
	for k, v in pairs(t) do
		if k == i then
			return true
		end
	end
	
	return false
end

function inRange(obj, args)
	attr = args[1] or "1"
	min = args[2] or 0
	max = args[3] or 0
	if obj[attr] >= min and obj[attr] <= max then
		return true
	end
	return false
end
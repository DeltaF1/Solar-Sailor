print("Entering Math library!")
math.randomseed(os.time())
math.random();math.random();math.random()
print("Defining Rects...")
Rect = {}

function Rect:new(x, y, w, h)
	
	local o = {["type"]="Rect",["x"]=x or 0, ["y"]=y or 0, ["w"]=w or 0, ["h"] = h or 0}
	setmetatable(o, self)
	self.__index = self
	
	o.pos = Vector2:new(o.x, o.y)
	o.scale = Vector2:new(o.w, o.h)
	
	o.center = o.pos+(o.scale/2)
	
	return o
end

function Rect:contains(a, b)
	
	local x
	local y
	
	if type(a)=="table" and a.type and a.type=="Vector2" then
		--print("Checking to see if vector is inside Rect!")
		x = a.x
		y = a.y
	else
		x = a
		y = b
	end

	if x >= self.x and x <= self.x+self.w then
		if y >= self.y and y <= self.y+self.h then
			return true
		end
	end
	return false
end

function Rect:collides(r)
	for i, v in ipairs(points(r)) do
		
		if self:contains(v) then
			--It's in us!!!
			return true
		end
		
	end
	
	return false
end

_oldrectangle = love.graphics.rectangle

function love.graphics.rectangle(mode, x, y, width, height)
	if not y and x.type == "Rect" then
		newx = x.x
		y = x.y
		width = x.w
		height = x.h
		x = newx
	end
	
	_oldrectangle(mode, x, y, width, height)
end

print("Defining Vectors...")
Vector2 = {}

Vector2.__index = Vector2



function Vector2:new(x, y)
	local o = {["type"]="Vector2",["x"]=x or 0, ["y"]=y or 0}
	
	return setmetatable(o, self)
end

setmetatable(Vector2, {__call = function(vec,...) return vec:new(...) end})

function Vector2:rand()
	local theta = math.random()*2*math.pi
	return Vector2(math.cos(theta), math.sin(theta))
end

function Vector2:rand2()
	local x = (math.random() * 2) - 1
	local y = randomSelect({-1,1}) * math.sqrt((1 - (x*x)))
	return Vector2(x, y)
end

function Vector2:clone()
	return Vector2:new(self.x, self.y)
end

function Vector2:len()
	return math.sqrt((self.x*self.x)+(self.y*self.y))
end

function Vector2:angle()
	return math.atan2(self.y, self.x)
end

function Vector2:norm()

	length = self:len()
	
	if length == 0 then
		return Vector2:new()
	end
	
	return Vector2:new(self.x/length, self.y/length)
end

function Vector2:floor()
	
	return Vector2:new(math.floor(self.x),math.floor(self.y))
	
end

function Vector2.__unm(a)
	
	return Vector2:new(-a.x, -a.y)
	
end

function Vector2.__add(a,b)
	
	if a.type then
		if b.type then
			if a.type == "Rect" then
				if b.type == "Vector2" then
					return Rect:new(a.x+b.x, a.y+b.y, a.w, a.h)
				end
			elseif a.type == "Vector2" then
				if b.type == "Rect" then
					return Vector2.__add(b, a)
				elseif b.type == "Vector2" then
					return Vector2:new(a.x+b.x, a.y+b.y)
				end
			end
		end
	end
	
	

	
end

function Vector2.__sub(a,b)
	return Vector2:new(a.x-b.x, a.y-b.y)
end

function Vector2.__mul(a, b)
	if type(a) == "number" then
		return Vector2:new(a*b.x, a*b.y)
	elseif type(b) == "number" then
		return Vector2:new(a.x*b, a.y*b)
	else
		--IDK what to do with 2 vectors...
		return nil
	end
end

function Vector2.__div(a,b)

	if type(a) == "number" then
		Vector2.__div(b,a)
	elseif type(b) == "number" then
		return Vector2:new(a.x/b, a.y/b)
	else
		return nil
	end

end

function Vector2.__mod(a, b)
	
	if type(a) == "number" then
		Vector2.__mod(b, a)
	elseif type(b) == "number" then
		return Vector2:new(a.x%b, a.y%b)
	else
	
		return nil
		
	end
	
end

function Vector2.__eq(a,b)
	print "Comparing vectors"	
	return a.x == b.x and a.y == b.y
end

function Vector2.__tostring(a)
	
	return("["..a.x..","..a.y.."]")
	
end

Vector2.Right = Vector2:new(1, 0)
Vector2.Left = Vector2:new(-1, 0)
Vector2.Up = Vector2:new(0, -1)
Vector2.Down = Vector2:new(0, 1)

function points(r)
	
	return {Vector2:new(r.x,r.y), Vector2:new(r.x+r.w,r.y), Vector2:new(r.x+r.w,r.y+r.h), Vector2:new(r.x,r.y+r.y)}

end

print("Defining intersections")

function intersection(ray1, ray2)
	dir1 = ray1[1]
	pos1 = ray1[2]
	
	dir2 = ray2[1]
	pos2 = ray2[2]
	
	--T2 = (r_dx*(s_py-r_py) + r_dy*(r_px-s_px))/(s_dx*r_dy - s_dy*r_dx)
	T2 = ( (dir1.x * (pos2.y-pos1.y) ) + (dir1.y * (pos1.x-pos2.x) ) ) / ( (dir2.x*dir1.y) - (dir2.y*dir1.x) )
	
	--T1 = (s_px+s_dx*T2-r_px)/r_dx 
	T1 = (pos2.x + (dir2.x * T2) - pos1.x) / dir1.x

	if T1 > 0 then
		return pos1 + dir1 * T1 , T1, T2
	else
		return nil
	end

end

function intersectionSeg(ray, segment)
	
	point, T1, T2 = intersection(ray, {segment[2]-segment[1], segment[1]})
	
	if point then
		if T2 > 0 and T2 <= 1 then
			return {point, T1}
		end
	end

	return nil 
end

function raycast(ray, ln, seg)
	local segs = seg  or segments
	local length = ln

	assert(ray, "No ray passed to raycast!")

	local lowest_t = 100000
	local nearest_seg = nil
	local point = nil

	for _, seg in ipairs(segments) do

		r = intersectionSeg(ray, seg)

		t = r[2]

		if t < lowest_t then
			lowest_t = t
			nearest_seg = seg
			point = r[1]
		end

	end

	--No segment found
	if not nearest_seg then
		return nil
	end

	--If we have a specifc range
	if length then
		if lowest_t > length then
			--The segment is too far away, return nil
			return nil
		end
	end

	return nearest_seg, point, lowest_t

end
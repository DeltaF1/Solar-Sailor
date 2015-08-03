
--David Relihan @ stackoverflow.com

--[[
int roundUp(int numToRound, int multiple)  
{  
 if(multiple == 0)  
 {  
  return numToRound;  
 }  

 int remainder = numToRound % multiple; 
 if (remainder == 0)
  {
    return numToRound; 
  }

 return numToRound + multiple - remainder; 
} 
]]--

function roundUp(num, multiple)
	
	if multiple == 0 then
		return num
	end
	
	remainder = num % multiple
	
	if remainder == 0 then
		return num
	end
	
	return num + multiple - remainder
	
end

function toggle(var, t, f)
	t = t or true
	f = f or false
	if var == t then
		return f
	else
		return t
	end
end

function remap(value, low1, high1, low2, high2, lock)
	
	if lock then

		value = math.max(low1, math.min(high1, value))

	end
	
	return (value * ((high2-low2)/(high1-low1))) + low2
	
end

function randomSelect(t)
	
	i = love.math.random(1,#t)
	
	return t[i]
	
end

function randomPercent(percent)
	
	val = love.math.random()

	
	
	if val <= percent then
		return true
		
	end
	
	return false
end

function randomPercentGet(_, percent)
	return randomPercent(percent)
end

--From Michael Kottman @ stackoverflow.com
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--"Tyler" @ stackoverflow
function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        -- as before, but if we find a table, make sure we copy that too
        if type(v) == 'table' then
            v = deepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

function split(s, delim)
	delim = delim or " "
	
	local t = {}
	for token in string.gmatch(s, string.format("[^%s]+", delim)) do
		table.insert(t, token)
	end
	
	return t
end

function join(t, delim)
	delim = delim or " "
	
	local s = ""
	local first = true
	for i, v in ipairs(t) do
		if first then 
			s = s..v
			first = false
		else
			s = s..delim..v
		end
	end
	
	return s
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function round2(num, idp)
  return string.format("%." .. (idp or 0) .. "f", num)
end

function map(t, f)
	
	for k, v in pairs(t) do
		if type(v) == "table" then
			map(v, f)
		else
			t[k] = f(v)
		end
	end
	
end

function any(...)
	for _, v in ipairs(...) do
		if v then return true end
	end
	
	return false
end

function all(...)
	local result = true
	for _, v in ipairs(...) do
		result = result and v
	end
	return result
end

_setColor = love.graphics.setColor

function love.graphics.setColor(...)
	
	if type(arg[1]) == 'table' then
		_setColor(unpack(arg[1]))
	else
		_setColor(...)
	end
end


-- Update the values of a default "table1" with the values of "table2"
--
-- e.g.
--[[

table1 = {foo="bar", foo2="baz", func=function() print("Hello, World!") end}
table2 = {foo="bar3"}

update(table1, table2)

--table1 now equals
	{foo="bar3", foo2="baz", func=function() print("Hello, World!") end}

--]]
function update(table1, table2, create, recurse)
	if create == nil then create = true end
	if recurse == nil then recurse = true end
	for k, v in pairs(table2) do
		if recurse and type(v) == "table"then
			if table1[k] then
				update(table1[k], v)
			elseif create then
				table1[k] = v
			end
		else
			table1[k] = v
		end
	end
	return table1
end

function table.merge(a,b)
	table.foreach(b,function(i,v)table.insert(a,v)end)
	return a
end

function math.randomf(min, max)
	return min + math.random() * (max - min)
end

function string.replace(s, t, sep)
	sep = sep or {"{", "}"}
	f = function(str)
        return t[str:sub(2,#str-1)]
    end

	return s:gsub("("..sep[1].."%a+"..sep[2]..")", f):gsub("\\"..sep[2], sep[2])
end

function table.remove2(t, rem)
	for i = #t, 1, -1 do
		if t[i] == rem or contains(rem, t[i]) then
			table.remove(t, i)
		end
	end
end
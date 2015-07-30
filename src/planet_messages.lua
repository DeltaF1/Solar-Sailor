local messages = {}


messages.adj = {" lush", " beautiful", " harsh"}
messages.noun = {"alien life", "strange wonders"}

messages.desc = {"{name} is a{adj} world, full of {noun}.","A{adj} world, {name} is famous for its {noun}",}

messages.send = {"The planet {name} is in desperate need of some {resource}!"}

messages.receive = {"We on {name} thank you for the much needed {resource} from {origin}"}

messages.survivors = {"Thank god you came by, we thought we were going to die with {name}!"}

local colours = {
	name = {255,20,0},
	resource = {0,255,50}
}

f = function(str)
	local k = str:sub(2,#str-1)
	print("k = "..k)
	if colours[k] then
		local c = colours[k]
		return "["..str.."](colour: "..c[1]..","..c[2]..","..c[3]..")"
	else
		return str
	end
end

for _, name in ipairs({"send", "receive", "survivors"}) do
	
	for i, msg in ipairs(messages[name]) do
		messages[name][i] = "["..msg:gsub("({%a+})", f).."](colour)" 
	end
	
end

return messages
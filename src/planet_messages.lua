local messages = {}


messages.replaces = {
	adj = {"lush", "beautiful", "harsh"},
	noun = {"alien life", "strange wonders", "breathtaking landscapes"},
	posverbed = {"renowned", "applauded", "recognized", "celebrated"},
	god = {"God", "Allah", "the Lord","Jehova"},
}

messages.desc = {"{name} is a {adj} world, full of {noun}.","A {adj} world, {name} is famous for its {noun}","{name} is {posverbed} the galaxy over for its {noun}."}

function messages.get(category)
	local s = randomSelect(messages[category])
	local t = {}
	for k, v in pairs(messages.replaces) do
		t[k] = randomSelect(v)
	end
	return string.replace(s, t)
end

messages.send = {"The planet {name} is in desperate need of some {resource}!","We've just received word from {name} that they need some {resource}. If they don't get some quick, they might not make it."}

messages.receive = {"We on {name} thank you for the much needed {resource} from {origin}","It's a good thing our message made it through to {origin}, we had almost given up","{origin} sent this? Never thought we'd be depending on them for survival..."}

messages.survivors = {"Thank {god} you came by, we thought we were going to die with {name}!","Most of us decided to stay on {name} till the end, but a few of us have families to take care of.", "After sending several messages on the IGSO-3398 standard hailing frequencies, a hoarse voice answers. \"Hello? Thank {god} {name} won't be our grave.\"",""}

messages.none = {
	"You hear nothing but the dull hiss of the subspace radio.", "The main broadcast station seems to be sending out an evacuation message on loop. No one responds to your hailing.",
	"The only sign of life on {name} is the twisted hulk of a space station in orbit.",
	"{name} doesn't seem to be emitting any radio signals. If there are people on the ground, they aren't hailing you."
}

local colours = {
	name = {255,20,0},
	resource = {0,50,200},
	origin = {0,200,50}
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

--local toBeColoured = {"send", "receive", "survivors","none"}
toBeColoured = {"send"}

for _, name in ipairs(toBeColoured) do
	
	for i, msg in ipairs(messages[name]) do
		messages[name][i] = "["..msg:gsub("({%a+})", f).."](colour)" 
	end
	
end

return messages
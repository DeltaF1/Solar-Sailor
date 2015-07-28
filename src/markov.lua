
if love and love.filesystem then
	print("Creating loadText for love.filesystem")
	loadText = function(name)
	  local s = love.filesystem.read(name)
	  --print(s)
	  s = s:gsub(".,!'\"/\\()","")--:lower()
	  return s
	end
else
	print("Creating loadText for native io")
	loadText = function(name)

	  local s = io.open(name, "r"):read("*a")
	  --print(s)
	  s = s:gsub(".,!'\"/\\()","")--:lower()
	  return s
	end
end

local markov = {}

local function add_key(chain, prefix, suffix)
  if not chain[prefix] then chain[prefix] = {} end
  table.insert(chain[prefix], suffix)
end

local function get_suffix(chain, prefix)
  local t = chain[prefix]
  if not t then
    print("invalid prefix '"..prefix.."'")
    return "\n"
  end
  --print("selecting suffix from:")
  --print(Tserial.pack(t))
  return t[math.random(#t)]
end

local function feed(chain, text)
  for word in text:gmatch("%w+") do
    word = string.rep(" ", markov.depth)..word
    for i = 1, (#word)-(markov.depth-1) do
      
      prefix = word:sub(i,i+(markov.depth-1))
      
      nextletter = word:sub(i+(markov.depth),i+(markov.depth))
      if nextletter == "" then
        add_key(chain,prefix, "\n")
        break
        end
      
      add_key(chain, prefix, nextletter)
      
    end
    add_key(chain, word:sub(#word,#word)..word:sub(#word+1,#word+1), "\n")
  end
  
  return chain
end

local function generate(chain, length)
  prefix = string.rep(" ", markov.depth)
  name = ""
  suffix = ""
  for i = 1,length do
    suffix = get_suffix(chain, prefix)
    if not suffix or suffix == "\n" then
      break
    end
    name = name .. suffix
    --print("old prefix: '"..prefix.."' , suffix: '"..suffix.."'")
    prefix = prefix:sub(2,#prefix) .. suffix
    --print("new prefix: '"..prefix.."'")
  end
  return name
end
--[[
function generate(chain, length)
  local keys = {}
  for key, _ in pairs(chain) do
    table.insert(keys, key)
    end
  first = keys[math.random(1,#keys)]
  s = "" 
  for i = 1, length do
    local next = chain[first]
    if not next then break end
    choice = next[math.random(1,#next)]
    s = s..choice
    first = choice
  end
  return s
  end
  ]]--
  markov = 
  {
    feed = feed,
    generate = generate,
	loadText = loadText,
    depth = 3
    }
  local alice = loadText("alice.txt")
  local alice_chain = feed({}, alice)
  
  markov.places = table.concat({'Adara', 'Adena', 'Adrianne', 'Alarice', 'Alvita', 'Amara', 'Ambika', 'Antonia', 'Araceli', 'Balandria', 'Basha',
'Beryl', 'Bryn', 'Callia', 'Caryssa', 'Cassandra', 'Casondrah', 'Chatha', 'Ciara', 'Cynara', 'Cytheria', 'Dabria', 'Darcei',
'Deandra', 'Deirdre', 'Delores', 'Desdomna', 'Devi', 'Dominique', 'Drucilla', 'Duvessa', 'Ebony', 'Fantine', 'Fuscienne',
'Gabi', 'Gallia', 'Hanna', 'Hedda', 'Jerica', 'Jetta', 'Joby', 'Kacila', 'Kagami', 'Kala', 'Kallie', 'Keelia', 'Kerry',
'Kerry-Ann', 'Kimberly', 'Killian', 'Kory', 'Lilith', 'Lucretia', 'Lysha', 'Mercedes', 'Mia', 'Maura', 'Perdita', 'Quella',
'Riona', 'Safiya', 'Salina', 'Severin', 'Sidonia', 'Sirena', 'Solita', 'Tempest', 'Thea', 'Treva', 'Trista', 'Vala', 'Winta'}, " ")
--print(places)
--local place_chain = feed({}, places)
--local planets = loadText("planets_parsed.txt")
--local planet_chain = feed(place_chain, planets)

--love.filesystem.write("planet_chain1.lua", Tserial.pack(planet_chain))

markov.alice_chain = alice_chain
--markov.planet_chain = place_chain

return markov
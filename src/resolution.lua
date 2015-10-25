local res = {}

local setMode = love.window.setMode or love.graphics.setMode
local lg = love.graphics
local max,min = math.max, math.min

local xscale
local yscale
local dx

function res.set(game_width, game_height, screen_width, screen_height)
	setMode(screen_width, screen_height)
	
	local ratio = game_width/game_height
	
	xscale = min(screen_width/game_width, screen_height/game_height)
	--xscale = min(game_width/screen_width, game_height/screen_height)
	yscale = xscale
	
	print("xscale = "..xscale)
	
	local hSpace = screen_width - (game_width * xscale)
    local vSpace = screen_height - (game_height * xscale)
    dx = hSpace / 2
    dy = vSpace / 2
	
	--dx=((game_width/screen_width)/2)
	
	print("dx = "..dx)
	
	_oldDimensions = love.graphics.getDimensions
	function love.graphics.getDimensions()
		return game_width,game_height
	end
	
	function love.graphics.getWidth()
		return game_width
	end
	
	function love.graphics.getHeight()
		return game_height
	end
end

function res.transform()
	lg.push()
	lg.setScissor(dx,0, love.graphics.getDimensions())
	lg.translate(dx, 0)
	lg.scale(xscale, yscale)
end

function res.gamePosition(sx,sy)
	local clampedX,clampedY = min(max(sx,dx),dx+rw),min(max(sy,dy),dy+rh)
	return (clampedX-dx)/xscale,(clampedY-dy)/yscale
end

return res

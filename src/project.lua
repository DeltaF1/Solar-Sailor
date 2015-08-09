--State flow map?

local t = {

	libs = {"class", "strong", "popo", "utils", "Tserial", "ser", "vmath", "list", "timer", "lerper", "control","TLfres","gamera","gui"},

	states = {"menu","game","planet","death","credits","console","splash","pause"}
}

love.filesystem.setIdentity("Solar_Sailor")

-- 1024 x 768 should be supported by everyone
love.window.setMode(1024,768)

-- Compatibility with some drivers/graphics cards
love.graphics.setPointStyle("rough")

love.graphics.setDefaultFilter("nearest", "nearest")

INITIAL_STATE = "splash"

return t
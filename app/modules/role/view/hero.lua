if not SYSPATH then return end

local meta = Class("HeroPane")

function meta:hello()
	print("hero pane say hello")
end

return meta
if not SYSPATH then return end

local meta = class("HeroPane")

function meta:Hello()
	print("hero pane say hello")
end

return meta
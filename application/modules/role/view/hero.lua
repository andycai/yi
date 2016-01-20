if not SYSPATH then return end

local HeroPane = class("HeroPane")
local meta = HeroPane

function meta:hello()
	print("hero pane say hello")
end

return meta
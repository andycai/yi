if not SYSPATH then return end

local meta = class("GridPane")

function meta:cleanup()
	print("clean up bag")
end

return meta
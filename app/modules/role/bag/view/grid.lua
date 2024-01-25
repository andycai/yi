if not SYSPATH then return end

local meta = Class("GridPane")

function meta:cleanup()
	print("clean up bag")
end

return meta
if not SYSPATH then return end

local meta = {}

-- view handler
function meta.show(param)
	print("view call me")
end

return meta
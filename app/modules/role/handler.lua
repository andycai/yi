if not SYSPATH then return end

local meta = {}

-- view handler
function meta.Show(param)
	print("view call me")
end

return meta
if not SYSPATH then return end

local meta = {}

-- server response
function meta.OnSayHello(param, actor)
	print("Hello, " .. param.name .. "!")
end

return meta
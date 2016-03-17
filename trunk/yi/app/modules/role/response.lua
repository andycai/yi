if not SYSPATH then return end

local meta = {
	actor = nil
}

-- server response
function meta:OnSayHello(param)
	print("Hello, Yi!")
end

return meta
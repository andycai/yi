local meta = {}

-- server response
function meta.onSayHello(param, actor)
	print("Hello, " .. param.name .. "!")
end

return meta
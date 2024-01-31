local meta = {}

-- server response
function meta.onSayHello(param, actor)
	print("role/response: Hello, " .. param.name .. "!")
end

return meta
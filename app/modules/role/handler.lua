local meta = Yi.Cell:extend{
	name = "role"
}

-- view handler
function meta.show(param)
	print("role/handler: view call me")
end

return meta
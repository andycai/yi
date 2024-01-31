local meta = Yi.Cell:extend{
	name = "role"
}

local role = Mod('role')

function meta:hello()
	print("role/view: role pane say hello")

	self:handler():show()
end

return meta
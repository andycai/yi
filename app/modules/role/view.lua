local meta = {}

local role = Mod('role')

function meta:hello()
	print("role pane say hello")

	role.handler:show()
end

return meta
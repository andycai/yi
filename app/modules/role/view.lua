if not SYSPATH then return end

local meta = {}

local role = Magic('role')

function meta:hello()
	print("role pane say hello")

	role.handler:show()
end

return meta
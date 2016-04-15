if not SYSPATH then return end

local handler = use('role.handler')

local meta = class("RolePane")

function meta:hello()
	print("role pane say hello")

	handler:show()
end

return meta
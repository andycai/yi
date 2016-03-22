if not SYSPATH then return end

local meta = class("RolePane")
local handler = Yi.use('role.handler')

function meta:hello()
	print("role pane say hello")

	handler:show()
end

return meta
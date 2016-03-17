if not SYSPATH then return end

local RolePane = class("RolePane")
local meta = RolePane

function meta:hello()
	print("role pane say hello")

	self.handler:show()
end

return meta
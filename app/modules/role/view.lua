if not SYSPATH then return end

local meta = {}

local role = magic('role')

function meta:Hello()
	print("role pane say hello")

	role.handler:Show()
end

return meta
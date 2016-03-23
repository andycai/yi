local meta = {}

local tbl = {
	[1001] = "user.Login",
	[1002] = "user.OnLogin",
}

local function reverse(t)
	local rt = {}
	for k, v in pairs(t) do
		rt[v] = k
	end
	return rt
end

local revtbl = reverse(tbl)

function meta.find_id(name)
	return revtbl[name]
end

function meta.find_name(id)
	return tbl[id]
end

return meta
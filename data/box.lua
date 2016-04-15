local meta = {}

local config_ = {
	hero = "data.config.role.hero",
}

Yi = Yi or {}
if not Yi.load then
	function Yi.load(path)
		return require(path)
	end
end
if ENV_DEVELOPMENT_SIDE == 1 then
	local mt_ = {}
	mt_.__index = function(table, key)
		return Yi.load(config_[key])
	end
	setmetatable(meta, mt_)
else
	for k,v in pairs(config_) do
		meta[k] = Yi.load(v)
	end
end

return meta

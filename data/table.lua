local meta = {}

local config_ = {
	hero = "data.config.role.hero",
}

if ENV_DEVELOPMENT_SIDE == 1 then
	local mt_ = {}
	mt_.__index = function(table, key)
		return require(config_[key])
	end
	setmetatable(meta, mt_)
else
	for k,v in pairs(config_) do
		meta[k] = require(v)
	end
end

return meta

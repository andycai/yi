local meta = {}

local config_ = {
	hero = "data.config.role.hero",
}

for k,v in pairs(config_) do
	meta[k] = require(v)
end

return meta

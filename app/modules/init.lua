if not SYSPATH then return end

local modules_init_ = {
	"role",
	"role.skill",
	"role.bag",
	nil,
}

function app.entity(name)
	return Yi.load('data.entity.' .. name)
end

Yi.facade:registerModules(modules_init_)
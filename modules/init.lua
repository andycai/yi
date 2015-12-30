if not SYSPATH then return end

local modules_init_ = {
	"role",
	nil,
}

_G.BaseActor = use('base.actor')
facade:registerModules(modules_init_)
if not SYSPATH then return end

local modules_init_ = {
	"role",
	nil,
}

_G.BaseActor = Yi.use('base.actor')
Yi.facade:registerModules(modules_init_)
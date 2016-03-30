if not SYSPATH then return end

local modules_init_ = {
	"role",
	nil,
}

function app.model(name)
    return Yi.use(name .. '.model')
end

function app.service(name)
    return Yi.use(name .. '.service')
end

function app.response(name)
    return Yi.use(name .. '.response')
end

Yi.facade:registerModules(modules_init_)

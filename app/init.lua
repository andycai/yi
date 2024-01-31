local meta = {}

Event = Yi.Event
Use = Yi.use
Mod = Yi.mod
Go = Yi.go

Class = require('libs.middleclass')
__ = require('core.utils.i18n')

require('core.ext.init')
require('core.utils.init')
require('core.utils.var')
require('app.i18n.' .. Yi.lang())
require("app.modules.init")

local function requestServer( ... )
	-- request to server
end
Yi.request = requestServer

function Route(response)
	xpcall(function()
		if response then
			local json = require('libs.dkjson')
			local resp = json.decode(response)
			local actions = string.explode(resp.act, ".")
			local moduleName = actions[1]
			local actor = Yi.facade:actor(moduleName)
			if actor then
				actor:on(resp.act, resp.param)
			else
				print(string.format("Wrong actor: %s", response))
			end
		end
	end, __G__TRACKBACK__)
end

function meta.run()
	Event.send(Event.EVENT_APP_START, "startup")
end

return meta
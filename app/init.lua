if not SYSPATH then return end

app = app or {}

class = Yi.class
Event = Yi.Event
load = Yi.load
use = Yi.use
magic = Yi.magic
__ = Yi.__
std = Yi.module

use("init")				-- load modules.init
load('data.init')

local function requestServer( ... )
	-- request to server
end
Yi.request = requestServer

function route(response)
	xpcall(function()
		if response then
			local json = load('libs.dkjson')
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

function app.run()
	Yi.facade:send(Event.EVENT_APP_START, "startup")
end
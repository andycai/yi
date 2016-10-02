if not SYSPATH then return end

app = app or {}

class = Yi.class
Event = Yi.Event
load = Yi.Load
use = Yi.Use
magic = Yi.Magic
__ = Yi.__

use("init")				-- load modules.init
load('data.init')

local function RequestServer( ... )
	-- request to server
end
Yi.Request = RequestServer

function Route(response)
	xpcall(function()
		if response then
			local json = load('libs.dkjson')
			local resp = json.decode(response)
			local actions = string.explode(resp.act, ".")
			local moduleName = actions[1]
			local actor = Yi.facade:Actor(moduleName)
			if actor then
				actor:On(resp.act, resp.param)
			else
				print(string.format("Wrong actor: %s", response))
			end
		end
	end, __G__TRACKBACK__)
end

function app.Run()
	Yi.facade:Send(Event.EVENT_APP_START, "startup")
end
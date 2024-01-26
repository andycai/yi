App = App or {}

Class = Yi.class
Event = Yi.Event
Load = Yi.load
Use = Yi.use
Mod = Yi.mod
__ = Yi.__
Go = Yi.go

Use("init")				-- load modules.init
Load('data.init')

local function requestServer( ... )
	-- request to server
end
Yi.request = requestServer

function Route(response)
	xpcall(function()
		if response then
			local json = Load('libs.dkjson')
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

function App.run()
	Event.send(Event.EVENT_APP_START, "startup")
end
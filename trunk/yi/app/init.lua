if not SYSPATH then return end

app = app or {}

class = Yi.class

Yi.use("init")				-- load modules.init

local function requestServer( ... )
	-- request to server
end
Yi.request = requestServer

function route(response)
	xpcall(function()
		if response then
			local json = Yi.system('helpers.simplejson')
			local resp_ = json.decode(response)
			local act_ = string.explode(resp_.act, ".")
			local module_ = act_[1]
			local actor_ = Yi.facade:actor(module_)
			if actor_ then
				actor_:on(resp_.act, resp_.param)
			else
				print(string.format("Wrong actor: %s", response))
			end
		end
	end, __G__TRACKBACK__)
end

function app.run()
	Yi.facade:send("app_start", "startup")
end
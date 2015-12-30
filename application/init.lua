if not SYSPATH then return end

app = app or {}

class = Yi.class
facade = Yi.facade
load = Yi.load			-- load application
import = Yi.import		-- load system
use = Yi.use			-- load modules

use("init")

function requestServer( ... )
	-- request to server
end

function route(response)
	xpcall(function()
		if response then
			local resp_ = Yi.json.decode(response)
			local act_ = string.explode(resp_.act, ".")
			local module_ = act_[1]
			local action_ = act_[2]
			local actor_ = facade:instanceActor(module_)
			if actor_ then
				local handler_ = actor_.resp[action_]
				if handler_ then
					handler_(resp.param)
				else
					print(string.format("Wrong action: %s", response))
				end
			else
				print(string.format("Wrong actor: %s", response))
			end
		end
	end, __G__TRACKBACK__)
end

function app.run()
	facade:send("app_start", "startup")
end
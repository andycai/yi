if not SYSPATH then return end

local RoleActor = class("RoleActor", BaseActor)

local meta = RoleActor

function meta:listInterests()
	return {
		"app_start"
	}
end

function meta:onRegister(name)
end

function meta:action_app_start(...)
	import('helpers.csv')

	puts("app start")
	local nums, data, labels = Yi.loadcsv("./doc/player.csv")
	puts(Yi.__("Testing %s", "RoleActor"))
	puts("csv data:", data)

	local rolePane = self:getView()
	rolePane:hello()

	local heroPane = self:view('hero')
	heroPane:hello()
end

function meta:action_bag_get(...)
	puts("role bag info:")

	self:request("bag.get", {type=1})
	self:response("bag.OnGet", function(param)
		-- response()
	end)
end

return meta
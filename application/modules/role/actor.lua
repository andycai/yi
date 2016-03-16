if not SYSPATH then return end

local meta = class("RoleActor", BaseActor)

function meta:listInterests()
	return {
		{"app_start", self.action_app_start}
	}
end

function meta:onRegister(name)
end

function meta:action_app_start(...)
	puts("app start")
	puts(Yi.__("Testing %s", "RoleActor"))

	local roleservice = Yi.use('role.service')
	roleservice:print_csv()

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
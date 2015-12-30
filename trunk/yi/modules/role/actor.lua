if not SYSPATH then return end

local RoleActor = class("RoleActor", BaseActor)

local meta = RoleActor

function meta:listInterests()
	return {
		"app_start"
	}
end

function meta:onRegister(name)
	puts(self.resp)
	puts(self.handler)
end

function meta:action_app_start(...)
	Yi.import('helpers.csv')

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

-- server response
meta.resp = {
	OnSayHello = function(param)
		print("Hello, Yi!")
	end
}

-- view handler
meta.handler = {
	show = function(param)
		print("view call me")
	end
}

return meta
if not SYSPATH then return end

local meta = class("RoleActor", Yi.Actor)

function meta:listInterests()
	return {
		Event.EVENT_APP_START, self.action_app_start,
		Event.EVENT_SAY_HELLO, self.action_say_hello,
	}
end

function meta:onRegister()
	-- 与 listInterests 返回数组等价
	-- self.actions[Event.EVENT_APP_START] = self.action_app_start
	-- self.actions[Event.EVENT_SAY_HELLO] = self.action_say_hello
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

	route('{"act":"role.OnSayHello", "param":{"name":"Andy"}}')
end

function meta:action_say_hello(...)
	puts("role bag info:")

	self:request("role.sayHello", {type=1})
	self:response("role.OnSayHello", function(param, actor)
		-- response()
	end)
end

return meta
if not SYSPATH then return end

local meta = class("RoleActor", Yi.Actor)

local role = magic('role')

function meta:ListInterests()
	return {
		Event.EVENT_APP_START, self.action_app_start,
		Event.EVENT_SAY_HELLO, self.action_say_hello,
	}
end

function meta:OnRegister()
	-- 与 listInterests 返回数组等价
	-- self.actions[Event.EVENT_APP_START] = self.action_app_start
	-- self.actions[Event.EVENT_SAY_HELLO] = self.action_say_hello
end

function meta:action_app_start(...)
	puts("app start")
	puts(__("Testing %s", "RoleActor"))

	local nums, data, labels = role.service:ParseCsv()
	puts("csv data:", data)

	role.model:SetNick('babala')
	role.view:Hello()

	local heroPane = role.NewView('hero')
	heroPane:Hello()

	Route('{"act":"role.OnSayHello", "param":{"name":"Andy"}}')
end

function meta:action_say_hello(...)
	puts("role bag info:")

	self:Request("role.sayHello", {type=1})
	self:Response("role.OnSayHello", on_say_hello_)
end

return meta
local meta = Class("RoleActor", Yi.Actor)

function meta:listInterests()
	return {
		Event.EVENT_APP_START, self.action_app_start,
		Event.EVENT_SAY_HELLO, self.action_say_hello,
		-- [Event.EVENT_SAY_HELLO] = self.action_say_hello,
	}
end

function meta:onRegister()
	-- 与 listInterests 返回数组等价
	-- self.addListener(Event.EVENT_APP_START, self.action_app_start)
	-- self.addListener(Event.EVENT_SAY_HELLO, self.action_say_hello)
end

function meta:action_app_start(...)
	Puts("app start")
	Puts(__("Testing %s", "RoleActor"))

	local nums, data, labels = Go.role.service:parseCsv()
	Puts("csv data:", data)

	Go.role.model:setNick('babala')
	Go.role.view:hello()

	local heroPane = Go.role.newView('hero')
	heroPane:hello()

	Route('{"act":"role.OnSayHello", "param":{"name":"Andy"}}')

	Event.send(Event.EVENT_BAG_OPEN, 'open bag please')
end

function meta:action_say_hello(...)
	Puts("role bag info:")

	self:request("role.sayHello", {type=1})
	self:response("role.onSayHello", on_say_hello_)
end

return meta
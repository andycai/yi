if not SYSPATH then return end

local meta = Class("RoleActor", Yi.Actor)

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
	puts(__("Testing %s", "RoleActor"))

	local nums, data, labels = Go.role.service:parseCsv()
	puts("csv data:", data)

	Go.role.model:setNick('babala')
	Go.role.view:hello()

	local heroPane = Go.role.newview('hero')
	heroPane:hello()

	Route('{"act":"role.OnSayHello", "param":{"name":"Andy"}}')

	Go.send(Event.EVENT_BAG_OPEN, 'open bag please')
end

function meta:action_say_hello(...)
	puts("role bag info:")

	self:request("role.sayHello", {type=1})
	self:response("role.onSayHello", on_say_hello_)
end

return meta
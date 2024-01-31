local meta = Class("RoleActor", Yi.Actor)

-- local role = Mod("role")

function meta:listInterests()
	return {
		[Event.EVENT_APP_START] = self.actionAppStart,
		[Event.EVENT_SAY_HELLO] = self.actionSayHello,
	}
end

function meta:onRegister()
	-- listening event, as same as meta:listInterests()
	-- self:addListener(Event.EVENT_APP_START, self.actionAppStart)
	-- self:addListener(Event.EVENT_SAY_HELLO, self.actionSayHello)

	-- initialize view or model ...
	-- role.model.init()
	-- role.view.init()
end

function meta:actionAppStart(actionName, ...)
	Puts("role/actor: app start")
	Puts("role/actor: action name: " .. actionName)
	Puts("role/actor: " .. __("Testing %s", "RoleActor"))

	local nums, data, labels = self:service():parseCsv()
	Puts("role/actor: csv data:", data)

	self:model():setNick('babala')
	self:view():hello()

	local heroPane = Go.role.newWidget('hero')
	heroPane:hello()

	Route('{"act":"role.onSayHello", "param":{"name":"Andy"}}')

	Event.send(Event.EVENT_BAG_OPEN, 'open bag please')
end

function meta:actionSayHello(...)
	Puts("role/actor: role bag info:")

	-- self:request("role.sayHello", {type=1})
	-- self:response("role.onSayHello", on_say_hello_)
end

return meta
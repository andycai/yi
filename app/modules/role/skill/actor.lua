local meta = Class("SkilActor", Yi.Actor)

function meta:listInterests()
	return {
		[Event.EVENT_APP_START] = self.actionAppStart,
	}
end

function meta:onRegister()
end

function meta:actionAppStart(...)
	Puts("app start")
	Puts(__("role skill initilize %s", "skill 143"))

	local pane = Go.skill.newView('skill')
	pane:learn()
end

return meta
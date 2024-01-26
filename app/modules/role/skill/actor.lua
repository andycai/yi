local meta = Class("SkilActor", Yi.Actor)

function meta:listInterests()
	return {
		Event.EVENT_APP_START, self.action_app_start,
	}
end

function meta:onRegister()
end

function meta:action_app_start(...)
	Puts("app start")
	Puts(__("role skill initilize %s", "skill 143"))

	local pane = Go.skill.newView('skill')
	pane:learn()
end

return meta
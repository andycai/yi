local meta = Class("SkilActor", Yi.Actor)

function meta:listInterests()
	return {
		[Event.EVENT_APP_START] = self.actionAppStart,
	}
end

function meta:onRegister()
end

function meta:actionAppStart(...)
	Puts("role/skill/actor: app start")
	Puts("role/skill/actor: " .. __("role skill initilize %s", "skill 143"))

	local pane = Go.skill.newWidget('skill')
	pane:learn()
end

return meta
local meta = Class("BagActor", Yi.Actor)

function meta:listInterests()
	return {
		[Event.EVENT_BAG_OPEN] = self.actionOpenBag,
	}
end

function meta:onRegister()
end

function meta:actionOpenBag(msg)
	Puts("role/bag/actor: title: open bag")
	Puts("role/bag/actor: " .. msg)
	Puts("role/bag/actor: " .. __("role bag initilize %s", "grid 8*8"))

	local pane = Go.bag.newWidget('grid')
	pane:cleanup()
end

return meta
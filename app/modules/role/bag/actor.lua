local meta = Class("BagActor", Yi.Actor)

function meta:listInterests()
	return {
		Event.EVENT_BAG_OPEN, self.action_open_bag,
	}
end

function meta:onRegister()
end

function meta:action_open_bag(msg)
	Puts("title: open bag")
	Puts(msg)
	Puts(__("role bag initilize %s", "grid 8*8"))

	local pane = Go.bag.newView('grid')
	pane:cleanup()
end

return meta
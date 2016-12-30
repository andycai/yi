if not SYSPATH then return end

local meta = class("BagActor", Yi.Actor)

function meta:listInterests()
	return {
		Event.EVENT_BAG_OPEN, self.action_open_bag,
	}
end

function meta:onRegister()
end

function meta:action_open_bag(msg)
	puts("title: open bag")
	puts(msg)
	puts(__("role bag initilize %s", "grid 8*8"))

	local pane = go.bag.NewView('grid')
	pane:cleanup()
end

return meta
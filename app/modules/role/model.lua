if not SYSPATH then return end

local meta = {}

function meta:set_nick(nick)
	self.nick = nick
end

return meta
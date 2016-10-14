if not SYSPATH then return end

local meta = {}

function meta:setNick(nick)
	self.nick = nick
end

return meta
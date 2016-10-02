if not SYSPATH then return end

local meta = {}

function meta:SetNick(nick)
	self.nick = nick
end

return meta
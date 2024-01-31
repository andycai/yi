local meta = Yi.Cell:extend{
	name = "role"
}

function meta:setNick(nick)
	self.nick = nick
end

return meta
if not SYSPATH then return end

load('system.helpers.csv')

local meta = {}

function meta.ParseCsv()
	return Yi.loadcsv("./doc/player.csv")
end

function meta:GetNick()
	return 'superman'
end

return meta
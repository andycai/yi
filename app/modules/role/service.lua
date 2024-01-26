Load('core.helpers.csv')

local meta = {}

function meta.parseCsv()
	return Yi.loadcsv("./doc/player.csv")
end

function meta:getNick()
	return 'superman'
end

return meta
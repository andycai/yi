local csv = require('core.utils.csv')

local meta = Yi.Cell:extend{
	name = "role"
}

function meta.parseCsv()
	return csv.loadcsv("./doc/player.csv")
end

function meta:getNick()
	return 'superman'
end

return meta
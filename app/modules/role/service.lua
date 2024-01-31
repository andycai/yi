local csv = require('core.utils.csv')

local meta = {}

function meta.parseCsv()
	return csv.loadcsv("./doc/player.csv")
end

function meta:getNick()
	return 'superman'
end

return meta
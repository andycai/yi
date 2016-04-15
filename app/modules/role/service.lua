if not SYSPATH then return end

system('helpers.csv')

local meta = {}

function meta.parse_csv()
	return Yi.loadcsv("./doc/player.csv")
end

function meta:get_nick()
	return 'superman'
end

return meta
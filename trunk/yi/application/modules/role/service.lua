if not SYSPATH then return end

local meta = {}

function meta.print_csv()
	Yi.import('helpers.csv')
	local nums, data, labels = Yi.loadcsv("./doc/player.csv")
	puts("csv data:", data)
end

function meta:get_nick()
	return 'superman'
end

return meta
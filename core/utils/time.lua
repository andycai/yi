function Yi.time(title, f, times)
	times = times or 10000
	collectgarbage()
	local startTime = os.clock()
	for i=0, times do f() end
	local endTime = os.clock()
	print( title, endTime - startTime )
end

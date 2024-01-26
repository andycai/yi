function math.round(num)
	local f = math.floor(num)
	if num == f then return f
	else return math.floor(num + 0.5)
	end
end

function math.randseed()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
end
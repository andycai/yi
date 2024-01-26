Yi = Yi or {}

Yi.load('core.helpers.var')
Yi.load('core.helpers.i18n')

function Yi.tostring(obj, ...)
	if type(obj) == "table" then
		return table.tostring(obj)
	end

	if ... then
		obj = string.format(tostring(obj), ...)
	else
		obj = tostring(obj)
	end

	return obj
end

function Sputs(obj, ...)
	if type(obj) == "table" then
		obj = Yi.tostring(obj)
	else
		if type(obj)=="string" and string.indexOf(obj, "%%s") ~= -1 then
			if ... then
				obj = obj:format(...)
			end
		else
			obj = Yi.tostring(obj)
			if ... then
				local len = select("#", ...)
				for i=1,len do
					obj = string.format("%s %s", obj, Yi.tostring(select(i, ...)))
				end
			end
		end
	end
	return obj
end

function Puts(obj, ...)
	print(Sputs(obj, ...))
end

function Yi.appendPath(...)
	local args = {...}
	for i=1, #args do
		local pkgPath = package.path  
		package.path = string.format("%s;%s?.lua;%s?/init.lua",  
			pkgPath, args[i], args[i]) 
	end
end

-- Function string.gfind was renamed string.gmatch. (Option LUA_COMPAT_GFIND) 
function Yi.getglobal(f)
	local v = _G
	-- for w in string.gfind(f, "[%w_]") do
	for w in string.gmatch(f, "[%w_]+") do
		v = v[w]
	end
	return v
end

function Yi.setglobal(f, v)
	local t = _G
	-- for w, d in string.gfind(f, "([%w_]+)(.?)") do
	for w, d in string.gmatch(f, "([%w_]+)(.?)") do
		if d == "." then -- not last field
			t[w] = t[w] or {}	-- create table if absent
			t = t[w]			-- get the table
		else					-- last field
			t[w] = v 			-- do the assignment
		end
	end
end

function Yi.vardump(...)
	local count = select("#", ...)
	if count < 1 then return end

	print("vardump:")
	for i = 1, count do
		local v = select(i, ...)
		local t = type(v)
		if t == "string" then
			print(string.format("  %02d: [string] %s", i, v))
		elseif t == "boolean" then
			print(string.format("  %02d: [boolean] %s", i, tostring(v)))
		elseif t == "number" then
			print(string.format("  %02d: [number] %0.2f", i, v))
		else
			print(string.format("  %02d: [%s] %s", i, t, tostring(v)))
		end
	end
end

function Yi.eval(input)
	return pcall(function()
		if not input:match("=") then
			input = "do return (" .. input .. ") end"
		end

		local code, err = loadstring(input, "REPL")
		if err then
			error("Syntax Error: " .. err)
		else
			print(code())
		end
	end)
end

function Yi.escape(s)
	if s == nil then return '' end
	local esc, i = s:gsub('&', '&amp'):gsub('<', '&lt'):gsub('>', '&gt')

	return esc
end

function Yi.urlencode(s)
	return s:gsub("\n", "\r\n"):gsub("([^%-%-%/]", 
		function(c) return ("%%%02X"):format(string.byte(c))
	end)
end

function Yi.clone(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end
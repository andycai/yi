local math = math
local string = string

function table.clone(t, nometa)
	local u = {}

	if not nometa then
		setmetatable(u, getmetatable(t))
	end

	for i, v in pairs(t) do
		if type(v) == "table" then
			u[i] = table.clone(v)
		else
			u[i] = v
		end
	end

	return u
end

function table.merge(t, u)
	local r = table.clone(t)

	for i, v in pairs(u) do
		r[i] = v
	end

	return r
end

function table.keys(t)
	local keys = {}
	for k, v in pairs(t) do table.insert(keys, k) end
	-- for k, v in pairs(t) do keys[#keys + 1] = k end
	return keys
end

function table.unique(t)
	local seen = {}
	for i, v in ipairs(t) do
		if not table.includes(seen, v) then table.insert(seen, v) end
	end

	return seen
end

function table.values(t)
	local values = {}
	for k, v in pairs(t) do table.insert(values, v) end
	-- for k, v in pairs(t) do values[#values + 1] = v end
	return values
end

function table.last(t)
	return t[#t]
end

function table.append(t, moreValues)
	for i, v in ipairs(moreValues) do
		table.insert(t, v)
	end

	return t
end

function table.indexOf(t, value)
	for k, v in pairs(t) do
		if type(value) == "function" then
			if value(v) then return k end
		else
			if v == value then return k end
		end
	end

	return nil
end

function table.includes(t, value)
	return table.indexOf(t, value)
end

function table.haskey(t, key)
	return type(t) == "table" and t[key] ~= nil
end

function table.len(t)
	if type(t) ~= "table" then return nil end
	local nums = 0
	for k, v in pairs(t) do
		nums = nums + 1
	end
	return nums
end

-- Recursively concat a table
function table.concatR(t)
	local output = {}
	local function table_concat_(t, output)
		for k, v in pairs(t) do
			if type(v) == "table" then
				table_concat_(v)
			else
				table.insert(output, v)
			end
		end
	end
	table_concat_(t, output)
	return table.concat(output)
end

function table.removeValue(t, value)
	local index = table.indexOf(t, value)
	if index then table.remove(t, index) end
	return t
end

function table.each(t, func)
	for k, v in pairs(t) do
		func(k, v)
	end
end

function table.find(t, func)
	for k, v in pairs(t) do
		if func(v) then return v, k end
	end

	return nil
end

function table.filter(t, func)
	local matches = {}
	for k, v in pairs(t) do
		if func(v) then table.insert(matches, v) end
	end

	return matches
end

function table.map(t, func)
	local mapped = {}
	for k, v in pairs(t) do
		table.insert(mapped, func(v, k))
	end

	return mapped
end

function table.groupBy(t, func)
	local grouped = {}
	for k, v in pairs(t) do
		local groupKey = func(v)
		if not grouped[groupKey] then grouped[groupKey] = {} end
		table.insert(grouped[groupKey], v)
	end

	return grouped
end

function table.tostring(tbl, indent, limit, depth, jstack)
	limit   = limit  or 1000
	depth   = depth  or 7
	jstack  = jstack or {}
	local i = 0

	local output = {}
	if type(tbl) == "table" then
		-- very important to avoid disgracing ourselves with circular referencs...
		for i,t in ipairs(jstack) do
			if tbl == t then
				return "<self>,\n"
			end
		end
		table.insert(jstack, tbl)

		table.insert(output, "{\n")
		for key, value in pairs(tbl) do
			local innerIndent = (indent or " ") .. (indent or " ")
			table.insert(output, innerIndent .. tostring(key) .. " = ")
			table.insert(output,
				value == tbl and "<self>," or table.tostring(value, innerIndent, limit, depth, jstack)
			)

			i = i + 1
			if i > limit then
				table.insert(output, (innerIndent or "") .. "...\n")
				break
			end
		end

		table.insert(output, indent and (indent or "") .. "},\n" or "}")
	else
		if type(tbl) == "string" then tbl = string.format("%q", tbl) end -- quote strings
		table.insert(output, tostring(tbl) .. ",\n")
	end

	return table.concat(output)
end

function table.shallowCopy(source, target, exclusions)
	local source_type = type(source)
	local copy, pass
	if source_type == "table" then
		copy = target or {}
		for source_key, source_value in pairs(source) do
			pass = false
			if exclusions and #exclusions > 0 then
				for i,v in ipairs(exclusions) do
					if v == source_key then
						pass = true
						break
					end
				end
			end
			if not pass then
				copy[source_key] = source_value
			end
		end
	else -- number, string, boolean, etc
		copy = source
	end
	return copy
end

function table.checkCopy(key, source, target)
	if not target or not source then return end
	
	local s_ = source[key]
	local found = false
	for k,v in pairs(source) do		-- need optimize
		if k == key then
			found = true
			break
		end
	end

	if found then
		if type(source[key]) == "table" then
			target[key] = table.shallowCopy(source[key])
		else
			target[key] = source[key]
		end
	end
end

function table.pick(tbl)
	local index = math.random(1, #tbl)
	return tbl[index]
end

function table.shuffle(tbl)
	for i = #tbl,1,-1 do
		local j = math.random(1, i)
		local tmp = tbl[i]
		tbl[i] = tbl[j]
		tbl[j] = tmp
	end
end

function table.cover(tbl, tbl2)
	local tbl_ = {}
	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			local have = false
			if type(tbl2) == "table" and tbl2[k] ~= nil then
				have = true
				tbl_[k] = tbl2[k]
			end
			if have == false then
				tbl_[k] = v
			end
		end
	end
	return tbl_
end

function table.extend(tbl, tbl2)
	local tbl_ = {}

	if type(tbl) == "table" then
		for k, v in pairs(tbl) do
			tbl_[k] = v
		end
	end

	if type(tbl2) == "table" then
		for k,v in pairs(tbl2) do
			tbl_[k] = v
		end
	end

	return tbl_
end

function table.modify(tbl, tbl2)
	if type(tbl) == "table" and type(tbl2) == "table" then
		for k, v in pairs(tbl2) do
			tbl[k] = tbl2[k]
		end
	end
end
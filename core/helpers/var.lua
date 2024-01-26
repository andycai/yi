Yi = Yi or {}

-- In other words, it will return true if the variable is an empty string, false, array(), NULL, "0", 0, and an unset variable
function IsEmpty(value)
	return value == nil or value == false or value == "" or value == 0 or value == "0" or (type(value) == "table" and table.len(value) <= 0)
end

function IsTrue(value)
	return not IsEmpty(value)
end

function IsTable(value)
	return type(value) == "table"
end

function IsFunction(value)
	return type(value) == "function"
end

function IsNumber(value)
	return type(value) == "number"
end

function IsString(value)
	return type(value) == "string"
end

function IsBool(value)
	return type(value) == "boolean"
end

function IsUserdata(value)
	return type(value) == "userdata"
end

function IsSet(value)
	return type(value) ~= nil
end

function Format(...)
	return string.format(...)
end

function CheckValue(value, msg)
	if not msg then msg = "value is nil" end
	if not value then
		error(msg)
	end
end
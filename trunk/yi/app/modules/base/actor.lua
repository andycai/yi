if not SYSPATH then return end

local meta = class("BaseActor", Yi.Actor)

function meta:request(req, param)
	-- requestServer(param)
end

meta.action_dict_  = {}
function meta:response(action, handler)
	if action and handler and isfunction(handler) then
		self.action_dict_[action] = handler
	end
end

function meta:on(action, param)
	local noresp = true

	local handler_ = self.action_dict_[action]
	if handler_ and isfunction(handler_) then
		noresp = false
		handler_(param)
	else
		resp_ = Yi.use(name .. ".response")
		if resp_ then
			if not resp_.actor then
				resp_.actor = self
			end
			local action_arr = string.explode(action, '.')
			local method_ = action_arr[2]
			handler_ = resp_[method_]
			if handler_ and isfunction(handler_) then
				noresp = false
				handler_(resp_, param)
			end
		end
	end

	if noresp then
		print(string.format("Wrong action: %s", action))
	end
end

return meta
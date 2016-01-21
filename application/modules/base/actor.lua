if not SYSPATH then return end

local BaseActor = class("BaseActor", Yi.Actor)

function BaseActor:request(req, param)
	-- requestServer(param)
end

BaseActor.action_dict_  = {}
function BaseActor:response(action, handler)
	if action and handler and isfunction(handler) then
		self.action_dict_[action] = handler
	end
end

function BaseActor:on(action, param)
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
			handler_ = resp_[action]
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

return BaseActor
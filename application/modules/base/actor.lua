if not SYSPATH then return end

local BaseActor = class("BaseActor", Yi.Actor)

function BaseActor:request(req, param)
	-- requestServer(param)
end

BaseActor.resp_list_  = {}
function BaseActor:response(resp, handler)
	if resp and handler and isfunction(handler) then
		self.resp_list_[resp] = handler
	end
end

function BaseActor:on(resp, param)
	local noresp = true

	local handler_ = self.resp_list_[resp]
	if handler_ and isfunction(handler_) then
		noresp = false
		handler_(param)
	else
		handler_ = Yi.use(name .. ".response")
		if not handler_.actor then
			handler_.actor = self
		end
		if handler_ and isfunction(handler_) then
			noresp = false
			handler_(param)
		end
	end

	if noresp then
		print(string.format("Wrong action: %s", resp))
	end
end

return BaseActor
if not SYSPATH then return end

local BaseActor = class("BaseActor", Yi.Actor)

function BaseActor:request(req, param)
	-- requestServer(param)
end

function BaseActor:response(resp, response)
	if resp and response and isfunction(response) then
		self.resp[resp] = response
	end
end

return BaseActor
local meta = {}

meta.skills = {}

function meta:learn(skillid)
	if skillid then
		self.skills[skillid] = skillid
	end
end

return meta
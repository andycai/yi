if not SYSPATH then return end

local format = string.format

Yi = {
	lang = 'zh_cn',
	log = false,
	init = false,
	loaded = {}
}

local Facade = {
	observerMap = {},
	actors = {}
}

Yi.facade = Facade

function Yi.load(path)
	if not Yi.loaded[path] then
		Yi.loaded[path] = true
	end
	return require(path)
end

function Yi.system(path)
	return Yi.load(SYSPATH .. path)
end

function Yi.import(path)
	return Yi.load(APPPATH .. path)
end

function Yi.use(path)
	return Yi.load(APPPATH .. 'modules.' .. path)
end

function Yi.lib(path)
	return Yi.load(LIBPATH .. path)
end

function Yi.view(path)
	return Yi.use(path)
end

function Yi.newView(path)
	local View_ = Yi.use(path)
	return View_:new()
end

function Yi.message(file, path)
	local messages = Yi.import('messages.' .. path)
	return messages[path]
end

function Yi.magic(moduleName)
	local obj ={}
	local mt = {}
	setmetatable(obj, mt)
	mt.__index = function(table, key)
		if key == 'actor' then
			return Facade:actor(moduleName)
		elseif key == 'newView' then
			return function(path) return Yi.newView(moduleName..'.view.'..path) end
		else
			return Yi.use(string.format('%s.%s', moduleName, key))
		end
	end
	return obj
end

Yi.class = Yi.lib('middleclass')
Yi.system('ext.init')
Yi.system('helpers.init')

function Yi:init(settings)
	if self.init then
		return
	end

	self.init = true

	if settings.log then
		self.log = settings.log
	end

	if settings.lang then
		self.lang = settings.lang
		Yi.import('i18n.' .. self.lang)
	end
end

--[[
Event
--]]

Yi.Event = {}
local e_mt = {}
setmetatable(Yi.Event, e_mt)
e_mt.__index = function(table, key)
	return 'Event.' .. key
end

--[[
class Observer
--]]
local Observer = Yi.class("Observer")

function Observer:notifyObserver(event, ...)
	if self.action and isfunction(self.action) then
		self.action(self.context, ...)
	end
end

function Facade:registerObserver(event, observer)
	assert(not isempty(event), "event is empty")

	if self.observerMap[event] == nil then
		self.observerMap[event] = {observer}
	else
		table.insert(self.observerMap[event], observer)
	end
end

function Facade:notifyObservers(event, ...)
	assert(not isempty(event), "event is empty")

	local observers_ = self.observerMap[event]
	if observers_ then
		for _,v in ipairs(observers_) do
			v:notifyObserver(event, ...)
		end
	end
end

function Facade:registerActor(name)
	assert(not isempty(name), "module name is empty")

	local actor_ = self.actors[name] 
	if not actor_ then
		local Actor_ = Yi.use(name..'.actor')
		actor_ = Actor_:new(name)
		self.actors[name] = actor_
	end
	actor_:onRegister()

	local interests_ = actor_:listInterests()
	local len_ = #interests_
	for i = 1, len_, 2 do
		local observer_ = Observer:new()
		observer_.name = name
		observer_.context = actor_
		observer_.action = interests_[i+1]
		self:registerObserver(interests_[i], observer_)
	end

	for event_, action_ in pairs(actor_.actions) do
		local observer_ = Observer:new()
		observer_.name = name
		observer_.context = actor_
		observer_.action = action_
		self:registerObserver(event_, observer_)
	end
end

function Facade:registerModules(modules)
	for _,v in ipairs(modules) do
		if v then
			self:registerActor(v)
		end
	end
end

function Facade:actor(name)
	return self.actors[name]
end

function Facade:send(event, ...)
	Facade:notifyObservers(event, ...)
end

--[[
class Actor
--]]
local Actor = Yi.class("Actor")

Yi.Actor = Actor

Actor.actionDict = {}
Actor.actions = {}

function Actor:initialize(name)
	assert(not isempty(name), "module name is empty")
	self.name = name
end

function Actor:newView(path)
	return Yi.newView(self.name .. ".view." .. path)
end

function Actor:send(event, ...)
	Facade:notifyObservers(event, ...)
end

function Actor:listInterests()
	return {}
end

function Actor:onRegister() end

function Actor:request(action, param)
	if isfunction(Yi.request) then
		Yi.request(action, param)
	end
end

function Actor:response(action, handler)
	assert(action, 'action is empty on response')
	assert(isfunction(handler), 'handler is not function on response')

	self.actionDict[action] = handler
end

function Actor:on(action, param)
	local on_resp_ = false
	local on_ = self.actionDict[action]
	if isfunction(on_) then
		on_resp_ = true
	else
		local resp_ = Yi.use(self.name .. '.response')
		assert(resp_, self.name .. '.response is nil')
		local act_ = string.explode(action, ".")
		local method_ = act_[2]
		on_ = resp_[method_]
		if isfunction(on_) then
			on_resp_ = true
		end
	end
	if on_resp_ then
		on_(param, self)
	else
		print(string.format('no response on action' .. action))
	end
end

return Yi
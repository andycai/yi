if not SYSPATH then return end

local format = string.format

Yi = {
	lang = 'zh_cn',
	log = false,
	init_ = false
}

local Facade = {
	observerMap = {},
	actors = {}
}

Yi.class = require(LIBPATH .. 'middleclass')

require(SYSPATH .. 'ext.init')
require(SYSPATH .. 'helpers.init')

Yi.facade = Facade

function Yi:init(settings)
	if self.init_ then
		return
	end

	self.init_ = true

	if settings.log then
		self.log = settings.log
	end

	if settings.lang then
		self.lang = settings.lang
		Yi.import('i18n.' .. self.lang)
	end
end

function Yi.use(path)
	return require(APPPATH .. 'modules.' .. path)
end

function Yi.system(path)
	return require(SYSPATH .. path)
end

function Yi.import(path)
	return require(APPPATH .. path)
end

function Yi.lib(path)
	return require(LIBPATH .. path)
end

function Yi.load(path)
	return require(path)
end

function Yi.view(path)
	return Yi.use(path)
end

function Yi.new_view(path)
	local View_ = Yi.use(path)
	return View_:new()
end

function Yi.message(file, path)
	messages = require(APPPATH .. 'messages.' .. path)
	return messages[path]
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

Actor.action_dict_ = {}
Actor.actions = {}

function Actor:initialize(name)
	assert(not isempty(name), "module name is empty")
	self.name = name
end

function Actor:view(path)
	return Yi.new_view(self.name .. ".view." .. path)
end

function Actor:getView()
	if self.viewComponent == nil then
		self.viewComponent = self:view(self.name)
		assert(self.viewComponent ~= nil, self.name .. " view is nil")
	end
	return self.viewComponent
end

function Actor:send(event, ...)
	Facade:notifyObservers(event, ...)
end

function Actor:listInterests()
	return {}
end

function Actor:onRegister() end

function Actor:request(act, param)
	if Yi.request and isfunction(Yi.request) then
		Yi.request(act, param)
	end
end

function Actor:response(action, handler)
	assert(action, 'action is empty on response')
	assert(isfunction(handler), 'handler is not function on response')

	self.action_dict_[action] = handler
end

function Actor:on(action, param)
	local on_resp_ = false
	local on_ = self.action_dict_[action]
	if on_ and isfunction(on_) then
		on_resp_ = true
	else
		local resp_ = Yi.use(self.name .. '.response')
		assert(resp_, self.name .. '.response is nil')
		local act_ = string.explode(action, ".")
		local method_ = act_[2]
		on_ = resp_[method_]
		if on_ and isfunction(on_) then
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
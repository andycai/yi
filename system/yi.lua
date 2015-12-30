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
		Yi.load('i18n.' .. self.lang)
	end
end

function Yi.use(path)
	return require(MODPATH .. path)
end

function Yi.import(path)
	return require(SYSPATH .. path)
end

function Yi.load(path)
	return require(APPPATH .. path)
end

function Yi.message(file, path)
	messages = require(APPPATH .. 'messages.' .. path)
	return messages[path]
end

--[[
class Observer
--]]
local Observer = Yi.class("Observer")

function Observer:notifyObserver(event, ...)
	self.context[self.handle](self.context, event, ...)
end

function Facade:registerObserver(event, observer)
	assert(event, "event is empty")

	if self.observerMap[event] == nil then
		self.observerMap[event] = {observer}
	else
		table.insert(self.observerMap[event], observer)
	end
end

function Facade:notifyObservers(event, ...)
	assert(event, "event is empty")

	local observers_ = self.observerMap[event]
	if observers_ then
		for _,v in ipairs(observers_) do
			v:notifyObserver(event, ...)
		end
	end
end

function Facade:registerActor(name)
	assert(name, "module name is empty")

	local actor_ = self.actors[name] 
	if not actor_ then
		local Actor_ = Yi.use(name..'.actor')
		actor_ = Actor_:new(name)
		self.actors[name] = actor_
	end
	actor_:onRegister()

	local interests_ = actor_:listInterests()

	for _,v in ipairs(interests_) do
		local observer_ = Observer:new()
		observer_.name = name
		observer_.context = actor_
		observer_.handle = "handleNotification"
		self:registerObserver(v, observer_)
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

function Facade:view(name, path)
	local View_ = Yi.use(name..'.view.'..path)
	return View_:new()
end

function Facade:send(event, ...)
	Facade:notifyObservers(event, ...)
end

--[[
class Actor
--]]
local Actor = Yi.class("Actor")
Actor.handler = {}
Actor.resp = {}

Yi.Actor = Actor

function Actor:initialize(name)
	assert(name ~= nil and name ~= "", "module name is empty")
	self.name = name
end

function Actor:view(path)
	return Facade:view(self.name, path)
end

function Actor:getView()
	if self.viewComponent == nil then
		self.viewComponent = self:view(self.name)
		self.viewComponent.handler = self.handler
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

function Actor:handleNotification(event, ...)
	assert(event, "event is empty")

	if event then
		local action = 'action_' .. event
		if self[action] and isfunction(self[action]) then
			self[action](self, ...)
		end
	end
end

return Yi
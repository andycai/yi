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
	return require(APPPATH .. 'modules.' .. path)
end

function Yi.import(path)
	return require(SYSPATH .. path)
end

function Yi.load(path)
	return require(APPPATH .. path)
end

function Yi:view(path)
	local View_ = Yi.use(path)
	return View_:new()
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

	for _,v in ipairs(interests_) do	
		local event_ = v
		local action_
		if istable(v) then
			event_ = v[1]
			action_ = v[2]
		end
		if not action_ then
			action_ = actor_['action_' .. event_]
		end

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

function Actor:initialize(name)
	assert(not isempty(name), "module name is empty")
	self.name = name
end

function Actor:view(path)
	return Yi:view(self.name .. ".view." .. path)
end

function Actor:getView()
	if self.viewComponent == nil then
		self.viewComponent = self:view(self.name)
		assert(self.viewComponent ~= nil, self.name .. " view is nil")

		local handler_ = Yi.use(self.name .. ".handler")
		if handler_ then
			handler_.actor = self
		end
		self.viewComponent.handler = handler_
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

return Yi
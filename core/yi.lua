local format = string.format

Yi = {
	_lang = 'zh_cn',
	_log = false,
	_isInit = false,
	_modules = {},
	_moduleNames = {}
}

local Facade = {
	_observerMap = {},
	_actors = {}
}

Yi.facade = Facade

local class = require('libs.middleclass')

function Yi.use(path)
	return require(APPPATH .. 'modules.' .. path)
end

function Yi.message(file, path)
	local messages = require(APPPATH .. 'messages.' .. path)
	return messages[path]
end

function Yi.mod(moduleName)
	if Yi._modules[moduleName] then
		return Yi._modules[moduleName]
	end

	local obj ={
		moduleName = moduleName,
	}

	obj.newObj = function(path)
		local cls = Yi.use(format('%s.class.%s', moduleName, path))
		return cls:new()
	end

	obj.newWidget = function(path)
		local cls = Yi.use(format('%s.widget.%s', moduleName, path))
		return cls:new()
	end
	obj.loadWidget = function(path)
		return Yi.use(format('%s.widget.%s', moduleName, path))
	end

	local mt = {}
	setmetatable(obj, mt)
	mt.__index = function(mtable, key)
		return Yi.use(format('%s.%s', mtable.moduleName, key))
	end
	Yi._modules[moduleName] = obj

	return obj
end

Yi.go = {}   -- go to module
Yi.go.send = function(...)
	Facade:send(...)
end

local modulemt_ = {}
setmetatable(Yi.go, modulemt_)
modulemt_.__index = function(_, key)
	assert(Yi._moduleNames[key], "module doesn't exists: " .. key)
	return Yi.mod(Yi._moduleNames[key])
end

function Yi.reload(path)
	package.loaded[path] = nil
end

function Yi.init(settings)
	if Yi._isInit then
		return
	end

	Yi._isInit = true

	if settings.log then
		Yi._log = settings.log
	end

	if settings.lang then
		Yi._lang = settings.lang
	end
end

function Yi.lang()
	return Yi._lang
end

--[==[
Event
--]==]

Yi.Event = {}
Yi.Event.send = function(...)
	Facade:send(...)
end

local e_mt = {}
setmetatable(Yi.Event, e_mt)
e_mt.__index = function(table, key)
	return 'Event.' .. key
end

--[==[
class Observer
--]==]
local Observer = class("Observer")

function Observer:notifyObserver(...)
	if self.action and IsFunction(self.action) then
		self.action(self.context, ...)
	end
end

function Facade:registerObserver(eventName, observer)
	assert(not IsEmpty(eventName), "event is empty")

	if self._observerMap[eventName] == nil then
		self._observerMap[eventName] = {observer}
	else
		table.insert(self._observerMap[eventName], observer)
	end
end

function Facade:notifyObservers(eventName, ...)
	assert(not IsEmpty(eventName), "event is empty")

	local observers_ = self._observerMap[eventName]
	if observers_ then
		for _,v in ipairs(observers_) do
			v:notifyObserver(...)
		end
	end
end

function Facade:registerActor(moduleName)
	assert(not IsEmpty(moduleName), "module name is empty")

	local sp_ = string.explode(moduleName, ".")
	local unique_name = sp_[#sp_]			-- support submodule like role.skill => skill

	local actor_ = self._actors[moduleName]
	assert(actor_ == nil, "module name repetition:" .. moduleName)
	assert(Yi._moduleNames[unique_name] == nil, "unique name repetition:" .. unique_name)
	Yi._moduleNames[unique_name] = moduleName

	local Actor_ = Yi.use(moduleName..'.actor')
	actor_ = Actor_:new(moduleName)
	self._actors[moduleName] = actor_
	actor_:onRegister()

	local interests_ = actor_:listInterests()
	for eventName, action in pairs(interests_) do
		assert(not IsEmpty(eventName), "listInterests key is empty")
		assert(IsFunction(action), "listInterests value is not function, event name: " .. eventName)
		local observer_ = Observer:new()
		observer_.name = moduleName
		observer_.context = actor_
		observer_.action = action
		self:registerObserver(eventName, observer_)
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
	return self._actors[name]
end

function Facade:send(eventName, ...)
	Facade:notifyObservers(eventName, ...)
end

--[==[
class Actor
--]==]
local Actor = class("Actor")

Yi.Actor = Actor

Actor._handlers = {}
Actor.static.instance_ = nil

Actor.static.instance = function()
	if not Actor.instance_ then
		Actor.instance_ = Actor:new()
	end
	return Actor.instance_
end

function Actor:initialize(name)
	assert(not IsEmpty(name), "module name is empty")
	self._name = name
end

function Actor:listInterests()
	return {}
end

function Actor:onRegister() end

function Actor:addListener(eventName, action)
	assert(not IsEmpty(eventName), 'event is empty on addListener')
	assert(IsFunction(action), 'action is not function on addListener')

	local observer_ = Observer:new()
	observer_.name = eventName
	observer_.context = self
	observer_.action = action
	Facade:registerObserver(eventName, observer_)
end

function Actor:request(action, param)
	if IsFunction(Yi.request) then
		Yi.request(action, param)
	end
end

function Actor:response(name, handler)
	assert(name, 'name is empty on response')
	assert(IsFunction(handler), 'handler is not function on response')

	self._handlers[name] = handler
end

function Actor:on(action, param)
	local on_resp_ = false
	local on_ = self._handlers[action]
	if IsFunction(on_) then
		on_resp_ = true
	else
		local resp_ = Yi.use(self._name .. '.response')
		assert(resp_, self._name .. '.response is nil')
		local act_ = string.explode(action, ".")
		local method_ = act_[2]
		on_ = resp_[method_]
		if IsFunction(on_) then
			on_resp_ = true
		end
	end
	if on_resp_ then
		on_(param, self)
	else
		print(format('no response on action' .. action))
	end
end

return Yi
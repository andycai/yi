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

function Yi.load(path)
	return require(path)
end

function Yi.use(path)
	return Yi.load(APPPATH .. 'modules.' .. path)
end

function Yi.newView(path)
	local View_ = Yi.use(path)
	return View_:new()
end

function Yi.message(file, path)
	local messages = Yi.load('app.messages.' .. path)
	return messages[path]
end

function Yi.mod(moduleName)
	if Yi._modules[moduleName] then
		return Yi._modules[moduleName]
	end

	local obj ={
		moduleName = moduleName,
	}
	obj.newView = function(path)
		return Yi.newView(format('%s.view.%s', moduleName, path))
	end
	obj.loadView = function(path)
		return Yi.use(format('%s.view.%s', moduleName, path))
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

Yi.class = Yi.load('libs.middleclass')
Yi.load('core.ext.init')
Yi.load('core.helpers.init')

function Yi:init(settings)
	if self._isInit then
		return
	end

	self._isInit = true

	if settings.log then
		self._log = settings.log
	end

	if settings.lang then
		self._lang = settings.lang
		Yi.load('app.i18n.' .. self._lang)
	end
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
local Observer = Yi.class("Observer")

function Observer:notifyObserver(event, ...)
	if self.action and IsFunction(self.action) then
		self.action(self.context, ...)
	end
end

function Facade:registerObserver(event, observer)
	assert(not IsEmpty(event), "event is empty")

	if self._observerMap[event] == nil then
		self._observerMap[event] = {observer}
	else
		table.insert(self._observerMap[event], observer)
	end
end

function Facade:notifyObservers(event, ...)
	assert(not IsEmpty(event), "event is empty")

	local observers_ = self._observerMap[event]
	if observers_ then
		for _,v in ipairs(observers_) do
			v:notifyObserver(event, ...)
		end
	end
end

function Facade:registerActor(name)
	assert(not IsEmpty(name), "module name is empty")

	local sp_ = string.explode(name, ".")
	local unique_name = sp_[#sp_]			-- support submodule like role.skill => skill

	local actor_ = self._actors[name]
	assert(actor_ == nil, "module name repetition:" .. name)
	assert(Yi._moduleNames[unique_name] == nil, "unique name repetition:" .. unique_name)
	Yi._moduleNames[unique_name] = name

	local Actor_ = Yi.use(name..'.actor')
	actor_ = Actor_:new(name)
	self._actors[name] = actor_
	actor_:onRegister()

	local interests_ = actor_:listInterests()
	for eventName, action in pairs(interests_) do
		assert(not IsEmpty(eventName), "listInterests key is empty")
		assert(IsFunction(action), "listInterests value is not function, event name: " .. eventName)
		local observer_ = Observer:new()
		observer_.name = name
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

function Facade:send(event, ...)
	Facade:notifyObservers(event, ...)
end

--[==[
class Actor
--]==]
local Actor = Yi.class("Actor")

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
	self.m_name = name
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
		local resp_ = Yi.use(self.m_name .. '.response')
		assert(resp_, self.m_name .. '.response is nil')
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
		print(string.format('no response on action' .. action))
	end
end

return Yi
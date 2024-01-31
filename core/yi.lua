local format = string.format

local yi_ = {
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

yi_.facade = Facade

local class = require('libs.middleclass')

function yi_.use(path)
	return require(APPPATH .. 'modules.' .. path)
end

function yi_.message(file, path)
	local messages = require(APPPATH .. 'messages.' .. path)
	return messages[path]
end

function yi_.mod(moduleName)
	if yi_._modules[moduleName] then
		return yi_._modules[moduleName]
	end

	local obj ={
		moduleName = moduleName,
	}

	obj.newObj = function(path)
		local cls = yi_.use(format('%s.class.%s', moduleName, path))
		return cls:new()
	end

	obj.newWidget = function(path)
		local cls = yi_.use(format('%s.widget.%s', moduleName, path))
		return cls:new()
	end
	obj.loadWidget = function(path)
		return yi_.use(format('%s.widget.%s', moduleName, path))
	end

	local mt = {}
	setmetatable(obj, mt)
	mt.__index = function(mtable, key)
		return yi_.use(format('%s.%s', mtable.moduleName, key))
	end
	yi_._modules[moduleName] = obj

	return obj
end

yi_.go = {}   -- go to module
yi_.go.send = function(...)
	Facade:send(...)
end

local modulemt_ = {}
setmetatable(yi_.go, modulemt_)
modulemt_.__index = function(_, key)
	assert(yi_._moduleNames[key], "module doesn't exists: " .. key)
	return yi_.mod(yi_._moduleNames[key])
end

function yi_.reload(path)
	package.loaded[path] = nil
end

function yi_.init(settings)
	if yi_._isInit then
		return
	end

	yi_._isInit = true

	if settings.log then
		yi_._log = settings.log
	end

	if settings.lang then
		yi_._lang = settings.lang
	end
end

function yi_.lang()
	return yi_._lang
end

--[==[
Event
--]==]

yi_.Event = {}
yi_.Event.send = function(...)
	Facade:send(...)
end

local e_mt = {}
setmetatable(yi_.Event, e_mt)
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
	assert(yi_._moduleNames[unique_name] == nil, "unique name repetition:" .. unique_name)
	yi_._moduleNames[unique_name] = moduleName

	local Actor_ = yi_.use(moduleName..'.actor')
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

yi_.Actor = Actor

Actor._handlers = {}
Actor.static.instance_ = nil

Actor.static.instance = function()
	if not Actor.instance_ then
		Actor.instance_ = Actor:new()
	end
	return Actor.instance_
end

function Actor:initialize(moduleName)
	assert(not IsEmpty(moduleName), "module name is empty")
	self._name = moduleName
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

function Actor:model(moduleName)
	moduleName = moduleName or self._name
	return yi_.mod(moduleName).model
end

function Actor:service(moduleName)
	moduleName = moduleName or self._name
	return yi_.mod(moduleName).service
end

function Actor:view()
	return yi_.mod(self._name).view
end

function Actor:request(action, param)
	if IsFunction(yi_.request) then
		yi_.request(action, param)
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
		local resp_ = yi_.use(self._name .. '.response')
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

--[==[
object 
--]==]
local Object = require('libs.object')
local cell = Object:extend()

yi_.Cell = cell

function cell:model(moduleName)
	moduleName = moduleName or self.name
	assert(moduleName ~= nil, 'moduleName is empty calling model')
	return yi_.mod(moduleName).model
end

function cell:service(moduleName)
	moduleName = moduleName or self.name
	assert(moduleName ~= nil, 'moduleName is empty calling service')
	return yi_.mod(moduleName).service
end

function cell:handler()
	local moduleName = self.name
	assert(moduleName ~= nil, 'moduleName is empty calling handler')
	return yi_.mod(moduleName).handler
end

function cell:newObj(path, moduleName)
	moduleName = moduleName or self.name
	assert(moduleName ~= nil, 'moduleName is empty calling newObj')
	return yi_.mod(moduleName).newObj(path)
end

function cell:newWidget(path, moduleName)
	moduleName = moduleName or self.name
	assert(moduleName ~= nil, 'moduleName is empty calling newWidget')
	return yi_.mod(moduleName).newWidget(path)
end

function cell:loadWidget(path, moduleName)
	moduleName = moduleName or self.name
	assert(moduleName ~= nil, 'moduleName is empty calling loadWidget')
	return yi_.mod(moduleName).loadWidget(path)
end

-- function cell:view()
-- 	local moduleName = self.name
-- 	assert(moduleName ~= nil, 'moduleName is empty calling view')
-- 	return Yi.mod(moduleName).view
-- end

-- 遵守开发约定
-- 1. 模块之间必须通过事件来做交互，主要是界面的处理
-- 2. 只有模块中的 Actor 层才能调用 view 层的接口，其他层如 model、service、handler 等都不能
-- 3. 模块之间可以互相调用之间的 model 层和 service 层的公开接口
-- 4. 模块 view 层，没有能力直接调用其他

return yi_
if not SYSPATH then return end

local format = string.format

Yi = {
	lang = 'zh_cn',
	log = false,
	init = false,
	loaded = {},
	magicModules = {}
}

local Facade = {
	observerMap = {},
	actors = {}
}

Yi.facade = Facade

function Yi.Load(path)
	if not Yi.loaded[path] then
		Yi.loaded[path] = true
	end
	return require(path)
end

function Yi.Use(path)
	return Yi.Load(APPPATH .. 'modules.' .. path)
end

function Yi.View(path)
	return Yi.Use(path)
end

function Yi.NewView(path)
	local View_ = Yi.Use(path)
	return View_:new()
end

function Yi.Message(file, path)
	local messages = Yi.Load('app.messages.' .. path)
	return messages[path]
end

function Yi.Magic(moduleName)
	if Yi.magicModules[moduleName] then
		return Yi.magicModules[moduleName]
	end

	local obj ={}
	local mt = {}
	setmetatable(obj, mt)
	mt.__index = function(table, key)
		if key == 'actor' then
			return Facade:Actor(moduleName)
		elseif key == 'NewView' then
			return function(path) return Yi.NewView(moduleName..'.view.'..path) end
		else
			return Yi.Use(string.format('%s.%s', moduleName, key))
		end
	end
	Yi.magicModules[moduleName] = obj
	
	return obj
end

Yi.module = {}   -- module
local modulemt_ = {}
setmetatable(Yi.module, modulemt_)
modulemt_.__index = function(table, key)
	if key == 'Send' then
		return function(...) return Facade:Send(...) end
	else
		return Yi.Magic(key)
	end
end

function Yi.Reload(path)
	package.loaded[path] = nil
end

Yi.class = Yi.Load('libs.middleclass')
Yi.Load('system.ext.init')
Yi.Load('system.helpers.init')

function Yi:Init(settings)
	if self.init then
		return
	end

	self.init = true

	if settings.log then
		self.log = settings.log
	end

	if settings.lang then
		self.lang = settings.lang
		Yi.Load('app.i18n.' .. self.lang)
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

function Observer:NotifyObserver(event, ...)
	if self.action and isfunction(self.action) then
		self.action(self.context, ...)
	end
end

function Facade:RegisterObserver(event, observer)
	assert(not isempty(event), "event is empty")

	if self.observerMap[event] == nil then
		self.observerMap[event] = {observer}
	else
		table.insert(self.observerMap[event], observer)
	end
end

function Facade:NotifyObservers(event, ...)
	assert(not isempty(event), "event is empty")

	local observers_ = self.observerMap[event]
	if observers_ then
		for _,v in ipairs(observers_) do
			v:NotifyObserver(event, ...)
		end
	end
end

function Facade:RegisterActor(name)
	assert(not isempty(name), "module name is empty")

	local actor_ = self.actors[name] 
	if not actor_ then
		local Actor_ = Yi.Use(name..'.actor')
		actor_ = Actor_:new(name)
		self.actors[name] = actor_
	end
	actor_:OnRegister()

	local interests_ = actor_:ListInterests()
	local len_ = #interests_
	for i = 1, len_, 2 do
		local observer_ = Observer:new()
		observer_.name = name
		observer_.context = actor_
		observer_.action = interests_[i+1]
		self:RegisterObserver(interests_[i], observer_)
	end

	for event_, action_ in pairs(actor_.actions) do
		local observer_ = Observer:new()
		observer_.name = name
		observer_.context = actor_
		observer_.action = action_
		self:RegisterObserver(event_, observer_)
	end
end

function Facade:RegisterModules(modules)
	for _,v in ipairs(modules) do
		if v then
			self:RegisterActor(v)
		end
	end
end

function Facade:Actor(name)
	return self.actors[name]
end

function Facade:Send(event, ...)
	Facade:NotifyObservers(event, ...)
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

function Actor:NewView(path)
	return Yi.NewView(self.name .. ".view." .. path)
end

function Actor:Send(event, ...)
	Facade:NotifyObservers(event, ...)
end

function Actor:ListInterests()
	return {}
end

function Actor:OnRegister() end

function Actor:Request(action, param)
	if isfunction(Yi.Request) then
		Yi.Request(action, param)
	end
end

function Actor:Response(action, handler)
	assert(action, 'action is empty on response')
	assert(isfunction(handler), 'handler is not function on response')

	self.actionDict[action] = handler
end

function Actor:On(action, param)
	local on_resp_ = false
	local on_ = self.actionDict[action]
	if isfunction(on_) then
		on_resp_ = true
	else
		local resp_ = Yi.Use(self.name .. '.response')
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
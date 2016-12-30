if not SYSPATH then return end

local format = string.format

Yi = {
	lang = 'zh_cn',
	log = false,
	init = false,
	loaded = {},
	magic_modules = {},
	module_names = {}
}

local Facade = {
	m_observer_map = {},
	m_actors = {}
}

Yi.facade = Facade

function Yi.load(path)
	if not Yi.loaded[path] then
		Yi.loaded[path] = true
	end
	return require(path)
end

function Yi.use(path)
	return Yi.load(APPPATH .. 'modules.' .. path)
end

function Yi.view(path)
	return Yi.use(path)
end

function Yi.newView(path)
	local View_ = Yi.use(path)
	return View_:new()
end

function Yi.message(file, path)
	local messages = Yi.load('app.messages.' .. path)
	return messages[path]
end

function Yi.magic(module_name)
	if Yi.magic_modules[module_name] then
		return Yi.magic_modules[module_name]
	end

	local obj ={}
	local mt = {}
	setmetatable(obj, mt)
	mt.__index = function(table, key)
		if key == 'NewView' then
			return function(path) return Yi.newView(module_name..'.view.'..path) end
		else
			return Yi.use(string.format('%s.%s', module_name, key))
		end
	end
	Yi.magic_modules[module_name] = obj

	return obj
end

Yi.module = {}   -- module
local modulemt_ = {}
setmetatable(Yi.module, modulemt_)

Yi.module.send = function(...)
	Facade:send(...)
end

modulemt_.__index = function(table, key)
	assert(Yi.module_names[key], "module doesn't exists: " .. key)
	return Yi.magic(Yi.module_names[key])
end

function Yi.reload(path)
	package.loaded[path] = nil
end

Yi.class = Yi.load('libs.middleclass')
Yi.load('system.ext.init')
Yi.load('system.helpers.init')

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
		Yi.load('app.i18n.' .. self.lang)
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

	if self.m_observer_map[event] == nil then
		self.m_observer_map[event] = {observer}
	else
		table.insert(self.m_observer_map[event], observer)
	end
end

function Facade:notifyObservers(event, ...)
	assert(not isempty(event), "event is empty")

	local observers_ = self.m_observer_map[event]
	if observers_ then
		for _,v in ipairs(observers_) do
			v:notifyObserver(event, ...)
		end
	end
end

function Facade:registerActor(name)
	assert(not isempty(name), "module name is empty")

	local sp_ = string.explode(name, ".")
	local unique_name = sp_[#sp_]			-- role.skill => skill

	local actor_ = self.m_actors[name]
	assert(actor_ == nil, "module name repetition:" .. name)
	assert(Yi.module_names[unique_name] == nil, "unique name repetition:" .. unique_name)
	Yi.module_names[unique_name] = name

	local Actor_ = Yi.use(name..'.actor')
	actor_ = Actor_:new(name)
	self.m_actors[name] = actor_
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

	for event_, action_ in pairs(actor_.m_actions) do
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
	return self.m_actors[name]
end

function Facade:send(event, ...)
	Facade:notifyObservers(event, ...)
end

--[[
class Actor
--]]
local Actor = Yi.class("Actor")

Yi.Actor = Actor

Actor.m_action_dict = {}
Actor.m_actions = {}
Actor.static.instance_ = nil

Actor.static.Instance = function()
	if not Actor.instance_ then
		Actor.instance_ = Actor:new()
	end
	return Actor.instance_
end

function Actor:initialize(name)
	assert(not isempty(name), "module name is empty")
	self.m_name = name
end

function Actor:newView(path)
	return Yi.newView(self.m_name .. ".view." .. path)
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

	self.m_action_dict[action] = handler
end

function Actor:on(action, param)
	local on_resp_ = false
	local on_ = self.m_action_dict[action]
	if isfunction(on_) then
		on_resp_ = true
	else
		local resp_ = Yi.use(self.m_name .. '.response')
		assert(resp_, self.m_name .. '.response is nil')
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
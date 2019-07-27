--
-- Author: Carl
-- Date: 2015-07-15 22:27:16
--
local EventDispatcher = class("EventDispatcher")
local scheduler = require("framework.scheduler")

function EventDispatcher:ctor()
	self._listeners = {}
	self._listenerHandleIndex = 0
	self._eventQueue = {}
	self._updateHandle = scheduler.scheduleUpdateGlobal(handler(self, self.__onUpdate))
end

local function makeKey(eventId)
	return "e"..eventId
end

-- 添加事件监听
function EventDispatcher:addListener(target, eventId, listener)
	local key = makeKey(eventId)
	if not self._listeners[key] then
		self._listeners[key] = {}
	end
	self._listenerHandleIndex = self._listenerHandleIndex + 1
	local handle = "#"..(self._listenerHandleIndex)
	self._listeners[key][handle] = {target=target, listener=listener}
	return handle
end

-- 触发事件
-- args: pendingBefore/pendingAfter 前/后阻塞事件多长时间
-- hook: 当所有监听通知到后回调
function EventDispatcher:dispatch(eventId, args, hook)
	local event = {}
	event.id = eventId
	event.args = args
	event.pendingBefore = (args or {}).pendingBefore or 0
	event.pendingAfter = (args or {}).pendingAfter or 0
	event.hook = hook
	table.insert(self._eventQueue, event)
end

-- 根据事件ID移除事件监听
function EventDispatcher:removeListenerByEvent(eventId)
	local key = makeKey(eventId)
	if self._listeners[key] then
		self._listeners[key] = {}
	end
end

-- 根据handle移除事件监听
function EventDispatcher:removeListenerByTarget(target)
	for _,listeners in pairs(self._listeners) do
		for handle, v in pairs(listeners) do
			if v.target == target then
				listeners[handle] = nil
			end
		end
	end
end

-- 根据handle移除事件监听
function EventDispatcher:removeListenerByHandle(handle)
	for _,listeners in pairs(self._listeners) do
		for h,_ in pairs(listeners) do
			if h == handle then
				listeners[handle] = nil
				return
			end
		end
	end
end

-- 移除所有事件监听
function EventDispatcher:removeAllListener()
	self._listeners = {}
end

function EventDispatcher:__onUpdate(dt)
	if #self._eventQueue == 0 then
		return
	end
	local event = self._eventQueue[1]
	if event then
		local id = event.id
		if not event.isexecuted then
			if event.pendingBefore > 0 then
				event.pendingBefore = event.pendingBefore - dt
			else
				event.isexecuted = true
				self:__executeEvent(id, event.args)
			end
		end
		if event.isexecuted then
			if event.pendingAfter > 0 then
				event.pendingAfter = event.pendingAfter - dt
			else
				table.remove(self._eventQueue, 1)
				if event.hook then event.hook() end
			end
		end
	end
end

function EventDispatcher:__executeEvent(eventId, args)
	local key = makeKey(eventId)
	local listeners = self._listeners[key]
	if listeners then
		for k,v in pairs(listeners) do
			if v.listener then
				v.listener(args)
			end
		end
	end
end

-- 打印监听器
function EventDispatcher:dumpAllListeners()
	if DEBUG > 0 then
		print("---- EventDispatcher:dumpAllEventListeners() ----")
	    for name, listeners in pairs(self.listeners_) do
	        printf("-- event: %s", name)
	        for handle, v in pairs(listeners) do
	            printf("--   target: %s, listener: %s, handle: %s", tostring(v.target), tostring(v.listener), tostring(handle))
	        end
	    end
	end
end

-- 销毁
function EventDispatcher:destory()
	scheduler.unscheduleGlobal(self._updateHandle)
	self:removeAllListener()
end

if not event then
	event = EventDispatcher.new()
end

return EventDispatcher
--
-- Author: Carl
-- Date: 2015-04-23 16:03:14
--

local BaseModel = class("BaseModel", cc.mvc.ModelBase)

function BaseModel:ctor(properties)
	BaseModel.super.ctor(self, properties)
	if self.onCreate then self:onCreate() end
	
end

-- 设置是否启用状态机
function BaseModel:setStateMachineEnable(enable)
	if enable and not self._fsm then
		self:addComponent("components.behavior.StateMachine")
		-- 由于状态机仅供内部使用，所以不应该调用组件的 exportMethods() 方法，改为用内部属性保存状态机组件对象
	    self._fsm = self:getComponent("components.behavior.StateMachine")
	    -- 启动状态机
        local _events, _callbacks = {}, {}
        if self.onSetFSMEvents then
            self:onSetFSMEvents(_events)
        end
        if self.onSetFSMCallbacks then
            self:onSetFSMCallbacks(_callbacks)
        end
        self._fsm:setupState({events=_events, callbacks=_callbacks})
	else
		self:removeComponent(self._fsm)
		self._fsm = nil
	end
end

--[[
增加状态机事件
@events: 事件table
@name: 事件名称
@from: 源状态
@to: 目标状态
]] 
function BaseModel:addFSMEvent(_events, _name, _from, _to)
	table.insert(_events, {name=_name, from=_from, to=_to})
end

--[[
增加状态机回调
@events: 事件table
@name: 事件名称
@from: 源状态
@to: 目标状态
]] 
function BaseModel:addFSMCallback(_callbacks, _name, _handler)
	_callbacks[_name] = handler(self, _handler)
end

-- 设置当前状态
function BaseModel:doEvent(event, ...)
	if self._fsm then
		return self._fsm:doEvent(event, ...)
	else
		printError("no enable State Machine!")
	end
end

-- 设置当前状态
function BaseModel:setState(state)
	if self._fsm then
		self._fsm.current_ = state
	else
		printError("no enable State Machine!")
	end
end

-- 获取当前状态
function BaseModel:getState()
	if self._fsm then
		return self._fsm:getState()
	end
	return "unknown"
end

-- 是否再当前状态
function BaseModel:isState(state)
	return self._fsm:isState(state)
end
return BaseModel
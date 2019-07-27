--
-- Author: Carl
-- Date: 2015-08-11 17:19:54
--
-- 数据管理类
 
local BaseData = class("BaseData")

-- 设置数据
-- @inMem 是否保存在内存里
function BaseData:set(key, value, inMem)
	storage:set(key, value, inMem)
end

-- 获取数据
function BaseData:get(key, def)
	return storage:get(key, def)
end

-- 保存到文件，不调用会在内存里保存数据
function BaseData:save()
	storage:save()
end

-- 设置值变化监听器
function BaseData:setObserver(key, observer)
	storage:setObserver(key, observer)
end

-- 移除监听器
function BaseData:removeObserver(key)
	storage:removeObserver(key)
end

-- 通知观察者
function BaseData:notifyObserver(key, oldval, newval)
	storage:notifyObserver(key, oldval, newval)
end

return BaseData
--
-- Author: Carl
-- Date: 2015-08-11 17:21:32
--
--[[
	数据存储，单例
]]
local LocalStorage = class("LocalStorage")
require("framework.cc.utils.GameState")

-- 从文件中加载数据
function LocalStorage:load()
	if not self._initialized then
		local function onEvent(event)
			if event.name == "load" then
				if event.values then
					--RgMJwaUGWrOfYg5e
					local str = crypto.decryptXXTEA(crypto.decodeBase64(event.values.data), "D5jz0Orc6Zcja6hn")
	            	local gameData = json.decode(str)
	            	if DEBUG > 0 then
	            		dump(gameData, "#打印缓存")
	            	end
	            	return gameData
				end
			elseif event.name == "save" then
				local str = json.encode(event.values)
	            if str then
	                str = crypto.encodeBase64(crypto.encryptXXTEA(str, "D5jz0Orc6Zcja6hn"))
	            end
	            return {data=str}
			end
		end
		cc.utils.State.init(onEvent, ".dat", "superman-carl-:)")
		self._initialized = true
	end
	self._persisMap = cc.utils.State.load() or {}
	self._memMap = {}
	self._observers = {}
end

-- 保存数据到文件
function LocalStorage:save()
	cc.utils.State.save(self._persisMap)
end

-- 获取内存数值
function LocalStorage:get(key, def)
	print("获取内存值")
	
	local table = self._persisMap[key] or self._memMap[key]
	if table then
		if table.t == "number" then
			return tonumber(decryptMemData(table.v))
		else
			return table.v
		end
	end
	return def
end

-- 重新设置值
function LocalStorage:set(key, value, inMem)
	local table
	if inMem then
		table = self._memMap[key]
	else
		table = self._persisMap[key]
	end
	if table then
		-- 老值和新值类型不同，尝试转换新值类型
		local oldType = table.t
		local newType = type(value)
		if oldType ~= "nil" and newType ~= "nil" and newType ~= oldType then
			if oldType == "number" then
				value = tonumber(value)
			elseif oldType == "string" then
				value = tostring(value)
			elseif oldType == "boolean" then
				if newType == "string" then
					if value == "true" then
						value = true
					else
						value = false
					end
				elseif newType == "number" then
					if value > 0 then
						value = true
					else
						value = false
					end
				else
					if DEBUG > 0 then
						printInfo("@无法进行类型转换！从%s到%s", newType, oldType)
					end
				end
			else
				if DEBUG > 0 then
					printInfo("@无法进行类型转换！从%s到%s", newType, oldType)
				end
				-- 无法进行转换
				return
			end
		end
		local oldValue = table.v
		if oldType == "number" then
			oldValue = tonumber(decryptMemData(oldValue))
		end
		if oldValue ~= value then
			-- 如果是数字，则进行加密
			if oldType == "number" then
				table.v = encryptMemData(value)
			else
				table.v = value
			end
			self:notifyObserver(key, oldval, value)
		end
	else
		local newType = type(value)
		local newValue = value
		if newType == "number" then
			newValue = encryptMemData(value)
		end
		if inMem then
			self._memMap[key] = {v=newValue, t=newType}
		else
			self._persisMap[key] = {v=newValue, t=newType}
		end
		self:notifyObserver(key, nil, value)
	end
end

-- 通知观察者
function LocalStorage:notifyObserver(key, oldval, newval)
	if self._observers[key] then
		for i,observer in ipairs(self._observers[key]) do
			observer({old=oldval, new=newval})
		end
	end
end

-- 增加对关键字的监听
function LocalStorage:setObserver(key, observer)
	if self._observers[key] then
		table.insert(self._observers[key], observer)
	else
		self._observers[key] = {}
		table.insert(self._observers[key], observer)
	end
end

-- 移除监听器
function LocalStorage:removeObserver(key)
	self._observers[key] = nil
end

if not storage then
	storage = LocalStorage.new()
end

return LocalStorage
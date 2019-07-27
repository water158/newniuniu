--
-- Author: Carl
-- Date: 2015-04-22 14:24:51
--

require("framework.cc.utils.bit")
local ByteBuffer = class("ByteBuffer")

function ByteBuffer:ctor(bytes)
	self:setBytes(bytes)
	self._pos = 1
end

--获取缓冲内总字节数
function ByteBuffer:getLen()
	return #self._bytes
end

-- 获取剩余字节大小
function ByteBuffer:getAvailable()
	return #self._bytes - self._pos + 1
end

-- 获取当前读取位置
function ByteBuffer:getPos()
	return self._pos
end

-- 重置缓冲
function ByteBuffer:reset()
	self._pos = 1
	self._bytes = {}
end

-- 重置读取位置
function ByteBuffer:resetPos()
	self._pos = 1
end

-- 写入字节数组
function ByteBuffer:setBytes(bytes)
	if bytes then
		self._bytes = {string.byte(bytes, 1, -1)}
	else
		self._bytes ={}
	end
end

-- 追加字节数组
function ByteBuffer:appendBytes(bytes)
	if #bytes == 0 then
		self:setBytes(bytes)
	else
		local bs = {string.byte(bytes, 1, -1)}
		for i,v in ipairs(bs) do
			table.insert(self._bytes, v)
		end
	end
end

-- 读取byte
function ByteBuffer:readByte()
	local byte = self._bytes[self._pos]
	self._pos = self._pos + 1
	return byte
end

-- 读取unsigned int
function ByteBuffer:readUInt()
	if #self._bytes >= 4 then
		return self:readByte() + bit.blshift(self:readByte(), 8) + bit.blshift(self:readByte(), 16) + bit.blshift(self:readByte(), 24)
	end
	return -1
end

-- 读取字符串
function ByteBuffer:readString(len)
	local s = nil
	if self:getAvailable() >= len then
		for i=self._pos,len+self._pos-1 do
			s = (s or "") .. string.char(self._bytes[i])
		end
        self._pos = self._pos + len
	end
	return s
end

-- 根据当前位置生成新的buffer
function ByteBuffer:compact()
	local new = {}
	for i=1, self:getAvailable() do
		new[i] = self._bytes[self._pos+i-1]
	end
	self._bytes = new
	self._pos = 1
end

return ByteBuffer
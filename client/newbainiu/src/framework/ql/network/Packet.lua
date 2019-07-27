--
-- Author: Carl
-- Date: 2015-04-22 11:49:41
--

local Packet = class("Packet")

local function int2bytes(value)
	local bytes = {}
	bytes[1] = bit.band(value, 0xFF)
	bytes[2] = bit.band(bit.brshift(value, 8), 0xFF)
	bytes[3] = bit.band(bit.brshift(value, 16), 0xFF)
	bytes[4] = bit.band(bit.brshift(value, 24), 0xFF)
	return string.char(unpack(bytes));
end

function Packet:ctor(msgid, seqno, bodyString)
	self._msgid = msgid or -1
	self._seqno = seqno or 0
	self._body = bodyString or "{}"
end

-- 获取消息ID
function Packet:getMsgId()
	return self._msgid
end

-- 获取消息序列号
function Packet:getSeqNO()
	return self._seqno
end

-- 获取包体(table)
function Packet:getBody()
	return json.decode(self._body)
end

function Packet:pack()
	local bodyLen = #{string.byte(self._body, 1, -1)}
	return int2bytes(self._msgid)..int2bytes(bodyLen)..int2bytes(self._seqno)..self._body
end



return Packet
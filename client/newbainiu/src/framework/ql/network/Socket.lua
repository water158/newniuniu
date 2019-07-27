--
-- Author: Carl
-- Date: 2015-04-21 18:24:48
--

--[[
Socket工具类，只支持单连接。
]]

local net = require("framework.cc.net.init")
local ByteBuffer = import(".ByteBuffer")
local Packet = import(".Packet")
local ByteArray = ("framework.cc.utils.ByteArray")
local scheduler = require("framework.scheduler")

SOCKET_STATE_IDLE       = -1
SOCKET_STATE_CONNECTING = 0
SOCKET_STATE_CONNECTED  = 1
SOCKET_STATE_CLOSING    = 2
SOCKET_STATE_CLOSED     = 3
SOCKET_HEARTBEAT_INTERVAL = 10 -- 心跳间隔 10s
SOCKET_HEARTBEAT_TIMEOUT = 5 -- 超时时间

HEARBEAT_ENABLE = true

-- 连接服务器
function socket.connect(msg_receiver, state_observer, heartbeatPacket)
	if socket._client then
		socket.disconnect()
	end 
	
	local time = net.SocketTCP.getTime()
	if DEBUG > 0 then
		printInfo("socket time:" .. time)
	end
	
	local tcp = net.SocketTCP.new()
	tcp:setName("qlSocket")
	--tcp:setTickTime(0.5) -- 默认0.1s
	--tcp:setReconnTime(6) 默认5s
	--tcp:setConnFailTime(4)  默认3s
	tcp:addEventListener(net.SocketTCP.EVENT_DATA, socket.__onReceive)
	tcp:addEventListener(net.SocketTCP.EVENT_CLOSE, socket.__onClose)
	tcp:addEventListener(net.SocketTCP.EVENT_CLOSED, socket.__onClosed)
	tcp:addEventListener(net.SocketTCP.EVENT_CONNECTED, socket.__onConnected)
	tcp:addEventListener(net.SocketTCP.EVENT_CONNECT_FAILURE, socket.__onError)
	socket._client = tcp
	socket._msg_receiver = msg_receiver
	socket._state_observer = state_observer
	socket._heartbeatPacket = heartbeatPacket or Packet.new()
	socket.state =  SOCKET_STATE_IDLE

	tcp:connect(SOCKET_SERVER_ADDRESS, SOCKET_SERVER_PORT, true)
end


-- 关闭连接
function socket.disconnect()
	if socket._client then
		socket._client:disconnect()
		socket._client = nil
	end
end

-- 发送数据
function socket.send(packet)
	assert(iskindof(packet, "Packet"), "packet must be a instance of Packet!!!")
	if socket.state == SOCKET_STATE_CONNECTED then
		local pack = packet:pack()
		if DEBUG > 0 then
			printInfo("发送TCP数据长度=%d", #pack)
		end
		socket._client:send(pack)
		-- 发送请求后，启动心跳
		socket.__delaySendHeartBeat()
		-- 开始检查超时
		socket.__startHeartBeatTimeoutListener()
	else
		printError("send data failed, wrong socket state!")
	end
end

function socket.__onConnected()
	if not socket._incmpBuf then
		socket._incmpBuf = ByteBuffer.new() -- 初始化incomplete buffer
	else
		socket._incmpBuf:reset() -- 重置
	end
	socket._changeState(SOCKET_STATE_CONNECTED)
end

--[[
    包结构
    ---------------------
    |   包头            |
    | ----------------- |
    | | 消息ID(uint)  | |
    | ----------------- |
    | | 包体长度(uint)| |
    | ----------------- |
    | | 序列号(uint)  | |
    | ----------------- |
    ---------------------
    ---------------------
    |        包体       |
    ---------------------
]]
function socket.__onReceive(event)
	if DEBUG > 0 then
		printInfo("---------------- 接收到TCP数据，数据长度为%d ---------------", #event.data)
	end
 	socket._incmpBuf:appendBytes(event.data)

 	-- 如果incomplete buffer存在并且包已经完整
 	while true do
 		local msgId = socket._incmpBuf:readUInt() -- 消息ID 4个字节
 		local bodyLen = socket._incmpBuf:readUInt() -- 包体长度 4个字节
 		local seqNo = socket._incmpBuf:readUInt() -- 序列号 4个字节
 		if DEBUG > 0 then
			printInfo("---------- 解包头 msgid=%d, bodyLen=%d, seqNo=%d ----------", msgId, bodyLen, seqNo)
		end
 		if msgId > 0 and bodyLen > 0 and seqNo >= 0 then
 			if socket._incmpBuf:getAvailable() >= bodyLen then
	 			-- 解包，再封装成Packet
	 			local body = socket._incmpBuf:readString(bodyLen)
	 			if not body then
	 				socket._incmpBuf:resetPos()
	 				break
	 			end
	 			-- 排除心跳
	 			if msgId ~= socket._heartbeatPacket:getMsgId() then
	 				if socket._msg_receiver then socket._msg_receiver(1, Packet.new(msgId, seqNo, body)) end
	 			else
	 				if DEBUG > 0 then
						printInfo("#接收到心跳包")
					end
	 			end
	 			-- 结束超时检查
	 			socket.__endHeartBeatTimeoutListener()
	 			-- 有剩余
	 			if socket._incmpBuf:getAvailable() > 0 then
	 				socket._incmpBuf:compact()
	 			else
	 				socket._incmpBuf:reset()
	 				break
	 			end
	 		else
	 			socket._incmpBuf:resetPos()
	 			break
	 		end
	 	else
	 		socket._incmpBuf:resetPos()
            break
 		end
 	end

 	if DEBUG > 0 then
		printInfo("--------------- TCP数据处理结束 ------------------")
	end
end

function socket.__delaySendHeartBeat()
	if HEARBEAT_ENABLE then
		if socket._hbTicktockHandler then
			scheduler.unscheduleGlobal(socket._hbTicktockHandler)
		end
		socket._hbTicktockHandler = scheduler.scheduleGlobal(socket.__onHeartBeatTicktock, SOCKET_HEARTBEAT_INTERVAL)
	end
end

function socket.__onHeartBeatTicktock()
	if socket.state == SOCKET_STATE_CONNECTED then
		if DEBUG > 0 then
			printInfo("#发送心跳包")
		end
		socket._client:send(socket._heartbeatPacket:pack())
		socket.__startHeartBeatTimeoutListener()
	end
end

function socket.__startHeartBeatTimeoutListener()
	if HEARBEAT_ENABLE then
		if socket._hbTimeoutHandler then
			socket.__endHeartBeatTimeoutListener()
		end
		socket._hbTimeoutHandler = scheduler.performWithDelayGlobal(socket.__onHeartBeatTimeout, SOCKET_HEARTBEAT_TIMEOUT)
	end
end

function socket.__endHeartBeatTimeoutListener()
	if HEARBEAT_ENABLE then
		if socket._hbTimeoutHandler then
			scheduler.unscheduleGlobal(socket._hbTimeoutHandler)
			socket._hbTimeoutHandler = nil
		end
	end
end

function socket.__onHeartBeatTimeout()
	if socket._client then
		socket._client:_disconnect()
		socket._client:_reconnect()
		socket._changeState(SOCKET_STATE_CLOSED)
	end
end

function socket.__onClose()
	socket._changeState(SOCKET_STATE_CLOSING)
end

function socket.__onClosed()
	socket._changeState(SOCKET_STATE_CLOSED)
end

function socket.__onError()
	socket._changeState(SOCKET_STATE_IDLE)
end

function socket._changeState(state)
	if socket.state ~= state then
		if DEBUG > 0 then
			printInfo("socket state changed, #%d", state)
		end
		socket.state = state
		if socket._state_observer then socket._state_observer(state) end
	end
end

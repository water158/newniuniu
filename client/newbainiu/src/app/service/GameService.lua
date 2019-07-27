--
-- Author: Carl
-- Date: 2015-05-06 19:49:40
--
--[[
	Socket游戏服务
]]
local GameService = class("GameService", import(".BaseService"))
local Packet = ql.net.Packet
import(".protocol")

-- 事件
GameService.EVENT_CONNECTED = "connected"
GameService.EVENT_CONNECTION_CLOSED = "connectionclosed"
GameService.EVENT_REQUEST_FAILED = "requestfailed"
GameService.EVENT_RECEIVED_ACK = "receivedack"
GameService.EVENT_RECEIVED_NTF = "receivedntf"
GameService.EVENT_RECEIVED_ERROR = "receivederror"
	
function GameService:onCreate(args)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods() -- 事件驱动方式
end

-- 启动游戏服务
function GameService:start()
	if state == SOCKET_STATE_CONNECTED then
		self:stop()
	end
	local hbPacket = Packet.new(ID_REQ + MSGID_SYS_HOLD, MSGID_SYS_HOLD, json.encode({cmd=ID_REQ + MSGID_SYS_HOLD, param={}}))
	socket.connect(handler(self, self.__onReceivePacket), handler(self, self.__onConnectionStateChanged), hbPacket)
end

--[[
	发送请求
	例子：gameService:request(MSGID_SYS_QUICK_START, {roomType=1000}); 协议参考protocol.py
]]
function GameService:request(msgid, params)
	
	local body = {cmd=ID_REQ + msgid, param=params}
	local packet = Packet.new(ID_REQ + msgid, msgid, json.encode(body))
	if self._isAvaliable then
		socket.send(packet)
		if DEBUG > 0 then
			printInfo("发送TCP请求成功！msgid=%d", msgid)
			dump(params, "请求参数")
		end
		return true
	else
		self:dispatchEvent({name=GameService.EVENT_REQUEST_FAILED, packet=packet})
		if DEBUG > 0 then
			printInfo("发送TCP请求失败！连接目前不可用！msgid=%d", msgid)
		end
		return false
	end
end

-- 刷新游戏数据
function GameService:refreshGameData()
	local ackHandle, errorHandle
    ackHandle = self:addEventListener(gameservice.EVENT_RECEIVED_ACK, function(event)
        local params = event.params
        if event.msgid == MSGID_SYS_GAME_INFO then
        	self:removeEventListener(errorHandle)
        	self:removeEventListener(ackHandle)
            -- 更新游戏数据
            gamedata:setWin(params.win)
            gamedata:setLose(params.lose)
            gamedata:setExp(params.exp)
            gamedata:setCoins(params.chip)
            gamedata:save()
        end
    end)
    errorHandle = self:addEventListener(gameservice.EVENT_RECEIVED_ERROR, function(event)
    	self:removeEventListener(errorHandle)
        self:removeEventListener(ackHandle)
    end)
    self:request(MSGID_SYS_GAME_INFO, {gameId=DDZ_GAME_ID})
end

-- 结束游戏服务
function GameService:stop()
	socket.disconnect()
end

-- 游戏服务是否可用
function GameService:isAvaliable()
	return self._isAvaliable or false
end

function GameService:__onReceivePacket(result, packet)
	local msgid = packet:getMsgId()
	if msgid then
		local body = packet:getBody() or {}
		if body.error then
			if DEBUG > 0 then
				printInfo("接收到TCP[错误]数据！msgid=%d, code=%d", msgid, body.error.result)
			end
			-- 错误处理
			self:dispatchEvent({name=GameService.EVENT_RECEIVED_ERROR, msgid=(msgid-ID_ACK), error=body.error.result})
		else
			local params = body.param or {}
			if bit.band(msgid, ID_NTF) == ID_NTF then
				if DEBUG > 0 then
					printInfo("接收到TCP[通知]数据！msgid=%d", (msgid-ID_NTF))
					dump(params, "参数", 6)
				end
				self:dispatchEvent({name=GameService.EVENT_RECEIVED_NTF, msgid=(msgid-ID_NTF), params=params})
			else
				if DEBUG > 0 then
					printInfo("接收到TCP[响应]数据！msgid=%d", (msgid-ID_ACK))
					dump(params, "参数", 6)
				end
				self:dispatchEvent({name=GameService.EVENT_RECEIVED_ACK, msgid=(msgid-ID_ACK), params=params})
			end
		end
	end
end

--[[
	SOCKET_STATE_IDLE       = -1
	SOCKET_STATE_CONNECTING = 0
	SOCKET_STATE_CONNECTED  = 1
	SOCKET_STATE_CLOSING    = 2
	SOCKET_STATE_CLOSED     = 3
]]
function GameService:__onConnectionStateChanged(state)
	if state == SOCKET_STATE_CONNECTED then
		-- 连接成功后，发送玩家信息
		self._isAvaliable = true
		local ackHandle, errorHandle
        ackHandle = self:addEventListener(gameservice.EVENT_RECEIVED_ACK, function(event)
            local params = event.params
            if event.msgid == MSGID_SYS_USER_INFO then
                -- 更新玩家数据
                gamedata:setIcon(params.avatar)
                gamedata:setSex(params.sex)
                gamedata:setNickname(params.nick)
            elseif event.msgid == MSGID_SYS_GAME_INFO then
            	self:removeEventListener(errorHandle)
            	self:removeEventListener(ackHandle)
                -- 更新游戏数据
                gamedata:setWin(params.win)
                gamedata:setLose(params.lose)
                gamedata:setExp(params.exp)
                gamedata:setCoins(params.chip)
                gamedata:setVip(params.vip)
                gamedata:setPhoneTicket(params.phone_ticket)
                gamedata:setFreeLottery(params.free_lottery)
                gamedata:save()
                self._isAvaliable = true
                self:dispatchEvent({name=GameService.EVENT_CONNECTED})
            end
        end)
        errorHandle = self:addEventListener(gameservice.EVENT_RECEIVED_ERROR, function(event)
        	self:removeEventListener(errorHandle)
            self:removeEventListener(ackHandle)
            self._isAvaliable = false
            self:dispatchEvent({name=GameService.EVENT_CONNECTION_CLOSED})
        end)
        if gamedata:getUserID() and gamedata:getToken() then
        	self:request(MSGID_SYS_USER_INFO, {userId=gamedata:getUserID(), gameId=DDZ_GAME_ID, sessionKey=gamedata:getToken()})
        	self:request(MSGID_SYS_GAME_INFO, {gameId=DDZ_GAME_ID})
        end
	else
		self._isAvaliable = false
		if state == SOCKET_STATE_CLOSED then
			self:dispatchEvent({name=GameService.EVENT_CONNECTION_CLOSED})
		end
	end
end

if not gameservice then
	gameservice = GameService.new()
end

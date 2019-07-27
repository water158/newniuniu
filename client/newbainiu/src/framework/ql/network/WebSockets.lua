
local WebSockets = class("WebSockets")
local scheduler = require("framework.scheduler")

WebSockets.TEXT_MESSAGE = 0
WebSockets.BINARY_MESSAGE = 1
WebSockets.BINARY_ARRAY_MESSAGE = 2

WebSockets.OPEN_EVENT    = "open"
WebSockets.MESSAGE_EVENT = "message"
WebSockets.CLOSE_EVENT   = "close"
WebSockets.ERROR_EVENT   = "error"


--心跳
SOCKET_HEARTBEAT_INTERVAL = 6 -- 心跳间隔 5s
SOCKET_HEARTBEAT_TIMEOUT = 4 -- 超时时间

HEARBEAT_ENABLE = true

RECONNECTION = nil
AFRESHBACKGAME = nil 

 
function WebSockets:ctor()
    

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods() -- 事件驱动方式

   
end

function WebSockets:isReady()
    
    local status = self.socket and self.socket:getReadyState() == cc.WEBSOCKET_STATE_OPEN
    return status

end

function WebSockets:send(data, messageType)

    if not self:isReady() then
       
       printInfo("WebSockets:send() - socket is't ready")
       printInfo("isReady  网络断开")
       --toastview:show(localize.get("network_issue"))
       return false

    else 
        
        messageType = checkint(messageType)
        self.messageType = messageType
        if messageType == WebSockets.TEXT_MESSAGE then
            self.socket:sendString(tostring(data))
        elseif messageType == WebSockets.BINARY_ARRAY_MESSAGE then
            data = checktable(data)
            self.socket:sendString(data, table.nums(data))
        else
            print(tostring(data))
            self.socket:sendString(tostring(data))
        end

        return true
    
    end
end

function WebSockets:close()

    if self.socket then
        self.socket:close()
        self.socket = nil
    end
    self:removeAllEventListeners()

end

function WebSockets:onOpen_()
    
    self:dispatchEvent({name = WebSockets.OPEN_EVENT})
    if RECONNECTION == 10 then
     
     printInfo("连接 TCP 服务器  RECONNECTION")
     self:loginTcp() 

    end
    self:__delaySendHeartBeat()

end

function WebSockets:onMessage_(message)

    local params = {
        name = WebSockets.MESSAGE_EVENT,
        message = message,
        messageType = self.messageType
    }
    
    self:dispatchEvent(params)
    local msg_t = json.decode(message)
    local id = msg_t["id"] 
    local body = msg_t["body"]

    if id ==  (ID_ACK + MSGID_SYS_HOLD) then

        print("webSocket_______________".."接收到心跳包")
        self:__endHeartBeatTimeoutListener()


    end
end

function WebSockets:onClose_()
    self:dispatchEvent({name = WebSockets.CLOSE_EVENT})
    self:close()
end

function WebSockets:onError_(error)
    self:dispatchEvent({name = WebSockets.ERROR_EVENT, error = error})
end

function WebSockets:start(url)
 
  self.socket = cc.WebSocket:create(url)
  if  self.socket then
    
    print("new WebSockets "..url)
    self.socket:registerScriptHandler(handler(self, self.onOpen_), cc.WEBSOCKET_OPEN)
    self.socket:registerScriptHandler(handler(self, self.onMessage_), cc.WEBSOCKET_MESSAGE)
    self.socket:registerScriptHandler(handler(self, self.onClose_), cc.WEBSOCKET_CLOSE)
    self.socket:registerScriptHandler(handler(self, self.onError_), cc.WEBSOCKET_ERROR)
   
  end


end

--------------------------------------------------------------------------------心跳

function WebSockets:__delaySendHeartBeat()

  if HEARBEAT_ENABLE then

    if self._hbTicktockHandler then
      scheduler.unscheduleGlobal(self._hbTicktockHandler)
    end

    self._hbTicktockHandler = scheduler.scheduleGlobal(function ()
     
      self:__onHeartBeatTicktock()

    end, SOCKET_HEARTBEAT_INTERVAL)
 end

end

function WebSockets:__onHeartBeatTicktock()
    

    if DEBUG > 0 then
      printInfo("#发送心跳包")
    end
    
    local temp = {}
    local msgbody = {}
    local body_t = json.encode(msgbody)
    temp["id"] =  (ID_REQ  + MSGID_SYS_HOLD)
    temp["body"] = body_t

    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1)
    self:__startHeartBeatTimeoutListener()
   
end


function WebSockets:__startHeartBeatTimeoutListener()
    if HEARBEAT_ENABLE then

        if self._hbTimeoutHandler then
            self:__endHeartBeatTimeoutListener()
        end

        self._hbTimeoutHandler = scheduler.performWithDelayGlobal(handler(self,self.__onHeartBeatTimeout), SOCKET_HEARTBEAT_TIMEOUT)

    end
end


function WebSockets:__endHeartBeatTimeoutListener()

    if HEARBEAT_ENABLE then
        if self._hbTimeoutHandler then
            scheduler.unscheduleGlobal(self._hbTimeoutHandler)
            self._hbTimeoutHandler = nil
        
        end
    end
end


function WebSockets:__onHeartBeatTimeout()
   
          
          printInfo("断线重连")
          self:close()
          self:reconnect()
         

end

----------------------------------------------------------------------心跳


--[[
此函数用来重连
@param  无
@return 无
]]
function WebSockets:reconnect()

  
    scheduler.performWithDelayGlobal(function ()
        
        RECONNECTION = 10
        self:start(gamedata:getSocketServerAddress()..":"..gamedata:getSocketServerPort())
      
   end,1)
         

end

function WebSockets:loginTcp()

  local ackHandle
  local function onReceivedAck(event)


    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if id  == (ID_ACK + MSGID_SYS_LOGINHALL)  then
        
       gameWebSocket:removeEventListener(ackHandle) 
       if body.result == 0 then
          
         printInfo("重连 tcp 服务器成功")
         printInfo("是否在游戏中"..body.status)
         AFRESHBACKGAME = body.status
         RECONNECTION = nil 
         print("WebSockets.RECONNECTION"..type(RECONNECTION))

       else

        
                
       end

   end


  end
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)
    
    print("loginHall")
    local temp = {}
    local msgbody = {}
    msgbody["userId"] = gamedata:getUserId()
    msgbody["token"] =  gamedata:getToken()
    local body_t = json.encode(msgbody)
    ------http 协议修改部分
    temp["id"] =  (ID_REQ  + MSGID_SYS_LOGINHALL)
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    print("消息ID"..(ID_REQ + MSGID_SYS_LOGINHALL))
    self:send(msg_t, 1)    

end




if not gameWebSocket then
 
 gameWebSocket = WebSockets.new()

end



return WebSockets

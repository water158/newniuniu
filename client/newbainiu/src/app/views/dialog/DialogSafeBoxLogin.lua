--
-- Author: Your Name
-- Date: 2015-11-09 19:26:08
local DialogSafeBoxLogin  = class("DialogSafeBoxLogin", ql.custom.DialogView)

local parentself 
function DialogSafeBoxLogin:onCreate(args)
  
  if args then

    parentself = args.parent

  end
  self:setOnViewClickedListener("exit",function()

   self:dismiss()
   
 end,nil,"zoom",true)

 self:setOnViewClickedListener("findBack_code",function()
  
   showDialog("DialogFindbackPassword",{codeType = true,parent = parentself})
   self:dismiss()

 end,nil,"zoom",true)

 self:enterSafeBox()

end

function DialogSafeBoxLogin:enterSafeBox()


  self:setOnViewClickedListener("ensure", function()
    
    print("发送 ensure 密码")
    self:onEnterSafeBox()
  	local temp = {}
    local msgbody = {}
    local passwd = self:findNodeByName("codeInput"):getString()
    print(passwd)
    msgbody["passwd"] = passwd
    local body_t = json.encode(msgbody)
    temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_ENTER
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1) 


  end,nil,"zoom",true)

end


function DialogSafeBoxLogin:onEnterSafeBox()
  
  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    print(msg_t["body"].result)
    if msg_t["id"]  == (ID_ACK+MSGID_SYS_SAFEBOX_ENTER)  then
      gameWebSocket:removeEventListener(ackHandle)
        
      if msg_t["body"].result == 0 then
           
         
        gamedata:setSafeCoins(tonumber(msg_t["body"].safeCoins))
        showDialog("DialogSafeBox",{parent = parentself})
        self:dismiss()
      
      else
         
        toastview:show(localize.getM("SAFEBOX_ENTER",msg_t["body"].result))

      end
    end
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)  

end

return  DialogSafeBoxLogin

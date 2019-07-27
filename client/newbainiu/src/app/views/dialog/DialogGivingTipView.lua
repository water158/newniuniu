--
-- Author: Your Name
-- Date: 2015-11-19 15:43:36
--
--
-- Author: Your Name
-- Date: 2015-11-11 20:04:24
--
local DialogGivingTipView  = class("DialogGivingTipView", ql.custom.DialogView)

local parentself 
function DialogGivingTipView:onCreate(args)

	if args then
      
      parentself = args.parent
      self.givingCoins = args.givingCoins
      self.givingID = args.givingID

	end

	self:findNodeByName("gevingNum"):setString(string.subComma(self.givingCoins))
	self:findNodeByName("gevingID"):setString(self.givingID)
	self:givingTips()
end

function DialogGivingTipView:givingTips()
	
	self:setOnViewClickedListener("ensure",function ()    
	    
	    self:OnGivingTips()
        local temp = {}
        local msgbody = {}
        msgbody["operateType"] = 3
        msgbody["operateCoins"] =  self.givingCoins
        msgbody["presentedUid"] =  self.givingID 
        local body_t = json.encode(msgbody)
        temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_OPERATECOINS
        temp["body"] = body_t
        local msg_t = json.encode(temp)
        gameWebSocket:send(msg_t, 1)

     end,nil,"zoom",true)

end

function DialogGivingTipView:OnGivingTips()

  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if msg_t["id"]  == (ID_ACK+MSGID_SYS_SAFEBOX_OPERATECOINS)  then
        gameWebSocket:removeEventListener(ackHandle)
    	if msg_t["body"].result == 0 then
           
           print("赠送  保险箱成功".."现有金币"..msg_t["body"].coins.."保险箱金币"..msg_t["body"].safeCoins)
           toastview:show(localize.get("giving_suess"))
           gamedata:setPlayerCoins(msg_t["body"].coins)
           gamedata:setSafeCoins(msg_t["body"].safeCoins)
           showDialog("DialogSafeBoxGiving")
           self:dismiss()
    	
    	else
    
           toastview:show(localize.getM("SAFEBOX_OPERATECOINS",msg_t["body"].result))
        
    	end
    
    end
 
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end

function DialogGivingTipView:onExit()
  
end


return DialogGivingTipView
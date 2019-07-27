
local DialogBinding   = class("DialogBinding", ql.custom.DialogView)

function DialogBinding:onCreate(args)

	self:setOnViewClickedListener("exit", function() 
	   
     showDialog("DialogPersonalInfo")
     self:dismiss()
 
  end,nil,"zoom",true) 
  
  self:checkIsBlind()
	self:binding()
  self:onBindingMsg()


end

function DialogBinding:checkIsBlind()
  
  if gamedata:getIsBind() == true  then
      
    self:findNodeByName("bindTitle"):setVisible(false)
    self:findNodeByName("unBindText"):setVisible(true)

  else
       
    self:findNodeByName("bindTitle"):setVisible(true)
    self:findNodeByName("unBindText"):setVisible(false)

  end
 
end

function DialogBinding:binding()
  
  local function getVerifyCode(result, bodys)

    if RESULT_OK ==  result then
        
      if RESULT_OK ==  bodys.result then
         toastview:show(localize.get("verify_suess"))
      else
         toastview:show(localize.getM("getVerifyCode",bodys.result))
      end
        
    elseif  RESULT_ERROR == result then
         toastview:show(localize.get("network_issue"))
    end
    
  end
   
  self:setOnViewClickedListener("authcode",function ()

      local mobileInput = self:findNodeByName("mobileInput"):getString()
      if self:findNodeByName("mobileInput"):getStringLength() ~= 11 then
        toastview:show(localize.get("wrong_mobile"))
        return
      end
      local isCheck = nil 
      if gamedata:getIsBind() == true  then 
           isCheck = 0
      else
           isCheck = 1
      end

      local temp = {}
	    temp["mobile"] = mobileInput
	    temp["isCheck"] = isCheck 
      webservice:requestPost(MSGID_GETVERIFYCODE_USER , temp, getVerifyCode)

  end,nil,"zoom",true)

  self:rufferBindingMsg()

end

function DialogBinding:rufferBindingMsg()
  

   self:setOnViewClickedListener("ruffer",function ()
     
     local mobileInput = self:findNodeByName("mobileInput"):getString()
     local verifyCode =  self:findNodeByName("vercitionInput"):getString()
     local temp = {}
     local msgbody = {}
     msgbody["mobile"] = mobileInput
     msgbody["verifyCode"] = verifyCode
     local body_t = json.encode(msgbody)
    
     if self:findNodeByName("mobileInput"):getStringLength() ~= 11 then
        toastview:show(localize.get("wrong_mobile"))
        return
     end

     if gamedata:getIsBind() == true  then 
        
        temp["id"] =  (ID_REQ  + MSGID_SYS_UNBIND_MOBILE)

     else
    
        temp["id"] =  (ID_REQ  + MSGID_SYS_BIND_MOBILE)

     end

     temp["body"] = body_t
     local msg_t = json.encode(temp)
     gameWebSocket:send(msg_t, 1)

  end,nil,"zoom",true)

end

function DialogBinding:onBindingMsg()
	
  local ackHandle 
  local function onReceivedAck(event)
    
    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]

    if id == (ID_ACK +MSGID_SYS_BIND_MOBILE) then

      if body.result == 0 then
        
        gameWebSocket:removeEventListener(ackHandle)
        gameWebSocket:removeEventListener(errorHandle)
        self:findNodeByName("bindTitle"):setVisible(false)
        self:findNodeByName("unBindText"):setVisible(true)
        gamedata:setIsBind(true)
        toastview:show(localize.get("BIND_MOBILE_suess"))
        showDialog("DialogPersonalInfo")
        self:dismiss()
        
      else
        
        toastview:show(localize.getM("BIND_MOBILE",body.result)) 

      end

    end
    
    
    if id == (ID_ACK +MSGID_SYS_UNBIND_MOBILE) then

      if body.result == 0 then
        
        gameWebSocket:removeEventListener(ackHandle)
        gameWebSocket:removeEventListener(errorHandle)
        self:findNodeByName("bindTitle"):setVisible(true)
        self:findNodeByName("unBindText"):setVisible(false)
        gamedata:setIsBind(false)
        toastview:show(localize.get("UNBIND_MOBILE_suess"))
        showDialog("DialogPersonalInfo")
        self:dismiss()
         
      else
        
        toastview:show(localize.getM("BIND_MOBILE",body.result)) 

      end

    end

  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end

function DialogBinding:onExit()
 
end

return DialogBinding
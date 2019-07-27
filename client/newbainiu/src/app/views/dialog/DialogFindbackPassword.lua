--
-- Author: Han
-- Date: 2015-10-12 19:16:20
local DialogFindbackPassword  = class("DialogFindbackPassword", ql.custom.DialogView)

local p_type
local parentself
function DialogFindbackPassword:onCreate(args)
  
  if args then
   
   p_type = args.codeType
   parentself = args.parent

  end
  self:setOnViewClickedListener("exit", function() 
	  
    if not p_type then
		
      showDialog("DialogLogin")
      self:dismiss()

    else
      
      showDialog("DialogSafeBoxLogin")
      self:dismiss()

    end
	
	end,nil,"zoom",true) 

--得到验证码
	self:getVerify()
  if not p_type then
--重置密码
	 self:resetPassword()

  else
--找回保险箱密码
   self:findBackSafeBoxCode()

  end

end

--找回手机号
function DialogFindbackPassword:getVerify()


    local function getVerifyCode(result, bodys)

        if RESULT_OK ==  result then
        
         if RESULT_OK ==  bodys.result then
           
           toastview:show(localize.get("verify_suess"))


         else

         end
        
        elseif  RESULT_ERROR == result then
            
          print("网络连接错误")
          toastview:show(localize.get("network_issue"))   
        
        end
    
    end
   
   self:setOnViewClickedListener("authcode",function ()
      
      local mobileInput = self:findNodeByName("mobileInput"):getString()
      if self:findNodeByName("mobileInput"):getStringLength() ~= 11 then
       
        toastview:show(localize.get("wrong_mobile"))
        return

      end

      local isCheck = 0
      local temp = {}
	    temp["mobile"] = mobileInput
	    temp["isCheck"] = isCheck 
      webservice:requestPost(MSGID_GETVERIFYCODE_USER , temp, getVerifyCode)

      end,nil,"zoom",true)


end

--找回密码
function DialogFindbackPassword:resetPassword()
   
  local function resetCode(result, bodys)

    if RESULT_OK ==  result then
        
      if RESULT_OK ==  bodys.result then

           toastview:show(localize.get("resetPasswd_suess"))
           showDialog("DialogLogin")
       
      else

           toastview:show(localize.getM("resetPasswd",bodys.result),self:getRoot())

      end
        
    elseif  RESULT_ERROR == result then
          toastview:show(localize.get("network_issue"))
    end
    
  end
   
   self:setOnViewClickedListener("Reffer",function ()

      local mobileInput = self:findNodeByName("mobileInput"):getString()
      if self:findNodeByName("mobileInput"):getStringLength() ~= 11 then
       
        toastview:show(localize.get("wrong_mobile"),self:getRoot())
        return

      end
      local verificationInput = self:findNodeByName("verificationInput"):getString()
      local newCodeInput = self:findNodeByName("newCodeInput"):getString()
      local pwdLen = self:findNodeByName("newCodeInput"):getStringLength()
      
      if pwdLen > 20 or pwdLen < 6 then
        toastview:show(localize.get("wrong_pwd"),self:getRoot())  
        return
      end
      
      local temp = {}
	    temp["mobile"] = mobileInput
	    temp["verifyCode"] = verificationInput
	    temp["newPasswd"] = newCodeInput
	 
      webservice:requestPost(MSGID_RESETPASSWD_USER , temp, resetCode)

      end,nil,"zoom",true)


end


--找回保险箱密码
function DialogFindbackPassword:findBackSafeBoxCode()

  
  self:setOnViewClickedListener("Reffer",function ()
      
      self:onMsgBack()
      local mobileInput = self:findNodeByName("mobileInput"):getString()
      if self:findNodeByName("mobileInput"):getStringLength() ~= 11 then
       
        toastview:show(localize.get("wrong_mobile"),self:getRoot())
        return
      end
      local verificationInput = self:findNodeByName("verificationInput"):getString()
      local newCodeInput = self:findNodeByName("newCodeInput"):getString()
      local pwdLen = self:findNodeByName("newCodeInput"):getStringLength()
      
      if pwdLen > 20 or pwdLen < 6 then
        toastview:show(localize.get("wrong_pwd"),self:getRoot())  
        return
      end

    local temp = {}
    local msgbody = {}
    msgbody["mobile"] = mobileInput
    msgbody["verifyCode"] = verificationInput
    msgbody["newPasswd"] = newCodeInput
    local body_t = json.encode(msgbody)
    temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_RESETPASSWD
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1)

    end,nil,"zoom",true) 

end


function DialogFindbackPassword:onMsgBack()

  local ackHandle
  local function onReceivedAck(event)
    
    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if msg_t["id"]  == (ID_ACK+MSGID_SYS_SAFEBOX_RESETPASSWD)  then
      gameWebSocket:removeEventListener(ackHandle)

      if msg_t["body"].result == 0 then

           showDialog("DialogSafeBoxLogin")
           self:dismiss()
      
      else

           toastview:show(localize.getM("SAFEBOX_RESETPASSWD",msg_t["body"].result))
    
      end

    end
 
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end

return DialogFindbackPassword
--
-- Author: Your Name
-- Date: 2015-09-11 14:52:1

local DialogModifyCode    = class("DialogModifyCode", ql.custom.DialogView)
local parentself

function DialogModifyCode:onCreate(args)
  
  if args then

    parentself = args.parent

  end
--退出
	self:setOnViewClickedListener("exit", function() 
	    
    parentself:showDialog("DialogPersonalInfo")
	  self:dismiss()

	end,nil,"zoom",true)

--修改密码
	self:modifyCode() 

end


--修改密码
function DialogModifyCode:modifyCode()
	
	self:setOnViewClickedListener("ruffer", function() 
    	 
    self:onModifyCode()
    local temp = {}
    local msgbody = {}
    local oldCode = self:findNodeByName("oldcode"):getString()
    local newCode = self:findNodeByName("newcode"):getString()
    local pwdLen  = self:findNodeByName("newcode"):getStringLength()
    if pwdLen > 20 or pwdLen < 6 then
        toastview:show(localize.get("wrong_pwd"))  
        return
    end
    local newCodeAgain = self:findNodeByName("newcodeagain"):getString()
    if newCode == newCodeAgain then
         	
      msgbody["oldPasswd"] = oldCode
      msgbody["newPasswd"] = newCode
  		local body_t = json.encode(msgbody)
      temp["id"] =   ID_REQ + MSGID_SYS_MODIFY_USERINFO 
      temp["body"] = body_t
  		local msg_t = json.encode(temp)
  		print("发送修改密码信息")
  		gameWebSocket:send(msg_t, 1)	
    
    else
      
      toastview:show(localize.get("newpwd_wrong"))  
    
    end



	 end,nil,"zoom",true)

end

--修改密码
function DialogModifyCode:onModifyCode()
  
  local ackHandle
  local function onReceivedAck(event)
    
    if DEBUG > 0 then

          printInfo("inModifyCode   @接收到TCP通知！")
    end
    local msg_t = json.decode(event.message)
    print(msg_t["id"])
    print(msg_t["body"].result)

    if msg_t["id"] == ID_ACK + MSGID_SYS_MODIFY_USERINFO then
         
      gameWebSocket:removeEventListener(ackHandle)
        
      if msg_t["body"].result == 0 then
           
        print("newPasswd"..msg_t["body"].newPasswd)
        if msg_t["body"].newPasswd ~= nil then
             
          print("修改密码成功")   
          gamedata:setpasswd(msg_t["body"].newPasswd)
          parentself:showDialog("DialogPersonalInfo")
          self:dismiss()
          toastview:show(localize.get("resetPasswd_suess")) 
             
        end

      else
           
         toastview:show(localize.getM("MODIFY_USERINFO",msg_t["body"].result))  
   
      end
      
    end
      
  end

  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)


end

return DialogModifyCode
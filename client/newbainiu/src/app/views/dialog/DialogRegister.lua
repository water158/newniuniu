--
-- Author: Your Name
-- Date: 2015-09-11 17:06:19
--
local DialogRegister  = class("DialogRegister", ql.custom.DialogView)
local scheduler = require("framework.scheduler")

local parentself
local showPersonalInfo
function DialogRegister:onCreate(args)
  
  if args then
    parentself = args.parent
    showPersonalInfo = args.isback
  end
--退出
	self:setOnViewClickedListener("exit", function() 
	    
	    print("退出")
      print(type(parentself))
      if showPersonalInfo  == true then
        parentself:showDialog("DialogPersonalInfo")
      end

	    self:dismiss()


	end,nil,"zoom",true)

  if gamedata:getIsRegister() == true  then
 
    self:userRegistration()

  else

    self:guestUpgrade()
  end

  self:playerlogin()

end

--用户注册
function DialogRegister:userRegistration()

    local function Registration(result, bodys)
	    print("Registration")
		  print(result)	
        if RESULT_OK ==  result then
        
         if RESULT_OK ==  bodys.result then
         
         	toastview:show(localize.get("userRegister_suess"))
          gamedata:setUserName(bodys.userName)
          gamedata:setpasswd(bodys.passwd)   
          gamedata:setIsRegister(true)
          self.delayRegister = scheduler.performWithDelayGlobal(function()
          parentself:login()
          self:dismiss()

           end,0.5)

         else

         	  toastview:show(localize.getM("userRegister",bodys.result))

         end
        
        elseif  RESULT_ERROR == result then
          toastview:show("网络连接错误")              
        end
    
    end

	   self:setOnViewClickedListener("referButton",function ()
      local userName = self:findNodeByName("userNameTextFiled"):getString()
      self.userName = userName
      local passwd = self:findNodeByName("passwdTextFiled"):getString()
      local pwdLen = self:findNodeByName("passwdTextFiled"):getStringLength()
      
      if pwdLen > 20 or pwdLen < 6 then
         toastview:show(localize.get("wrong_pwd"))  
         return
      end
      self.passwd = passwd 
      local temp = {}
	    temp["userName"] = userName
	    temp["passwd"] =  passwd
      local infos = getMobileInfos()
	    temp["devName"] = infos.model
	    temp["deviceId"] = infos.imei1 
      webservice:requestPost(MSGID_REGISTER_USER  , temp, Registration)
      end,nil,"zoom",true)
end

--游客升级
function DialogRegister:onGuestUpgrade()

  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    print("游客升级")

    if msg_t["id"]  == (ID_ACK+MSGID_SYS_UPGRADE_GUEST)  then
       
      gameWebSocket:removeEventListener(ackHandle)
      if msg_t["body"].result == 0 then
       
        print("游客升级成功")
        
        toastview:show(localize.get("userRegister_suess"))
        gamedata:setUserName(msg_t["body"].userName)
        gamedata:setpasswd(msg_t["body"].passwd)
        gamedata:setIsRegister(true)

        self.delayUpgrade = scheduler.performWithDelayGlobal(function()
           
       --if showPersonalInfo  == true then
        --parentself:showDialog("DialogPersonalInfo")
       --end
        parentself:login()
        self:dismiss()

         end,0.5)

      else

        toastview:show(localize.getM("UPGRADE_GUEST",msg_t["body"].result))  
    
      end
  

  end
  
  end

  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end

--游客升级
function DialogRegister:guestUpgrade()

  self:onGuestUpgrade()
  print("guestUpgrade")
  self:setOnViewClickedListener("referButton",function ()
  
    local userName = self:findNodeByName("userNameTextFiled"):getString()
    self.userName = userName 

    local passwd = self:findNodeByName("passwdTextFiled"):getString()
    local pwdLen = self:findNodeByName("passwdTextFiled"):getStringLength()
    if pwdLen > 20 or pwdLen < 6 then
      toastview:show(localize.get("wrong_pwd"))  
      return
    end

    self.passwd = passwd
    local temp = {}
    local msgbody = {}
    msgbody["userName"] = userName
    msgbody["passwd"] = passwd
    msgbody["mobile"] = mobile
    local body_t = json.encode(msgbody)
    temp["id"] =   ID_REQ + MSGID_SYS_UPGRADE_GUEST
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1) 

                                              end,nil,"zoom",true)
 
  
end

--登录
function DialogRegister:playerlogin()

  self:setOnViewClickedListener("login_button",function ()
    
    self:dismiss()
    showDialog("DialogLogin",{parent = parentself})
    
  end)

end


function DialogRegister:onExit()

   if self.delayRegister then
    scheduler.unscheduleGlobal(self.delayRegister)
   end
  
   if self.delayUpgrade then
    scheduler.unscheduleGlobal(self.delayUpgrade)
   end

end


return DialogRegister
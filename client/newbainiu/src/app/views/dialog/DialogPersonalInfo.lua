--
-- Author: Han
-- Date: 2015-09-10 15:28:17


local DialogPersonalInfo  = class("DialogPersonalInfo", ql.custom.DialogView)
--全局控件
local globalCommon = import("...common.GlobalCommon")
local playerInfoView = import("..playerInfoView") 

local parentself
function DialogPersonalInfo:onCreate(args)
   
    if args  then
		parentself = args.parent
    end
--初始化个人信息
	self:initPersonalInfo()
--检查是否已绑定 
	self:checkIsBlind() 
--修改昵称
  self:modifyNickname() 
--充值记录
	self:setOnViewClickedListener("Prepaidphonerecords", function() 
	    
	 showDialog("DialogPrepaidRecords",{parent = parentself})
   self:dismiss()

	end,nil,"zoom",true)

	self:setOnViewClickedListener("changepassword", function() 
	    
	 showDialog("DialogModifyCode",{parent = parentself})
   self:dismiss()

	end,nil,"zoom",true)

--切换账号
	self:setOnViewClickedListener("changeZhanghao", function() 
	    
	 showDialog("DialogRegister",{parent = parentself,isback = true})
	 self:dismiss()

	end,nil,"zoom",true)

--退出
	self:setOnViewClickedListener("exit", function() 
	    
	 self:dismiss()

	end,nil,"zoom",true)

--修改头像
	self:setOnViewClickedListener("headIcon", function() 

	    showDialog("DialogModifyavatar",{parent = parentself})
      self:dismiss()
  end,nil,"none")
    
end

function DialogPersonalInfo:checkIsBlind()
	
	 if gamedata:getIsBind() == true  then 
      
        self:findNodeByName("b_Button"):setVisible(false)
        self:findNodeByName("j_Button"):setVisible(true)
   	    self:setOnViewClickedListener("j_Button", function() 
	      showDialog("DialogBinding")
        self:dismiss()
	    
	   end,nil,"zoom",true)

    else
       
       self:findNodeByName("b_Button"):setVisible(true)
       self:findNodeByName("j_Button"):setVisible(false)
   	   self:setOnViewClickedListener("b_Button", function() 
	     showDialog("DialogBinding")
       self:dismiss()
	    
	   end,nil,"zoom",true)

    end

end

--个人信息
function DialogPersonalInfo:initPersonalInfo()

--头像
    self:findNodeByName("headIcon"):loadTexture("Common/avatar_"..gamedata:getPlayerAvatar()..".png",ccui.TextureResType.plistType)
--昵称
    self:findNodeByName("nickname"):setString(gamedata:getPlayerNickname())
--ID Num  
    self:findNodeByName("IDnum"):setString(gamedata:getUserId())
--Coins Num 
    self:findNodeByName("coinsNum"):setString(gamedata:getPlayerCoins())
    local labaData = gamedata:getPackageData()
    local labaNum 
    for k,v in pairs(labaData) do
     
     if tonumber(v["id"]) == 1001 then
    
        labaNum = v["num"]

     end

    end
    if labaNum then
        self:findNodeByName("labaNum"):setString(labaNum)
    end


end

--修改昵称
function DialogPersonalInfo:modifyNickname()
	
    local editBox = cc.ui.UIInput.new({
    
        image = display.newScale9Sprite("bigImage/fm_common_empty.png"),
--1 为Edibox 
        UIInputType = 1,
        size = cc.size(60, 60),
        x = 646,
        y = 440,
        listener = function(event, editbox)
            if event == "began" then
                self:onEditBoxBegan(editbox)
            elseif event == "ended" then
                self:onEditBoxEnded(editbox)
            elseif event == "return" then
                self:onEditBoxReturn(editbox)
            elseif event == "changed" then
                self:onEditBoxChanged(editbox)
            else
                printf("EditBox event %s", tostring(event))
            end
        end
    })

    editBox:setFontColor(cc.c3b(255, 0, 255))
    editBox:setFontSize(0)
    editBox:setMaxLength(10)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self:getRoot():addChild(editBox)

end


--[[
此函数是输入框的回调函数
@param  editbox 
@return 无
--]]
function DialogPersonalInfo:onEditBoxBegan(editbox)
    printf("editBox1 event began : text = %s", editbox:getText())
end


--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogPersonalInfo:onEditBoxEnded(editbox)

    printf("editBox event ended : %s", editbox:getText())
    local text =   editbox:getText()
    if globalCommon.stringStrlen(text) == 0 then
      
      return 

    else

      globalCommon.GetShortName(text,10,10) 
      self:ModifyPersonalInfo(text)

    end  
    

end

--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogPersonalInfo:onEditBoxReturn(editbox)

  printf("editBox event return : %s", editbox:getText())
  
end


--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogPersonalInfo:onEditBoxChanged(editbox)

  printf("editBox event changed : %s", editbox:getText())

end



--修改昵称
function DialogPersonalInfo:ModifyPersonalInfo(text)

  local ackHandle
  
  local function onReceivedAck(event)
    

    local msg_m = json.decode(event.message)

    print("result"..msg_m["body"].result)
     
    if msg_m["id"]  == (ID_ACK+MSGID_SYS_MODIFY_USERINFO)  then
      
      gameWebSocket:removeEventListener(ackHandle)
      
      if msg_m["body"].result == 0 then
        
         
         if msg_m["body"].newNick ~= nil then
           

           local newNick = msg_m["body"].newNick
           gamedata:setPlayerNickname(newNick)
           playerInfoView:setPlayerNickName(false)
           
         end
      
      else
     
          toastview:show(localize.getM("MODIFY_USERINFO",msg_m["body"].result)) 
    
      end

    end
  
  end


  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)
  
  local temp = {}
  local msgbody = {}
  
  self:findNodeByName("nickname"):setString(text)
  self.newNick = globalCommon.GetShortName(self:findNodeByName("nickname"):getString(),10,10)
  if self.newNick ~= gamedata:getPlayerNickname() then
  	
  	msgbody["newNick"] = globalCommon.GetShortName(self.newNick,10,10)
  	local body_t = json.encode(msgbody)
  	temp["id"] =   ID_REQ + MSGID_SYS_MODIFY_USERINFO 
  	temp["body"] = body_t
  	local msg_t = json.encode(temp)
  	gameWebSocket:send(msg_t, 1)
  
  else
    
    return 
  
  end

end

return DialogPersonalInfo
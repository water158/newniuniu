--
-- Author: Han
-- Date: 2015-09-10 20:59:18
--
--修改头像
local DialogModifyavatar  = class("DialogModifyavatar", ql.custom.DialogView)
local playerInfoView = import("..playerInfoView") 

local parentself
function DialogModifyavatar:onCreate(args)
   
  if args then

    parentself = args.parent

  end
  self:verdictAvatar()
  self.headIcon = self:findNodeByName("headIcon")
  self.avatarId = nil
	
  self:setOnViewClickedListener("exit", function() 
    
    parentself:showDialog("DialogPersonalInfo")
    self:dismiss()                        
  
  end,nil,"zoom",true)

	--选择头像
	for i=1,5 do

		self:setOnViewClickedListener("avatar_"..i, function() 

	for j=1,5 do

		if i==j then

			self:findNodeByName("selected_"..j):setVisible(true)
			self.headIcon:loadTexture("Common/avatar_"..j..".png",ccui.TextureResType.plistType)  
      self.avatarId = j 
      self:Modifyavatar()

		else

			self:findNodeByName("selected_"..j):setVisible(false)	

		end

	end
 
 end,nil,"none")

	
  end

end

function DialogModifyavatar:verdictAvatar()

    self:findNodeByName("Nickname"):setString(gamedata:getPlayerNickname())
    local selected = gamedata:getPlayerAvatar()
    self:findNodeByName("selected_"..selected):setVisible(true)
    self:findNodeByName("headIcon"):loadTexture("Common/avatar_"..selected..".png",ccui.TextureResType.plistType)

end

--修改头像
function DialogModifyavatar:Modifyavatar()
  
  local ackHandle
  local function onReceivedAck(event)
    
    if DEBUG > 0 then

          printInfo("in Modifyavatar   @接收到TCP通知！")
    end
    local msg_m = json.decode(event.message)
     
    if msg_m["id"]  == (ID_ACK+MSGID_SYS_MODIFY_USERINFO)  then
    
      if msg_m["body"].result == 0 then
        
         if msg_m["body"].newAvatar ~= nil then
      
           local avatar = msg_m["body"].newAvatar
           --保存头像ID
           gamedata:setPlayerAvatar(avatar)
           playerInfoView:setPlayerAvatar(false)
       
          end
      
      else
     
          toastview:show(localize.getM("MODIFY_USERINFO",msg_m["body"].result)) 
    
      end

   end
  
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)
  
  if self.avatarId  then
  	gamedata:setPlayerAvatar(self.avatarId)
  end
  local temp = {}
  local msgbody = {}
  if self.avatarId ~= nil then
  	
  	msgbody["newAvatar"] = self.avatarId
  	local body_t = json.encode(msgbody)
  	temp["id"] =   ID_REQ + MSGID_SYS_MODIFY_USERINFO 
  	temp["body"] = body_t
  	local msg_t = json.encode(temp)
  	gameWebSocket:send(msg_t, 1)
  
  else
    
    return 
  
  end


end


return DialogModifyavatar
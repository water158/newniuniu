
-- Author: Han 
-- Date: 2015-08-20 17:09:54
require("app.utils.PlatformUtils")

local MainMenuController = class("MainMenuController", ql.mvc.BaseController)
local scheduler = require("framework.scheduler")
local playerInfoView = import("..views.playerInfoView") 
local globalEffect = import("..common.GlobalEffect")
local globalCommon = import("..common.GlobalCommon")
local sounds = import("..data.sounds")

local this 
function MainMenuController:onCreate(args)
  
  
  this = self
  self._isAlreadyConnet = false
  self:initDialog()
  self:showMenuEffect()
  self.playerInfo = playerInfoView.new(self)
  self:getView():addChild(self.playerInfo)
  self:judgeLoginState(args)
	self:setOnViewClickedListener("quickstartButton", function()

    if self:checkLoginState() then
      self:enterRoom("-1")
    end

	end)
--进入房间1
	self:setOnViewClickedListener("exprience", function()
    self:enterScene("GrabBankerScene")
    if self:checkLoginState() then 
		    --self:enterRoom(BAINIU_ROOMS[1].id)
        --self:enterScene("GrabBankerScene")
    end

	end)
--进入房间2
	self:setOnViewClickedListener("passion", function()

    if self:checkLoginState() then
		  self:enterRoom(BAINIU_ROOMS[2].id)
    end
	end)
--进入房间3
	self:setOnViewClickedListener("crazy", function()

    if self:checkLoginState() then
		  self:enterRoom(BAINIU_ROOMS[3].id)
    end
	end)
   
--添加退出键功能
  self:addBackKeyEventListener(function()
    
    local exitdialog =self:showDialog("DialogExit")
  
  end)


end


function MainMenuController:onEnter()

  sounds.playBackgroundMusic("HALL")
  self:showSpark() 
  self:runHallAction()

end


function MainMenuController:__onUpate()
  
   if  RECONNECTION then

  else

    if self._updateHandel then
       scheduler.unscheduleGlobal(self._updateHandel)
    end

     self._isAlreadyConnet = true
     self:buildSocketConnection()
     self.rooms = gamedata:getRoomConfig()
     self:initPlayerInfo()
     if AFRESHBACKGAME  == 2 then
     
      self:allotTable()
             
     end
  end

end


--[[
判断登录
@param  args
@return 无
]]
function MainMenuController:judgeLoginState(args)
  printInfo("-------------- MainMenuController :judgeLoginState ")
  dump(args,"参数表")
  if not args then
 --登录
    self:login()

  else 
         
       if  RECONNECTION  then   

        self._updateHandel = scheduler.scheduleGlobal(handler(self, self.__onUpate),1)
        self:initPlayerInfo()

       else

          if args then
            self._isAlreadyConnet = args.isAlreadyConnet
          end
          self.rooms = gamedata:getRoomConfig()
          self:buildSocketConnection()
          self:initPlayerInfo()
        
       end
    
  end

end

--[[
播放动画
@param  args
@return 无
]]
function MainMenuController:runHallAction()
  
  for i=1,3 do
    
    local lampBliding = self:findNodeByName("lamp_"..i)
    runTimelineAction(lampBliding, "HallLampAction.csb", true) 

  end
  local logoBliding = self:findNodeByName("Logo_1")
  runTimelineAction(logoBliding, "LogoAction.csb", true)

end


--[[
显示按钮流光特效
@param  无
@return 无
]]

function MainMenuController:showSpark()

	-- 1.创建模板、ClippingNode(裁剪节点)
	local stencil = display.newSprite("#MainMenuScene/quickStart.png")
	local clipper = cc.ClippingNode:create()
	clipper:setStencil(stencil)
	clipper:setAlphaThreshold(0.6)

	-- 2.标题和光效
	local spr_title = display.newSprite("#MainMenuScene/quickStart.png")
	local spark = display.newSprite("#MainMenuScene/spark.png")
	spr_title:setVisible(false)
	clipper:addChild(spr_title)
	clipper:addChild(spark)
	clipper:setPosition(self:findNodeByName("quickstartButton"):getPosition())
	self:getView():addChild(clipper)

	-- 3.光效移动、自动裁剪
	local sz = spr_title:getContentSize()
	spark:setPositionX(-sz.width)
	local move = cc.MoveTo:create(1, cc.p(sz.width, 0))
	local delay1 = cc.DelayTime:create(1.5)
	local seq = cc.Sequence:create(delay1, move, cc.CallFunc:create(function()
		spark:setPositionX(-sz.width)
	end))
	local repeatAction = cc.RepeatForever:create(seq)
	spark:runAction(repeatAction)


end


--[[
初始化玩家信息
@param  无
@return 无
]]
function MainMenuController:initPlayerInfo()

  self.playerInfo:setPlayerNickName(false)
  self:findNodeByName("playerAvatar"):setVisible(true)
  self.playerInfo:setPlayerAvatar(false)
  self.playerInfo:setPlayerCoins(false)	
	
end


--[[
此函数初始化各种弹窗
@param  无
@return 无
]]
function MainMenuController:initDialog()

--设置
  self:setOnViewClickedListener("setButton", function()
    self:showDialog("DialogSeting")
  end, nil, "zoom",true)
--勋章
  
--退出
  self:setOnViewClickedListener("exitButton", function()
    self:showDialog("DialogExit")
  end, nil, "zoom",true)

--个人信息
  self:setOnViewClickedListener("playerAvatar", function()
      
      if self:checkLoginState() then 
        self:showDialog("DialogPersonalInfo",{parent = self})
      end

  end, nil, "none",true)
--商城
   
  --self:setOnViewClickedListener("plusCoins", function()
   -- self:showDialog("DialogShop")
  --end,nil,"none",true)

--保险箱
  self:setOnViewClickedListener("safeBox", function()
     if self:checkLoginState() then 
       local packageData = gamedata:getPackageData()
       local isEnterSafeBox 
       if packageData then
       
          for k,v in pairs(packageData) do
            
            if tonumber(v["id"]) == 1002 then
               
               if tonumber(v["num"]) > 0 then

                  isEnterSafeBox = true   

               end 

            end

          end

       end

      if isEnterSafeBox then
        self:showDialog("DialogSafeBoxLogin",{parent = self})
      else
        toastview:show(localize.get("ENTER_NO_SAFEBOX"))
      end
     
     end
  end,nil,"none",true)

end

--[[
此函数用来显示按钮特效
@param  无
@return 无
]]
function MainMenuController:showMenuEffect()

--金币特效
  local coinLight = self:findNodeByName("lightParticle")
  globalEffect.light_effect(coinLight)
--按钮特效
  local buttonName = {"activityButton","rankButton","storeButton"}
  for i=1,3 do
  
    self:setOnViewClickedListener(buttonName[i],function ()
--显示弹窗
    local  selected  = i 
      if selected ==1 then
        toastview:show(localize.get("staytuned"))
      elseif selected == 2 then
        toastview:show(localize.get("staytuned"))
      elseif  selected == 3 then 
         
        local Button_blink = self:findNodeByName("lighting_"..selected)
        self:showDialog("DialogShop",{ parent = self})

      end
 
 --显示按钮特效
    --[[
      for j=1,3 do
  
        if selected == j then
    
          self.Button_blink = self:findNodeByName("lighting_"..selected)
          globalEffect.shake_effect(self.Button_blink)
        else
  
          globalEffect.stop_Action(self:findNodeByName("lighting_"..j))
  
        end

      end
      --]]

    end,nil,"none",true)

  end


end

function MainMenuController:stopMenueffect(menuTag)
  
 local Button_blink =  self:findNodeByName("lighting_"..menuTag)  
 globalEffect.stop_Action(self:findNodeByName("lighting_"..menuTag))
 Button_blink:setVisible(false)

end

--[[
判断登录状态
@param  无
@return 无
]]

function MainMenuController:checkLoginState()
  
  return self:login()

end


--[[
登录
@param  无
@return 无
]]
function MainMenuController:login()
 
  if not isNetworkConnected() then
    
      self:runAction(transition.sequence({cca.delay(0.2), cca.callFunc(function()
      toastview:show(localize.get("network_issue"))

      end)}))
    return false
   
  end

  if gamedata:isLogining() then   --更新UI

    return true
 
  end

  if gamedata:getIsRegister() == true then
  
  --游客登录
     self:loginByUser()
  
  else
  
  --用户登录
     self:loginByGuest()

  end
  
end


--[[
此函数用来游客登录
@param  无
@return 无
]]
function MainMenuController:loginByGuest()
   
   if not isNetworkConnected() then
    
      self:runAction(transition.sequence({cca.delay(0.2), cca.callFunc(function()
      toastview:show(localize.get("network_issue"))

      end)}))
    return false
   end
  
  local function onLogin(result, bodys)
	  print("onLogin")
		print(result)	
        if RESULT_OK ==  result then
        
         if RESULT_OK ==  bodys.result then
           
          print("获得数据"..type(bodys))
          gamedata:setLogining(true)
          self:updateGameData(bodys)
          self:initPlayerInfo()
          self:buildSocketConnection()
          
         else
              
          toastview:show(localize.getM("loginByGuest",bodys.result))

         end
        
        elseif  RESULT_ERROR == result then
            
          toastview:show(localize.get("network_issue"))
        
        end
    
    end
    
    local temp = {}
    local infos = getMobileInfos()
    print("------------- lp --------------")
    dump(infos)
    temp["devName"] = infos.model
    temp["deviceId"] = infos.imei1
       --保存账号
    gamedata:setAcountName(infos.imei1)
    webservice:requestPost(MSGID_LOGIN_GUEST , temp, onLogin)
  
   

end

--[[
此函数用来正式用户登录
@param  无
@return 无
]]
function MainMenuController:loginByUser()
   
   if not isNetworkConnected() then
    
      self:runAction(transition.sequence({cca.delay(0.2), cca.callFunc(function()
      toastview:show(localize.get("network_issue"))

      end)}))
    return false
   end
  
  local function onLogin(result, bodys)
    print("onLogin")
    print(result) 
        if RESULT_OK ==  result then
        
         if RESULT_OK ==  bodys.result then
           
          print("获得数据"..type(bodys))
          gamedata:setLogining(true)
          self:updateGameData(bodys)
          self:initPlayerInfo()
          self:buildSocketConnection()
          
         else
              
          toastview:show(localize.getM("loginByGuest",bodys.result))

         end
        
        elseif  RESULT_ERROR == result then
            
          toastview:show(localize.get("network_issue"))
        
        end
    
    end
    
    local temp = {}
    local infos = getMobileInfos()
    printInfo("注册用户登录")
    print(gamedata:getUserName())
    print(gamedata:getpasswd())
    temp["userName"]  = gamedata:getUserName()
    temp["passwd"] = gamedata:getpasswd()
    gamedata:setAcountName(infos.imei1)
    webservice:requestPost(MSGID_LOGIN_USER , temp, onLogin)
   

end



--[[
此函数用来退出
@param  无
@return 无
]]
function MainMenuController:onExit()
	
  MainMenuController.super.onExit(self)
     
    if self._onOpen then
        gameWebSocket:removeEventListener(self._onOpen)
    end

    if self._onClose then
        gameWebSocket:removeEventListener(self._onClose)
    end

    if self._onMessage then
        gameWebSocket:removeEventListener(self._onMessage)
    end

    if self._onError then

        gameWebSocket:removeEventListener(self._onError)
    end
 
end


--[[
此函数用来建立连接
@param  无
@return 无
]]

function MainMenuController:buildSocketConnection()


	if self._onOpen then
        gameWebSocket:removeEventListener(self._onOpen)
  end
  if self._onClose then
        gameWebSocket:removeEventListener(self._onClose)
  end
  if self._onMessage then
        gameWebSocket:removeEventListener(self._onMessage)
  end
  if self._onError then
        gameWebSocket:removeEventListener(self._onError)
  end
  self._onOpen = gameWebSocket:addEventListener(gameWebSocket.OPEN_EVENT, handler(self,self.onOpen))
  self._onClose = gameWebSocket:addEventListener(gameWebSocket.CLOSE_EVENT,handler(self,self.onClose))
	self._onMessage = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT,handler(self,self.onMessage))
  self._onError = gameWebSocket:addEventListener(gameWebSocket.ERROR_EVENT,handler(self,self.onError))

--建立长链接  webSocket 
  
  if self._isAlreadyConnet == false then 
    
     gameWebSocket:start(gamedata:getSocketServerAddress()..":"..gamedata:getSocketServerPort())
     self._isAlreadyConnet = true 

  end

end


--[[
此函数用来保存游戏数据
@param  无
@return 无
]]
function MainMenuController:updateGameData(params)

--保存userId
	gamedata:setUserId(params.userId)
--保存金币值
  gamedata:setPlayerCoins(params.coins)	
--保存Token值
	gamedata:setToken(params.token)
--保存昵称
	gamedata:setPlayerNickname(params.nick)
--保存头像ID
	gamedata:setPlayerAvatar(params.avatar)
--保存长连接IP地址
	gamedata:setSocketServerAddress(params.host)
--保存长连接端口号
  gamedata:setSocketServerPort(params.port)
--保存
  gamedata:save()

end



--[[
此函数用来登录房间
@param  无
@return 无
]]
function MainMenuController:loginHall(userId, token)
    
    local temp = {}
    local msgbody = {}
    msgbody["userId"] = userId
    msgbody["token"] = token
    local body_t = json.encode(msgbody)
	  temp["id"] =  (ID_REQ  + MSGID_SYS_LOGINHALL)
    temp["body"] = body_t
	  local msg_t = json.encode(temp)
    print("消息ID"..(ID_REQ + MSGID_SYS_LOGINHALL))
    gameWebSocket:send(msg_t, 1)

end

--[[
此函数用来获取背包
@param  无
@return 无
]]
function MainMenuController:getPackage()
    
  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if id  == (ID_ACK + MSGID_SYS_PACKAGE)  then
        
       gameWebSocket:removeEventListener(ackHandle) 
       if body.result == 0 then

         local listTable = body["list"]
         gamedata:setPackageData(listTable)

        else

            print("获取背包失败"..body.result)
  
                
       end

    end

  end
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

    local temp = {}
    local msgbody = {}
    local body_t = json.encode(msgbody)
    ------http 协议修改部分
    temp["id"] =  (ID_REQ  + MSGID_SYS_PACKAGE)
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1)


end

--[[
打开 webScoket
@param  无
@return 无
]]
function MainMenuController:onOpen(event)

  if DEBUG > 0 then

    printInfo("@连接TCP服务器成功！")

  end
   
  this:loginHall(gamedata:getUserId(),gamedata:getToken())

end


function MainMenuController:onMessage(event)

    if DEBUG > 0 then

      printInfo("inHall   @接收到TCP通知！")


    end
    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]

    if msg_t["id"] == (ID_ACK + MSGID_SYS_LOGINHALL)  then
          
      if msg_t["body"].result == 0 then
          
        print("in Hall 登录大厅成功")
        self.rooms =   msg_t["body"].rooms
        gamedata:setRoomConfig(self.rooms)
        --获取背包
        webservice:updatePackageInfo()
        --self:getPackage()

       --[[ 
        for k,v in pairs(self.rooms) do
         
         print(k,v)
         for i,j in pairs(v) do
             
          print("房间数据"..i.."数据"..j)

         end
    

        end
      --]]

                
      end

    end

end

function MainMenuController:onClose(event)

  if DEBUG > 0 then
			
    printInfo("inHall   @连接TCP服务器失败！")

  end
  toastview:show(localize.get("network_issue"))
  scheduler.performWithDelayGlobal(function ()
    
    self:onExit()
    RECONNECTION = 10 
    self:enterScene("MainMenuScene",{isAlreadyConnet=true})

  end,0.6)

end

function MainMenuController:onError(event)

  if DEBUG > 0 then

    printInfo("连接服务器错误!")

  end
  toastview:show(localize.get("network_issue"))

end


--[[
进入房间
@param  无
@return 无
]]
function MainMenuController:enterRoom(roomId)
	
    if(self.rooms == nil) then
    else 
      gamedata:setRoomId(roomId)
    --配桌
      self:allotTable()
  
    end

end


--[[
配桌
@param  userId,roomId 
@return 无
]]
function MainMenuController:allotTable()
  
  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if id  == (ID_ACK + MSGID_SYS_QUICK_START)  then
        
       gameWebSocket:removeEventListener(ackHandle) 
       if body.result == 0 then
          
          local tableId =  body.tableId
          local roomId = body.roomId
          gamedata:setRoomId(roomId)
          printInfo("roomId  "..roomId)
          printInfo("tableId  "..tableId)
         --加入桌子
          self:loginTable(tableId)

        else

         toastview:show(localize.getM("SYS_QUICK_START",body.result))
                
       end

   end


  end

  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

  printInfo("allotTable   配桌")
  local temp = {}
  local msgbody = {}

  local userId = gamedata:getUserId()
  local roomId = gamedata:getRoomId()
  msgbody["userId"] = userId
  msgbody["roomId"] = roomId
  msgbody["roomType"] = 1
  local body_t = json.encode(msgbody)
  temp["id"] =  ID_REQ + MSGID_SYS_QUICK_START
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)

end



--[[
加入桌子
@param  userId,token
@return 无
]]
function MainMenuController:loginTable(tableId)
  
  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    printInfo("loginTable")
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if id  == (ID_ACK + MSGID_SYS_JOIN_TABLE)  then
       
       gameWebSocket:removeEventListener(ackHandle)
  
       if body.result == 0 then
          
          self:enterScene("PlayingScene",{freeTime = self.rooms[1].freeTime, joinTime = self.rooms[1].joinTime,
          gameTime = self.rooms[1].gameTime},"crossFade")
       else

          printInfo("加入桌子失败"..body.result)
          toastview:show(localize.getM("SYS_JOIN_TABLE",body.result))
                
       end

    end
  

  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)
 
  printInfo("loginRoom")
  local temp = {}
  local msgbody = {}
  msgbody["tableId"] = tableId
  local body_t = json.encode(msgbody)
  temp["id"] =  ID_REQ + MSGID_SYS_JOIN_TABLE
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)

end


return MainMenuController
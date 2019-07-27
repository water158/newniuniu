--
-- Author:Han
-- Date: 2015-08-16 11:02:15
--继承  BaseController 
local PlayingController = class("PlayingController", ql.mvc.BaseController)
--倒计时
local countdown = import("..utils.countdown")
--定时器
local scheduler = require("framework.scheduler")
--声音控件
local sounds = import("..data.sounds")
--全局控件
local globalCommon = import("..common.GlobalCommon")
--全局动作特效控件
local globalEffect = import("..common.GlobalEffect")
--全局枚举定义
local globalDefine = import("..common.GlobalDefine")
--引入扑克控件
local pokerShow = import("..views.PokerShow")
--引入玩家信息控件
local playerInfoView = import("..views.playerInfoView") 
--抢红包
local redPacketView = import("..views.RedpacketView")
--引入庄家信息控件
local bankerInfoView = import("..views.bankerInfoView")
--引入砝码控件
local farmar = import("..views.farmarView")
--引入聊天模块
local chatMode = import("..views.ChatModeView")
--引入玩家列表模块
local userList = import("..views.UserlistView")
--申请上庄列表
local waitBankerView = import("..views.waitBankerList")
--引入喇叭控件
local hornView = import("..views.hornView")
--引入金币特效
local moveCoinsView = import("..views.moveCoinsView")
--定义函数索引
local this 

function PlayingController:onCreate(args)
  
--定义函数索引
  this = self 
--初始化本文件全局变量
  self:initGlobalData(args)
--初始化牌的坐标
  self:initPokerPos()
--建立长连接
  self:buildSocketConnection()
--初始化牌型
	self:initCardsType()
--台面押注
  self:tableboardTouch()
  self:initCoinsFont()
--引入扑克控件
  self.pokerView = pokerShow.new(self)
  self:getView():addChild(self.pokerView,2)
--引入玩家控件信息
  self.playerInfo = playerInfoView.new(self)
  self:getView():addChild(self.playerInfo)
--引入庄家控件信息
  self.bankerInfo =  bankerInfoView.new(self)
  self:getView():addChild(self.bankerInfo)
--上庄列表控件
  self.waitBanker = waitBankerView.new(self)
  self:getView():addChild(self.waitBanker)
  self:initLayerMultiplex()
--处理上庄的问题
  self:initApplyMode()
--引入红包控件
  self.redPacket = redPacketView.new(self)
  self:getView():addChild(self.redPacket,4)
--引入移动金币特效
  self.moveCoins = moveCoinsView.new()
  self:getView():addChild(self.moveCoins,10)
--输赢结果左右移动变量
  self.winInfoControl = 0
--砝码模块
  self.farmarView = farmar.new(self)
  self:getView():addChild(self.farmarView)
--初始化输赢历史记录 
  self:creatHistory()
--初始化左右输赢左右按钮
  self:initWinHistoryMode()
--初始化玩家信息
  self:initPlayerInfo(self.isBanker)
--聊天转换模块
  self:chatModeChange()


end


--[[
--初始化本文件全局变量
@param  无
@return 无
]]
function PlayingController:initGlobalData(args)
   
  --时间
  self.restTime = args.freeTime
  self.payTime = args.joinTime
  self.openPoker = args.gameTime
  --是否可以下注
  self.isBetTouch  = false
  --是否是庄家
  self.isBanker = false 
  --砝码标签
  self.farmarTag = 10000
  --牌
  self.pokerShow = self:findNodeByName("reverse_21")
  --庄家
  self.dealer = self:findNodeByName("dealer")
  --天
  self.tianPlace = self:findNodeByName("tableboard_1")
  --地
  self.diPlace = self:findNodeByName("tableboard_2")
  --玄
  self.xuanPlace = self:findNodeByName("tableboard_3")
  --黄
  self.huangPlace = self:findNodeByName("tableboard_4")
  --时钟
  self.clock = self:findNodeByName("clock")
  --位置坐标
  self.CardsTypePosTable = 
  { 

  { x= self.dealer:getPositionX(),y = self.dealer:getPositionY()-self.pokerShow:getBoundingBox().height*1.3 },
  { x= self.tianPlace:getPositionX(),y = self.tianPlace:getPositionY()},
  { x= self.diPlace:getPositionX(),y =  self.diPlace:getPositionY()},
  { x= self.xuanPlace:getPositionX() ,y = self.xuanPlace:getPositionY()},
  { x= self.huangPlace:getPositionX(),y = self.huangPlace:getPositionY()}

  }
  --播放荷官动画
  local dealerAction = self:findNodeByName("dealer")
  runTimelineAction(dealerAction, "blinkeye.csb", true)
  --初始化金币变量
  self.PlayerCoinsTable = {0,0,0,0}
  --是否返回-掉线！？
  self.isBack = false
--为返回按钮增加监听
  self:setOnViewClickedListener("back", function()
    
    self:leaveTable()
    self:quitGracefully(true)

  end, nil, "zoom",true)
--声音设置按钮
   self:setOnViewClickedListener("gameSet", function()
     
    self:showDialog("DialogSeting")

  end, nil, "zoom",true)  
--宝箱按钮
  self:setOnViewClickedListener("treasureBox", function()

    self:showDialog("DialogShop",{parent = self})

  end, nil, "none",true)
--宝箱特效
  globalEffect.flotage_effect(self:findNodeByName("treasureBoxLight"),14)
  globalEffect.flotage_effect(self:findNodeByName("treasureBox"),14)
  globalEffect.shake_effect(self:findNodeByName("treasureBoxLight"))
--加金币按钮
  self:setOnViewClickedListener("miangameplus",function()
    self:showDialog("DialogShop")
  end, nil, "none",true)
--增加退出键功能
  self:addBackKeyEventListener(function()
    
    self:quitGracefully(true)

  end)

end

--[[
初始化层管理器
@param  args
@return 无
]]
function PlayingController:initLayerMultiplex()
 
--聊天模块
  self.chatLayer = chatMode.new(self)
--玩家列表模块
  self.userList = userList.new(self)
--喇叭模块
  self.horn = hornView.new(self)

  self.layerManager = cc.LayerMultiplex:create(self.chatLayer,self.userList,self.horn)
  self:getView():addChild(self.layerManager)
  

end

--[[
初始化玩家信息
@param  args
@return 无
]]
function PlayingController:initPlayerInfo(isUserBanker)

  self.playerInfo:setPlayerNickName(isUserBanker)
  self.playerInfo:setPlayerAvatar(isUserBanker)
  self.playerInfo:setPlayerCoins(isUserBanker)  
  
end

--[[
初始化庄家信息
@param  args
@return 无
]]
function PlayingController:initBankerInfo(bankerData)

  gamedata:setBankerAvatar(bankerData["avatar"])
  gamedata:setBankerCoins(bankerData["coins"])
  gamedata:setBankerNickname(bankerData["nick"])
  self.bankerInfo:setBankerNickName()
  self.bankerInfo:setBankerCoins()
  self.bankerInfo:setBankerAvatar()
  
end

--[[
时间状态类型
@param  时间状态类型
@return 无
]]
function PlayingController:timeTypeLo(timeType)

  local typeLo =  timeType
  for i=1,3 do

    if typeLo == i then
      self:findNodeByName("TimeLabel_"..i):setVisible(true)
    else
      self:findNodeByName("TimeLabel_"..i):setVisible(false) 
    end
  
  end

end

--[[
初始化历史记录
@param  args
@return 无
]]
function PlayingController:creatHistory()

  self.ListView_history  = cc.ui.UIListView.new 
   {
            bgScale9 = true,
            viewRect = cc.rect(1083,602,160,118),
            direction = cc.ui.UIScrollView.DIRECTION_HORIZONTAL,
   }
  self.ListView_history:setBounceable(true)
  self.ListView_history:setTouchEnabled(true)
  self.ListView_history:isSideShow()
  self:getView():addChild(self.ListView_history)

end

--[[
加载输赢记录信息
@param  msg
@return 无
]]
function PlayingController:Load_WinInfo(msg)
  
  self.itemList = {}
  self.itemIdx = 0
  for i=1,#msg do
    
    local item = self.ListView_history:newItem()
    table.insert(self.itemList,i,item)
    self.itemIdx = self.itemIdx + 1
    local content = display.newNode()
    local winInfoItem =  msg[i]
    local winInfoStr = nil 

    for j=1,4 do

       if winInfoItem[j] ==  1 then
          winInfoStr = "Common/n1.png"
       else
          winInfoStr = "Common/n0.png"
       end

       if winInfoStr then
        
        local sp = display.newSprite("#"..winInfoStr)
        sp:setPosition(cc.p(0,sp:getBoundingBox().height*1.6-sp:getBoundingBox().height*1.2*(j-1)))
        content:addChild(sp)

       end

    end

    item:addContent(content)
    item:setItemSize(33,160)
    self.ListView_history:addItem(item)

  end
    self.ListView_history:reload()

end

--[[
更新输赢记录信息
@param  msg 
@return 无
]]
function PlayingController:updateWinInfoHistory(msg)

  local item = self.ListView_history:newItem()
  local content = display.newNode()
  local winInfoStr = nil 
  for j=1,4 do
  
    local winInfoItem =  msg[j]

     if globalDefine.winHistroy[j] > 0  then

         if winInfoItem  > 0  then
            winInfoStr = "Common/y1.png"
         else
            winInfoStr = "Common/y0.png"
         end

       else

          if winInfoItem  > 0 then
             winInfoStr = "Common/n1.png"
           else
             winInfoStr = "Common/n0.png"
          end

    end
      
      if winInfoStr then
         local sp = display.newSprite("#"..winInfoStr)
         sp:setPosition(cc.p(0,sp:getBoundingBox().height*1.6-sp:getBoundingBox().height*1.2*(j-1) ))
         content:addChild(sp)
      end

  end 
  self.itemIdx =   self.itemIdx + 1
  item:addContent(content)
  item:setItemSize(33,160)
  self.ListView_history:addItem(item,1)
  self.ListView_history:reload()

end

--[[
输赢记录付初值
@param  无 
@return 无
]]
function PlayingController:initialValue()
  
  for i=1,table.getn(globalDefine.winHistroy) do
  
     globalDefine.winHistroy[i] = 0

  end

end

--[[
记录玩家是否下注
@param  无 
@return 无
]]
function PlayingController:isPlayerBet(betIndex)
  
  local betPlace = betIndex
  for i=1,table.getn(globalDefine.winHistroy) do
 
      if betPlace == i then
  
        globalDefine.winHistroy[i] = 1 
  
      end
  end

end


--[[
发牌
@param  无
@return 无
]]
function PlayingController:dealPoker()
  
  self.pokerShowBackTable = {}
  for i=1,25 do
     
     local sp = self:findNodeByName("reverse_"..i)
     sp:setVisible(true)
     sp:setLocalZOrder(4)
     table.insert(self.pokerShowBackTable,i,sp)
     self.pokerShowBackTable[i]:setPosition(self.pokerShow:getPosition())
    

  end
  sounds.playDealPokerEffect() 
  for i=1,25 do

      if i/5 <= 1   then

        self:easeBounceOut(self.pokerShowBackTable[i],0.1*i,cc.p(self.pokerPos[1+(i-1)*5].x,self.pokerPos[1+(i-1)*5].y))

      elseif (i/5 > 1) and (i/5 <= 2) then

        self:easeBounceOut(self.pokerShowBackTable[i],0.1*i,cc.p(self.pokerPos[2+(i-6)*5].x,self.pokerPos[2+(i-6)*5].y))

      elseif (i/5> 2) and (i/5 <= 3) then

        self:easeBounceOut(self.pokerShowBackTable[i],0.1*i,cc.p(self.pokerPos[3+(i-11)*5].x,self.pokerPos[3+(i-11)*5].y))

      elseif (i/5> 3) and (i/5 <= 4) then

        self:easeBounceOut(self.pokerShowBackTable[i],0.1*i,cc.p(self.pokerPos[4+(i-16)*5].x,self.pokerPos[4+(i-16)*5].y))

      elseif (i/5>4) and (i/5<= 5) then 

        self:easeBounceOut(self.pokerShowBackTable[i],0.1*i,cc.p(self.pokerPos[5+(i-21)*5].x,self.pokerPos[5+(i-21)*5].y))

      end

  end



end

-- 建立长连接
function PlayingController:buildSocketConnection()

    if self._onClose then
        gameWebSocket:removeEventListener(self._onClose)
    end
    if self._onMessage then
        gameWebSocket:removeEventListener(self._onMessage)
    end
    if self._onError then
        gameWebSocket:removeEventListener(self._onError)
    end
    self._onClose = gameWebSocket:addEventListener(gameWebSocket.CLOSE_EVENT,handler(self,self.__onClose))
    self._onMessage = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT,handler(self,self.__onMessage))
    self._onError = gameWebSocket:addEventListener(gameWebSocket.ERROR_EVENT,handler(self,self.__onError))
    
end


--[[
关闭
@param  event
@return 无
]]
function PlayingController:__onClose(event)

  if DEBUG > 0 then
      printInfo("@连接TCP服务器失败！")
  end
  toastview:show(localize.get("network_issue"))
  scheduler.performWithDelayGlobal(function ()
    
    self:onExit()
    RECONNECTION = 10 
    self:enterScene("MainMenuScene",{isAlreadyConnet=true})

 end,0.6)

end


--[[
错误
@param  event
@return 无
]]
function PlayingController:__onError(event)

  if DEBUG > 0 then

   printInfo("连接服务器错误")

  end
  toastview:show(localize.get("network_issue"))

end

--[[
消息
@param  event
@return 无
]]
function PlayingController:__onMessage(event)

  if DEBUG > 0 then

     printInfo("inGame    @接收到TCP通知！")
  
  end  
    
    print("onMessage")
    printf("receive text msg: %s", event.message)
    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"] 
    print("消息ID     值"..id)

    if self.isBack == false then
        
        self:onReceivedAck(id,body)
        self:onReceivedNotify(id, body)

    end
  

end

--[[
与服务器交互信息,接收到反应
@param  userId,token
@return 无
]]
function PlayingController:onReceivedAck(msgId,body)

 if msgId == (ID_ACK+MSGID_JOIN_COINS) then
      
      if body["result"] == 0 then
        
        local placeType =  body["address"]
        local totalCoins = body["coins"]
        local joinCoins = body["joinCoins"]
        local posX = body["posX"]
        local posY = body["posY"]
        self:farmarAction(placeType,joinCoins,posX,posY,true)
        self:ShowAllBoardForAck(placeType,joinCoins)
        self:ShowAllPlayerCoins(placeType,joinCoins)
        gamedata:setPlayerCoins(totalCoins)
        self.playerInfo:setPlayerCoins(false) 
        self.userList:updateUserCoins(totalCoins)
        self.waitBanker:updateUserCoins(totalCoins)
        self.farmarView:changeLight(self.farmarView.roomType,joinCoins) 
         --记录输赢历史记录
        self:isPlayerBet(placeType)

      else
          
       toastview:show(localize.getM("JOIN_COINS",body["result"]))
       
      end
 elseif  msgId == (ID_ACK+MSGID_GIFT_GRAB)  then 
     
      if body["result"] == 0 then

          gamedata:setPlayerCoins(body["coins"])
          self.playerInfo:setPlayerCoins(self.isBanker)
       else
          
          toastview:show(localize.getM("GIFT_GRAB",body["result"]))

       end

 end



end

--[[
与服务器交互信息,接收到通知
@param  userId,token
@return 无
]]
function PlayingController:onReceivedNotify(msgId, body)

  if msgId == (ID_NTF + MSGID_BOARD_INFO) then    --进入桌子时，通知玩家当前的桌面信息

    local timer = body["timer"]
    printInfo("获取游戏倒计时时间返回= "..timer)
    local status = body["status"]
    printInfo("获取游戏状态信息返回="..status)
    --初始化庄家信息
    if body["bankerInfo"].bankerId == gamedata:getUserId() then 
     
     print("初始化庄家信息+++++++++++++++++++++++++++++++++++++++++++")
     self.isBanker = true
     self:initPlayerInfo(self.isBanker)

    else
      
     self:initBankerInfo(body["bankerInfo"])

    end      
--获取初始游戏状态
    self:originalGameState(body)
--获取输赢历史记录
    self:Load_WinInfo(body["winHistory"])
--等待上庄列表
    local waitBankerList = body["waitBanker"]
    
    self.waitBanker:LoadApplyBanker(waitBankerList)

--当前坐庄次数
    local bankerInfo = body["bankerInfo"]
    self.bankerInfo.bankerTimes = bankerInfo["bankerTimes"]
    self:findNodeByName("dealertimes"):setString(self.bankerInfo.bankerTimes)

  elseif msgId == (ID_NTF+MSGID_STATUS) then    -- 通知当前状态

    local status = body["status"]
    print("进入循环   获取游戏状态信息返回="..status)
       
       if status == 0 then  --进入休息状态

          printInfo("广播空闲开始")
          globalEffect.flipY_effect(self.clock)
          self:timeTypeLo(1)
          self:startCountDown(self:findNodeByName("secondsLabel"),self.restTime,globalDefine.timeType.restType)
      --空闲游戏状态
          self:clearDesktop()
          self:RestGamestate()
      --坐庄次数
          self.bankerInfo.bankerTimes = self.bankerInfo.bankerTimes + 1
          self:findNodeByName("dealertimes"):setString(self.bankerInfo.bankerTimes)

      elseif status == 1 then  --进入下注状态
 
          printInfo("广播下注开始")
          globalEffect.flipY_effect(self.clock)
          self:timeTypeLo(2)
          self:startCountDown(self:findNodeByName("secondsLabel"),self.payTime,globalDefine.timeType.payType)
      --开始下注:
          self.isBetTouch = true 
          sounds.beginBet() 


      elseif status == 2 then  --进入开牌状态

          printInfo("广播开牌开始")
          globalEffect.flipY_effect(self.clock)
          self:timeTypeLo(3)
          self:startCountDown(self:findNodeByName("secondsLabel"),self.openPoker,
          globalDefine.timeType.openPokerType )
      --无法下注
          self.isBetTouch  = false 
      --发牌 
          self:dealPoker()
      ---status 
      end

  elseif msgId ==  (ID_NTF+MSGID_JOIN_COINS)  then   --通知下注

         printInfo("广播下注情况")
         self:notifyBet(body)

  elseif msgId ==  (ID_NTF+MSGID_RESULT) then  -- 通知游戏结果 结算

         printInfo("通知游戏结果 广播牌面信息   接收输赢数据")
   
     --初始化玩家手牌服务器数据
         self.pokerView:initServicerNormalCards(this:getServicerNormalCards(body["cardInfo"]))
     --获取牌的类型 
         self.cardTypeList  =  this:getServicerNoramlType(body["niuInfo"])
     --显示牌型服务器数据
         this:showCardsType(self.cardTypeList)
     --开牌
         self.perDalayOpen = scheduler.performWithDelayGlobal(function()
           
            self:Openbrand(body)

        end,1)
     --数字up
      self:gameDelayGlobalPopup(body,11)
     --输赢弹框
      self:gameDelayGlobalOne(body)

  elseif msgId  == (ID_NTF + MSGID_JOIN_BANKER)   then 

        self.waitBanker:onApplyBanker(body)

  elseif  msgId ==   (ID_NTF+ MSGID_CHANGE_BANKER) then   --通知换庄
        printInfo("通知换庄，通知换庄")
        self:change_banker(body)
        self.waitBanker:onQueueBanker(msgId,body)

  elseif  msgId ==   (ID_NTF+MSGID_CHAT)   then    --通知聊天 

        printInfo("接受到聊天信息")
        self.chatLayer:onChatMsg(msgId,body)
  elseif msgId == (ID_NTF + MSGID_SYS_BROADCAST) then   --喇叭广播

        printInfo("接收到喇叭广播")
        self.horn:onNoticeMsg(body)
  
  elseif msgId == (ID_NTF+MSGID_GIFT_GRAB)  then   --通知抢红包
        
        self.redPacket:redpackShow()

  elseif msgId == (ID_NTF+MSGID_CHAT_SYSTEM)  then  --系统消息
        
        printInfo("接受到系统消息")
        self.chatLayer:onChatMsg(msgId,body)
         
  elseif msgId == (ID_NTF+MSGID_QUIT_BANKER)  then  --通知退出等待上庄列表
        
        printInfo("退出庄家"..body["userId"])
        self.waitBanker:onQueueBanker(msgId,body)
  
  elseif msgId == (ID_NTF+MSGID_MONEY_CHG)  then     --通知玩家金币变化
        
        printInfo("通知玩家金币变化"..body["coins"])
        self.waitBanker:onMoneyChange(body)
        self.userList:renewalCoins(body)
        
  elseif  msgId == (ID_NTF+MSGID_SYS_LEAVE_TABLE)  then  --离开桌子
 
  
---总
end


---函数
end


--[[
加入金币
@param  位置、金币数 
@return 无
]]
function PlayingController:joinCoins(address,coins,posX,posY)

	local temp = {}
  local msgbody = {}
  msgbody["joinCoins"] = coins
  msgbody["address"] = address
  msgbody["posX"] = posX
  msgbody["posY"] = posY
  local body_t = json.encode(msgbody)
	temp["id"] = (ID_REQ + MSGID_JOIN_COINS)
	temp["body"] = body_t
	local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)

end

function PlayingController:initCoinsFont()

  for i=1,4 do
  
    self:findNodeByName("BoardCoins_"..i):setLocalZOrder(1)
    self:findNodeByName("PlayerCoins_"..i):setLocalZOrder(1)
    self:findNodeByName("psCoins_"..i):setLocalZOrder(1)
    self:findNodeByName("PlayerCoins_L_"..i):setLocalZOrder(1)
    self:findNodeByName("grade_"..i):setLocalZOrder(1)

  end

end

--[[
显示下注金币，传来天、地、玄、黄上的Board金币数
@param  无
@return 无
]]
function PlayingController:ShowAllBoardForAck(address,coinNum)
  
  local boardCoins = self:findNodeByName("BoardCoins_"..address):getString()
  if tonumber(boardCoins)  then
    
    boardCoins = tonumber(boardCoins) + tonumber(coinNum)
 
  end

    self:findNodeByName("BoardCoins_"..address):setString(boardCoins)

end


--[[
显示下注金币，传来天、地、玄、黄上的Board金币数
@param  无
@return 无
]]
function PlayingController:ShowAllBoardCoins(address,coinNum)
  
  self:findNodeByName("BoardCoins_"..address):setString(coinNum)

end

--[[
显示下注金币，传来天、地、玄、黄上的Player金币数
@param  无
@return 无
]]
function PlayingController:ShowAllPlayerCoins(address,selfCoins)
  
  self.PlayerCoinsTable[address] = self.PlayerCoinsTable[address] + selfCoins
  self:findNodeByName("PlayerCoins_"..address):setString(self.PlayerCoinsTable[address])

end


--[[
金币倍数 结算
@param  位置、金币数 
@return 无
]]
function PlayingController:multipleCoins(address,body)
  
    local winInfo = body["winFan"]
    local playerJoinCoins = body["joinCoins"]
    local i = address
    if winInfo[i] > 0 and playerJoinCoins[tostring(i)] ~= 0 then
      local winNum = winInfo[i]
      self:findNodeByName("PlayerCoins_"..i):setString(playerJoinCoins[tostring(i)].."*"..tostring(winNum))
      local psNum = tonumber(winNum) * tonumber(playerJoinCoins[tostring(i)])
      self:findNodeByName("psCoins_"..i):setFntFile("fontFolder/jinse.fnt")
      self:findNodeByName("psCoins_"..i):setString("+"..tostring(psNum))
      self:findNodeByName("PlayerCoins_L_"..i):setString("")
    elseif winInfo[i] < 0 and playerJoinCoins[tostring(i)] ~= 0 then
      local loseNum = -tonumber(winInfo[i])
      local jsNum = loseNum* tonumber(playerJoinCoins[tostring(i)])
      self:findNodeByName("psCoins_"..i):setFntFile("fontFolder/hui.fnt")
      self:findNodeByName("psCoins_"..i):setString("-"..tostring(jsNum))
      self:findNodeByName("PlayerCoins_"..i):setString("")
      self:findNodeByName("PlayerCoins_L_"..i):setString(playerJoinCoins[tostring(i)].."*"..tostring(loseNum))
    elseif playerJoinCoins[tostring(i)] == 0  then     
      self:findNodeByName("grade_"..i):setVisible(true)
    end

end


function PlayingController:onEnter( )

  sounds.playBackgroundMusic("INGAME")
  self._enterBackgroundHandle = app:addEventListener(app.APP_ENTER_BACKGROUND_EVENT, function()
    self:quitGracefully(true)
  end)

end

function PlayingController:onExit()
     
  PlayingController.super.onExit(self)

  if self.perDalay1 then
    scheduler.unscheduleGlobal(self.perDalay1)
  end
  if self.perDalayOpen then
     scheduler.unscheduleGlobal(self.perDalayOpen)
  end
  if self.perDalay2  then
     scheduler.unscheduleGlobal(self.perDalay2)
  end

  if self.perDalayPopup then
     scheduler.unscheduleGlobal(self.perDalayPopup)
  end

  sounds.stopBackgroundMusic(isReleaseData)
  sounds.stopAllSounds()
  countdown.stop()

  app:removeEventListener(self._enterBackgroundHandle)
    
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
启动倒计时
@param  body
@return 无
]]
function PlayingController:startCountDown(label, duration,timeType)

	label:setString(duration)
	countdown.run(duration, function(event)
	   
    label:setString(event.remains)
    if timeType ==  globalDefine.timeType.restType  then
       
       if tonumber(event.remains) == 2 then
         
         local winFlashing = self:findNodeByName("cow_Action")
         winFlashing:setLocalZOrder(10)
         sounds.playCowEffect()
         winFlashing:setVisible(true)
         runTimelineAction(winFlashing,"cowAction.csb",false,function()
            
            winFlashing:setVisible(false)

         end)

       end

    elseif timeType == globalDefine.timeType.payType  then
      

      if tonumber(event.remains) ==  4 then
        
        sounds.playCountdownEffect(3)

      end
  
    elseif timeType  ==  globalDefine.timeType.openPokerType   then 

    end
   
    end)

end


--更新函数，定时器 
function PlayingController:__onUpate(dt)


end

--[[
初始游戏状态
@param  body
@return 无
]]
function  PlayingController:originalGameState(body)
  
  local status = body["status"]
  printInfo("获取初始游戏状态是  status"..status)
  local timer = body["timer"]
  printInfo("当前状态游戏时间是  timer"..timer)
  local playerCoins = body["coins"]
  gamedata:setPlayerCoins(playerCoins)
  self.playerInfo:setPlayerCoins(self.isBanker)
  gamedata:setNewBankerId(body["bankerInfo"].bankerId)
  globalEffect.flipY_effect(self:findNodeByName("clock"))

  if   status == 0 then
       
       printInfo("进入时为空闲时间"..timer)
       local restTime = (self.restTime-timer-1)
       self:startCountDown(self:findNodeByName("secondsLabel"),restTime,globalDefine.timeType.restType)
       sounds.prepareEffect()
       sounds.playCountdownEffect(restTime-1)
       self:initialValue()
       self:timeTypeLo(1)

 elseif status == 1 then
       
       printInfo("进入时为下注时间"..timer) 
       local payTime = (self.payTime-timer-1)
---如果时间大于等于 5 s 可以下注 ，否则不可以下注
       if payTime >= 5 then
         
        self.isBetTouch = true 
         
       end
       self:startCountDown(self:findNodeByName("secondsLabel"),payTime,globalDefine.timeType.payType)
       self:timeTypeLo(2)
       --显示下注情况 
       self:joinCoinSituation(body["totalJoinCoinsDetail"])
       self:betSituation(body["totalJoinCoins"],body["joinCoins"])

 elseif status == 2 then
       
       printInfo("进入时为开牌时间是"..timer)
       local openPoker = (self.openPoker-timer-1)
       self:startCountDown(self:findNodeByName("secondsLabel"),openPoker,globalDefine.timeType.openPokerType)
       self:timeTypeLo(3)
     --显示下注情况
       self:joinCoinSituation(body["totalJoinCoinsDetail"])
       self:betSituation(body["totalJoinCoins"],body["joinCoins"])

     --获取牌的数据  
       local cardMsg = body["resultInfo"] 

       --if cardMsg ~= nil then
        
        printInfo("牌的数据"..type(cardMsg["cardInfo"]))
        local CardList =  this:getServicerNormalCards(cardMsg["cardInfo"])
     
       --end

       if  CardList ~= nil then
    
        self.pokerView:initServicerNormalCards(CardList)
       
        for i=1,25 do
      
          self.pokerView.showCard[i]:setVisible(true)

        end  
        
       end
     
     --获取牌型的数据 
       self.cardTypeList  =  this:getServicerNoramlType(cardMsg["niuInfo"])
       if self.cardTypeList ~= nil then
    
     --显示牌型服务器数据
        this:showCardsType(self.cardTypeList)
    
        for i=1,5 do
    
          self.cardsTypeTable[i]:setVisible(true)
    
        end

       end
 ---------显示输赢弹框      
       self:gameDelayOriginal(timer,cardMsg)
          
  end

end

--[[
空闲游戏状态
@param  body
@return 无
]]
function PlayingController:RestGamestate()

  sounds.prepareEffect()
  sounds.playCountdownEffect(4)
  self:initialValue()

end

--[[
空闲游戏状态
@param  body
@return 无
--]]
function PlayingController:textRecover()
  
  local bankerJS = self:findNodeByName("bankerJS")
  local playerJS = self:findNodeByName("playerJS")
  playerJS:setString("")
  local playerJSMove = cc.MoveTo:create(0.1,cc.p(414,105))
  local playerJsBack = cc.FadeTo:create(0.1,255)
  local se1 = transition.sequence({playerJSMove,playerJsBack})
  playerJS:runAction(se1)
  bankerJS:setString("")
  local bankerJSMove = cc.MoveTo:create(0.1,cc.p(145,619))
  local bankerJsBack = cc.FadeTo:create(0.1,255)
  local se2 = transition.sequence({bankerJSMove,bankerJsBack})
  bankerJS:runAction(se2)

end
--[[
清理桌面
@param  body
@return 无
]]
function PlayingController:clearDesktop()
  
      self:pokerRestore()
      self:textRecover()
      self.redPacket:redpacketHide() 
      for i=1,4 do
        
       if self:findNodeByName("grade_"..i):isVisible() == true then
          self:findNodeByName("grade_"..i):setVisible(false)
       end
          self:findNodeByName("PlayerCoins_L_"..i):setString("")
          self:findNodeByName("psCoins_"..i):setString("")
          self:findNodeByName("BoardCoins_"..i):setString("")
          self:findNodeByName("PlayerCoins_"..i):setString("")

      end 

 --砝码消失 

      if  self.farmarTag~= 10000   then 
           
          for i= 10000,(self.farmarTag-1)  do 
 
             self:getView():removeChildByTag((i+1), true)

          end
            
          self.farmarTag = 10000 

      end
--输赢弹框消失

      if  self.DialogSettle ~= nil  then
   
       self.DialogSettle:dismiss()
       self.DialogSettle = nil 

      end

--所有的明牌数消失
     if self.pokerView.showCard ~= nil then
     
        for i=1,25 do
      
          self.pokerView.showCard[i]:setVisible(false)
          self.pokerView.showCard[i] = nil 

        end
        
     end 

--牌型消失
     if self.cardsTypeTable ~= nil then
       
       for i = 1,5 do
         
         self.cardsTypeTable[i]:setVisible(false)
         self.cardsTypeTable[i] = nil 
      
      end

    end  

--个人金币数重新赋值
    for i=1,table.getn(self.PlayerCoinsTable)  do
     
       self.PlayerCoinsTable[i]= 0 

    end

end

--[[
poker恢复
@param  body
@return 无
]]

function PlayingController:pokerRestore()
  
  for i=1,25 do
    
    local sp = self:findNodeByName("reverse_"..i)
    sp:setVisible(true)
    if i <= 13 then
      
      sp:setPosition(cc.p(825,(461+i)))
     
    else
      sp:setPosition(cc.p(825,473))
  
    end


  end

end

--[[
通知下注
@param  body
@return 无
]]
function PlayingController:notifyBet(body)
  

  local joinCoinsList = body["joinCoinsDetail"]
  local totalCoins = body["totalJoinCoins"]
  sounds.PlayDropCoinsEffect()
  for k,v in pairs(joinCoinsList) do
   
   local placeList = v 
   if placeList ~= nil then
      
      for i,j in pairs(placeList) do 
         
         if j["userId"] ~= gamedata:getUserId() then
             
           self:farmarAction(tonumber(k),j["joinCoins"])
        
         end


       
      end 
   
   end
 
  end

  for k,v in pairs(totalCoins) do
   if v ~= 0 then
    self:ShowAllBoardCoins(k,v)
   end

  end

end

--[[
显示下注情况  砝码
@param  
@return 无
]]
function PlayingController:joinCoinSituation(joinCoinMsg)
  
  local totalJoinCoinsDetail
  
  if joinCoinMsg ~= nil then
      
      totalJoinCoinsDetail = joinCoinMsg
  
  else
     return 
  end
  local curtime =  os.time()
  for i,j in pairs(totalJoinCoinsDetail) do
     
    local placeList = j
    if placeList ~= nil  then
      
      if tonumber(i) == globalDefine.BoardType[tonumber(i)]  then
      for k,v in pairs(placeList)  do

        for n=1,v do 

          self:farmarAction(tonumber(i),k)
          local consumtime = os.time() - curtime

        end    
      
       end

      end
   
    end

  end


end

--[[
显示下注情况  Coin Num
@param  
@return 无
]]
function PlayingController:betSituation(totalbetMsg,personbetMsg)
   
   local totalJoinCoins = totalbetMsg 
   local personJoinCoins = personbetMsg

   if totalJoinCoins ~= nil then
       
      for i=1,table.getn(globalDefine.BoardType)  do
       
       if totalJoinCoins[tostring(i)] ~= 0 then
     
          self:ShowAllBoardCoins(tostring(i),totalJoinCoins[tostring(i)])

       end


      end
   
   else 

    return 

   end

   if personJoinCoins ~= nil then
  
     
     for i=1,table.getn(globalDefine.BoardType)  do
       
       if personJoinCoins[tostring(i)] ~= 0 then
     
        self:findNodeByName("PlayerCoins_"..tostring(i)):setString(personJoinCoins[tostring(i)])

       end


      end


   else

    return 

   end

end

--台面触摸(注册台面触摸事件)
function PlayingController:tableboardTouch()
  
  if self.isBanker == false   then
     self.tableBoardTable = {}
     for i=1,4 do
  
      table.insert(self.tableBoardTable,i,self:findNodeByName("tableboard_"..i))
      self:setOnClickListener("tableboard_"..i,function (event)
      local spriteIndex = i 
      for j=1,4 do
   
        if spriteIndex == j then
   
  --上传数据至服务器
          local node = self.tableBoardTable[j]
          local posX,posY = globalCommon.Adjust(node,event.x,event.y)
          this:joinCoins(spriteIndex,self.farmarView:getFarmarData(),posX,posY)

        end

       end

                                                  end,nil,"none")
      end
  end

end

--[[
砝码移动至牌面
@param  牌面类型
@return 无
]]
function PlayingController:farmarAction(placeType,coins,posX,posY,isSelf)
  
  local node = nil 
  local nodeX,nodeY 
  for i=1,4 do

    if i == placeType then

      node = self.tableBoardTable[i]

    end
  end
  
  if isSelf then
   nodeX = posX
   nodeY = posY 
  else
   nodeX,nodeY = globalCommon.Rectborder(node)
  end

  if coins ~= nil then

    self.farmarTag = self.farmarTag +1
--播放下注金币声音
    local spriteImage = self.farmarView:getFarmarImage(coins)
    local coin = display.newSprite("#"..spriteImage)
    coin:setScale(self:findNodeByName("tableboard_1"):getBoundingBox().height/coin:getContentSize().height*0.22)
    coin:setPosition(cc.p(nodeX,nodeY))
    self:getView():addChild(coin,0,self.farmarTag)
 end


end


--发牌运动
function PlayingController:easeBounceOut(node,movetime,pos) 
  local delay = cc.DelayTime:create(movetime)
  local moveby1=cc.MoveTo:create(0.1,pos)
  local seq= cc.Sequence:create(delay,moveby1)
  node:runAction(seq)
end


--初始化25张牌坐标
function PlayingController:initPokerPos()

  self.pokerPos = {}
  local dealerPosX = self.dealer:getPositionX()
  local dealerPosY = self.dealer:getPositionY()-self.pokerShow:getBoundingBox().height*1.3
  for i=1,25 do
  
    if  i/5 <=1 then
 
      table.insert(self.pokerPos,i,{x = dealerPosX-self.pokerShow:getBoundingBox().width*0.7+(self.pokerShow:getBoundingBox().width*0.35*(i-1)),y = dealerPosY-self.pokerShow:getBoundingBox().height*0.2})

    elseif i/5>1 and i/5 <= 2 then

      table.insert(self.pokerPos,i,{x = self.tianPlace:getPositionX()-self.pokerShow:getBoundingBox().width*0.7+(self.pokerShow:getBoundingBox().width*0.35*(i-6)),y = self.tianPlace:getPositionY()-self.pokerShow:getBoundingBox().height*0.2})

    elseif i/5>2 and i/5 <=3 then
 
      table.insert(self.pokerPos,i,{x = self.diPlace:getPositionX()-self.pokerShow:getBoundingBox().width*0.7+(self.pokerShow:getBoundingBox().width*0.35*(i-11)),y = self.diPlace:getPositionY()-self.pokerShow:getBoundingBox().height*0.2})

    elseif i/5>3 and i/5 <=4 then

      table.insert(self.pokerPos,i,{x = self.xuanPlace:getPositionX()-self.pokerShow:getBoundingBox().width*0.7+(self.pokerShow:getBoundingBox().width*0.35*(i-16)),y = self.xuanPlace:getPositionY()-self.pokerShow:getBoundingBox().height*0.2})

    elseif i/5>4 and  i/5<=5 then

      table.insert(self.pokerPos,i,{x = self.huangPlace:getPositionX()-self.pokerShow:getBoundingBox().width*0.7+(self.pokerShow:getBoundingBox().width*0.35*(i-21)),y = self.huangPlace:getPositionY()-self.pokerShow:getBoundingBox().height*0.2})

    end

  end


end

--开牌运动
function PlayingController:Openbrand(body)
 
  self.zhuan = {}
  self.tian = {}
  self.di = {}
  self.xuan = {}
  self.huang = {}
  for i=1,25 do
    
    if i%5 ==1 then
      table.insert(self.zhuan,self.pokerShowBackTable[i])
    elseif i%5 == 2 then
      table.insert(self.tian,self.pokerShowBackTable[i])
    elseif i%5 ==3 then
      table.insert(self.di,self.pokerShowBackTable[i])
    elseif i%5 ==4 then 
      table.insert(self.xuan,self.pokerShowBackTable[i])
    elseif i%5 ==0 then 
      table.insert(self.huang,self.pokerShowBackTable[i])
    end

  end
  

  local delay = cc.DelayTime:create(1.8)
  local zhuancall = cc.CallFunc:create(function ()
  for i=1,5 do
    self:flipCards(self.zhuan[i],self.pokerView.showCard[i],self.cardsTypeTable[1])
  end
    sounds.playniuEffect((self.cardTypeList[1]+1))
  end)
  local zhuanseq = cc.Sequence:create(delay,zhuancall)
------天
  local tiancall = cc.CallFunc:create(function ()

  for i=1,5 do
  
    self:flipCards(self.tian[i],self.pokerView.showCard[5+i],self.cardsTypeTable[2])
   
  end
  
    self:multipleCoins(1,body)
    sounds.playniuEffect((self.cardTypeList[2]+1))

  end)

  local tianseq = cc.Sequence:create(delay,tiancall)

-----地

  local dicall =cc.CallFunc:create(function ()

  for i=1,5 do
    self:flipCards(self.di[i],self.pokerView.showCard[10+i],self.cardsTypeTable[3])
  end

    self:multipleCoins(2,body)
    sounds.playniuEffect((self.cardTypeList[3]+1))

  end)
  local diseq = cc.Sequence:create(delay,dicall)

------玄
  local xuancall =cc.CallFunc:create(function ()

  for i=1,5 do
 
    self:flipCards(self.xuan[i],self.pokerView.showCard[15+i],self.cardsTypeTable[4])

  end
  
    self:multipleCoins(3,body)
    sounds.playniuEffect((self.cardTypeList[4]+1))

  end)

  local xuanseq = cc.Sequence:create(delay,xuancall)

------huang

  local huangcall =cc.CallFunc:create(function ()

    for i=1,5 do
  
      self:flipCards(self.huang[i],self.pokerView.showCard[20+i],self.cardsTypeTable[5])
 
    end
  
      self:multipleCoins(4,body)
      sounds.playniuEffect((self.cardTypeList[5]+1))

  end)

  local huangseq = cc.Sequence:create(delay,huangcall)

--总共
  local seql = cc.Sequence:create(zhuanseq,tianseq,diseq,xuanseq,huangseq)
  self:runAction(seql)

end

--初始化牌型
function PlayingController:initCardsType(pngindex)

  self.niuPngTable = {}
  for i=1,14 do

    local imageStr = "card/t_"..(i-1)..".png" 
    table.insert(self.niuPngTable,i,imageStr)
  end
  return self.niuPngTable[pngindex]

end

--获取服务器牌型
function PlayingController:showCardsType(cardTypeList)

  local servicerCardTypeList = cardTypeList
  self.cardsTypeTable = {}
  for i = 1,5 do 
    local sp = display.newSprite("#"..this:initCardsType(checkint(servicerCardTypeList[i])+1))
    sp:setPosition(cc.p(self.CardsTypePosTable[i].x,self.CardsTypePosTable[i].y-self.pokerShow:getBoundingBox().height*0.4))
    sp:setVisible(false)
    self:getView():addChild(sp,2)
    table.insert(self.cardsTypeTable,i,sp)

  end

end

function PlayingController:getServicerNormalCards(NormalCardsList)

    local CardList = NormalCardsList
      
      if CardList ~= nil then

         return CardList

      end

end

function PlayingController:getServicerNoramlType(NormalCardsType)
 
  local cardTypeList = NormalCardsType
  if cardTypeList ~= nil then
     return cardTypeList
  end

end

function PlayingController:flipCards(node,shownode,typenode)
	
  local  duration = 1
  local  orbitFront = cc.OrbitCamera:create(duration*0.5,1,0,90,-90,0,0)
  local  call1 = cc.CallFunc:create(function ()
	
      node:setVisible(false)

  end)
  local call2 = cc.CallFunc:create(function ()
 
    shownode:setVisible(true)  

  end)
  local call3 = cc.CallFunc:create(function ()
  
      typenode:setVisible(true)
  end)
  local se = cc.Sequence:create(orbitFront,call1,call2,call3)
  node:runAction(se) 

end

function PlayingController:initApplyMode()

--申请上庄
  self:setOnViewClickedListener("Image_apply", function()
    self.waitBanker:applyBanker()
  end)

--取消上庄
    self:setOnViewClickedListener("Image_quene", function()
    self.waitBanker:queueBanker()

  end)


end

--初始输赢历史记录左右按钮
function PlayingController:initWinHistoryMode()
  
  self:setOnViewClickedListener("Image_left", function()

 if self.ListView_history:getScrollNode():getPositionX() <= -33*(self.itemIdx-1) then
    
    self.winInfoControl = -33*(self.itemIdx-2)
   
 end 
    self.winInfoControl = self.winInfoControl-33
    self.ListView_history:getScrollNode():setPosition(cc.p(self.winInfoControl,0))


  end)

  self:setOnViewClickedListener("Image_right", function()

    if self.ListView_history:getScrollNode():getPositionX() >= -33 then
      
      self.winInfoControl = -33

    end
    self.winInfoControl = 33+self.winInfoControl
    self.ListView_history:getScrollNode():setPosition(cc.p(self.winInfoControl,0))

  end)

end

--聊天转换
function PlayingController:chatModeChange()
  
--聊天模块
  local switchButtonTable = {}
  for i=1,3 do

  table.insert(switchButtonTable,i,self:findNodeByName("switchButton_"..i))

  end
  for i=1,3 do
    
    self:setOnViewClickedListener("switchButton_"..i,function ()
    
    self.layerManager:switchTo((i-1))
    local changeIdx = i
    if changeIdx == 2 then
      
      self.userList:sendUserListMsg()

    end

    for j=1,3 do
      
      if j == changeIdx then
         switchButtonTable[j]:loadTexture(globalDefine.modeChangeType[j].Y,ccui.TextureResType.plistType)
      else
         switchButtonTable[j]:loadTexture(globalDefine.modeChangeType[j].N,ccui.TextureResType.plistType)
      end

    end
  
             end,nil,"none",true)

  end

end


--换庄
function PlayingController:change_banker(msg)

  --坐庄次数
  local msg_t = msg
  print("newBankerId++++++++++++++++++++++"..msg_t["newBankerId"])
  print("oldBankerId++++++++++++++++++++++"..msg_t["oldBankerId"])
  gamedata:setNewBankerId(msg_t["newBankerId"])
  self.bankerInfo.bankerTimes = 1
  self:findNodeByName("dealertimes"):setString(self.bankerInfo.bankerTimes)

  if msg_t["newBankerId"] ==  gamedata:getUserId() then     --自己上庄
  
    self.isBanker = true
    printInfo("自己上庄")
    self:initPlayerInfo(self.isBanker)

  elseif msg_t["oldBankerId"] == gamedata:getUserId() then  --自己下庄

  --初始化庄家 
    self:initBankerInfo(msg_t)
    self.isBanker = false
  --初始化玩家
    self:initPlayerInfo(self.isBanker)
  else                                                    --其他玩家上下庄
    self:initBankerInfo(msg_t)
  end

  
end


function PlayingController:gameDelayGlobalOne(body)

  --更新输赢历史记录
  self.perDalay1 = scheduler.performWithDelayGlobal(function()
  self:updateWinInfoHistory(body["winFan"])     
 --赢特效  
  local playerWinData = body["winCoinsTotal"]
  local bankerWinData = body["bankerWinCoins"]
  local isUserBanker = body["isBanker"]

  local presentCoin = gamedata:getPlayerCoins() + playerWinData + gamedata:getSafeCoins()
  
  if presentCoin <= 1000 then
    
    self:applyFreeCharge()

  end
--弹出输赢结果
  self:dealsettle(playerWinData,bankerWinData,isUserBanker)
--玩家金币赋值
  gamedata:setPlayerCoins(body["coins"])
  self.playerInfo:setPlayerCoins(self.isBanker)
--庄家金币赋值
  gamedata:setBankerCoins(body["bankerCoins"]) 
  self.bankerInfo:setBankerCoins() 
--更新金币
  self.userList:updateBankerCoins(body["bankerCoins"])
  self.userList:updateUserCoins(body["coins"]) 

         end,13)
 
end

function PlayingController:dealsettle(playerWinData,bankerWinData,isUserBanker)
   
   if isUserBanker == 1 then
    
      playerWinData = bankerWinData

   end

   if playerWinData >= 0 then
    
    self.DialogSettle = self:showDialog("DialogWin",{playerData = playerWinData})
    self.DialogSettle:setCallback(self.DialogSettle.DISMISS,function()
      self.DialogSettle = nil
    end)

   elseif playerWinData < 0 then
    
    self.DialogSettle = self:showDialog("DialogLose",{playerData = playerWinData})
    self.DialogSettle:setCallback(self.DialogSettle.DISMISS,function()
      self.DialogSettle = nil
    end)

   end

end

--pop-up
function PlayingController:popupText(playerWinData,bankerWinData,isUserBanker)
    
   if playerWinData >=0 then
   
   self:findNodeByName("playerJS"):setFntFile("fontFolder/jinse.fnt")
   self:findNodeByName("playerJS"):setString("+"..playerWinData)
   globalEffect.textUp(self:findNodeByName("playerJS")) 

  else
   
   self:findNodeByName("playerJS"):setFntFile("fontFolder/hui.fnt")
   self:findNodeByName("playerJS"):setString(playerWinData)
   globalEffect.textUp(self:findNodeByName("playerJS"))  

  end

  if bankerWinData >= 0 then
   
   self:findNodeByName("bankerJS"):setFntFile("fontFolder/jinse.fnt")
   self:findNodeByName("bankerJS"):setString("+"..bankerWinData)
   globalEffect.textUp(self:findNodeByName("bankerJS"))  

  else
   
   self:findNodeByName("bankerJS"):setFntFile("fontFolder/hui.fnt")
   self:findNodeByName("bankerJS"):setString(bankerWinData)
   globalEffect.textUp(self:findNodeByName("bankerJS"))  

  end


end


function PlayingController:gameDelayGlobalPopup(body,time)
  
  local playerWinData = body["winCoinsTotal"]
  local bankerWinData = body["bankerWinCoins"]
  local isUserBanker = body["isBanker"]
  self.perDalayPopup = scheduler.performWithDelayGlobal(function()
    
    self:gameCoinActionView(body)    
    self:popupText(playerWinData,bankerWinData,isUserBanker)

  end,time)


end


function PlayingController:gameDelayOriginal(timer,cardMsg)
  
  local playerWinData = cardMsg["winCoinsTotal"]
  local bankerWinData = cardMsg["bankerWinCoins"]
  local isUserBanker = 0
  if (self.openPoker-timer) >= 9 then
      
    self:gameDelayGlobalPopup(cardMsg,4)
    self.perDalay2 = scheduler.performWithDelayGlobal(function ()
          
        self:dealsettle(playerWinData,bankerWinData,isUserBanker)

    end,6)   
  
  else
      
     if self.openPoker-timer >= 2 then
       self:gameDelayGlobalPopup(cardMsg,0)
     end
     if self.DialogSettle ~= nil then
      self:dealsettle(playerWinData,bankerWinData,isUserBanker)
     end
  

   end  

end

function PlayingController:gameCoinActionView(body)
  
  local playerWinData = body["winCoinsTotal"]
  local otherWinCoins = body["otherWinCoins"]
  local bankerPlace = self:findNodeByName("banker_playerFrame")
  local playerPlace = self:findNodeByName("Image_playerFrame")
  local listViewPlace = self:findNodeByName("switchButton_2")
 
  if playerWinData > 0 then
   
   self.moveCoins:moveCoinsView(bankerPlace,10,cc.p(playerPlace:getPositionX(),playerPlace:getPositionY())) 

  elseif playerWinData < 0 then
   
   self.moveCoins:moveCoinsView(playerPlace,10,cc.p(bankerPlace:getPositionX(),bankerPlace:getPositionY())) 

  end

  if otherWinCoins > 0 then
  
   self.moveCoins:moveCoinsView(bankerPlace,10,cc.p(listViewPlace:getPositionX(),listViewPlace:getPositionY())) 

  elseif otherWinCoins < 0 then
   
   self.moveCoins:moveCoinsView(listViewPlace,10,cc.p(bankerPlace:getPositionX(),bankerPlace:getPositionY())) 

  end

end


function PlayingController:leaveTable()
  
  local temp = {}
  local msgbody = {}
  local body_t = json.encode(msgbody)
  temp["id"] = (ID_REQ + MSGID_SYS_LEAVE_TABLE)
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)

end

function PlayingController:onLeaveTable(id,body)
  
  
  if id == (ID_ACK + MSGID_SYS_LEAVE_TABLE) then
     
    if body["result"] == 0 then
      --self:quitGracefully(true)
    else
      
    end

  end


end

--金币免冲，破产补助
function PlayingController:applyFreeCharge()
  

  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if id  == (ID_ACK + MSGID_SYS_FREECHARGE)  then
       
       print("金币免冲，破产补助+++++++++++++返回消息")
       gameWebSocket:removeEventListener(ackHandle) 
       if body.result == 0 then
       
        local freeChargeCoins =  body.freeChargeCoins
        local coins = body.coins
        gamedata:setPlayerCoins(coins)
        print("+++++++++++++++++++++++++++申请破产补助成功！++++++++++++++++++++++++++++"..coins)
        toastview:show(localize.get("FreeCharge",#freeChargeCoins))
        self.playerInfo:setPlayerCoins(self.isBanker)

       else
         
        toastview:show(localize.getM("FREECHARGE",body.result))
                
       end

    end

  end

  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)
  local temp = {}
  local msgbody = {}
  local body_t = json.encode(msgbody)
  temp["id"] = (ID_REQ + MSGID_SYS_FREECHARGE)
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)


end



-- 优雅退出, 
-- @backToMenu 如果为true，将回退到主菜单；如果为false只向服务器请求离开桌子
function PlayingController:quitGracefully(backToMenu)

  self.isBack = backToMenu
  if self.isBack == true  then

    self:onExit()
    self:enterScene("MainMenuScene",{isAlreadyConnet=true})

  else
    --向服务器发送消息
    self:leaveTable()

  end

end

return PlayingController
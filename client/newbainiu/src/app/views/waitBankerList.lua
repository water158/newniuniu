--
-- Author: Han
-- Date: 2015-10-14 09:41:49
--
local waitBankerList  = class("waitBankerList",ql.mvc.BaseView)
local globalCommon = import("..common.GlobalCommon")
--定时器
local scheduler = require("framework.scheduler")
local parentself 
function waitBankerList:onCreate(args)

  parentself = args
  self.itemList = {}
  self.userIdList = {}
  self.nicknameList = {}
  self.CoinsList = {}
  self.ItemIdx = 0
  self.waitBankerList = cc.ui.UIListView.new{

    bgScale9 = true,
    viewRect = cc.rect(799,604,220,80),
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  } 
  self.waitBankerList:setBounceable(true)
  self.waitBankerList:setTouchEnabled(true)
  self.waitBankerList:setAlignment(cc.ui.UIListView.ALIGNMENT_LEFT)
  self.waitBankerList:isSideShow()
  self:addChild(self.waitBankerList)

end


--申请上庄
function waitBankerList:applyBanker()
  
  local ackHandle, errorHandle
  local function onReceivedAck(event)
  local msg_t = json.decode(event.message)
  local id = msg_t["id"] 
  local body = msg_t["body"]
  if id == ID_ACK+MSGID_JOIN_BANKER then
      
    gameWebSocket:removeEventListener(ackHandle)
    gameWebSocket:removeEventListener(errorHand)
    if body.result == 0 then
        
      parentself:findNodeByName("Image_apply"):setVisible(false)
      parentself:findNodeByName("Image_quene"):setVisible(true)

    else
         
      toastview:show(localize.getM("JOIN_BANKER",body.result))

    end

  end
  
end
  
  local function onReceivedError(event)
      
    gameWebSocket:removeEventListener(ackHandle)
    gameWebSocket:removeEventListener(errorHandle)
    if DEBUG > 0 then

      printInfo("连接服务器错误!")

    end
  
  end
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)
  errorHandle = gameWebSocket:addEventListener(gameWebSocket.ERROR_EVENT, onReceivedError) 
  local temp = {}
  local msgbody = {}
  local body_t = json.encode(msgbody)
  temp["id"] =   ID_REQ + MSGID_JOIN_BANKER
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)

end

function waitBankerList:LoadApplyBanker(body)

    local waitBankerList = body
    for i=1,#waitBankerList do 
    
      local nickname = waitBankerList[i].nick
      local coins =  waitBankerList[i].coins
      local userId = waitBankerList[i].userId

      self.ItemIdx = self.ItemIdx + 1

      local msg = globalCommon.GetShortName(nickname,10,10)
     
      local item = self.waitBankerList:newItem()
      table.insert(self.itemList,self.ItemIdx,item)
      table.insert(self.userIdList,self.ItemIdx,userId)
      table.insert(self.nicknameList,self.ItemIdx,nickname)
      local content = display.newNode()
      local textView = ccui.Text:create(msg,"Arial",20)
      textView:setAnchorPoint(cc.p(0,0.5)) 
      textView:setColor(cc.c3b(253, 210, 137))
      content:addChild(textView)  
      local coinView =  ccui.Text:create(globalCommon.changeDigitsForCoins(coins),"Arial",20)
      coinView:setAnchorPoint(cc.p(0,0.5))
      coinView:setColor(cc.c3b(255,255,0)) 
      coinView:setPosition(cc.p(120,0))
      table.insert(self.CoinsList,self.ItemIdx,coinView)
      content:addChild(coinView)
      item:addContent(content)
      local W = textView:getContentSize().width
      local Y = textView:getContentSize().height
      item:setItemSize(W,Y)
      self.waitBankerList:addItem(item)
      self.waitBankerList:reload()

  end

end


function waitBankerList:onApplyBanker(body)
  
      local waitBankerList = body
      local nickname = waitBankerList["nick"]
      local coins =  waitBankerList["coins"]
      local userId = waitBankerList["userId"]

      for i=1,#self.userIdList do
          
        if self.userIdList[i] == userId  then
           self.userIdList[i] = -1 
        end

      end

      self.ItemIdx = self.ItemIdx + 1

      local msg = globalCommon.GetShortName(nickname,10,10) 
      local item = self.waitBankerList:newItem()
      table.insert(self.itemList,self.ItemIdx,item)
      table.insert(self.userIdList,self.ItemIdx,userId)
      table.insert(self.nicknameList,self.ItemIdx,nickname)  
      local content = display.newNode()
      local textView = ccui.Text:create(msg,"Arial",20)
      textView:setAnchorPoint(cc.p(0,0.5)) 
      textView:setColor(cc.c3b(253, 210, 137))
      content:addChild(textView)
      local coinView =  ccui.Text:create(globalCommon.changeDigitsForCoins(coins),"Arial",20)
      coinView:setAnchorPoint(cc.p(0,0.5))
      coinView:setColor(cc.c3b(255,255,0)) 
      coinView:setPosition(cc.p(120,0))
      content:addChild(coinView)
      table.insert(self.CoinsList,self.ItemIdx,coinView)
      item:addContent(content)
      local W = textView:getContentSize().width
      local Y = textView:getContentSize().height
      item:setItemSize(W,Y)
      self.waitBankerList:addItem(item)
      scheduler.performWithDelayGlobal(function()
         
        self.waitBankerList:reload()
         
      end,0.2)
   
      --if self.waitBankerList:getScrollNode():getPositionY() <= 0 then
          --self.waitBankerList:getScrollNode():setPositionY(0)
      --end
  
end


--取消上庄
function waitBankerList:queueBanker()
  
  local temp = {}
  local msgbody = {}
  local body_t = json.encode(msgbody)
  temp["id"] =   ID_REQ + MSGID_QUIT_BANKER
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)


end

--处理取消上庄
function waitBankerList:onQueueBanker(id,body)
  
  local queueBankerId
  local oneselfBankerId

  if id == ID_NTF+ MSGID_CHANGE_BANKER then
     
    queueBankerId = body["newBankerId"]
    oneselfBankerId = body["oldBankerId"]
    if oneselfBankerId == gamedata:getUserId() then
      parentself:findNodeByName("Image_apply"):setVisible(true)
      parentself:findNodeByName("Image_quene"):setVisible(false)
    end

  elseif id == ID_NTF+MSGID_QUIT_BANKER  then 
    
    queueBankerId = body["userId"]
    if queueBankerId == gamedata:getUserId() then
   
      parentself:findNodeByName("Image_apply"):setVisible(true)
      parentself:findNodeByName("Image_quene"):setVisible(false)
    
    end
 
  end 
  
  for i=1,#self.userIdList do 
         
    if self.userIdList[i] == queueBankerId  then

          self.userIdList[i] = -1 
          self.waitBankerList:removeItem(self.itemList[i])
    end
    
  end

end

function waitBankerList:updateUserCoins(totalCoins)
  
  for i=1,#self.userIdList do
      
    if self.userIdList[i] == gamedata:getUserId() then
         
      local msg = globalCommon.changeDigitsForCoins(totalCoins)
      self.CoinsList[i]:setString(msg)

    end

  end

end

--处理金币变化
function waitBankerList:onMoneyChange(body)
	
	for i=1,#self.userIdList do
    	
    if self.userIdList[i] == body["userId"] then
         
      local msg = globalCommon.changeDigitsForCoins(body["coins"])
      self.CoinsList[i]:setString(msg)

    end

	end

end

return waitBankerList
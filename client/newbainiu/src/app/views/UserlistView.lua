--
-- Author: han
-- Date: 2015-09-15 18:56:30

local UserlistView  = class("UserlistView",ql.mvc.BaseView)
local globalCommon = import("..common.GlobalCommon")
local parentSelf 
function UserlistView:onCreate(args)
 
  self.ListView_userListMsg = cc.ui.UIListView.new{
    bgScale9 = true,
    viewRect = cc.rect(4,6,360,192),
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  } 
  self.ListView_userListMsg:setBounceable(true)
  self.ListView_userListMsg:setTouchEnabled(true)
  self.ListView_userListMsg:setAlignment(cc.ui.UIListView.ALIGNMENT_LEFT)
  self.ListView_userListMsg:isSideShow()
  self.ListView_userListMsg:onTouch(handler(self, self.touchListener))
  self.frontPage = 0
  self.pageIdx = 1
  self.moveIdx = 10
  self.itemList = {}
  self.userIdList = {}
  self.CoinsList = {}
  self.isRequest = true
  self:getRoot():addChild(self.ListView_userListMsg)

end


--发送玩家列表请求
function UserlistView:sendUserListMsg()

  local ackHandle
  local function onReceivedAck(event)

    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    if id == ID_ACK+MSGID_PLAYER_LIST then
      
      gameWebSocket:removeEventListener(ackHandle)
      if body.result == 0 then
    
        self:onUserListMsg(body)

      else

      end

    end
  
  end


  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

  if self.frontPage ~=  self.pageIdx then
    
    local temp = {}
    local msgbody = {}
    msgbody["page"] = self.pageIdx 
    local body_t = json.encode(msgbody)
    temp["id"] =  ID_REQ + MSGID_PLAYER_LIST
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1)

  else

    return 

  end
   
end


function UserlistView:onUserListMsg(body)

    local playerList = body["playerList"]
    self.frontPage  =  body["page"]

--系统消息
   for i=1,#playerList do
     
    local nickname = globalCommon.GetShortName(playerList[i].nick,8,10)
    local coins = globalCommon.changeDigits(playerList[i].coins)
    local userId = playerList[i].userId
    local item = self.ListView_userListMsg:newItem()
    table.insert(self.itemList,i,item)
    table.insert(self.userIdList,i,userId)
    local content = display.newNode()
    
     --昵称
    local nick = ccui.Text:create(nickname,"Arial",25)
    nick:setAnchorPoint(cc.p(0,0.5)) 
    nick:setColor(cc.c3b(253, 210, 137))
    content:addChild(nick)

    --金币Image
    local CoinsImage = display.newSprite("#Common/coins.png")
    CoinsImage:setAnchorPoint(cc.p(0,0.5))
    CoinsImage:setScale(0.6)
    local x = nick:getPositionX()+nick:getContentSize().width
    local y = nick:getPositionY()
    CoinsImage:setPosition(cc.p(160,0))
    content:addChild(CoinsImage)
   --金币Num
    local coinsNums = ccui.Text:create(coins,"Arial",25)
    table.insert(self.CoinsList,i,coinsNums)
    coinsNums:setColor(cc.c3b(253, 210, 137))
    coinsNums:setAnchorPoint(cc.p(0,0.5))
    coinsNums:setPosition(cc.p(CoinsImage:getPositionX()+CoinsImage:getBoundingBox().width*2,0))
    content:addChild(coinsNums)  
    item:addContent(content)
    local X = 360
    local Y = CoinsImage:getBoundingBox().height*1.3  --39
    item:setItemSize(X,Y)
    self.ListView_userListMsg:addItem(item)

  end
     self.ListView_userListMsg:reload()

  if self.ListView_userListMsg:getScrollNode():getPositionY() <= -390 then
     self.ListView_userListMsg:getScrollNode():setPositionY(-351)
  end

end

function UserlistView:renewalCoins(body)
  
  for i=1,#self.userIdList do
      
      if self.userIdList[i] == body["userId"] then
         
         local msg = body["coins"]
         self.CoinsList[i]:setString(msg)

      end

  end
  
end


function UserlistView:updateBankerCoins(bankerCoins)
  
  for i=1,table.getn(self.userIdList) do
  
    if self.userIdList[i] == gamedata:getNewBankerId() then
      self.CoinsList[i]:setString(bankerCoins)
    end
  
  end

end

function UserlistView:updateUserCoins(userCoins)
  
  for i=1,table.getn(self.userIdList)  do
  
    if self.userIdList[i] == gamedata:getUserId() then
      self.CoinsList[i]:setString(userCoins)
    end
  
  end

end

function UserlistView:touchListener(event)
  
  local listView = event.listView
    if "clicked" == event.name then
      
    elseif "moved" == event.name then

    elseif "ended" == event.name then

      if self.ListView_userListMsg:isItemInViewRect(self.moveIdx) then
         
         self.pageIdx = self.pageIdx+1
         self.moveIdx = self.moveIdx + 10 
         self:sendUserListMsg()
         self:onUserListMsg()
         
     else
        
      end
      
    else

    end

end


return UserlistView

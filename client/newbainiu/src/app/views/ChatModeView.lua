--
-- Author: Your Name
-- Date: 2015-09-15 18:56:30
--
--
-- Author: Your Name
-- Date: 2015-09-15 15:00:11
--
local ChatModeView  = class("ChatModeView",ql.mvc.BaseView)
--定时器
local scheduler = require("framework.scheduler")
local globalDefine = import("..common.GlobalDefine")

local parentSelf 
function ChatModeView:onCreate(args)
 
  parentself = args
  self.systemRemind = false
  self.ListView_chatMsg = cc.ui.UIListView.new{

    bgScale9 = true,
    viewRect = cc.rect(2,62,364,136),
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  } 
  self.ListView_chatMsg:setBounceable(true)
  self.ListView_chatMsg:setTouchEnabled(true)
  self.ListView_chatMsg:isSideShow()
  self:getRoot():addChild(self.ListView_chatMsg)
  self:initChatMode()

end


--初始化聊天消息
function ChatModeView:initChatMode()

  self:setOnViewClickedListener("Button_send", function()
    self:sendChatMsg()
  end,nil,"zoom",true)
 
end


--发送消息函数
function ChatModeView:sendChatMsg()

  self.TextField_msg = self:findNodeByName("TextField_msg")
    --print(self.TextField_msg)
  local msg = self.TextField_msg:getString()
  print(msg)
  if(msg == "") then
      return
  end
  local temp = {}
  local msgbody = {}
  msgbody["chat"] = msg
  local body_t = json.encode(msgbody)
  temp["id"] =  ID_REQ + MSGID_CHAT
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)
  self.TextField_msg:setString("")

end

--处理收到的聊天记录
function ChatModeView:onChatMsg(msgId,body)

  self.itemList = {}
  local msg 
  local nicknameMsg 
 
 --聊天
  if msgId == ID_NTF+MSGID_CHAT then
    
    self.systemRemind = false
    local nickname = body["nick"]
    --nicknameMsg = body["nick"]
    local chat = body["chat"]
    print("onChat nickname = "..nickname)
    print("onChat chat = "..chat)
    msg = nickname.."："..chat
--系统消息
  elseif msgId == ID_NTF+MSGID_CHAT_SYSTEM then
    
    self.systemRemind = true
    local sysText = "系统消息："
    local chat = body["tips"]
    msg = sysText..chat
  
  end

  for i=1,1 do

    local item = self.ListView_chatMsg:newItem()
    
    table.insert(self.itemList,i,item)
    --local content = display.newNode()
    local content = ccui.Layout:create() 
    local nickName = ccui.Text:create("系统消息","Arial",24)
    nickName:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT )
    nickName:setTextAreaSize(cc.size(360,0))
    nickName:ignoreContentAdaptWithSize(false)

    local textView = ccui.Text:create(msg,"Arial",24)
    textView:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textView:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    --textView:setAnchorPoint(cc.p(0,0.5))
    if self.systemRemind == false then 
      textView:setColor(cc.c3b(253, 210, 137))
    elseif self.systemRemind == true then
      textView:setColor(cc.c3b(0, 255, 255))
    end
    textView:setTextAreaSize(cc.size(360,0))
    textView:ignoreContentAdaptWithSize(false)
    content:addChild(textView)
    item:addContent(content)
    local W = 360
    local H = textView:getCustomSize().height 
    item:setItemSize(W,H)
    self.ListView_chatMsg:addItem(item)

  end
     self.ListView_chatMsg:reload()

    if self.ListView_chatMsg:getScrollNode():getPositionY() <= 0 then
       self.ListView_chatMsg:getScrollNode():setPositionY(0)
    end

end


return ChatModeView

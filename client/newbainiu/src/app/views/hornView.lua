--
-- Author: Your Name
-- Date: 2015-11-07 13:50:15
local hornView  = class("hornView",ql.mvc.BaseView)

local parentself
function hornView:onCreate(args)
  if args then
    parentself = args
  end
  self.harn_node = parentself:findNodeByName("horn_node")
  self._imgLabaBar =  self.harn_node:getChildByName("Image_announcement")
  self._scrolBar =   self._imgLabaBar:getChildByName("ScrollView_announcement")
  self._rollingText = {}
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
  self:initNoticeMode()

end

--初始化公告模块
function hornView:initNoticeMode()

 
  self:setOnViewClickedListener("Button_send", function()
      
      self:sendNotice()
  
  end,nil,"zoom",true)

end

--初始化聊天消息
function hornView:initChatMode()

  self:setOnViewClickedListener("Button_send", function()
    self:sendChatMsg()
  end,nil,"zoom",true)
 
end

--发送公告
function hornView:sendNotice()
	
	print("send msg ttst")
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
    temp["id"] =  ID_REQ + MSGID_SYS_BROADCAST
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    gameWebSocket:send(msg_t, 1)
    self.TextField_msg:setString("")	

end

--接收到公告通知
function hornView:onNoticeMsg(body)
	
	local horn_msg = body["nick"].."喊话："..body["chat"]
  print(horn_msg)
  print(type(self._rollingText))
  table.insert(self._rollingText,horn_msg)
  self:noticeHandler()
  self:onHornChatMsg(horn_msg)
    
end

--公告通知
function hornView:noticeHandler()

  if #self._rollingText <= 0 then
     self._imgLabaBar:setVisible(false)
     return
  end

  if self._txtIsAnimation then

    return
  end

  if not self._imgLabaBar:isVisible()then
     self._imgLabaBar:setOpacity(0)
     self._imgLabaBar:setVisible(true)
     self._imgLabaBar:runAction(cca.fadeIn(1))

  end
   
  local svTestContent =  self._scrolBar:getChildByName("svTestContent")

  local txtContent =  self._scrolBar:getChildByName("txtContent")

  local start_x = svTestContent:getContentSize().width
  local start_y = 281

  txtContent:setPosition(start_x,start_y)
  txtContent:setString(self._rollingText[1])

  local end_x = -(txtContent:getContentSize().width)
  self._txtIsAnimation = true
  txtContent:runAction(transition.sequence({
    cca.moveTo(10, end_x, start_y), 
    cca.callFunc(function()
      if #self._rollingText >= 1 then
         table.remove(self._rollingText,1)
      end
      self._txtIsAnimation = false
      self:noticeHandler()
  end)}))

end

function hornView:onHornChatMsg(horn_msg)

  local item = self.ListView_chatMsg:newItem()
  local content = ccui.Layout:create() 
  local textView = ccui.Text:create(horn_msg,"Arial",24)
  textView:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  textView:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
  textView:setColor(cc.c3b(253, 210, 137))
  textView:setTextAreaSize(cc.size(360,0))
  textView:ignoreContentAdaptWithSize(false)
  content:addChild(textView)
  item:addContent(content)
  local W = 360
  local H = textView:getCustomSize().height 
  item:setItemSize(W,H)
  self.ListView_chatMsg:addItem(item)
  self.ListView_chatMsg:reload()

  if self.ListView_chatMsg:getScrollNode():getPositionY() <= 0 then
    self.ListView_chatMsg:getScrollNode():setPositionY(0)
  end


end


return hornView
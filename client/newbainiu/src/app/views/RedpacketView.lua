--
-- Author: Han 
-- Date: 2015-09-01 10:45:25

local RedpacketView = class("RedpacketView", ql.mvc.BaseView)
local parentself

function RedpacketView:onCreate(args)
   
  if args then
    parentself = args
  end

end

function RedpacketView:redpackShow()

  self.randomPosList = parentself.pokerPos
  local randomNum = math.random(1,25)
  local randomPosX = self.randomPosList[randomNum].x 
  local randomPosY = self.randomPosList[randomNum].y
  local move = cc.MoveTo:create(0.01,cc.p(randomPosX,randomPosY))
  local callShow = cc.CallFunc:create(function ()
    
    self:findNodeByName("redPacket"):setVisible(true)
    self:setOnViewClickedListener("redPacket",function ()
      
      self:applyGrabRed()
      self:findNodeByName("redPacket"):setVisible(false)
    
                                                 end,nil,"none")
                                        end)

  local dey = cc.DelayTime:create(3)
  local callHide = cc.CallFunc:create(function ()
    
    self:findNodeByName("redPacket"):setVisible(false)

  end)
  local seq=transition.sequence({move,callShow,dey,callHide})
  self:findNodeByName("redPacket"):runAction(seq)

end

function RedpacketView:redpacketHide()
 
 self:findNodeByName("redPacket"):setVisible(false) 

end

--请求抢红包
function RedpacketView:applyGrabRed()
  
  local temp = {}
  local msgbody = {}
  local body_t = json.encode(msgbody)
  temp["id"] =   ID_REQ + MSGID_GIFT_GRAB
  temp["body"] = body_t
  local msg_t = json.encode(temp)
  gameWebSocket:send(msg_t, 1)

end


return RedpacketView 
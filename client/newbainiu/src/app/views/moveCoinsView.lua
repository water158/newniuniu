--
-- Author: Your Name
-- Date: 2015-11-09 15:28:16
--
local moveCoinsView  = class("moveCoinsView",ql.mvc.BaseView)
--全局控件
local globalCommon = import("..common.GlobalCommon")
--声音控件
local sounds = import("..data.sounds")
local parentself
function moveCoinsView:onCreate(args)

end

function moveCoinsView:moveCoinsView(placeNode,coinsNum,movePos)
  
  sounds.flyCoinsEffect()
  local coinsNum = 10
  local roomId = gamedata:getRoomId()
  if roomId == "101" then
   coinsNum = 20
  elseif roomId == "102" then
   coinsNum = 40
  elseif roomId == "103" then
   coinsNum = 60
  end

  for i=1,coinsNum do
    
    local nodeX,nodeY  = globalCommon.RandomCoins(placeNode)
  	local sp = cc.ui.UIImage.new("#Common/coins.png", {scale9 = true})
  	sp:setPosition(cc.p(nodeX,nodeY))
  	self:getRoot():addChild(sp,0,i)
    local bzier = cc.BezierTo:create((coinsNum+4-i)*0.1, {cc.p(nodeX,nodeY), cc.p(427,500), movePos})
  	local move = cc.MoveTo:create(i*0.08,cc.p(147,655))
  	local call = cc.CallFunc:create(function()
  		sp:removeFromParent()
  	end)
  	local seq = transition.sequence({bzier,call})
  	sp:runAction(seq)

  end

end

function moveCoinsView:dismissCoinsView()

end

return moveCoinsView
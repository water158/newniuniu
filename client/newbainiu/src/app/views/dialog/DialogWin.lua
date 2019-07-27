--
-- Author: Your Name
-- Date: 2015-11-11 20:04:24
--
local DialogWin  = class("DialogWin", ql.custom.DialogView)
local globalEffect = import("...common.GlobalEffect")
local sounds = import("...data.sounds")
local scheduler = require("framework.scheduler")
local playerData
function DialogWin:onCreate(args)
   
  if args then
     
    playerData = args.playerData

  end
  self:setDismissedOnTouchOutside(true)
  sounds.playSettlementEffect(true)
  local movedown  = cc.MoveTo:create(0.4,cc.p(643,446))
  local scaleTo = cc.ScaleTo:create(0.5,1.2)
  local seq = transition.sequence({movedown,scaleTo})
  self:findNodeByName("Image_CoinBag"):runAction(seq)
  local winText = self:findNodeByName("winText")
  globalEffect.popup_effect(winText) 
  globalEffect.rotateAction(self:findNodeByName("bgGuang"))
  self.NumTextDelay = scheduler.performWithDelayGlobal(function ()
    
    local winNumText = self:findNodeByName("winFontText")
    winNumText:setString("+"..playerData)
    globalEffect.popup_effect(winNumText) 
  
  end,1)
  
end

function DialogWin:onExit()
  
  if self.NumTextDelay then
   
   scheduler.unscheduleGlobal(self.NumTextDelay)

  end

end


return DialogWin
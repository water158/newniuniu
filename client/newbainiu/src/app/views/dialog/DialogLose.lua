--
-- Author: Your Name
-- Date: 2015-11-11 20:04:10
--
local DialogLose  = class("DialogLose", ql.custom.DialogView)
--全局动作特效控件
local globalEffect = import("...common.GlobalEffect")
local scheduler = require("framework.scheduler")
local sounds = import("...data.sounds")

local playerData
function DialogLose:onCreate(args)
     
  if args then
     
    playerData = args.playerData

  end
  self:setDismissedOnTouchOutside(true)
  sounds.playSettlementEffect(false)
  local loseText = self:findNodeByName("loseText")
  globalEffect.popup_effect(loseText) 
  self.NumTextDelay = scheduler.performWithDelayGlobal(function()
    
    local loseNumText = self:findNodeByName("loseFontText")
    loseNumText:setString(playerData)
    globalEffect.popup_effect(loseNumText) 

  end,1) 
    

end


function DialogLose:onExit()
  
  if self.NumTextDelay then
   
   scheduler.unscheduleGlobal(self.NumTextDelay)

  end

end

return DialogLose
--
-- Author: Your Name
-- Date: 2015-09-07 14:37:37


local DialogSettle = class("DialogSettle", ql.custom.DialogView)
--数字精灵控件
local setSingo = import("...common.SetSingo")
--声音控件
local sounds = import("...data.sounds")
--全局动作特效控件
local globalEffect = import("...common.GlobalEffect")

function DialogSettle:onCreate(args)
  
--下载数据
  local playerWin
  local bankerWin
  local isUserBanker
  if args then
    
     playerWin = args.playerWinData 
     bankerWin = args.bankerWinData 
     isUserBanker = args.isUserBanker 
  
  end
  self:setDismissedOnTouchOutside(true)
--显示
  self:showTotalResult(playerWin,bankerWin,isUserBanker)
  self:showCoinsResult(playerWin,bankerWin)



end

function DialogSettle:showTotalResult(playerWin,bankerWin,isUserBanker)
	
--------输赢情况
  local playerWinData
  local bankerWinData

  if isUserBanker == 0 then
  
    playerWinData = playerWin
    bankerWinData = bankerWin


  elseif isUserBanker == 1 then
    
    playerWinData = bankerWin 
    bankerWinData = bankerWin 
  
  end


  if playerWinData > 0 then

    local winSetttle = self:findNodeByName("win"):setVisible(true)
    self:findNodeByName("radiance"):setVisible(true)
    globalEffect.rotateAction(self:findNodeByName("radiance"))
    if winSetttle:isVisible()  == true then
      
       local winFlashing = self:findNodeByName("winFlashing")
       runTimelineAction(winFlashing,"settleAction.csb",true)
    
    end

    for i=1,5 do
  
      globalEffect.starMoveEffect(self:findNodeByName("xingxing"..i))
      globalEffect.rotateAction(self:findNodeByName("xingxing"..i))

    end  
     sounds.playSettlementEffect(true)

  elseif playerWinData == 0  then
    

    local nowinnolose =  self:findNodeByName("nowinnolose"):setVisible(true)
    self:findNodeByName("radiance"):setVisible(true)
    globalEffect.rotateAction(self:findNodeByName("radiance")) 
    --播放全屏动画
    

    if nowinnolose:isVisible() == true then

      print("播放全屏动画")
       local flatFlashing = self:findNodeByName("settleflashing")
       runTimelineAction(flatFlashing,"settleAction.csb",true)
    end
   
    for i=1,5 do

       self:findNodeByName("xingxing"..i):setVisible(false)
      --globalEffect.starMoveEffect(self:findNodeByName("xingxing"..i))
      --globalEffect.rotateAction(self:findNodeByName("xingxing"..i))

    end 
   
    sounds.playSettlementEffect(true)
  elseif playerWinData < 0   then

    self:findNodeByName("lose"):setVisible(true)

    for i=1,5 do
  
      self:findNodeByName("xingxing"..i):setVisible(false)

    end 
    sounds.playSettlementEffect(false)

  end



 end
  
function DialogSettle:showCoinsResult(playerWin,bankerWin)
  

  if playerWin >=0 then

   self:findNodeByName("benWin"):setString("+"..playerWin) 
  
  else
  
   self:findNodeByName("benLose"):setString(playerWin) 

  end

  if bankerWin >= 0 then
  
   self:findNodeByName("bankerWin"):setString("+"..bankerWin) 

  else
   
   self:findNodeByName("bankerLose"):setString(bankerWin) 

  end

end


return DialogSettle
--
-- Author: han
-- Date: 2015-08-22 19:31:13
--
--音乐类
local sounds ={}
local handler
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
function sounds.run(duration, callback,intertime)
    sounds._pause = false
    local function onTimer(dt)
        if sounds._pause then
            return
        end
        duration = duration - dt

        if DEBUG > 0 then
            printInfo("@倒计时%d秒", math.round(duration))
        end

        if duration <= 0 then
            scheduler.unscheduleGlobal(handler)
            callback({timeout=true, remains=0})
        else
            callback({timeout=false, remains=math.round(duration)})
        end
    end
    if handler then
        scheduler.unscheduleGlobal(handler)
    end
    handler = scheduler.scheduleGlobal(onTimer, intertime)
end


--播放背景音乐
function sounds.playBackgroundMusic(backMusicType)
  
  if backMusicType == "HALL" then
	 audio.playMusic("audio/HALL.mp3",true)
  elseif   backMusicType == "INGAME"  then 
   audio.playMusic("audio/INGAME.mp3",true)
  end

end

--停止播放背景音乐
function sounds.stopBackgroundMusic(isReleaseData)
  audio.stopMusic(isReleaseData)
end
--停止所有音效
function sounds.stopAllSounds()
  
  if handler then
    scheduler.unscheduleGlobal(handler)
  end
  audio.stopAllSounds()
end

--播放牌型音效
function sounds.playniuEffect(niuType)
	
  local niuEffectTable = {}
	for i=1,14 do
      
   niustr =  "audio/N_"..(i-1)..".mp3"
   table.insert(niuEffectTable,i,niustr) 
  end
  audio.playSound(niuEffectTable[niuType],false)

end

--发牌音效
function sounds.playDealPokerEffect()
  
  sounds.run(2.7,function(events)
    audio.playSound("audio/dealPoker.mp3",false) 
  end,0.3)

end

--停止发牌音效
function sounds.stopDealPokerEffect(handle)
  
  if handle ~= nil then
	
	audio.stopSound(handle)
  
  end

end

--开始下注
function sounds.beginBet()

  audio.playSound("audio/BeginBet.mp3", false)

end

--金币声音
function sounds.PlayDropCoinsEffect()

  audio.playSound("audio/audio_coins.mp3", false)

end
--开牌
function sounds.openCard()
  
  audio.playSound("audio/openCard.mp3",false)

end

--结算音效
function sounds.playSettlementEffect(isWin)

  if isWin == true then

    audio.playSound("audio/endwin.mp3",false)

  else

    audio.playSound("audio/endlost.mp3",false)

  end

end

--倒计时声音
function sounds.playCountdownEffect(timer)

  sounds.run(timer,function(events)
 
    audio.playSound("audio/second.mp3",false)  

  end,1)
 

end

function sounds.playCowEffect()
  
  audio.playSound("audio/cowsound.mp3",false)

end


--准备的音效
function sounds.prepareEffect()

  audio.playSound("audio/prepare.mp3",false)

end

--flyCoins
function sounds.flyCoinsEffect()
  
  audio.playSound("audio/moneyLots.mp3",false)
  
end

return sounds 
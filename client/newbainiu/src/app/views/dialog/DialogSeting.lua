--
-- Author: Your Name
-- Date: 2015-09-06 17:05:53
--
local DialogSeting = class("DialogSeting", ql.custom.DialogView)

function DialogSeting:onCreate(args)
  
    --self:setLocalZOrder(100)
	self:setOnViewClickedListener("exit", function() 
	    
		self:dismiss()
	end,nil,"zoom",true)
 
 --设置音乐
	local sliderMusic = self:findNodeByName("musicSlider")
	sliderMusic:setPercent(gamedata:get("music_vol", audio.getMusicVolume()) * 100)
	sliderMusic:addEventListener(function(sender, type)
		audio.setMusicVolume(sliderMusic:getPercent() / 100)
		gamedata:set("music_vol", audio.getMusicVolume())
		gamedata:save()
	end)
--设置音效
    local sliderSound = self:findNodeByName("soundSlider")
	sliderSound:setPercent(gamedata:get("sound_vol", audio.getSoundsVolume()) * 100)
	sliderSound:addEventListener(function(sender, type)
		audio.setSoundsVolume(sliderSound:getPercent() / 100)
		gamedata:set("sound_vol", audio.getSoundsVolume())
		gamedata:save()
	end)
--反馈
  	self:setOnViewClickedListener("couplebackButton", function() 
	    
	    openFeedbackPage()
		self:dismiss()

	end,nil,"zoom",true)

--帮助
   	self:setOnViewClickedListener("helpButton", function() 
	    
	   showDialog("DialogHelp")
	   self:dismiss()

	end,nil,"zoom",true)


end


return DialogSeting
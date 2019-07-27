--
-- Author:  Han 
-- Date: 2015-08-20 17:09:54

local LoadingController = class("LoadingController", ql.mvc.BaseController)
local scheduler = require("framework.scheduler")
local sounds = import("..data.sounds")
LoadingController._texList = 
{
	"bigImage/dialogbackground.png",
	"bigImage/hallBackground.jpg",
	"bigImage/light.png",
	"bigImage/loingBg.jpg",
	"bigImage/bglayer.jpg",
	"bigImage/bgGuan.png"

}
LoadingController._plistList = 
{
	"Common",
	"DialogHelp",
	"farmar",
	"loingUI",
	"newCommon",
	"MainMenuScene",
	"mainSceneP",
	"text",
	"card"

}
LoadingController._musicList =
{
	"audio/HALL.mp3",
	"audio/INGAME.mp3",
	"audio/audio_coins.mp3",
	"audio/endwin.mp3"
}

function LoadingController:onEnter()
	
	local bar = self:findNodeByName("LoadingBar")
	self._loadingBar = bar;
	self.tt = 0
    bar:setPercent(0)
	storage:load()
    audio.setMusicVolume(gamedata:get("music_vol", 0.5))
	audio.setSoundsVolume(gamedata:get("sound_vol", 0.5))
	local logoBliding = self:findNodeByName("Logo_1")
	-- 加载资源
	self:loadResource()

end

function LoadingController:loadResource()
	if DEBUG > 0 then
		printInfo("@加载资源")
	end

	if self._isLoadingResource then
		return
	end
	-- 加载资源
	self._isLoadingResource = true
	self._totalResourceCount = #LoadingController._texList+#LoadingController._plistList+#LoadingController._musicList
	self._currResourceIndex = 1
	self._updateHandle = scheduler.scheduleUpdateGlobal(handler(self, self.__onUpdate))
end

function LoadingController:__onUpdate(dt)

	local texCount = #LoadingController._texList
	local plistCount = #LoadingController._plistList
	local musicCount = #LoadingController._musicList

	if self._currResourceIndex <= texCount then -- 加载图片资源
		cc.Director:getInstance():getTextureCache():addImage(LoadingController._texList[self._currResourceIndex])
	elseif self._currResourceIndex <= texCount+plistCount then -- 加载plist资源
		local plist = LoadingController._plistList[self._currResourceIndex-texCount]
		display.addSpriteFrames(plist..".plist", plist..".png")
	elseif self._currResourceIndex <= texCount+plistCount+musicCount then -- 加载音乐
		audio.preloadMusic(LoadingController._musicList[self._currResourceIndex-texCount-plistCount])
	end
	
	if self._currResourceIndex <= self._totalResourceCount then
		self._loadingBar:setPercent(self._currResourceIndex*100/self._totalResourceCount)
		self._currResourceIndex = self._currResourceIndex + 1
	else
		scheduler.unscheduleGlobal(self._updateHandle)
		self._loadingBar:setPercent(100)
		self:enterMainScene()
	end

end
function LoadingController:onExit()
	LoadingController.super.onExit(self)
end

function LoadingController:enterMainScene()
	self:enterScene("MainMenuScene")
end


return LoadingController
--
-- Author: luffy 
-- Date: 2015-11-19 17:23:04
-- 抢庄

local GrabBankerController = class("GrabBankerController", ql.mvc.BaseController)
local scheduler = require("framework.scheduler")
local countdown = import("..utils.countdown")
local PlayerView = require("PlayerView")
local CalculationNiu = require("CalculationNiu")
require("..models.PokerController")

function GrabBankerController:onCreate(args)
	
	self:init()
end

--初始化
function GrabBankerController:init()
	local grabBanker = self:findNodeByName("grabBanker")

	--玩家信息
	playerInfo = {
		{x = 166  ,y = 70  ,type = "playerHorizontal.csd" ,position = 1},
		{x = 90   ,y = 360 ,type = "playerVertical.csd"	,position = 2},
		{x = 432  ,y = 628 ,type = "playerHorizontal.csd" ,position = 3},
		{x = 832  ,y = 628 ,type = "playerHorizontal.csd" ,position = 4},
		{x = 1185 ,y = 360 ,type = "playerVertical.csd"   ,position = 5}
	}

	self._players = {}
	for i = 1,#playerInfo do
		local player = PlayerView.new({controller=self,playerInfo=playerInfo[i],data={}})
		player:distributionPosition()
		player:setPosition(playerInfo[i].x,playerInfo[i].y)
		grabBanker:addChild(player)
		table.insert(self._players,player)
	end

	--初始化扑克牌UI
	self._pokers = {}
	for i = 1,PokerController.CARD_NEEDED do
		local poker = PokerView.new()
		poker:setVisible(false)
		table.insert(self._pokers,poker)
		self._players[pokerController:remainder(i,5)]:addPokerView(poker)
	end

	--下拉列表
	local imgList = self:findNodeByName("imgList")
	self:setOnViewClickedListener(imgList,function()

	end)

	--礼包效果
	local imgEffect = self:findNodeByName("imgEffect")
	imgEffect:runAction(cca.repeatForever(cca.rotateBy(5, 360)))

	--打开礼包
	local imgGift = self:findNodeByName("imgGift")
	self:setOnViewClickedListener(imgGift, function()

	end)

	--礼包倒计时
	local txtReward = self:findNodeByName("txtReward")
	local giftReceiveTime = 300
	self._giftCountdown = scheduler.scheduleGlobal(function()
    	giftReceiveTime = giftReceiveTime - 1
    	local min = giftReceiveTime / 60
    	local sec = giftReceiveTime % 60
    	if min < 10 then
    		min = "0"..min
    	end
    	if sec < 10 then
    		sec = "0"..sec
    	end
    	txtReward:setString(min..":"..sec)
    	if giftReceiveTime < 1 then
    		giftReceiveTime = 300
    	end
    end,1)

    --有牛,没牛按钮
    self._btnNotNiu = self:findNodeByName("btnNotNiu")
    self._btnHaveNiu = self:findNodeByName("btnHaveNiu")
    self._btnHaveNiu:setVisible(false)

    --是否抢牛按钮
    self._grabState = false
    self._pGrabBtn = self:findNodeByName("pGrabBtn")
    self._pGrabBtn:setVisible(false)
    local btnGrab = self:findNodeByName("btnGrab")
    self:setOnViewClickedListener(btnGrab, function()
    	self._pGrabBtn:setVisible(true)
    	self:stopCountDown()
    	self._grabState = true
	end)
	local btnNotGrab = self:findNodeByName("btnNotGrab")
	self:setOnViewClickedListener(btnNotGrab, function()
		self._pGrabBtn:setVisible(false)
		self:stopCountDown()
		self._grabState = false
	end)

	--倍数
	self._pMultiple = self:findNodeByName("pMultiple")
	self._pMultiple:setVisible(false)
	for i = 1,4 do
		local btnMultiple = self:findNodeByName("btnMultiple"..i)
		self:setOnViewClickedListener(btnMultiple, function()

		end)
	end

	self._countdown = self:findNodeByName("countdown")
	self._txtDec = self:findNodeByName("txtDec")
	self._imgClock = self:findNodeByName("imgClock")
	self._imgClock:setVisible(false)

	--休息时间
	self:restTimeHandler()
end

--休息时间处理
function GrabBankerController:restTimeHandler()
	self._imgClock:setVip(true)
	self._txtDec:setString(localize.get("calculation_countdown1"))
	self:startCountDown(self._countdown,10,function()

	end)
end

--播放游戏开始动画
function GrabBankerController:playStartAnimation()
	local startAnimation = self:findNodeByName("startAnimation")
	runTimelineAction(startAnimation, "cowAction.csb", true)
	self:startCountDown(self._countdown,3,function()
		
	end)
end

--发牌前四张牌
function GrabBankerController:dealHandler()
	self:startCountDown(self._countdown,10,function()
		
	end)

	--洗牌
	local allPoint = pokerController:randomPoint()

	--发牌
	for i = 1,#self._pokers do
		self._pokers[i]:setPokerPoint(allPoint[i])
		self._pokers[i]:changeCardFace(false)
	end
	for i = 1,#self._players do
		scheduler.performWithDelayGlobal(function()
			local x = CONFIG_SCREEN_WIDTH/2
			local y = CONFIG_SCREEN_HEIGHT/2
			self._players[i]:getSeveralPoker(x,y)
		end,0.3)
	end
end

--抢庄
function GrabBankerController:grabBankerHandler()
	self._txtDec:setString(localize.get("calculation_countdown2"))
	self._pGrabBtn:setVisible(true)
	self._pMultiple:setVisible(false)
	self:startCountDown(self._countdown,10,function()
		self._pGrabBtn:setVisible(false)
		self._grabState = false
	end)
end

--抢庄动画
function 

--倍数选择
function GrabBankerController:selectMultiple()
	self._pGrabBtn:setVisible(false)
	self._pMultiple:setVisible(true)
	self:startCountDown(self._countdown,10,function()
		self._pMultiple:setVisible(false)
	end)
end

--是否有牛
function GrabBankerController:whetherHaveNiu(bool)
	if bool then
		self._btnNotNiu:setVisible(false)
		self._btnHaveNiu:setVisible(true)
	else
		self._btnNotNiu:setVisible(true)
		self._btnHaveNiu:setVisible(false)
	end
end

-- 启动倒计时
function GameBettingController:startCountDown(label, duration,callBack,backTime)
	if not backTime then
		backTime = 0
	end

	label:setString(duration)
	countdown.run(duration, function(event)
		if event.remains <= 3 then
			local action = cc.CSLoader:createTimeline("Timer.csb")
			label:getParent():runAction(action)
			action:gotoFrameAndPlay(0, false)
			if event.remains <= backTime then
				callBack()
			end
		end
		label:setString(event.remains)
	end)
end

-- 停止计时
function GameBettingController:stopCountDown()
	countdown.stop()
end

function GrabBankerController:onExit()
	if self._giftCountdown then
		scheduler.unscheduleGlobal(self._giftCountdown)
	end
end

return GrabBankerController
--
-- Author: luffy 
-- Date: 2015-11-24 14:04:04
-- 玩家头像

local PlayerView  = class("PlayerView",ql.mvc.BaseView)

function PlayerView:ctor(args)
	self._data = args.data
	self._playerPosition = args.playerInfo.position
	self._controller = args.controller
	local csbname = args.playerInfo.type

	-- 设置场景名称
	self.name = self.class.__cname or "<unknown-view>"
	if self._node then
        self._node:removeSelf()
        self._node = nil
	end
	if cc.FileUtils:getInstance():isFileExist(csbname) then
	   	self._node = cc.uiloader:load(csbname)
	   	assert(self._node, string.format("BaseView:onCreate() - load resouce node from file \"%s\" failed", csbname))
	    self:addChild(self._node)
	end
	self:setAnchorPoint(cc.p(0.5, 0.5))
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	if self.onCreate then self:onCreate(args) end
end

function PlayerView:onCreate(args)
	self:initPlayerUI()
end

--给UI赋值
function PlayerView:initPlayerUI()
	local imgHead = self:findNodeByName("imgHead")
	--imgHead:loadTexture("",ccui.TextureResType.plistType)

	local txtName = self:findNodeByName("txtName")
	--txtName:setString("")

	local txtCoins = self:findNodeByName("txtCoins")
	--txtCoins:setString(string.formatTenThousand())

	self._imgZhuang = self:findNodeByName("imgZhuang")
	self._imgZhuang:setVisible(false)

	self._multiple = self:findNodeByName("multiple")
	self._multiple:setVisible(false)

	self:chatHandler()

	--扑克摆放位置
	self:calculationPosition()
end

--自身位置计算
function PlayerView:calculationPosition()
	local x = self:getPositionX()
	local y = self:getPositionY()
	local width = self:getContentSize().width
	local height = self:getContentSize().height

	if self._playerPosition == 1 then
		self._pokerX = x + width + 30
		self._pokerY = y
	elseif self._playerPosition = 2 then
		self._pokerX = x + width + 50
		self._pokerY = y
	elseif self._playerPosition == 3 or self._playerPosition == 4 then
		self._pokerX = x + 10
		self._pokerY = y - s_height - 20
	elseif self._playerPosition == 5 then
		self._pokerX = x - width - 50
		self._pokerY = y
	end
end

--添加扑克
function PlayerView:addPokerView(poker)
	self._controller:getView():addChild(poker)

	if not self._pokers then
		self._pokers = {}
	end
	table.insert(self._pokers,poker)
end

--扑克添加响应事件
function PlayerView:pokerSelected()
	self:setOnViewClickedListener(poker,function()
		if not poker.state then
			poker:setPositionY(50)
			poker.state = true
		else
			poker:setPositionY(0)
			poker.state = false
		end
		event:dispatch(EVENT_NOTICE_SELECT_POKER,{point = poker:getPokerPoint()})
	end)
end

--获取多张扑克动画
function PlayerView:getSeveralPoker(x,y)
	for i = 1,#self._pokers - 1 do
		self._pokers[i]:setPosition(x,y)
		self._pokers[i]:setVisible(true)
		if self._playerPosition == 1 then
			x = x + poker:getContentSize().width
		else
			x = x + 30
		end
		self:dealAnimation(self._pokers[i])
	end
end

--获取单张扑克动画
function PlayerView:getSinglePoker(x,y)
	self._pokers[#self._pokers]:setPosition(x,y)
	self._pokers[#self._pokers]:setVisible(true)
	self:dealAnimation(self._pokers[#self._pokers])
end

--发牌动画
function PlayerView:dealAnimation(poker)
	transition.moveTo(pokerList, {time=2, x=self._pokerX, y=self._pokerY, 
		easing = "backInOut",
		onComplete = function()
			self:flopAnimation(poker)
		end
	})
	if self._playerPosition == 1 then
		self._pokerX = self._pokerX + poker:getContentSize().width
	else
		self._pokerX = self._pokerX + 30
	end
end

--翻牌动画
function PlayerView:flopAnimation(poker)
	poker:runAction(transition.sequence({
		cc.RotateBy:create(0.5,90),
		cca.callFunc(function()
			poker:changeCardFace(true)
		end),
		cc.RotateBy:create(0.5,90)
	}))
end

--自动选牌
function PlayerView:automaticSelection(data)
	for key,value in pairs(data) do
		self._pokers[value]:setPositionY(50)
		self._pokers[value].state = false
	end
end

--屏幕其他地方双击使牌全部落下
function PlayerView:doubleClickFall()
	if not self._clickTime then
		self._clickTime = os.clock()
	elseif os.clock() - self._clickTime > 0.3 then
		for i = 1,#self._pokers do
			self._pokers[i]:setPositionY(0)
			self._pokers[i].state = false
		end
		self._clickTime = nil
	end
end

--聊天功能
function PlayerView:chatHandler()
	--打开聊天功能
	local imgChat = self:findNodeByName("imgChat")
	if not imgChat then
		return
	end
	if playerPosition == 1 then
		imgChat:setVisible(true)
	else
		imgChat:setVisible(false)
	end
	self:setOnViewClickedListener(imgChat,function()
		
	end)
end

--是否是庄
function PlayerView:whetherIsZhuang(bool)
	self._imgChat:setVisible(bool)
end

--分配位置
function PlayerView:distributionPosition()

	if self._playerPosition == 1 then
		self._multiple:setPosition(32, 90)
	elseif self._playerPosition == 2 then
		self._multiple:setPosition(12, 123)
	elseif self._playerPosition == 3 then
		self._multiple:setPosition(202, 36)
	elseif self._playerPosition == 4 then
		self._multiple:setPosition(202, -23)
	elseif self._playerPosition == 5 then
		self._multiple:setPosition(202, -117)
	end

end

--是否显示倍数
function PlayerView:whetherShowMultiple(bool)
	self._multiple:setVisible(bool)
end

return PlayerView
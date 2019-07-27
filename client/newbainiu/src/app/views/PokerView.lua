--
-- Author: luffy 
-- Date: 2015-11-19 17:23:04
-- 牌UI

local PokerView  = class("PokerView",ql.mvc.BaseView)

function PokerView:onCreate(args)
	self._pokerPointImg = self:findNodeByName("pokerPoint")
	self._floret = self:findNodeByName("floret")
	self._bigFlower = self:findNodeByName("bigFlower")
	self._pokerBg = self:findNodeByName("pokerBg")
end

--设置牌点
function PokerView:setPokerPoint(pokerNum)
	self._pokerPoint = 0
	self._pokerColor = 0
	if pokerNum % 4 > 0 then
		self._pokerPoint = pokerNum / 4 + 1
		self._pokerColor = pokerNum % 4 
	else
		self._pokerPoint = pokerNum / 4
		self._pokerColor = 4
	end

	if self._pokerColor % 2 == 0 then
		self._pokerPointImg:loadTexture("pokers/b"..self._pokerPoint , ccui.TextureResType.plistType)
	else
		self._pokerPointImg:loadTexture("pokers/r"..self._pokerPoint , ccui.TextureResType.plistType)
	end
	self._floret:loadTexture("pokers/floret"..self._pokerColor , ccui.TextureResType.plistType)
	self._bigFlower:loadTexture("pokers/flower"..self._pokerColor , ccui.TextureResType.plistType)
	self:changeCardFace(false)
end

--获取牌点
function PokerView:getPokerPoint()
	if self._pokerPoint > PokerController.MAX_POINT then
		return PokerController.MAX_POINT
	end
	return self._pokerPoint
end

--换牌面
function PokerView:changeCardFace(bool)
	self._pokerPointImg:setVisible(bool)
	self._floret:setVisible(bool)
	self._bigFlower:setVisible(bool)
	if not bool then
		self._pokerBg:loadTexture("mainSceneP/reverse.png",ccui.TextureResType.plistType)
	else
		self._pokerBg:loadTexture("card/card_front.png",ccui.TextureResType.plistType)
	end
end

--获取颜色
function PokerView:getPokerColor()
	return self._pokerColor
end

return PokerView
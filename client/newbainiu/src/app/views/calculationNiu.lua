--
-- Author: luffy 
-- Date: 2015-11-19 17:23:04
-- 玩家头像

local CalculationNiu  = class("CalculationNiu",ql.mvc.BaseView)

local scheduler = require("framework.scheduler")

function CalculationNiu:onCreate(args)
	self._num1 = self:findNodeByName("num1")
	self._num2 = self:findNodeByName("num2")
	self._num3 = self:findNodeByName("num3")
	self._result = self:findNodeByName("result")
	self:setWhetherShowNumber(false)

	self._bubble = self:findNodeByName("bubble")
	self._bubble:setVisible(false)

	self._txtDec = self:findNodeByName("txtDec")

	self._btnOff = self:findNodeByName("btnOff")

	--点击打开Tip
	local imgRobot = self:findNodeByName("imgRobot")
	self:setOnViewClickedListener(imgRobot,function()
		if self._bubble:isVisible() then
			self._bubble:setVip(false)
		else
			self._bubble:setVip(true)
			self._bubble:setContentSize(cc.size(411,127))
			self._txtDec:setString(localize.get("calculation_niu_tip1"))
			self._btnOff:setVisible(true)
		end
	end)

	--是否开启自动算牌
	self:setOnViewClickedListener(self._btnOff,function()
		if not self._OffState then
			self._OffState = true
			self._btnOff:setString(localize.get("calculation_niu_state2"))
			event:dispatch(EVENT_NOTICE_OPENSTATE)
		else
			self._OffState = false
			self._btnOff:setString(localize.get("calculation_niu_state1"))
		end
	end)
end

--显示泡泡提示
function CalculationNiu:showTip()
	self._bubble:setVip(true)
	self._bubble:setContentSize(cc.size(560,127))
	self._txtDec:setString(localize.get("calculation_niu_tip2"))
	self._btnOff:setVisible(false)

	scheduler.performWithDelayGlobal(function()
		self._bubble:setVip(false)
	end,3)
end

--关闭泡泡
function CalculationNiu:closeTip()
	self._bubble:setVip(false)
end

--获取状态是否开启
function CalculationNiu:getOffState()
	return self._OffState
end

--设置计算数
function CalculationNiu:setCalculation(n1,n2,n3)
	self._num1:setString(n1)
	self._num2:setString(n2)
	self._num3:setString(n3)
	self._result:setString(n1+n2+n3)

	self:setWhetherShowNumber(true)
end

--设置是否显示计算数
function CalculationNiu:setWhetherShowNumber(bool)
	self._num1:setVisible(bool)
	self._num2:setVisible(bool)
	self._num3:setVisible(bool)
	self._result:setVisible(bool)
end

return CalculationNiu
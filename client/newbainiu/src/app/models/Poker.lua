--
-- Author: Han
-- Date: 2015-08-18  15:55:44
--
local Poker = class("Poker",  ql.mvc.BaseModel)

-- 常量
POKER_COUNT 	  = 52
POKER_POINT_COUNT = 15
POKER_COLOR_COUNT = 4

-- 牌点
POKER_UNKNOWN = -1 -- 非名牌
POKER_3 	= 0
POKER_4 	= 1
POKER_5 	= 2
POKER_6 	= 3
POKER_7 	= 4
POKER_8 	= 5
POKER_9 	= 6
POKER_10 	= 7
POKER_J 	= 8
POKER_Q 	= 9
POKER_K 	= 10
POKER_A 	= 11
POKER_2 	= 12

-- 花色
POKER_COLOR_SPADE	= 3 -- 黑桃
POKER_COLOR_HEART 	= 2 -- 红桃
POKER_COLOR_CLUB 	= 1 -- 梅花
POKER_COLOR_DIAMOND = 0 -- 方片

-- 定义属性
Poker.schema = clone(cc.mvc.ModelBase.schema)
Poker.schema["value"] = {"number", 0} -- 数值类型，没有默认值
Poker.schema["index"] = {"number", 1} -- 位置索引

-- 事件
Poker.EVENT_START 		= "start"
Poker.EVENT_SELECT 		= "select"
Poker.EVENT_UNSELECT	= "unselect"
Poker.EVENT_PLAY		= "play"
Poker.EVENT_REMOVE		= "remove"
Poker.EVENT_CHANGE_VALUE = "changevalue"

-- 状态
Poker.STATE_IDLE 		= "idle"
Poker.STATE_SELECTED 	= "selected"
Poker.STATE_PLAYED		= "played"
Poker.STATE_REMOVED		= "removed"

-- 从牌值获取牌点
function Poker.getPokerPoint(pokerValue)
	return math.floor(pokerValue / POKER_COLOR_COUNT)
end

-- 从牌值获取花色
function Poker.getPokerColor(pokerValue)
	return pokerValue % POKER_COLOR_COUNT
end

--[[ 
	比较两个牌值的牌点 
	@return：
		1，pokerValue1 > pokerValue2；
		0：equal; 
		-1，pokerValue1 < pokerValue2
]]
function Poker.comparePokerPoint(pokerValue1, pokerValue2)
	local point1 = Poker.getPokerPoint(pokerValue1)
	local point2 = Poker.getPokerPoint(pokerValue2)
	if point1 > point2 then
		return 1
	elseif point1 == point2 then
		return 0
	else
		return -1
	end
end

function Poker:onCreate()
	self:setStateMachineEnable(true)

	-- 分解牌值
	if self.value_ then
		self.point_ = Poker.getPokerPoint(self.value_)
		self.color_ = Poker.getPokerColor(self.value_)
	end

end

-- @override
function Poker:onSetFSMEvents(events)
	self:addFSMEvent(events, "start", "none", "idle")
	self:addFSMEvent(events, "select", "idle", "selected")
	self:addFSMEvent(events, "unselect", "selected", "idle")
    self:addFSMEvent(events, "play", {"idle", "unselect", "selected", "played"}, "played") -- 可能会出现已经打出牌的同时掉线
	self:addFSMEvent(events, "remove", "played", "removed")
end

-- @override
function Poker:onSetFSMCallbacks(callbacks)
	self:addFSMCallback(callbacks, "onselect", self.onSelect_)
	self:addFSMCallback(callbacks, "onunselect", self.onUnselect_)
	self:addFSMCallback(callbacks, "onplay", self.onPlay_)
	self:addFSMCallback(callbacks, "onremove", self.onRemove_)
end

--[[
	服务器返回的值是0-53代表所有牌值，
	此方法将牌值分解成牌点和花色。
	@value: 0-53
]]
function Poker:setValue(value)
	if self.value_ ~= value then
		self.value_ = value
		if value ~= POKER_UNKNOWN then
			self.point_ = Poker.getPokerPoint(value)
			self.color_ = Poker.getPokerColor(value)
		end
		self:dispatchEvent({name=Poker.EVENT_CHANGE_VALUE, value=value})
	end
end

-- 获取牌值
function Poker:getValue()
	return self.value_
end

-- 获取点数
function Poker:getPoint()
	return self.point_
end

-- 获取位置
function Poker:getIndex()
	return self.index_
end

-- 获取花色
function Poker:getColor()
	return self.color_
end

-- 换位置
function Poker:setIndex(index)
	self.index_ = index
end

-- 是否被选中
function Poker:isSelected()
	return self:isState(Poker.STATE_SELECTED)
end

function Poker:onSelect_(event)
	printf("@选择扑克, value=%d, point=%d, color=%d", self.value_, self.point_, self.color_)
	self:dispatchEvent({name = Poker.EVENT_SELECT})
end

function Poker:onUnselect_(event)
	printf("@取消选择扑克, value=%d, point=%d, color=%d", self.value_, self.point_, self.color_)
	self:dispatchEvent({name = Poker.EVENT_UNSELECT})
end

function Poker:onPlay_(event)
	printf("@打出扑克, value=%d, point=%d, color=%d", self.value_, self.point_, self.color_)
	self:dispatchEvent({name = Poker.EVENT_PLAY})
end

function Poker:onRemove_(event)
	printf("@移除扑克, value=%d, point=%d, color=%d", self.value_, self.point_, self.color_)
	self:dispatchEvent({name = Poker.EVENT_REMOVE})
end

return Poker
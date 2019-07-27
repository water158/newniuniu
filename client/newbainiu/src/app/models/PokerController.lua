--
-- Author: luffy 
-- Date: 2015-11-20 17:23:04
-- 扑克控制器

local PokerController = class("PokerController", ql.mvc.BaseModel)

PokerController.CARD_TOTAL = 52
PokerController.CARD_NEEDED = 25
PokerController.MAX_POINT = 10

function PokerController:onCreate()
	self._pokerPoints = {}
	for i = 1,PokerController.CARD_TOTAL do
		table.insert(self._pokerPoints,i)
	end
end

--洗牌
function PokerController:randomPoint()
	local tem = 0
	for i = 1,#self._pokerPoints do
		local index = math.random(0,51) % (#self._pokerPoints - i) + i
		if index ~= i then
			tem = self._pokerPoints[i]
			self._pokerPoints[i] = self._pokerPoints[index]
			self._pokerPoints[index] = tem
		end
	end

	return self._pokerPoints
end

--取余
function PokerController:remainder(n1,n2)
	if n1 % n2 == 0 then
		return n2
	end
	return n1 % n2
end

--计算是否有牛
function PokerController:bullfightAlgorithm(pokers)
	for x = 1,3 do
		for y = x + 1,4 do
			for z = y + 1,5 do
				if pokers[x]:getPokerPoint() + pokers[y]:getPokerPoint() 
					+ pokers[z]:getPokerPoint() % PokerController.MAX_POINT == 0 then
					return {x = x,y = y,z = z}
				end
			end
		end
	end
	return nil
end

--计算是牛几
function PokerController:calculationNumber(pokers,data)
	local temp = 0
	for i = 1,#pokers do
		if i ~= data.x and i ~= data.y and i ~= data.z then
			temp = temp + self:getPokerPoint(i)
		end
	end

	return temp % PokerController.MAX_POINT
end

if not pokerController then
	pokerController = PokerController.new()
end

return PokerController
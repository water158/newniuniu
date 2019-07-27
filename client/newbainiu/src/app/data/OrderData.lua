



local OrderData = class("OrderData", ql.mvc.BaseData)

-- 增加内存未发货订单
function OrderData:addMemoryUndeliveredOrder(orderId)
	if self._orders == nil then
		self._orders = self:getUndeliveredOrders()
	end
	table.insert(self._orders,orderId)
end

-- 删除内存未发货订单
function OrderData:removeMemoryUndeliveredOrder(orderId)
	if self._orders == nil then
		return
	end
	table.removebyvalue(self._orders, orderId, true)
end

--获取内存未发货订单
function OrderData:getMemoryUndeliveredOrder()
	if self._orders == nil then
		self._orders = self:getUndeliveredOrders()
	end
	return self._orders
end

-- 增加未发货订单
function OrderData:addUndeliveredOrder(orderId)
	if not self:hasOrder(orderId) then
		local orders = (self:get("orders") or {})
		table.insert(orders, orderId)
		self:set("orders", orders)
		self:save()
	end
end

-- 是否存在订单
function OrderData:hasOrder(orderId)
	local orders = self:get("orders")
	if orders then
		if table.indexof(orders, orderId) then
			return true
		end
	end
	return false
end

-- 移除未发货订单
function OrderData:removeUndeliveredOrder(orderId)
	local orders = self:get("orders")
	if orders then
		table.removebyvalue(orders, orderId, true)
		self:set("orders", orders)
		self:save()
	end
end

function OrderData:getUndeliveredOrders()
	return clone(self:get("orders") or {})
end

function OrderData:getUndeliveredOrderCount()
	return #(self:get("orders") or {})
end

if not orderdata then
	orderdata = OrderData.new()
end
return OrderData
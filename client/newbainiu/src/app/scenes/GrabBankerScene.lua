--
-- Author: luffy 
-- Date: 2015-11-19 17:23:04
-- 抢庄场景

local GrabBankerScene = class("GrabBankerScene", ql.mvc.BaseScene)

function GrabBankerScene:onCreate(args)
	self:bindController("GrabBankerController",args)
end

return GrabBankerScene
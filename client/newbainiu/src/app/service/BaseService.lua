--
-- Author: Carl
-- Date: 2015-05-06 19:39:31
--
--[[
	网络访问服务基类
]]
local BaseService = class("BaseService")

function BaseService:ctor(args)
	
	if self.onCreate then self:onCreate(args) 

	end

end

return BaseService
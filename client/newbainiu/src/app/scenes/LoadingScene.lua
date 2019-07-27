--
-- Author: Han 
-- Date: 2015-04-21 17:12:04
--加载场景

local LoadingScene = class("LoadingScene", ql.mvc.BaseScene)

function LoadingScene:onCreate(args)
	
	self:bindController("LoadingController",args)

end

return LoadingScene
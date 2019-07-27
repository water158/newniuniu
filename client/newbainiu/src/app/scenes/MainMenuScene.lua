--
-- Author: Carl
-- Date: 2015-04-21 16:27:46
--主要按钮的场景

local MainMenuScene = class("MainMenuScene", ql.mvc.BaseScene)

function MainMenuScene:onCreate(args)
	
	self:bindController("MainMenuController",args)

end

return MainMenuScene
				
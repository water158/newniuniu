--
-- Author: Your Name
-- Date: 2015-09-10 16:52:20
--
local DialogExit  = class("DialogExit", ql.custom.DialogView)

function DialogExit:onCreate(args)

--退出该界面
	self:setOnViewClickedListener("exit", function()
      self:dismiss()
  end, nil, "zoom",true)
--退出游戏
	self:setOnViewClickedListener("ensure", function()
      
      gamedata:setLogining(false)     
      cc.Director:sharedDirector():endToLua()

	end, nil, "zoom",true)

--取消
	self:setOnViewClickedListener("cancel", function()
      self:dismiss()
  end, nil, "zoom",true)	

end

return DialogExit
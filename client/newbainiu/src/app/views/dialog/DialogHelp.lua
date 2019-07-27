--
-- Author: Your Name
-- Date: 2015-09-11 10:18:10
--
local DialogHelp   = class("DialogHelp", ql.custom.DialogView)

function DialogHelp:onCreate(args)
  
  self:setOnViewClickedListener("exit", function() 
	self:dismiss()
  end,nil,"zoom",true) 
    
end

return DialogHelp
--
-- Author: Your Name
-- Date: 2015-09-11 16:03:26
--
local DialogPrepaidRecords = class("DialogPrepaidRecords", ql.custom.DialogView)

local parentself
function DialogPrepaidRecords:onCreate(args)
    
   if args then

    parentself = args.parent

  end
  
	self:setOnViewClickedListener("exit", function() 

	   parentself:showDialog("DialogPersonalInfo")
	   self:dismiss()

	end,nil,"zoom",true)

end


return DialogPrepaidRecords
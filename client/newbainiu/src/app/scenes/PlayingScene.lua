--
-- Author: Carl
-- Date: 2015-04-30 10:39:07
--

local PlayingScene = class("PlayingScene", ql.mvc.BaseScene)

function PlayingScene:onCreate(args)
 
   self:bindController("PlayingController", args)
 
end


return PlayingScene
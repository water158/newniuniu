
-- Author: Your Han 
-- Date: 2015-08-31 19:39:58

local bankerInfoView = class("bankerInfoView",ql.mvc.BaseView)
--全局控件
local globalCommon = import("..common.GlobalCommon")
--初始化函数
local parentself

function bankerInfoView:ctor(parent)
 
  parentself = parent
  self.bankerTimes = 0

end

--设置昵称
function bankerInfoView:setBankerNickName()

  parentself:findNodeByName("bankerNickname"):setString(gamedata:getBankerNickname())

end

function bankerInfoView:setBankerAvatar()
  
  parentself:findNodeByName("bankerAvatar"):loadTexture("Common/avatar_"..gamedata:getBankerAvatar()..".png",ccui.TextureResType.plistType)

end

function bankerInfoView:setBankerCoins()

  parentself:findNodeByName("bankerCoins"):setString(gamedata:getBankerCoins())

end

return bankerInfoView
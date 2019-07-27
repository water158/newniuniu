--
-- Author: Your Han 
-- Date: 2015-08-31 19:39:58

local playerInfoView = class("playerInfoView",ql.mvc.BaseView)

--初始化函数
local parentself
function playerInfoView:ctor(parent)
 
 --传来父类指针
	parentself = parent

end

--得到数据
function playerInfoView:getPlayerInfo(getPlayerInfo)

	if getPlayerInfo ~= nil then	
	
		local playerInfo = getPlayerInfo
 		self:initView(playerInfo)

	else

		return 

	end

end

--显示
function playerInfoView:initView(information)
 
	local playerMsg = information
	parentself:findNodeByName("playerNickname"):setString(playerMsg["nickname"])


end

function playerInfoView:isPlayerBanker(isShow)

	parentself:findNodeByName("playerAvatar"):setVisible(isShow)
	parentself:findNodeByName("playerNickname"):setVisible(isShow)
	parentself:findNodeByName("playerCoinIcon"):setVisible(isShow)
	parentself:findNodeByName("playerCoins"):setVisible(isShow)
	parentself:findNodeByName("miangameplus"):setVisible(isShow)	

end

--设置昵称
function playerInfoView:setPlayerNickName(isUserBanker)

	if isUserBanker == false  then
		parentself:findNodeByName("playerNickname"):setString(gamedata:getPlayerNickname())
	else
        parentself:findNodeByName("bankerNickname"):setString(gamedata:getPlayerNickname())
        parentself:findNodeByName("playerNickname"):setString(gamedata:getPlayerNickname())
	end

end

--设置头像
function playerInfoView:setPlayerAvatar(isUserBanker)
    
   if  isUserBanker == false then
	parentself:findNodeByName("playerAvatar"):loadTexture("Common/avatar_"..gamedata:getPlayerAvatar()..".png",ccui.TextureResType.plistType)
   else

   	parentself:findNodeByName("playerAvatar"):loadTexture("Common/avatar_"..gamedata:getPlayerAvatar()..".png",ccui.TextureResType.plistType)
    parentself:findNodeByName("bankerAvatar"):loadTexture("Common/avatar_"..gamedata:getPlayerAvatar()..".png",ccui.TextureResType.plistType)
   end

end

--设置金币额
function playerInfoView:setPlayerCoins(isUserBanker)
    
    if isUserBanker == false then
		parentself:findNodeByName("playerCoins"):setString(gamedata:getPlayerCoins())
    else
    	parentself:findNodeByName("playerCoins"):setString(gamedata:getPlayerCoins())
        parentself:findNodeByName("bankerCoins"):setString(gamedata:getPlayerCoins())
    end

end

return playerInfoView



local GameData = class("GameData", ql.mvc.BaseData)
--全局控件
local globalCommon = import("..common.GlobalCommon")
function GameData:setHallHost(host)
	self:set("hallhost", host)
	self:save()
end

function GameData:getHallHost()
	return self:get("hallhost")
end

function GameData:setAcountName(acountName)
	self:set("acountName", acountName)
	self:save()
end

function GameData:getAcountName()
	return self:get("acountName")
end

function GameData:setUserId(id)
	self:set("userid", id)
	self:save()
end

function GameData:getUserId()
	return self:get("userid")
end

function GameData:setNewBankerId(BankerId)
 	self:set("BankerId", BankerId)
	self:save()
end

function GameData:getNewBankerId()
	return self:get("BankerId")
end


function GameData:setRoomId(roomid)
    
    self:set("roomid", roomid)
 	self:save()

end

function GameData:getRoomId()
	
	return self:get("roomid")
end

function GameData:setToken(token)
	self:set("token", token, true)
	self:save()
end

function GameData:getToken()
	return self:get("token")
end


function GameData:setPlayerCoins(coins)
	self:set("playercoins", coins)
	self:save()
end

function GameData:getPlayerCoins()
	
	return  globalCommon.changeDigits(self:get("playercoins"))

end

function GameData:setSafeCoins(coins)

	self:set("safeCoins", coins)
	self:save()
	
end

function GameData:getSafeCoins()
	
	return  self:get("safeCoins")

end

function GameData:setBankerCoins(coins)
	self:set("bankercoins", coins)
	self:save()
end

function GameData:getBankerCoins()
	
	return globalCommon.changeDigits(self:get("bankercoins"))
end


function GameData:setPlayerNickname(nickname)
	self:set("playernickname", nickname)
	self:save()
end

function GameData:getPlayerNickname()
	return globalCommon.GetShortName(self:get("playernickname"),10,10)
end

function GameData:setBankerNickname(nickname)
	self:set("bankernickname", nickname)
	self:save()
end

function GameData:getBankerNickname()
    return globalCommon.GetShortName(self:get("bankernickname"),10,10)
end

function GameData:setPlayerAvatar(av)
	self:set("playeravatar", av)
	self:save()
end

function GameData:getPlayerAvatar()
   
    return self:get("playeravatar")
end


function GameData:setBankerAvatar(av)
	
	self:set("bankeravatar", av)
	self:save()
end

function GameData:getBankerAvatar()
	
	return self:get("bankeravatar")   

end

function GameData:setUserName(userName)
	
	self:set("userName", userName)
	self:save()
end 

function GameData:getUserName()
	
	return self:get("userName")

end


function GameData:setpasswd(passwd)
	
	self:set("passwd", passwd)
	self:save()
end 

function GameData:getpasswd()
	
	return self:get("passwd")

end

function GameData:setIsRegister(isRegister)

	self:set("isRegister", isRegister)
	self:save()

end

function GameData:getIsRegister()

	 return self:get("isRegister")

end

function GameData:setLoginStatus(status)
	self:set("loginStatus", status)
	self:save()
end

function GameData:getLoginStatus()
	return self:get("loginStatus")
end

function GameData:setRoomConfig(rooms)
	self:set("rooms", rooms, true)
end

function GameData:getRoomConfig()
	return self:get("rooms")
end

function GameData:setSocketServerAddress(host)
	self:set("host", host)
end

function GameData:getSocketServerAddress()
	return self:get("host")
end

function GameData:setSocketServerPort(port)
	self:set("port", port)
end

function GameData:getSocketServerPort()
	return self:get("port")
end

function GameData:setIsBind(isBind)
	
	self:set("isBind", isBind)
	self:save()
end

function GameData:getIsBind()
	return self:get("isBind")
end

function GameData:setLogining(bool)
	self._logining = bool
end

function GameData:isLogining()
	return self._logining
end

function GameData:setPackageData(PackageData)
	self:set("PackageData", PackageData)
end

function GameData:getPackageData()
   
   return self:get("PackageData")
   
end

if not gamedata then
	gamedata = GameData.new()
end

return GameData
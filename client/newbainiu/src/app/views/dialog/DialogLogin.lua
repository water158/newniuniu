--
-- Author: Your Name
-- Date: 2015-09-11 15:32:06
--用户登录
local DialogLogin    = class("DialogLogin", ql.custom.DialogView)

local parentself
function DialogLogin:onCreate(args)
    
  if args then
     parentself = args.parent
  end
  self:setOnViewClickedListener("exit", function() 
	  self:dismiss()
  end)
  self:setOnViewClickedListener("Registeredaccount", function() 

    self:dismiss()
    showDialog("DialogRegister",{parent = parentself})

  end,nil,"zoom",true)

--找回密码
  self:setOnViewClickedListener("Retrievepassword", function() 

    self:dismiss()
    showDialog("DialogFindbackPassword",{parent = self})

  end,nil,"zoom",true)
  
	self:loginByUser()  

end

function DialogLogin:loginByUser()

	local function userlogin(result, bodys)
	    	
		if RESULT_OK ==  result then
        	
      if RESULT_OK ==  bodys.result then

        parentself:updateGameData(bodys)
        parentself:initPlayerInfo()
        toastview:show(localize.get("loginByUserName_suess"))
        self:dismiss()

      else

        toastview:show(localize.getM("loginByUserName",bodys.result))

      end
        
    elseif  RESULT_ERROR == result then
            
            toastview:show(localize.get("network_issue"))

    end
    
  end
    
  self:setOnViewClickedListener("loginButton",function ()
      	
    local userName = self:findNodeByName("passwordFileld"):getString()
    local passwd = self:findNodeByName("codeFileld"):getString()
    local temp = {}
	  temp["userName"] = userName
	  temp["passwd"] =  passwd 
    webservice:requestPost(MSGID_LOGIN_USER, temp, userlogin)

    end,nil,"zoom",true)
	

end


--[[
此函数用来保存游戏数据
@param  无
@return 无
]]
function DialogLogin:updateGameData(params)

--保存userId
  gamedata:setUserId(params.userId)
--保存金币值
  gamedata:setPlayerCoins(params.coins) 
--保存Token值
  gamedata:setToken(params.token)
--保存昵称
  gamedata:setPlayerNickname(params.nick)
--保存头像ID
  gamedata:setPlayerAvatar(params.avatar)
--保存长连接IP地址
  gamedata:setSocketServerAddress(params.host)
--保存长连接端口号
  gamedata:setSocketServerPort(params.port)
--保存
  gamedata:save()

end

--[[
初始化玩家信息
@param  无
@return 无
]]
function DialogLogin:newPlayerInfo()

  self.playerInfo:setPlayerNickName(false)
  self.playerInfo:setPlayerAvatar(false)
  self.playerInfo:setPlayerCoins(false) 
  
end


return DialogLogin
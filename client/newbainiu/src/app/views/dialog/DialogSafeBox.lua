--
-- Author: Your Name
-- Date: 2015-11-09 16:47:35
--
local DialogSafeBox  = class("DialogSafeBox", ql.custom.DialogView)
--全局枚举定义
local globalDefine = import("...common.GlobalDefine")
local changeLayer = import("..ChangeLayer")

local parentself 
function DialogSafeBox:onCreate(args)

 if args then

  parentself = args.parent

 end 
 
  self:setOnViewClickedListener("exit", function()
		
   if self.recordLayer then
    parentself:getView():removeChildByTag(1001, true)
    self.recordLayer = nil 
  end
		self:dismiss()
  
  end,nil,"none",true)
 
  self.current_coins = gamedata:getPlayerCoins()
  self.safeBox_coins = gamedata:getSafeCoins()

  self.current_coins_view = self:findNodeByName("current_coins")
  self.current_coins_view:setString(gamedata:getPlayerCoins())

  self.safebox_coins_view = self:findNodeByName("safebox_coins")
  self.safebox_coins_view:setString(gamedata:getSafeCoins())

  self._viewArr = {}
  for i=1,4 do
  
    table.insert(self._viewArr,i,self:findNodeByName("ChangePanel_"..i))

 
  end

  self:initDepositView()
  self:changeShowPage()

end

--换页显示
function DialogSafeBox:changeShowPage()
 
    for i=1,4 do 

      self:setOnViewClickedListener("touch_"..i, function()
	  
	  local selecteView = i 
	  for j=1,4 do
      	
      	if selecteView == j then
         
         self:findNodeByName("touch_"..j):loadTexture(globalDefine.touchViewType[j].Y,ccui.TextureResType.plistType)

        else
          
         self:findNodeByName("touch_"..j):loadTexture(globalDefine.touchViewType[j].N,ccui.TextureResType.plistType)
      	
      	end

	  end


	  if selecteView == 1 then
        
        self:showLayoutView(selecteView)
        self:initDepositView()

      elseif selecteView == 2 then
      	self:showLayoutView(selecteView)
      	self:initCashView()

      elseif selecteView == 3 then
      	self:showLayoutView(selecteView)
      	self:initRecordView()

      elseif selecteView == 4 then
        self:showLayoutView(selecteView)
        self:initModifyCodeView() 

	  end
  
      end,nil,"none",true)

    end

end

function DialogSafeBox:showLayoutView(showIdx)


	for index =1,4 do

		if showIdx == index then
    
         self._viewArr[index]:setVisible(true)        

        else
          
         self._viewArr[index]:setVisible(false)   

        end

	end


end


--修改存入保险箱
function DialogSafeBox:modifyDepositCoins()
	
    local editBox = cc.ui.UIInput.new({
    
        image = display.newScale9Sprite("bigImage/fm_common_empty.png"),
--1 为Edibox 
        UIInputType = 1,
        size = cc.size(500, 60),
        x = 397,
        y = 128,
        listener = function(event, editbox)
            if event == "began" then
              
              self:onEditBoxBegan(editbox)

            elseif event == "ended" then
                self:onEditBoxEnded(editbox)
            elseif event == "return" then
            
            elseif event == "changed" then
           
            else
                printf("EditBox event %s", tostring(event))
            end
        end
    })

    editBox:setFontColor(cc.c3b(255, 0, 255))
    editBox:setFontSize(0)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self:findNodeByName("ChangePanel_1"):addChild(editBox)

end

--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogSafeBox:onEditBoxBegan(editbox)
  
    printf("editBox event began : %s", editbox:getText())
    self:findNodeByName("DepositCoinsNums"):setString("")

end


--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogSafeBox:onEditBoxEnded(editbox)

    printf("editBox event ended : %s", editbox:getText())
    local text =   editbox:getText()
    if not tonumber(text) then
     
       toastview:show(localize.get("wrong_safeBox_Input"))
   
    else
      
      local perNum = tonumber(text)
      if perNum <= self.current_coins then
      print("perNum/self.current_coins"..perNum/self.current_coins)
      self:findNodeByName("one_Slider"):setPercent(perNum/self.current_coins*100)
      end
      self:findNodeByName("DepositCoinsNums"):setString(tostring(checkint(text)))

    end
   
end

function DialogSafeBox:DepositSlider()
	
	self:setOnViewClickedListener("one_safeadd", function() 
	    
	    local one_Slider = self:findNodeByName("one_Slider")
	    local DepositCoinsNums = self:findNodeByName("DepositCoinsNums")
	    self.depositPer = one_Slider:getPercent()
	    self.depositPer = self.depositPer + 1
	    if self.depositPer <= 100 then
	    	
	    	one_Slider:setPercent(self.depositPer)
	    	DepositCoinsNums:setString(tostring(checkint(self.current_coins*(self.depositPer/100))))

	    end
	 
	end,nil,"zoom",true)

    self:setOnViewClickedListener("one_safeminus", function() 
	   
	    local one_Slider = self:findNodeByName("one_Slider")
	    local DepositCoinsNums = self:findNodeByName("DepositCoinsNums")
	    self.depositPer = one_Slider:getPercent()
	    self.depositPer = self.depositPer - 1
	    if self.depositPer >= 0 then
	    	
	    	one_Slider:setPercent(self.depositPer)
	    	DepositCoinsNums:setString(tostring(checkint(self.current_coins*(self.depositPer/100))))

	    end
 
	end,nil,"zoom",true)

end


function DialogSafeBox:initDepositView()
     
  if self.recordLayer then
    parentself:getView():removeChildByTag(1001, true)
    self.recordLayer = nil 
  end
  self.depositPer = 0
  self:findNodeByName("DepositCoinsNums"):setString("")
	self:modifyDepositCoins()
	self:findNodeByName("one_Slider"):setPercent(self.depositPer)
	self:DepositSlider()
	
    self:findNodeByName("one_Slider"):addEventListener(function(event)
            
      local sliderNum = self:findNodeByName("one_Slider"):getPercent()
      self:findNodeByName("DepositCoinsNums"):setString(tostring(checkint(self.current_coins*(sliderNum/100))))
    
    end)

    self:setOnViewClickedListener("deposit",function ()
    
    	local operateCoins = self:findNodeByName("DepositCoinsNums"):getString()
    	print(operateCoins)
    	if operateCoins ~= 0 then
    	
    		self:onDeposit()
  			local temp = {}
    		local msgbody = {}
    		msgbody["operateType"] = 1
    		msgbody["operateCoins"] = operateCoins
    		local body_t = json.encode(msgbody)
    		temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_OPERATECOINS
    		temp["body"] = body_t
    		local msg_t = json.encode(temp)
    		gameWebSocket:send(msg_t, 1) 
        else
            
            return 

        end


    end)
	

end

function DialogSafeBox:onDeposit()
	
  local ackHandle
  local function onReceivedAck(event)
    
    print("接受到返回 信息")
    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    print(msg_t["body"].result)
    if msg_t["id"]  == (ID_ACK+MSGID_SYS_SAFEBOX_OPERATECOINS)  then
        gameWebSocket:removeEventListener(ackHandle)
    	if msg_t["body"].result == 0 then
           
           print("存入保险箱成功".."现有金币"..msg_t["body"].coins.."保险箱金币"..msg_t["body"].safeCoins)
           toastview:show(localize.get("Despit_suess"))
           gamedata:setPlayerCoins(msg_t["body"].coins)
           gamedata:setSafeCoins(msg_t["body"].safeCoins)
           self.current_coins_view:setString(gamedata:getPlayerCoins())
           self.safebox_coins_view:setString(gamedata:getSafeCoins())
           self.depositPer = 0
           self:findNodeByName("DepositCoinsNums"):setString("")
           self:findNodeByName("one_Slider"):setPercent(self.depositPer)
             --更新个人金币额
           gamedata:setPlayerCoins(msg_t["body"].coins)
           gamedata:setSafeCoins(msg_t["body"].safeCoins)
           parentself:findNodeByName("playerCoins"):setString(gamedata:getPlayerCoins())

           self.current_coins = gamedata:getPlayerCoins()
           self.safeBox_coins = gamedata:getSafeCoins()

    	
    	else
         
           print("存入保险箱失败")
           toastview:show(localize.getM("SAFEBOX_OPERATECOINS",msg_t["body"].result))
    
    	end
    end
 
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)	


end

--修改存款金额
function DialogSafeBox:modifyCashCoins()
	
    local editBox = cc.ui.UIInput.new({
    
        image = display.newScale9Sprite("bigImage/fm_common_empty.png"),

        UIInputType = 1,
        size = cc.size(700, 60),
        x = 398,
        y = 107,
        listener = function(event, editbox)
            if event == "began" then
              self:onModifyBegan(editbox)
            elseif event == "ended" then
                self:onModifyEnded(editbox)
            elseif event == "return" then
            
            elseif event == "changed" then

            else
                printf("EditBox event %s", tostring(event))
            end
        end
    })

    editBox:setFontColor(cc.c3b(255, 0, 255))
    editBox:setFontSize(0)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
    self:findNodeByName("ChangePanel_2"):addChild(editBox)

end

function DialogSafeBox:onModifyBegan(editbox)

  printf("onModifyBegan   editBox event Began : %s", editbox:getText())
  self:findNodeByName("cashCoinNums"):setString("")

end



--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogSafeBox:onModifyEnded(editbox)

    printf("onModifyEnded   editBox event ended : %s", editbox:getText())
    local text  =  editbox:getText()
    if not tonumber(text) then

       toastview:show(localize.get("wrong_safeBox_Input"))

    else

      local perNum = tonumber(text)
      if perNum <= tonumber(self.safeBox_coins) then
        print("perNum/self.current_coins"..perNum/self.safeBox_coins*100)
        self:findNodeByName("two_Slider"):setPercent(perNum/self.safeBox_coins*100)
      end

      self:findNodeByName("cashCoinNums"):setString(tostring(checkint(text)))

    end
    
   
end



function DialogSafeBox:CashSlider()
	
	self:setOnViewClickedListener("two_safeadd", function() 
	    
	  local two_Slider = self:findNodeByName("two_Slider")
	  local DepositCoinsNums = self:findNodeByName("cashCoinNums")
	  self.carhPer = two_Slider:getPercent()
	  self.carhPer = self.carhPer + 1
	  if self.carhPer <= 100 then
	    	
	    two_Slider:setPercent(self.carhPer)
	    DepositCoinsNums:setString(tostring(checkint(self.safeBox_coins*(self.carhPer/100))))

	  end
	 
	end,nil,"zoom",true)
  self:setOnViewClickedListener("two_safeminus", function() 
	   
	  local two_Slider = self:findNodeByName("two_Slider")
	  local DepositCoinsNums = self:findNodeByName("cashCoinNums")
	  self.carhPer = two_Slider:getPercent()
	  self.carhPer = self.carhPer - 1
	  if self.carhPer >= 0 then
	      two_Slider:setPercent(self.carhPer)
	    	DepositCoinsNums:setString(tostring(checkint(self.safeBox_coins*(self.carhPer/100))))
    end

	end,nil,"zoom",true)

end

function DialogSafeBox:initCashView()
     
  if self.recordLayer then
    parentself:getView():removeChildByTag(1001, true)
    self.recordLayer = nil 
  end
  self.carhPer = 0
  self:findNodeByName("cashCoinNums"):setString("")
  self:findNodeByName("two_Slider"):setPercent(self.carhPer)
	self:modifyCashCoins()
	self:CashSlider()	

	self:findNodeByName("two_Slider"):addEventListener(function(event)
            
    local sliderNum = self:findNodeByName("two_Slider"):getPercent()
    self:findNodeByName("cashCoinNums"):setString(tostring(checkint(self.safeBox_coins*(sliderNum/100))))
  
  end)
  self:setOnViewClickedListener("withdrawals_button",function ()
    
    local operateCoins = self:findNodeByName("cashCoinNums"):getString()
    if operateCoins ~= 0 then
    	
    	self:onCash()
  		local temp = {}
    	local msgbody = {}
    	msgbody["operateType"] = 2
    	msgbody["operateCoins"] = operateCoins
    	local body_t = json.encode(msgbody)
    	temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_OPERATECOINS
    	temp["body"] = body_t
    	local msg_t = json.encode(temp)
    	gameWebSocket:send(msg_t, 1) 
    else
            
      return 

    end

  end)
  self:setOnViewClickedListener("giving_button",function ()
    
    showDialog("DialogSafeBoxGiving")
    self:dismiss()
  end)

end


function DialogSafeBox:onCash()
	
  local ackHandle
  local function onReceivedAck(event)
    
    print("接受到返回 信息")
    local msg_t = json.decode(event.message)
    local id = msg_t["id"] 
    local body = msg_t["body"]
    print(msg_t["body"].result)
    if msg_t["id"]  == (ID_ACK+MSGID_SYS_SAFEBOX_OPERATECOINS)  then
        gameWebSocket:removeEventListener(ackHandle)
    	if msg_t["body"].result == 0 then
           
           toastview:show(localize.get("Cash_suess"))
           gamedata:setPlayerCoins(msg_t["body"].coins)
           gamedata:setSafeCoins(msg_t["body"].safeCoins)
           self.current_coins_view:setString(gamedata:getPlayerCoins())
           self.safebox_coins_view:setString(gamedata:getSafeCoins())
           self.carhPer = 0
           self:findNodeByName("cashCoinNums"):setString("")
           self:findNodeByName("two_Slider"):setPercent(self.carhPer)
           gamedata:setPlayerCoins(msg_t["body"].coins)
           parentself:findNodeByName("playerCoins"):setString(gamedata:getPlayerCoins())
           gamedata:setSafeCoins(msg_t["body"].safeCoins)
           self.current_coins = gamedata:getPlayerCoins()
           self.safeBox_coins = gamedata:getSafeCoins()
    	
    	else
         
           toastview:show(localize.getM("SAFEBOX_OPERATECOINS",msg_t["body"].result))

    	end
    
    end
 
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end



function DialogSafeBox:initRecordView()
    
  if self.recordLayer then
    parentself:getView():removeChildByTag(1001, true)
    self.recordLayer = nil 
  end
    self:onRecordListMsg()

  	local temp = {}
    local msgbody = {}
    local body_t = json.encode(msgbody)
    temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_HISTORY 
    temp["body"] = body_t
    local msg_t = json.encode(temp)
    print("发送请求历史记录信息")
    gameWebSocket:send(msg_t, 1)	
  
	
end

function DialogSafeBox:onRecordListMsg()
 	
 	local ackHandle
  local function onReceivedAck(event)
    
    if DEBUG > 0 then

          printInfo("in DialogSafeBox    @接收到TCP通知！")
    end
      local msg_t = json.decode(event.message)
      print(msg_t["id"])
      print(msg_t["body"].result)

      if msg_t["id"] == ID_ACK + MSGID_SYS_SAFEBOX_HISTORY then
         
         gameWebSocket:removeEventListener(ackHandle)
        
        if msg_t["body"].result == 0 then
          
          print("获得历史记录信息"..type(msg_t["body"].list))
          local recordList = msg_t["body"].list 
          table.insert(recordList,1,{date = "日期",operate = "操作",coins = "金额"})
          local listLen = table.getn(recordList)
          if listLen > 1 then
            
            self.recordLayer = changeLayer.new()
            parentself:getView():addChild(self.recordLayer,MAX_ZORDER,1001)
            self.recordLayer:LoadrecordMsg(recordList)
          
          else
             
            self:findNodeByName("tips_text"):setVisible(true)
                
          end

        else
          
          toastview:show(localize.getM("SAFEBOX_HISTORY",msg_t["body"].result))
   
        end
      
      end

  end

  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end

function DialogSafeBox:LoadrecordList(recordList)
	
 self.recordList = cc.ui.UIListView.new{

    bgColor = cc.c4b(125,125,125,100),
    bgScale9 = true,
    viewRect = cc.rect(1.12,1.12,800,300),
    direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  } 
  self.recordList:setBounceable(true)
  self.recordList:setTouchEnabled(true)
  self.recordList:setAlignment(cc.ui.UIListView.ALIGNMENT_LEFT)
  self.recordList:isSideShow()
  self.recordList:onTouch(handler(self, self.touchListener))
  self.recordLayer:getRoot():addChild(self.recordList,100)

  local listLen = table.getn(recordList)

  if listLen ~= 0 then
  	
  	for i=1,listLen do
    	
     local date = recordList[i].date
     local operate = recordList[i].operate
     local coins = recordList[i].coins
     local item = self.recordList:newItem()
     local content = display.newNode()
 
     --日期
     local dateText = ccui.Text:create(date,"Arial",25)
     dateText:setAnchorPoint(cc.p(0,0.5)) 
     dateText:setPosition(cc.p(40,0))
     dateText:setColor(cc.c3b(253, 210, 137))
     content:addChild(dateText)
     
     --操作
     local operateText = ccui.Text:create(operate,"Arial",25)
     operateText:setAnchorPoint(cc.p(0,0.5)) 
     operateText:setPosition(cc.p(300,0))
     operateText:setColor(cc.c3b(253, 210, 137))
     content:addChild(operateText)
     --金币
     local coinsText = ccui.Text:create(coins,"Arial",25)
     coinsText:setAnchorPoint(cc.p(0,0.5)) 
     coinsText:setPosition(cc.p(650,0))
     coinsText:setColor(cc.c3b(253, 210, 137))
     content:addChild(coinsText)
     item:addContent(content)
     local X = 800
     local Y = dateText:getBoundingBox().height*1.3  --39
     item:setItemSize(X,Y)
     self.recordList:addItem(item)

    end

    self.recordList:reload()
 

 else

    self:findNodeByName("tips_text"):setVisible(true)

 end
 	

end

function DialogSafeBox:touchListener(event)
    
    local listView = event.listView
    if "clicked" == event.name then
       print(event.name)
    elseif "moved" == event.name then
       
    elseif "ended" == event.name then
      
    else
        print("event name:" .. event.name)
    end
end

function DialogSafeBox:initModifyCodeView()
	 
   if self.recordLayer then
    parentself:getView():removeChildByTag(1001, true)
  end
	
	self:setOnViewClickedListener("ruffer_button",function ()

	  self:onModifyCode()
	  local oldCode = self:findNodeByName("oldcode"):getString()
      local newCode = self:findNodeByName("newcode"):getString()
      local pwdLen  = self:findNodeByName("newcode"):getStringLength()

      if pwdLen > 20 or pwdLen < 6 then
        toastview:show(localize.get("wrong_pwd"))  
        return
      end
      local newCodeAgain = self:findNodeByName("newcodeagain"):getString()

    	if newCode == newCodeAgain then
         	
        local temp = {}
        local msgbody = {}
        msgbody["oldPasswd"] = oldCode
        msgbody["newPasswd"] = newCode
  			local body_t = json.encode(msgbody)
        temp["id"] =   ID_REQ + MSGID_SYS_SAFEBOX_MODIFYPASSWD 
        temp["body"] = body_t
  			local msg_t = json.encode(temp)
  			print("发送修改密码信息")
  			gameWebSocket:send(msg_t, 1)	

    	else

        toastview:show(localize.get("newpwd_wrong"))  

    	end

	end,nil,"zoom",true)

end

function DialogSafeBox:onModifyCode()

  local ackHandle
  local function onReceivedAck(event)
    
    if DEBUG > 0 then
       printInfo("in DialogSafeBox    @接收到TCP通知！")
    end
      local msg_t = json.decode(event.message)
      print(msg_t["id"])
      print(msg_t["body"].result)

      if msg_t["id"] == ID_ACK + MSGID_SYS_SAFEBOX_MODIFYPASSWD then
         
         gameWebSocket:removeEventListener(ackHandle)
        
        if msg_t["body"].result == 0 then
           
           print("newPasswd"..msg_t["body"].newPasswd)

           if msg_t["body"].newPasswd ~= nil then
             
               print("修改密码成功")
               self:findNodeByName("oldcode"):setString("")
               self:findNodeByName("newcode"):setString("")
               self:findNodeByName("newcodeagain"):setString("")
               toastview:show(localize.get("resetPasswd_suess"))

             
           end

        else
           
             print("修改宝箱密码失败")
             toastview:show(localize.getM("SAFEBOX_MODIFYPASSWD",msg_t["body"].result))
   
        end
      

      end
      
  end

  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)


end


return  DialogSafeBox
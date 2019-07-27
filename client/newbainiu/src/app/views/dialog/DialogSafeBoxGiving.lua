--
-- Author: Your Name
-- Date: 2015-11-10 17:25:06
--
local DialogSafeBoxGiving  = class("DialogSafeBoxGiving", ql.custom.DialogView)


local parentself 
function DialogSafeBoxGiving:onCreate(args)
   
    if args then
   
     parentself = args 

    end
  self:setOnViewClickedListener("exit",function ()
    
    showDialog("DialogSafeBox")
    self:dismiss()  

  end,nil,"zoom",true)
  self:initGivingEdibox()
	self:initGivingCoins()

 
end

--修改存入保险箱
function DialogSafeBoxGiving:initGivingEdibox()
  

  --初始化输入框

    local editBox = cc.ui.UIInput.new({
    
        image = display.newScale9Sprite("bigImage/fm_common_empty.png"),
--1 为Edibox 
        UIInputType = 1,
        size = cc.size(450, 50),
        x = 699,
        y = 421,
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
    self:getRoot():addChild(editBox)

end

--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogSafeBoxGiving:onEditBoxBegan(editbox)
  
    printf("editBox event began : %s", editbox:getText())
    self:findNodeByName("givingNum_input"):setString("")

end


--[[
此函数是输入框的回调函数
@param  editbox
@return 无
--]]
function DialogSafeBoxGiving:onEditBoxEnded(editbox)

    printf("editBox event ended : %s", editbox:getText())
    local text =   editbox:getText()
    if not tonumber(text) then
     
       toastview:show(localize.get("wrong_safeBox_Input"))
   
    else
      
      self:findNodeByName("givingNum_input"):setString(string.subComma(tostring(checkint(text))))
      local safeCoins = gamedata:getSafeCoins()
      if tonumber(safeCoins) < tonumber(text) then
        toastview:show(localize.get("wrong_givingCoin_Input_1"))
      elseif tonumber(text) == 0 then
       
        toastview:show(localize.get("wrong_givingCoin_Input_2"))
       
      else 
        
       self.givingCoins = text

      end


    end
   
end

function DialogSafeBoxGiving:initGivingCoins()


	self:setOnViewClickedListener("giving_Button",function ()
		 
    local ID_input = self:findNodeByName("ID_input"):getString()
    if ID_input  and   self.givingCoins  then

      showDialog("DialogGivingTipView",{parent = self,givingCoins = self.givingCoins,givingID = ID_input })
      self:dismiss()

    end

	end)

end

function DialogSafeBoxGiving:OnGivingCoins()

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
           
        toastview:show(localize.get("giving_suess"))
        gamedata:setPlayerCoins(msg_t["body"].coins)
        gamedata:setSafeCoins(msg_t["body"].safeCoins)
        showDialog("DialogSafeBox")
        self:dismiss()
        self:findNodeByName("givingNum_input"):setString("")
        self:findNodeByName("ID_input"):setString("")
   	
    	else
           
        self:findNodeByName("givingNum_input"):setString("")
        self:findNodeByName("ID_input"):setString("")
        toastview:show(localize.getM("SAFEBOX_OPERATECOINS",msg_t["body"].result))
          
    	end
    
    end
 
  end
  
  ackHandle = gameWebSocket:addEventListener(gameWebSocket.MESSAGE_EVENT, onReceivedAck)

end

return  DialogSafeBoxGiving

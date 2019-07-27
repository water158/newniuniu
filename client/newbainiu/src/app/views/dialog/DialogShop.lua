
-- Author: Your Name
-- Date: 2015-09-06 17:05:53
--
local DialogShop  = class("DialogShop", ql.custom.DialogView)
--全局枚举定义
local globalDefine = import("...common.GlobalDefine")

local parentself
function DialogShop:onCreate(args)
 
 	if args then
 		parentself = args.parent
 	end
  
  local userId = gamedata:getUserId()
  if userId then
 		self:findNodeByName("ID_Num"):setString(userId)
  end

 	self:payGoods()
	self:setOnViewClickedListener("exit", function() 
	    self:dismiss()
	end,nil,"zoom",true) 

  self._viewArr = {}
  for i=1,2 do
   table.insert(self._viewArr,i,self:findNodeByName("Chanpage_"..i))
  end
  
  self:changePageView()

end

function DialogShop:changePageView()
	
	for i=1,2 do
         
    local selecteView = i 
    self:setOnViewClickedListener("page_"..i,function ()
          
      for j=1,2 do
           
        if selecteView == j then
                
          self:findNodeByName("page_"..j):loadTexture(globalDefine.shopPageType[j].Y,ccui.TextureResType.plistType)

        else
               
          self:findNodeByName("page_"..j):loadTexture(globalDefine.shopPageType[j].N,ccui.TextureResType.plistType)

        end

      end

      if selecteView == 1 then
        self:showLayoutView(selecteView)
      elseif  selecteView == 2 then
        self:showLayoutView(selecteView)
      end

    	end,nil,"zoom",true)

	end

end


function DialogShop:showLayoutView(showIdx)

  for index = 1,2 do
   
   if index == showIdx then
   	 self._viewArr[index]:setVisible(true)
   else
     self._viewArr[index]:setVisible(false)
   end

  end

end

function DialogShop:payGoods()

	for i=1,8 do

		self:setOnViewClickedListener("coinPay_"..i, function()
            
			payservice:pay(BAINIU_PRODUCTS[i].id, BAINIU_PRODUCTS[i].price, false, function(result, params)

				if result then
         
         webservice:updatePackageInfo()
         self:RenewalFrame()
         
				end
        
			end)
    
		end, nil, "none")

	end

end

function DialogShop:RenewalFrame()
    
  printInfo("In shop 更新游戏金币数据")
  parentself:findNodeByName("playerCoins"):setString(gamedata:getPlayerCoins())

end

return DialogShop
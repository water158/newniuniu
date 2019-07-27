--
-- Author: Carl
-- Date: 2015-06-24 11:27:39
--

local PayService = class("PayService")
local globalDefine = import("..common.GlobalDefine")

import(".WebService")
import("..utils.PlatformUtils")

function PayService:pay(productId, price, isQuickPay, callback)
	--dismissLoading()
	--showToast(localize.get("pay_failed"))
    webservice:requestPost(MSGID_GETORDER,{userId = gamedata:getUserId(),productId = productId, channelId = BAINIU_USER_CHANNEL_ID},function(result,bodys)
    	
     if RESULT_OK ==  result then
        
         if RESULT_OK ==  bodys.result then
           
            self:__onPay(productId,bodys.cost,isQuickPay,bodys.orderId,bodys.tradeDesc,callback)
         
         else
              

         end
        
    elseif  RESULT_ERROR == result then
            
          toastview:show(localize.get("network_issue"))
    end

    end)

end


function PayService:__onPay(productId, price, isQuickPay, orderId, tradeDesc, callback)

	if BAINIU_USER_CHANNEL_ID == "qifan"  then  
       
      pay_qifan({productId=productId, productName=tradeDesc, price=price, needValidateOrder=false, gameOrder=orderId, isQuickPay=isQuickPay}, function(result)
       
       if result then
         	
         webservice:requestPost(MSGID_DELIVER,{orderList = {orderId}},function(result,bodys)
          
          	if RESULT_OK == result then
               
               if RESULT_OK ==  bodys.result then
                  
                  printInfo("成功!")
                  
                  if  #bodys.orders == 1 and bodys.orders[1].status == 7  then
                      
                      callback(true, {productId=productId, orderId=orderId})
                  
                  else
                      
                      
                      if globalDefine.polling then

                        globalDefine.polling = false
                        orderdata:addUndeliveredOrder(orderId)
                        webservice:checkUndeliveredOrders(orderId)
                      
                      end


                  end

               else


               end

          	elseif RESULT_ERROR == result then
              toastview:show(localize.get("network_issue"))
          	end


         end)
      


       end
        

      end)
    
    else

    	callback(false, {productId=productId, orderId=orderId})


    end


end




if not payservice then
	payservice = PayService.new()
end

return PayService



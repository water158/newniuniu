local WebService = class("WebService", import(".BaseService"))
local scheduler = require("framework.scheduler")
import(".protocol")
require("framework.crypto")
import("..data.OrderData")
RESULT_OK = 0
RESULT_ERROR = -1

WebService.MSGID_SUBURL = 
{    
	"nil",
	"/v1/user/loginByGuest",
	"/v1/user/register",
	"/v1/user/loginByUserName",
	"/v1/mobile/getVerifyCode",
	"/v1/mobile/resetPasswd",
	"/v1/shop/getOrder",
	"/v1/shop/deliver",
	"/v1/user/package"
}
--[[
http请求
reqParams: (table)请求参数
callback: 回调函数callback(int result, params)
]]

function WebService:requestPost(msgid, msgbody, callback)
	local function onRequestFinished(event)
		if event.name == "progress" then
			return
		end
	    local request = event.request
	 
	    if event.name == "failed" then
	        -- 请求失败，显示错误代码和错误消息
	        if DEBUG > 0 then
	        	printInfo("@请求失败, 错误码=%d, 消息=%s", request:getErrorCode(), request:getErrorMessage())
	        	
	        end
	        if callback then callback(RESULT_ERROR) end
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        if DEBUG > 0 then
	        	printInfo("@服务器响应码不为200(%d)!!!", code)
	        end
	        if callback then callback(RESULT_ERROR) end
	        return
    	end
 
	    -- 请求成功，显示服务端返回的内容
	    local response = request:getResponseString()
	    if DEBUG > 0 then
	    	printInfo("@HTTP请求结果="..response)
	    end

	    local data = json.decode(response)
	    
        if data.body then
        	 bodys = data.body
        	 printf("receive text msg  for  HTTP : %s", bodys)
        	 if not bodys.result then
                
                bodys.result =  RESULT_OK

        	 end
        elseif data.error then

             bodys = data.error
        end 
       
         if callback then callback(RESULT_OK, bodys) end
	end


	local request = network.createHTTPRequest(onRequestFinished,HTTP_SERVER_URL..WebService.MSGID_SUBURL[msgid-MSGID_OUTER_SYSTEM-100], "POST")

	request:setTimeout(5) -- 5秒超时
	local sendData = json.encode(msgbody)

	print("-----------lp -------- sendData == " .. sendData)

	request:addPOSTValue("id", msgid)
	request:addPOSTValue("body", sendData)

	request:start()
end


--[[
	下载文件
]]
function WebService:downloadFile(url, destDir, callback)
	local function onDownloadCompleted(event)  
		if event.name == "progress" then
			if event.total > 0 then
		        callback({progress=event.dltotal/event.total})
			end
			return
		end
	    local request = event.request
	 
	    if event.name == "failed" then
	        -- 请求失败，显示错误代码和错误消息
	        if DEBUG > 0 then
	        	printInfo("@下载文件失败, 错误码=%d, 消息=%s", request:getErrorCode(), request:getErrorMessage())
	        end
	        if callback then callback({error=true}) end
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        if DEBUG > 0 then
	        	printInfo("@文件服务器响应码不为200(%d)!!!", code)
	        end
	        if callback then callback({error=true}) end
	        return
    	end
	    if event.name == "completed" then
	    	local pathinfo = io.pathinfo(url)
	    	if not io.exists(destDir) then
    			io.mkdirs(destDir)
	    	end
	    	local path = destDir..pathinfo.filename 
	    	event.request:saveResponseData(path)
	    	if DEBUG > 0 then
	    		printInfo("@文件下载成功!, 地址=%s, 目录=%s", url, path)
	    	end
	    	if callback then callback({done=true, path=path}) end
	    end
	end  
	local request = network.createHTTPRequest(onDownloadCompleted, url, "GET")  
	request:start()
end

-- [[批量下载文件]]
function WebService:downloadFiles(baseurl, filepaths, from, destDir, callback)
	if from > #filepaths then
		return
	end
	baseurl = io.rmlastsep(baseurl)
	destDir = io.rmlastsep(destDir)
	local pathinfo = io.pathinfo(filepaths[from])
	self:downloadFile(baseurl..'/'..filepaths[from], destDir..device.directorySeparator..pathinfo.dirname, function(result)
		if result.done then
			if from == #filepaths then
				callback({progress=1})
				-- 下载完成
				callback({done=true})
				return
			end
			-- 下载下一个
			from = from + 1
			self:downloadFiles(baseurl, filepaths, from, destDir, callback)
		elseif result.progress then
			callback({progress=((from-1)+result.progress)/#filepaths})
		else
			callback(result)
		end
	end)
end

--[[
	请求json文件
]]
function WebService:requestFile(url, callback)
	local function onRequestFinished(event)
		if event.name == "progress" then
			return
		end
	    local request = event.request
	    if event.name == "failed" then
	    	if DEBUG > 0 then
	        	printInfo("@获取JSON文件失败, 错误码=%d, 消息=%s", request:getErrorCode(), request:getErrorMessage())
	        end
	    	if callback then callback() end
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	    	if DEBUG > 0 then
	        	printInfo("@JSON文件服务器响应码不为200(%d)!!!", code)
	        end
	    	if callback then callback() end
	        return
    	end
 
	    -- 请求成功，显示服务端返回的内容
	    local response = request:getResponseString()
	    if DEBUG > 0 then
	    	printInfo("@请求JSON文件结果="..response)
	    end
	    if callback then callback(json.decode(response)) end
	end
	local request = network.createHTTPRequest(onRequestFinished, url, "GET")
	request:start()
end


-- 检查尚未发货的订单
function WebService:checkUndeliveredOrders(orderId)
     

    local orders = orderdata:getMemoryUndeliveredOrder()

	if #orders > 0  then


		self._handle = scheduler.scheduleGlobal(function()
               
			webservice:requestPost(MSGID_DELIVER,{orderList = orders},function(result,bodys)
            
            if RESULT_OK == result then
               
                 if RESULT_OK ==  bodys.result then
                    
                    print("開啟訂單輪回")
                    local deliveredOrders = {}
                    
                    for i,v in ipairs(bodys.orders) do
						if v.status == 7 or v.status == 6 or v.status == 8 then
							
							orderdata:removeUndeliveredOrder(v.orderId)
							orderdata:removeMemoryUndeliveredOrder(v.orderId)
							table.insert(deliveredOrders, v.orderId)
					   elseif v.status == 1 then 
                        	 
                        	orderdata:removeMemoryUndeliveredOrder(v.orderId)
                       else

                       	    orderdata:removeUndeliveredOrder(v.orderId)
							orderdata:removeMemoryUndeliveredOrder(v.orderId)
                           
						end

				    end

					if #deliveredOrders > 1 then
						toastview:show(localize.get("order_delivered", #deliveredOrders))
					elseif #deliveredOrders == 1 then
						toastview:show(localize.get("single_order_delivered", deliveredOrders[1]))
					end

					if #orderdata:getMemoryUndeliveredOrder()  == 0 and self._handle  then
						scheduler.unscheduleGlobal(self._handle)
					end

             
               else
                     
                 

               end

          	elseif RESULT_ERROR == result then
                   
                    --print("開啟訂單輪回 失敗")
            
                   --toastview:show(localize.get("network_issue"))

          	end



			end)	

		end, 20)


	end
end

--更新背包信息
function WebService:updatePackageInfo()


	 local function onPackage(result, bodys)

        if RESULT_OK ==  result then
        
         if RESULT_OK ==  bodys.result then
            
            printInfo("更新游戏金币成功")
         	gamedata:setPlayerCoins(bodys.coins)
            printInfo("更新背包信息成功")
            gamedata:setPackageData(bodys.list)
            
          
         else
               
            print("获取背包失败"..body.result)

         end
        
        elseif  RESULT_ERROR == result then
            
          toastview:show(localize.get("network_issue"))
        
        end
    
    end
    
    local temp = {}
    temp["userId"]  = gamedata:getUserId() 
    webservice:requestPost(MSGID_GETPACKAGEINFO , temp, onPackage)


end


if not webservice then
	print("new webservice ")
	webservice = WebService.new()
end


return WebService
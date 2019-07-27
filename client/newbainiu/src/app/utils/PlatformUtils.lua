--
-- Author: Carl
-- Date: 2015-05-22 20:31:55
--
 local javaClassName = "org/cocos2dx/lua/AppActivity"
 local global = {} 

function getMobileInfos()
	if device.platform == "android" then
        -- call Java method
	    local _, ip = luaj.callStaticMethod(javaClassName, "getIpAddress", {}, "()Ljava/lang/String;")
	    local _, model = luaj.callStaticMethod(javaClassName, "getModel", {}, "()Ljava/lang/String;")
	    local _, imei1 = luaj.callStaticMethod(javaClassName, "getIMEI1", {}, "()Ljava/lang/String;")
	    local _, imei2 = luaj.callStaticMethod(javaClassName, "getIMEI2", {}, "()Ljava/lang/String;")
	    local _, imsi = luaj.callStaticMethod(javaClassName, "getIMSI", {}, "()Ljava/lang/String;")
	    local _, releaseVersion = luaj.callStaticMethod(javaClassName, "getReleaseVersion", {}, "()Ljava/lang/String;")
	    local _, wifiMac = luaj.callStaticMethod(javaClassName, "getMAC", {}, "()Ljava/lang/String;")
	    local _, location = luaj.callStaticMethod(javaClassName, "getLocation", {}, "()Ljava/lang/String;")
	    local _, phoneType = luaj.callStaticMethod(javaClassName, "getPhoneType", {}, "()Ljava/lang/String;")
	    local _, resolution = luaj.callStaticMethod(javaClassName, "getResolution", {}, "()Ljava/lang/String;")
	    return {
		    ip=ip, 
		    model=model, 
		    imei1=imei1, 
		    imei2=imei2, 
		    imsi=imsi, 
		    releaseVersion=releaseVersion,
		    mac=wifiMac,
		    location=location,
		    phoneType=phoneType,
		    resolution=resolution
		}
    elseif device.platform == "ios" then
    	-- TODO
    	return {
		    ip="0.0.0.0", 
		    model="ios", 
		    imei1="qlhd-test-device-1", 
		    imei2="", 
		    imsi="", 
		    releaseVersion="",
		    mac="",
		    location="",
		    phoneType="",
		    resolution=""
		}
    else
    	return {
		    ip="0.0.0.0", 
		    model="Windows", 
		    imei1="qlhd-test-device-1", 
		    imei2="", 
		    imsi="", 
		    releaseVersion="",
		    mac="",
		    location="",
		    phoneType="",
		    resolution=""
		}
    end
end

-- 获取友盟设备ID
function getUmengDeviceToken()
	if device.platform == "android" then
		local ok, result = luaj.callStaticMethod(javaClassName, "getUmengDeviceToken", {}, "()Ljava/lang/String;")

		print("获取友盟设备ID")
		return result
	else
		return ""
	end
end

-- 打开反馈页面
function openFeedbackPage()
	if device.platform == "android" then
		print("打开反馈页面")
		luaj.callStaticMethod(javaClassName, "openFeedbackPage", {}, "()V")
	end
end

-- 支付
--[[
	/**
	 * 商品ID
	 */
	pay.productId = object.getString("productId");
	/**
	 * 商品名称
	 */
	pay.productName = object.getString("productName");
	/**
	 * 商品价格，以元为单位
	 */
	pay.price = object.getInt("price");
	/**
	 * 是否需要强制对单
	 */
	pay.needValidateOrder = object.getBoolean("needValidateOrder");
	/**
	 * 透传参数，原样返回
	 */
	pay.gameOrder = object.getString("gameOrder");

	/**
	 * 是否短信快冲
	 */
	pay.isQuickPay = object.getBoolean("isQuickPay");
]]
function pay_qifan(params, callback)
	if device.platform == "android" then
		payCallbackFunc = callback
		local ok = luaj.callStaticMethod(javaClassName, "payQifan", {json.encode(params)}, "(Ljava/lang/String;)V")
		return ok
	else
		callback()
		return false
	end
end

-- 支付回调
function onQifanPayFinish(result)
	if payCallbackFunc then
		payCallbackFunc(result == "true")
	end
end

-- 报告问题-友盟
function reportError(error)
	if device.platform == "android" then
		luaj.callStaticMethod(javaClassName, "reportError", {error}, "(Ljava/lang/String;)V")
	else
		--TODO
	end
end

function getUserChannel()
	if device.platform == "android" then
		local _, channel = luaj.callStaticMethod(javaClassName, "getUserChannel", {}, "()Ljava/lang/String;")
		return channel
	else
		--TODO
	end
	return ""
end

-- 网络是否可用
function isNetworkConnected()

	if device.platform == "android" or device.platform == "ios" then
		return network.getInternetConnectionStatus() > 0
	end
	return true
end
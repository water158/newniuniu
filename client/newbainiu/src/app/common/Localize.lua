
--version number v1.1.0
--@client side Localize.lua
--[[
  游戏
]]

local globalDefine = import(".GlobalDefine")
local Localize = {}

Localize._messages =
    {
        cn = {
               
               staytuned  = "敬请期待!",
               network_issue = "网络请求失败，请检查网络",
               wrong_mobile = "无效手机号码",
               wrong_pwd = "密码无效，6-20位字母或数字!",
               newpwd_wrong = "您输入的密码不匹配，请重新输入密码",
               loginByGuest_suess = "登录成功",
               order_delivered = "%d个订单已经确认完成",
               single_order_delivered = "订单%s已经确认完成",  
               userRegister_suess = "用户注册成功",
               loginByUserName_suess = "用户登录成功",
               verify_suess = "获得验证码成功",
               resetPasswd_suess = "设置新密码成功",
               BIND_MOBILE_suess = "绑定手机成功",
               UNBIND_MOBILE_suess = "解绑手机成功",
               Despit_suess = "存入保险箱成功",
               Cash_suess = "从保险箱取款成功",
               giving_suess = "赠送好友金币成功",
               ENTER_NO_SAFEBOX = "请购买保险箱",
               wrong_safeBox_Input = "请输入数字",
               wrong_givingCoin_Input_1 = "保险箱金币不足,无法赠送",
               wrong_givingCoin_Input_2 = "赠送金币不能为 0",
               FreeCharge = "金币不足，系统给予补助金币%s",
               SYS_LOGINHALL = "登录大厅失败",
               loginByGuest = globalDefine.loginByGuest,                 --游客登录
               userRegister = globalDefine.userRegister,                 --游客注册
               UPGRADE_GUEST = globalDefine.UPGRADE_GUEST,               --游客升级
               MODIFY_USERINFO = globalDefine.MODIFY_USERINFO,           --修改个人信息
               loginByUserName = globalDefine.loginByUserName,           --用户登录
               SYS_QUICK_START = globalDefine.SYS_QUICK_START,            --快速开始
               SYS_JOIN_TABLE = globalDefine.SYS_JOIN_TABLE,              --加入桌子
               JOIN_BANKER = globalDefine.JOIN_BANKER,                    --上庄
               JOIN_COINS = globalDefine.JOIN_COINS,                      --下注
               GIFT_GRAB = globalDefine.GIFT_GRAB,                        --抢红包
               getVerifyCode = globalDefine.getVerifyCode,                --获取手机验证码 
               resetPasswd = globalDefine.resetPasswd,                    --重置密码
               BIND_MOBILE = globalDefine.BIND_MOBILE,                    --绑定手机
               UNBIND_MOBILE = globalDefine.UNBIND_MOBILE,                --解绑手机
               SAFEBOX_ENTER = globalDefine.SAFEBOX_ENTER ,               --进入保险箱
               SAFEBOX_OPERATECOINS = globalDefine.SAFEBOX_OPERATECOINS,  --保险箱金币操作
               SAFEBOX_HISTORY = globalDefine.SAFEBOX_HISTORY,            -- 保险箱历史记录
        	     SAFEBOX_RESETPASSWD = globalDefine.SAFEBOX_RESETPASSWD,    --保险箱找回保险箱密码
               SAFEBOX_MODIFYPASSWD = globalDefine.SAFEBOX_MODIFYPASSWD,  --保险箱修改保险箱密码
               FREECHARGE = globalDefine.FREECHARGE,                       --系统免充，破产补助  
               calculation_niu_tip1 = "让我帮你记牌吧",
               calculation_niu_tip2 = "算不出来不要急，快点我，我可以帮你算哦~",
               calculation_niu_state1 = "开启",
               calculation_niu_state2 = "关闭",
               calculation_countdown1 = "休息时间",
               calculation_countdown2 = "请抢庄",
               calculation_countdown3 = "选择倍数",
               calculation_countdown4 = "拼命思考中"
             }
    }


--[[
获取本地化后的字符串
]]
function Localize.get(key, ...)
    return string.format(Localize._messages[device.language][key], ...)
end

--[[
获取本地化后的字符串
]]

function Localize.getM(key,m)
	
    local M = Localize._messages[device.language][key]
    return string.format(M[m])

end

localize = Localize

return Localize

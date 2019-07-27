--version number v1.0.0
--@client side GlobalDefine.lua
--[[
  此文件用来定义游戏的枚举定义
]]--
--script writer Han 
--creation time 2015-08-28
local globalCommon = import(".GlobalCommon")
local GlobalDefine = {}

--时间状态类型
GlobalDefine.timeType = 
 {
  restType = 1,
  payType = 2,
  openPokerType = 3
 }

GlobalDefine.polling = true
GlobalDefine.isPayType = false 

GlobalDefine.Room_Data = 
 {
  {
  10,
  50,
  100,
  500,
  1000
 },
 {
  100,
  1000,
  5000,
  10000,
  50000
 },
 {
  5000,
  10000,
  50000,
  100000,
  1000000,
 },
 }

--定义台面类型
GlobalDefine.BoardType =
{
  1,
  2,
  3,
  4 
}

--定义砝码类型：
GlobalDefine.Room_FarmarImage = 
{
  {
  "farmar/chip-10-1.png",
  "farmar/chip-50-1.png",
  "farmar/chip-100-1.png",
  "farmar/chip-500-1.png",
  "farmar/chip-1000-1.png"

  },
  {
  "farmar/chip-100-1.png",
  "farmar/chip-1000-1.png",
  "farmar/chip-5000-1.png",
  "farmar/chip-10000-1.png",
  "farmar/chip-50000-1.png"

  },
  {
  "farmar/chip-5000-1.png",
  "farmar/chip-10000-1.png",
  "farmar/chip-50000-1.png",
  "farmar/chip-100000-1.png",
  "farmar/chip-1000000-1.png"

  }

}

--记录输赢记录
GlobalDefine.winHistroy = 
{
  0,
  0,
  0,
  0
} 
GlobalDefine.res = 
{
    b_1_2 = "card/b_1_2.png",
    l_1_2 = "card/l_1_2.png",
    b_1_1 =  "card/b_1_1.png",
    l_1_1 = "card/l_1_1.png",
    b_2_1 = "card/b_2_1.png",
    l_2_1 = "card/l_2_1.png",
    b_2_2 = "card/b_2_2.png",
    l_2_2 = "card/l_2_2.png",
    Black_1  ="card/b_1.png",
    Black_2 ="card/b_2.png",
    Black_3 ="card/b_3.png",
    Black_4 ="card/b_4.png",
    Black_5 ="card/b_5.png",
    Black_6 ="card/b_6.png",
    Black_7 ="card/b_7.png",
    Black_8 ="card/b_8.png",
    Black_9 ="card/b_9.png",
    Black_10 ="card/b_10.png",
    Black_11 ="card/b_11.png",
    Black_12 ="card/b_12.png",
    Black_13 ="card/b_13.png",
    Red_1 ="card/r_1.png",
    Red_2 ="card/r_2.png",
    Red_3 ="card/r_3.png",
    Red_4 ="card/r_4.png",
    Red_5 ="card/r_5.png",
    Red_6 ="card/r_6.png",
    Red_7 ="card/r_7.png",
    Red_8 ="card/r_8.png",
    Red_9 ="card/r_9.png",
    Red_10 ="card/r_10.png",
    Red_11 ="card/r_11.png",
    Red_12 ="card/r_12.png",
    Red_13 ="card/r_13.png",


}

--定义宝箱类型
GlobalDefine.touchViewType = 
{ 
  {Y ="Common/depositY.png" ,N = "Common/depositN.png" },
  {Y = "Common/cashY.png",N ="Common/cashN.png" },
  {Y ="Common/recordY.png" ,N = "Common/recordN.png" },
  {Y ="Common/changepasswordY.png" ,N = "Common/changepasswordN.png" },
      
}
--定义聊天转换类型
GlobalDefine.modeChangeType = 
{
  {Y ="Common/chatButtonY.png" ,N = "Common/chatButtonN.png" },
  {Y = "Common/playerListY.png", N = "Common/playerListN.png"},
  {Y= "Common/KabaY.png", N = "Common/KabaN.png" },
}

--定义商城
GlobalDefine.shopPageType = 
{
  {Y ="newShop/coinY.png",N = "newShop/coinN.png" },
  {Y ="newShop/daojuY.png" ,N = "newShop/daojuN.png"}

}

--游客登录
GlobalDefine.loginByGuest =
{
   "用户名非法",  --用户名非法
   "密码非法",    --密码非法
   "用户不存在",  --用户不存在
   "密码不正确"   --密码不正确
}

--用户注册
GlobalDefine.userRegister = 
{
  
   "用户名非法",  --用户名非法
   "密码非法",    --密码非法
   "用户已存在",  --用户不存在

}

--游客升级
GlobalDefine.UPGRADE_GUEST =
{
   
   "用户名非法",  --用户名非法
   "密码非法",    --密码非法
   "用户不存在",  --用户不存在
   "用户非游客"   --密码不正确

}


--用户登录
GlobalDefine.loginByUserName =
{
   
   "用户名非法",  --用户名非法
   "密码非法",    --密码非法
   "用户不存在",  --用户不存在
   "密码不正确"   --密码不正确

}

--配桌
GlobalDefine.SYS_QUICK_START = 
{
 
  "未知错误" ,    --未知错误
  "金币不足",     --金币不足
  "金币太多" ,     --金币太多
  "无效的房间ID", --无效的房间ID

}
--修改用户信息
GlobalDefine.MODIFY_USERINFO =
{
  "修改昵称错误",
  "修改头像错误",
  "修改密码错误",
  "输入的旧密码不对",
  "用户昵称已存在",
  "不是注册用户,无法修改密码"
}

--加入桌子
GlobalDefine.SYS_JOIN_TABLE = 
{

  "断线重连",               --断线重连
  "未知错误",               --未知错误
  "错误的桌子ID",           --错误的桌子ID
  "同时进入多张桌子",       --同时进入多张桌子
  "您上局逃跑，游戏未结束",  --上局逃跑，游戏未结束
  "游戏状态错误",            --游戏状态错误
  "桌子已坐满",              --桌子已坐满
  "您已在桌子上",            --您已在桌子上
  "金币不足",               --金币不足
  "金币太多"                --金币太多

}

--申请上庄
GlobalDefine.JOIN_BANKER = 
{
  
  "用户不存在" ,           --用户不存在
  "已经申请个上庄" ,       --已经申请个上庄
  "上庄金币不足,请充值！"
}

--下注
GlobalDefine.JOIN_COINS =
{
  
  "用户不存在" ,          --用户不存在
  "现在不是下注时间",     --不是下注时间
  "庄家金币不足！",       --大于庄家的1/8金币
  "您的金币不足请充值！", --大于自身的1/8
  "庄家不能下注",         --庄家不能下注
  "下注失败"              --下注失败

}

--抢红包
GlobalDefine.GIFT_GRAB = 
{ 

  "用户不存在" ,                       --用户不存在
  "亲，有人捷足先登了，下次继续努力！" --红包已被清空
   
}

--获取手机验证码
GlobalDefine.getVerifyCode = 
{ 
  "手机号非法" ,     
  "您未绑定手机号" ,   
  "该手机号已经绑定过，不能再次绑定", 
  "验证码发送失败"     
   
}

--找回密码,重置密码 
GlobalDefine.resetPasswd = 
{ 
  "您未绑定手机号",
  "验证码错误"
}

--绑定手机
GlobalDefine.BIND_MOBILE =
{
  "验证码错误",
  "您的手机号已绑定过",
  "您已绑定过手机号"
}

--解绑手机
GlobalDefine.UNBIND_MOBILE =
{
  "验证码错误",
  "您未绑定过手机号",
  "手机号输入不正确"
}

--进入保险箱
GlobalDefine.SAFEBOX_ENTER =
{
  
  "没有保险箱",
  "保险箱密码不正确"
}

--保险箱金币操作
GlobalDefine.SAFEBOX_OPERATECOINS = 
{ 
  "操作金币非法",
  "操作类型非法",
  "没有保险箱",
  "当前金币数太少",
  "保险箱金币太少",
  "您赠送的用户ID不存在"
}

--保险箱历史记录
GlobalDefine.SAFEBOX_HISTORY = 
{ 
  "获取历史记录失败"
}

--找回保险箱密码
GlobalDefine.SAFEBOX_RESETPASSWD = 
{
  "手机号和绑定的手机号不匹配",
  "验证码不正确"

}

--修改保险箱密码
GlobalDefine.SAFEBOX_MODIFYPASSWD =
{ 
  "手机号和绑定的手机号不匹配",
  "验证码不正确"
}

--金币免充
GlobalDefine.FREECHARGE =
{ 
  "免充失败",
  "金币充足，不需要系统补助",
  "今日的系统补助已用完"
}

--桌子事件
GlobalDefine.TABLE_EVENT =
{
  "未知错误",
  "指定时间内不准备",
  "低于最低限制%s",
  "高于最高限制%s",
  "断线",
  "长时间不操作"
}

return  GlobalDefine







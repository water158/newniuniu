/**
 * Created by yelong on 2015/8/7.
 */
var util = require('util');
var consts = require('../../consts/consts');
var lobby = require('../lobby');

var stUserInfo = function(userInfo){
    this.coins = userInfo.coins;
    this.nick = userInfo.nick;
    this.eIdentity = userInfo.eIdentity;
    this.nSeatID = userInfo.nSeatID;
    this.eState = userInfo.eState;
    this.timeOutType = consts.BaiTimeOutType.timeout_type_unknown;
    this.nNoReadyTime = 0;
    this.xiaZhuCoins = {1:0,2:0,3:0,4:0};//各个位置的下注金额
    this.totalXiaZhuCoins = 0;           //各个位置的下注数之和
    this.coinsChg = 0;                   //总共赢了多少金币
    this.nClockTime = 0;                         //玩家的计时器
    this.nXiaZhuHappen = lobby.GetRandomNum(1,4);//可以下注了
    this.gamesLimit = 0;                         //局数限制
};

pro = stUserInfo.prototype;
module.exports = stUserInfo;

pro.init = function(){
    this.xiaZhuCoins = {1:0,2:0,3:0,4:0};//各个位置的下注金额
    this.totalXiaZhuCoins = 0;           //各个位置的下注数之和
    this.coinsChg = 0;                   //总共赢了多少金币
    this.nClockTime = 0;                         //玩家的计时器
    this.nXiaZhuHappen = lobby.GetRandomNum(1,4);//可以下注了
};
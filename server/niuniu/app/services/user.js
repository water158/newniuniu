/**
 * Created by ddz-001 on 2015/9/9.
 */

var querystring = require("querystring");
var lobby = require('./lobby');
var consts = require('../consts/consts');
var crypto = require('crypto');
var async = require('async');
var logger = require('pomelo-logger').getLogger('niuniu', __filename);

var user = module.exports;

E_NOLOGINNED = -101;
E_EXCEPTION = -102;
E_BADURL = -103;
E_BADREDIS = -104;
E_BADDB = -105;

E_REGISTERROBOT_PARAM_USERNAME = 1;
E_REGISTERROBOT_USER_EXISTS = 2;
user.registerRobot = function(app, data, remoteAddress, cb) {
    this.app = app;
    var reqData = querystring.parse(data);
    var msgId = parseInt(reqData.id)%consts.MSG.ID_REQ;
    var msgBody = reqData.body;
    var params = JSON.parse(msgBody);
    var userName = params.userName;
    var nick = params.nick;
    if(userName.length < 6){
        cb(null, {'id':msgId | consts.MSG.ID_ACK , 'body':{'result': E_REGISTERROBOT_PARAM_USERNAME}});
        return;
    }
    lobby.GetUserIDByUserName(userName, consts.Macro.IDTYPE_ROBOT, function(err, userId){
        if(!err){
            cb(null, {'id':msgId | consts.MSG.ID_ACK , 'body':{'result': E_REGISTERROBOT_USER_EXISTS}});
            return;
        }
        var dictInfo = {'userName':userName, 'idType':consts.Macro.IDTYPE_ROBOT, 'nick':nick, 'token':'', 'deviceId':'', 'createIP':remoteAddress, 'channel':'qifan'};
        lobby.CreateUser(dictInfo,function(err){
            if(err){
                cb(null, {'id':msgId | consts.MSG.ID_ACK , 'body':{'result': E_BADDB}});
                return;
            }
            cb(null, {'id':msgId | consts.MSG.ID_ACK , 'body':{'result': 0}});
        })
    })
};

user.checkDate = function(dateBegin, dateEnd){
    if(dateBegin >= dateEnd){
        return false;
    }
    return true;
};

user.GetFormatDate = function(date){
    var year = date.getFullYear().toString();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    if(month < 10){
        month = '0'+month.toString();
    }
    if(day < 10){
        day = '0'+day.toString();
    }
    return year + '-' + month +'-' + day;
};

E_GAME_INFO_SUCCESS = 1;
E_GAME_INFO_ERROR = 2;
user.game_info = function(app, data, remoteAddress, cb) {
    this.app = app;
    var params = JSON.parse(data);
    var gameId = params.gameId;
    var ts = params.ts;
    var sign = params.sign;
    var signData = 'gameId=' + gameId + '&ts=' + ts + '&token=' + consts.BIRD.STAT_TOKEN;
    var mySign = crypto.createHash('md5').update(signData).digest('hex');
    if(sign != mySign){
        cb(null, {code:E_GAME_INFO_ERROR, reason:'签名错误'});
        return;
    }
    var dateBegin = new Date(params.start);
    var dateEnd = new Date(params.end);
    dateEnd.setDate(dateEnd.getDate() + 1);
    if(!user.checkDate(dateBegin, dateEnd)){
        cb(null, {code:E_GAME_INFO_ERROR, reason:'日期错误'});
        return;
    }
    var gameInfo = [];
    async.whilst(function(){
            return dateBegin < dateEnd;
        },
        function(cb){
            lobby.GetBirdDayInfo(dateBegin, function(err, birdDayInfo){
                if(!err && birdDayInfo && birdDayInfo.bankerWinCoins){
                    gameInfo.push({Day:user.GetFormatDate(dateBegin), Gold:parseInt(birdDayInfo.bankerWinCoins)});
                }
                dateBegin.setDate(dateBegin.getDate() + 1);
                cb(null);
            })
        },
        function(err){
            cb(null, {code:E_GAME_INFO_SUCCESS, reason:'成功', gameInfo:gameInfo});
        });
};

E_GAME_START_SUCCESS = 1;
E_GAME_START_ERROR = 2;
user.game_start = function(app, data, remoteAddress, cb) {
    this.app = app;
    var params = JSON.parse(data);
    var gameId = params.gameId;
    var ts = params.ts;
    var sign = params.sign;
    var signData = 'gameId=' + gameId + '&ts=' + ts + '&token=' + consts.BIRD.STAT_TOKEN;
    var mySign = crypto.createHash('md5').update(signData).digest('hex');
    if(sign != mySign){
        cb(null, {code:E_GAME_START_ERROR, reason:'签名错误'});
        return;
    }
    //control：1-获取状态；2-设置状态；
    //status： 设置的状态：1-开启；2-关闭；
    var control = parseInt(params.control);
    var status = parseInt(params.status);
    if([1,2].indexOf(control) < 0){
        cb(null, {code:E_GAME_START_ERROR, reason:'control错误'});
        return;
    }
    if(control == 2 && [1,2].indexOf(status) < 0){
        cb(null, {code:E_GAME_START_ERROR, reason:'status错误'});
        return;
    }
    //control为1，获取状态; control为2，设置状态
    if(control == 1){
        lobby.GetBirdDataByField('gameStatus', function(err, gameStatus){
            if(err){
                cb(null, {code:E_GAME_START_ERROR, reason:'状态获取失败'});
                return;
            }
            status = 1;
            if(gameStatus){
                status = parseInt(gameStatus);
            }
            cb(null, {code:E_GAME_START_SUCCESS, reason:'成功', status:status});
        })
    }else{
        lobby.SetBirdDataByField('gameStatus', status, function(err){
            if(err){
                cb(null, {code:E_GAME_START_ERROR, reason:'状态设置失败'});
                return;
            }
            cb(null, {code:E_GAME_START_SUCCESS, reason:'成功', status:status});
        })
    }
};

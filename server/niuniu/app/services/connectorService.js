/**
 * Created by wjl on 2015/5/7.
 */
var EventEmitter = require('events').EventEmitter;
var util = require('util');
var crypto = require('crypto');
var consts = require('../consts/consts');
var lobby = require('./lobby');
var socketClent = require('./socket');
var logger = require('pomelo-logger').getLogger('niuniu', __filename);

CHECK_TIME_OUT = 15000;
var server = function(app, host, port){
    var self = this;
    self.app = app;
    self.host = host;
    self.port = port;

    EventEmitter.call(this);

    self.processSocket();
    setInterval(self.OnTimer, CHECK_TIME_OUT, self);
    console.log("connect server start port = "+port);
};

util.inherits(server, EventEmitter);
var pro = server.prototype;

pro.OnTimer = function(ptr){
    var self = ptr;
    if(self.birdClient.is_connected == false || self.birdClient.is_register == false){
        self.processSocket();
    }
};

pro.registerToBirdSvr = function(){
    var self = this;
    var ts = parseInt(new Date().getTime()/1000);
    var signData = 'gameId=' + consts.BIRD.GAMEID + '&token=' + consts.BIRD.TOKEN + '&ts=' + ts;
    var sign = crypto.createHash('md5').update(signData).digest('hex');
    var body = consts.BIRD.GAMEID + '\20' + '\20' + '\20' + JSON.stringify({"gameId":consts.BIRD.GAMEID, "ts":ts, "sign":sign});
    self.sendData(consts.MSG.MSG_INNER_SERVER_REGISTER | consts.MSG.ID_REQ, body);
};

pro.processSocket = function(){
    var self = this;
    self.birdClient = new socketClent(consts.BIRD.HOST, consts.BIRD.PORT);
    self.birdClient.on('on_connect', function(){
        self.registerToBirdSvr();
    });
    self.birdClient.on('on_data', function(data){
        var dataBuffer = new Buffer(data);
        var msgId = dataBuffer.readUInt32LE(0, 4);
        var bodyBufferLength = dataBuffer.readUInt32LE(4, 4);
        logger.debug('===========================================req,data:'+data);
        var bodyBuffer = new Buffer(bodyBufferLength);
        dataBuffer.copy(bodyBuffer, 0, 12, dataBuffer.length);
        var body = bodyBuffer.toString();
        switch (msgId){
            case consts.MSG.MSG_INNER_SERVER_REGISTER | consts.MSG.ID_ACK:
            {
                self.OnRegisterResponse(msgId, body);
                break;
            }
            case consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_REQ:
            {
                self.OnGetRoomCfg(msgId, body);
                break;
            }
            case consts.MSG.MSGID_QUICK_START | consts.MSG.ID_REQ:
            {
                self.SendQuickStartMsg(msgId, body);
                break;
            }
            default:
            {
                self.SendGameMsg(msgId, body);
                break;
            }
        }
    })
};

pro.OnRegisterResponse = function(msgId, body){
    var self = this;
    self.birdClient.setRegister(true);
    var list = body.split('\20');
    var data = JSON.parse(list[3]);
    var http = data['http'];
    lobby.SetBirdDataByField('http', http,function(err){});
};

E_GET_ROOM_CFG_FAILED = 1;
pro.OnGetRoomCfg = function(msgId, body){
    var self = this;
    var list = body.split('\20');
    var gid = parseInt(list[0]);
    var userId = parseInt(list[2]);
    var roomId = consts.Macro.ROOMS[0];
    lobby.GetBirdLockStatus(userId, function(err, gameId){
        if(err){
            var reason = '系统未知错误！';
            var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
            self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
            return;
        }
        if(gameId != 0 && gameId != consts.BIRD.GAMEID){
            var reason = '您当前正在其他场次游戏中，请稍后再试！';
            if(gameId == 10002){
                reason = '您当前正在龙虎斗游戏中，请稍后再试！';
            }
            var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
            self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
            return;
        }
        lobby.GetBirdUserInfo(userId, function(err, userInfo){
            if(err){
                var reason = '系统未知错误！';
                var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
                self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
                return;
            }
            var coins = parseInt(userInfo.chip);
            lobby.GetRoomInfo(roomId, function(err, roomInfo){
                if(err){
                    var reason = '系统未知错误！';
                    var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
                    self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
                    return;
                }
                var minCoins = parseInt(roomInfo['minCoins']);
                var limitWinCoins = parseInt(roomInfo['limitWinCoins']);
                if(minCoins > 0 && coins < minCoins){
                    var reason = '您最少需要'+minCoins+'金币才可以进入百人牛牛游戏哦！';
                    var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
                    self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
                    return;
                }
                lobby.GetBirdDataByField('gameStatus', function(err, gameStatus){
                    if(!err && gameStatus){
                        if(parseInt(gameStatus) == 2){
                            var reason = '百人牛牛游戏正在维护中！';
                            var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
                            self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
                            return;
                        }
                    }
                    lobby.GetDayInfo(userId, function(err, dayInfo){
                        if(!err && dayInfo && dayInfo.winCoins){
                            var winCoins = parseInt(dayInfo.winCoins);
                            if(winCoins < -limitWinCoins || winCoins > limitWinCoins){
                                var reason = '您今日的输赢金币已经超过限制，为保护您的账户安全，请明日再来继续游戏！';
                                var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":E_GET_ROOM_CFG_FAILED, "reason":reason});
                                self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
                                return;
                            }
                        }
                        var data = consts.BIRD.GAMEID + '\20' + '\20' + userId + '\20' + JSON.stringify({"result":0, 'rooms':[{'roomId':roomId, 'xiaZhuTime':parseInt(roomInfo['xiaZhuTime']), 'faPaiTime':parseInt(roomInfo['faPaiTime']),
                            'jiesuanTime':parseInt(roomInfo['jiesuanTime']), 'minCoins':parseInt(roomInfo['minCoins']), 'maxCoins':parseInt(roomInfo['maxCoins']), 'chips':JSON.parse(roomInfo['chips'])}], 'addressMaxCoins':parseInt(roomInfo['addressMaxCoins']), 'playerMultiple':parseInt(roomInfo['playerMultiple'])});
                        self.sendData(consts.MSG.MSGID_GET_ROOM_CFG | consts.MSG.ID_ACK, data);
                    })
                })
            })
        })
    })
};

pro.sendData = function(msgId, body){
    var self = this;
    logger.debug('===========================================res, data:'+body);
    var bodyBuffer = new Buffer(body);
    var dataBuffer = new Buffer(12 + bodyBuffer.length);
    dataBuffer.writeUInt32LE(msgId, 0);
    dataBuffer.writeUInt32LE(bodyBuffer.length, 4);
    dataBuffer.writeUInt32LE(0, 8);
    bodyBuffer.copy(dataBuffer, 12, 0, bodyBuffer.length);
    self.birdClient.socketSend(dataBuffer, function(err){});
};

pro.OnInterMsg = function(userId, msgId, data){
    var self = this;
    if(msgId == (consts.MSG.MSGID_ROBOT_JOIN_TABLE | consts.MSG.ID_REQ)){
        self.HandleScriptMessage(msgId, data);
    }else{
        self.sendData(msgId, data);
    }
};

pro.SendQuickStartMsg = function(msgId, data){
    var self = this;
    self.app.rpc.quickStart.quickStartRemote.OnMsg('quickStart-server-1', self.app.getServerId(), -1, msgId, data, function(err){
    })
};

pro.SendGameMsg = function(msgId, data){
    var self = this;
    var list = data.split('\20');
    var userId = parseInt(list[2]);
    data = JSON.parse(list[3]);
    self.app.rpc.gameBaiRen.gameBaiRenRemote.OnMsg('game-server-1', self.app.getServerId(), userId, msgId, data, function(err){
    });
};

pro.HandleScriptMessage = function(msgId, data){
    var self = this;
    switch (msgId){
        case consts.MSG.MSGID_ROBOT_JOIN_TABLE | consts.MSG.ID_REQ:
        {
            var serverId = data.serverId;
            var serverType = data.serverType;
            var userId = data.userId;
            if(serverType == 'gameBaiRen'){
                self.app.rpc.gameBaiRen.gameBaiRenRemote.OnMsg(serverId, self.app.getServerId(), userId, msgId, data, function(err){
                });
            }
            break;
        }
    }
};

module.exports = server;

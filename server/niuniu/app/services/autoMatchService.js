var pomelo = require('pomelo');
var redis = require('redis');
var lobby = require('./lobby');
var consts = require('../consts/consts');
var async = require('async');
var os = require('os');
var crypto = require('crypto');
var logger = require('pomelo-logger').getLogger('niuniu', __filename);

var autoMatchService = function(app) {
    var self = this;
    self.app = app;
    self.tmLast = 0;
    self.nLastGrep = 2;

    self.nRobotNum = 20;
    self.tmRobotNum = 0;
    self.nRobotNumGrep = 2;

    self.tmReportOnlineNum = 0;
    setInterval(self.OnTimer, 2000, self);
};

module.exports = autoMatchService;
pro = autoMatchService.prototype;

pro.OnTimer = function(ptr){
    var self = ptr;
    var tmNow = new Date().getTime()/1000;
    if(tmNow - self.tmLast > self.nLastGrep){
        self.autoMatch_bairen();
        self.nLastGrep = lobby.GetRandomNum(4, 8);
        self.tmLast = tmNow;
    }
    if(tmNow - self.tmRobotNum > self.nRobotNumGrep){
        self.nRobotNum = lobby.GetRandomNum(22, 27);
        self.nRobotNumGrep = lobby.GetRandomNum(50, 100);
        self.tmRobotNum = tmNow;
    }
    if(tmNow - self.tmReportOnlineNum > 15*60){
        self.reportOnlineNum();
        self.tmReportOnlineNum = tmNow;
    }
    self.CheckUserReqSitList();
};

pro.CheckUserReqSitList = function(){
    var self = this;
    lobby.GetUserReqSitList(function(err, userList){
        if(err){
            return;
        }
        userList.forEach(function(userId){
            lobby.GetUserStatus(userId, function(err, status, location){
                if(!err){
                    if(status != 0 || !location){
                        lobby.RemUserFromReqSitList(userId);
                    }else{
                        var tmNow = parseInt(new Date().getTime()/1000);
                        var freshTime = parseInt(location.freshTime);
                        if(tmNow - freshTime > 10){
                            lobby.RemUserFromReqSitList(userId);
                            lobby.KickUserOff_lua(userId, location.roomId, location.tableId, function(err, seatId, beforeCnt, afterCnt){
                                if(err || beforeCnt == afterCnt){
                                    logger.error(err+',CheckUserReqSitList,KickUserOff_lua failed,seatId:'+seatId+',beforeCnt:'+beforeCnt+',afterCnt:'+afterCnt);
                                }else{
                                    logger.debug(err+',CheckUserReqSitList,KickUserOff_lua success,seatId:'+seatId+',beforeCnt:'+beforeCnt+',afterCnt:'+afterCnt);
                                }
                            })
                        }
                    }
                }
            })
        })
    })
};

pro.ReqGameSvrdRobotJoinTable = function(serverId, serverType, userId, tableId, seatId){
    var self = this;
    var msgId = consts.MSG.MSGID_ROBOT_JOIN_TABLE | consts.MSG.ID_REQ;
    var msg = {serverId:serverId, serverType:serverType, userId:parseInt(userId), tableId:parseInt(tableId), seatId:parseInt(seatId)};
    self.app.rpc.connector.connectorRemote.OnInterMsg('connector-server-1', parseInt(userId), msgId, msg, function(err){
    });
};

pro.robotIn_bairen = function(roomId, tableId){
    var self = this;
    var maxPlayerNum = 100;
    lobby.GetTableInfo(tableId, function(err, tableInfo){
        if(err){
            return;
        }
        var playerNum = parseInt(tableInfo['playerNum']);
        if(playerNum >= maxPlayerNum){
            logger.debug(err+',autoMatch_bairen big playerNum:'+playerNum);
            return;
        }

        var robotNum = parseInt(tableInfo['robotNum']);
        if(robotNum >= self.nRobotNum){
            logger.debug(err+',autoMatch_bairen big robotNum:'+robotNum);
            return;
        }

        var joinNum = self.nRobotNum - robotNum;
        var count = 0;
        async.whilst(function(){
                return count < joinNum;
            },
            function(cb){
                lobby.GetRobotFromIdleList_bairen(roomId, consts.BaiRobotType.robot_type_stand, function(err, robotId){
                    logger.debug('autoMatch_bairen, GetRobotFromIdleList_bairen, robotId:'+robotId);
                    if(err){
                        logger.debug(err+',autoMatch_bairen GetRobotFromIdleList');
                        cb(err);
                        return;
                    }
                    self.ReqGameSvrdRobotJoinTable(tableInfo['serverId'], lobby.GetServerType(roomId), robotId, tableId, -1);
                    lobby.HincrbyTableInfoByField(tableId, 'playerNum', 1);
                    lobby.HincrbyTableInfoByField(tableId, 'robotNum', 1);
                    count++;
                    cb(null);
                })
            },
            function(err){
            });
    })
};

pro.autoMatch_bairen = function(){
    var self = this;
    lobby.GetBirdDataByField('gameStatus', function(err, gameStatus){
        if(!err && gameStatus){
            if(parseInt(gameStatus) == 2){
                return;
            }
        }
        self.robotIn_bairen(101, 101);
    })
};

pro.address = function(){
    var self = this;
    var network = os.networkInterfaces();
    for(var i = 0; i < network.eth0.length; i++) {
        var json = network.eth0[i];
        if(json.family == 'IPv4') {
            return json.address;
        }
    }
};

pro.GetReportHost = function(){
    var self = this;
    var address = self.address();
    if(address == '192.168.1.133'){
        return '192.168.1.21';
    }else if(address == '211.155.95.182'){
        return 'bntest.dapai2.com';
    }else{
        return 'bncenter.dapai2.com';
    }
};

pro.reportOnlineNum = function(){
    var self = this;
    lobby.GetTableInfo(101, function(err, tableInfo){
        var playerNum = 0;
        if(!err){
            playerNum = parseInt(tableInfo['playerNum']);
        }
        var ts = parseInt(new Date().getTime()/1000);
        var signData = 'gameId=' + 2 + '&ts=' + ts + '&token=' + consts.BIRD.STAT_TOKEN;
        var sign = crypto.createHash('md5').update(signData).digest('hex');
        var host = self.GetReportHost();
        lobby.reqWebSvrd2(host, 80, '/show_online_niu/add', {'online_data':JSON.stringify({'gameId':2, 'ts':ts, 'sign':sign, 'online':[playerNum]})}, function(err, data){
            console.log(err+',reportOnlineNum:'+JSON.stringify(data));
        });
    })
};

var lobby = require('./lobby');
var consts = require('../consts/consts');
var logger = require('pomelo-logger').getLogger('niuniu', __filename);

var quickStartService = function(app) {
    var self = this;
    self.app = app;
};

module.exports = quickStartService;
pro = quickStartService.prototype;

pro.SendBirdMsg = function(remoteServerId, roomId, uid, msgId, msg){
    var self = this;
    msg = consts.BIRD.GAMEID + '\20' + roomId + '\20'+ uid + '\20' + JSON.stringify(msg);
    self.app.rpc.connector.connectorRemote.OnInterMsg(remoteServerId, uid, msgId | consts.MSG.ID_ACK, msg, function(err){
    });
};

pro.OnMsg = function(remoteServerId, userId, msgId, data){
    var self = this;
    switch (msgId){
        case consts.MSG.MSGID_QUICK_START | consts.MSG.ID_REQ:
        {
            self.OnQuickStart(remoteServerId, userId, data);
            break;
        }
        default:
        {
            break;
        }
    }
};

pro.JoinTable = function(userId, roomId, lastTableId, cb){
    var self = this;
    var gameServices = self.app.getServersByType(lobby.GetServerType(roomId));
    if(!gameServices || gameServices.length == 0) {
        cb(consts.QuickStart.quick_start_failed_unknown);
        return;
    }
    var services = [];
    for(var i = 0; i < gameServices.length; i++){
        services.push(gameServices[i].id);
    }
    console.log('==============JoinTable,userId:'+userId+',roomId:'+roomId+',serices:'+JSON.stringify(services));
    lobby.Join2Table_lua(userId, roomId, services, lastTableId, function(err, serverId, targetRoomId, tableId, seatId, beforeCnt, afterCnt){
        logger.debug(err+',JoinTable seatId:'+seatId+',beforeCnt:'+beforeCnt+',afterCnt:'+afterCnt);
        if(err){
            cb(consts.QuickStart.quick_start_failed_unknown);
            return;
        }
        if(tableId < 0){
            cb(consts.QuickStart.quick_start_failed_unknown);
            return;
        }
        cb(null, serverId, targetRoomId, tableId, seatId);
    })
};

pro.FindAvalableRoom = function(coins, roomId, cb){
    var self = this;
    lobby.GetRoomInfo(roomId, function(err, roomInfo){
        if(err){
            cb(consts.QuickStart.quick_start_failed_param_roomid);
            return;
        }
        var minCoins = parseInt(roomInfo['minCoins']);
        var maxCoins = parseInt(roomInfo['maxCoins']);
        if (minCoins > 0 && coins < minCoins){
            cb(consts.QuickStart.quick_start_failed_coins_small);
            return;
        }
        if (maxCoins > 0 && coins > maxCoins){
            cb(consts.QuickStart.quick_start_failed_coins_big);
            return;
        }
        cb(null);
    })
};

pro.OnQuickStart = function(remoteServerId, userId, data){
    var self = this;
    var list = data.split('\20');
    userId = parseInt(list[2]);
    data = JSON.parse(list[3]);
    var roomId = parseInt(data.roomId);
    logger.debug('quickStart,userId:'+userId+',roomId:'+roomId);
    lobby.GetUserStatus(userId, function(err, status, location){
        if(err){
            logger.error('quickStart,userId:'+userId+',GetUserStatus error:'+JSON.stringify(err));
            self.SendBirdMsg(remoteServerId, roomId, userId, consts.MSG.MSGID_QUICK_START, {result:consts.QuickStart.quick_start_failed_unknown});
            return;
        }
        lobby.GetBirdUserInfo(userId, function(err, userInfo){
            if(err){
                logger.error('quickStart,userId:'+userId+',GetBirdUserInfo error:'+JSON.stringify(err));
                self.SendBirdMsg(remoteServerId, roomId, userId, consts.MSG.MSGID_QUICK_START, {result:consts.QuickStart.quick_start_failed_unknown});
                return;
            }
            var coins = parseInt(userInfo.chip);
            //在游戏中
            if(location){
                var res = {'result':0, 'serverId':location['serverId'], 'roomId':parseInt(location['roomId']), 'tableId':parseInt(location['tableId']), 'seatId':parseInt(location['seatId'])};
                logger.debug('quickStart,userId:'+userId+',old location, res:'+JSON.stringify(res));
                self.SendBirdMsg(remoteServerId, roomId, userId, consts.MSG.MSGID_QUICK_START, res);
                return;
            }
            self.FindAvalableRoom(coins, roomId, function(result){
                if(result){
                    logger.error('quickStart,userId:'+userId+',FindAvalableRoom error:'+JSON.stringify(result));
                    self.SendBirdMsg(remoteServerId, roomId, userId, consts.MSG.MSGID_QUICK_START, {result:result});
                    return;
                }
                self.JoinTable(userId, roomId, -1, function(result, serverId, targetRoomId, tableId, seatId){
                    if(result){
                        logger.error('============================quickStart,userId:'+userId+',JoinTable error:'+JSON.stringify(result));
                        self.SendBirdMsg(remoteServerId, roomId, userId, consts.MSG.MSGID_QUICK_START, {result:result});
                        return;
                    }
                    var res = {'result':0, 'serverId':serverId, 'roomId':parseInt(targetRoomId), 'tableId':parseInt(tableId), 'seatId':parseInt(seatId)};
                    logger.debug('quickStart,userId:'+userId+',JoinTable res:'+JSON.stringify(res));
                    self.SendBirdMsg(remoteServerId, roomId, userId, consts.MSG.MSGID_QUICK_START, res);
                });
            })
        })
    });
};

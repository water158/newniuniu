/**
 * Created by wjl on 2015/9/18.
 */
var consts = require('../../consts/consts');
var logger = require('pomelo-logger').getLogger('logic_bairen', __filename);

var player = function(userId, app, gameService) {
    var self = this;
    self.app = app;
    self.gameService = gameService;
    self.serverId = -1;
    self.m_nTableId = -1;
    self.m_nRecycleTime = 0;
    self.m_nUserId = parseInt(userId);
    self.m_bOffline = false;
};

module.exports = player;
pro = player.prototype;

pro.SendMsg = function(msgId, msg){
    var self = this;
    if(!self.m_bOffline){
        msg = consts.BIRD.GAMEID + '\20' + '\20'+ self.m_nUserId + '\20' + JSON.stringify(msg);
        self.app.rpc.connector.connectorRemote.OnInterMsg(self.serverId, self.m_nUserId, msgId, msg, function(err){
        });
    }
};

pro.JoinTable = function(tableId, seatId){
    var self = this;
    self.gameService.CreateTable(tableId, function(err, tempTable){
        if(err){
            logger.debug('JoinTable, CreateTable error, userId:'+self.m_nUserId+',tableId:'+tableId);
            self.SendMsg(consts.MSG.MSGID_JOIN_TABLE | consts.MSG.ID_ACK, {'result':consts.JoinTable.join_table_failed_id});
            return;
        }
        tempTable.JoinTable(self.m_nUserId, seatId, function(err, result){
            if(err){
                self.SendMsg(consts.MSG.MSGID_JOIN_TABLE | consts.MSG.ID_ACK, {'result':result});
                self.m_bOffline = true;
                return;
            }
            self.m_nTableId = tableId;
            self.m_nRecycleTime = 0;
        })
    })
};

pro.OnJoinTable = function(msg){
    var self = this;
    var tableId = parseInt(msg['tableId']);
    var seatId = parseInt(msg['seatId']);
    self.m_bOffline = false;
    if(self.m_nTableId > 0 && self.m_nTableId != tableId){
        logger.debug('warning OnJoinTable, m_nTableId:'+self.m_nTableId+',tableId:'+tableId);
        self.SendMsg(consts.MSG.MSGID_JOIN_TABLE | consts.MSG.ID_ACK, {'result':consts.JoinTable.join_table_failed_multi});
    }else{
        self.JoinTable(tableId, seatId);
    }
};

pro.OnRobotJoinTable = function(msg){
    var self = this;
    var tableId = parseInt(msg['tableId']);
    var seatId = parseInt(msg['seatId']);
    logger.debug('OnRobotJoinTable, userId:'+self.m_nUserId+',seatId:'+seatId);
    self.m_bOffline = false;
    self.gameService.CreateTable(tableId, function(err, tempTable){
        if(err){
            logger.debug('RobotJoinTable, CreateTable error, userId:'+self.m_nUserId+',tableId:'+tableId);
            return;
        }
        tempTable.RobotJoinTable(self.m_nUserId, seatId, function(err, result){
            if(err){
                logger.debug('RobotJoinTable, RobotJoinTable error, userId:'+self.m_nUserId);
                self.m_bOffline = true;
                return;
            }
            self.m_nTableId = tableId;
            self.m_nRecycleTime = 0;
        })
    })
};

pro.OnLeaveTable = function(msg){
    var self = this;
    self.gameService.GetTableByID(self.m_nTableId, function(err, tempTable){
        if(err){
            logger.debug('OnLeaveTable, GetTableByID error');
            self.SendMsg(consts.MSG.MSGID_LEAVE_TABLE | consts.MSG.ID_ACK, {'result':consts.LeaveTable.leave_table_failed_id});
            return;
        }
        tempTable.LeaveTable(self.m_nUserId, function(err, result){
            if(err){
                self.SendMsg(consts.MSG.MSGID_LEAVE_TABLE | consts.MSG.ID_ACK, {'result':result});
                return;
            }
            self.m_nTableId = -1;
        })
    })
};

pro.OnBroken = function(){
    var self = this;
    self.gameService.GetTableByID(self.m_nTableId, function(err, tempTable){
        if(!err){
            tempTable.Offline(self.m_nUserId, function(err){
                self.m_nTableId = -1;
                self.m_nRecycleTime = new Date().getTime()/1000;
            })
        }else{
            self.m_nTableId = -1;
            self.m_nRecycleTime = new Date().getTime()/1000;
        }
    });
};

pro.OnReady = function(){
    var self = this;
    self.gameService.GetTableByID(self.m_nTableId, function(err, tempTable){
        if(err){
            logger.debug('OnReady, GetTableByID error');
            self.SendMsg(consts.MSG.MSGID_LEAVE_TABLE | consts.MSG.ID_ACK, {'result':consts.Ready.ready_failed_id});
            return;
        }
        tempTable.Ready(self.m_nUserId, function(err, result){
            if(err){
                self.SendMsg(consts.MSG.MSGID_READY | consts.MSG.ID_ACK, {'result':result});
            }
        })
    })
};

pro.LeaveTable = function(){
    var self = this;
    self.m_nTableId = -1;
};

pro.Attach = function(serverId){
    var self = this;
    self.serverId = serverId;
};

pro.OnMsg = function(remoteServerId, userId, msgId, msg){
    var self = this;
    self.Attach(remoteServerId);
    switch (msgId){
        case consts.MSG.MSGID_JOIN_TABLE | consts.MSG.ID_REQ:
        {
            self.OnJoinTable(msg);
            break;
        }
        case consts.MSG.MSGID_ROBOT_JOIN_TABLE | consts.MSG.ID_REQ:
        {
            self.OnRobotJoinTable(msg);
            break;
        }
        case consts.MSG.MSGID_READY | consts.MSG.ID_REQ:
        {
            self.OnReady(msg);
            break;
        }
        case consts.MSG.MSGID_LEAVE_TABLE | consts.MSG.ID_REQ:
        {
            self.OnLeaveTable(msg);
            break;
        }
        case consts.MSG.MSGID_BROKEN | consts.MSG.ID_NTF:
        {
            self.OnBroken();
            break;
        }
        default:
        {
            self.gameService.GetTableByID(self.m_nTableId, function(err, table){
                if(!err){
                    table.OnClientMsg(self.m_nUserId, msgId, msg);
                }
            });
            break;
        }
    }
};

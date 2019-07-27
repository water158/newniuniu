/**
 * Created by wjl on 2015/9/18.
 */
var logic = require('./logic');
var lobby = require('../lobby');
var consts = require('../../consts/consts');
var logger = require('pomelo-logger').getLogger('logic_bairen', __filename);

var table = function(tableId, app, gameService) {
    var self = this;
    self.app = app;
    self.gameService = gameService;
    self.m_nTableId = tableId;
    self.m_pLogic = null;
};

module.exports = table;
pro = table.prototype;

pro.Init = function(cb){
    var self = this;
    self.m_nRecycleTime = 0;
    self.m_bPlaying = false;
    self.m_pLogic = new logic(self.app, self);

    self.m_pLogic.OnInit(function(err){
        if(err){
            delete self.m_pLogic;
            self.m_pLogic = null;
            cb(err);
        }else{
            cb(null);
        }
    })
};

pro.GetTableId = function(){
    var self = this;
    return self.m_nTableId;
};

pro.CheckRecycle = function(cb){
    var self = this;
    if(self.m_nRecycleTime != 0){
        self.m_pLogic.OnInit(function(err) {
            if (err) {
                cb('logic init error', consts.JoinTable.join_table_failed_unknown);
                return;
            }
            cb(null);
        });
    }else{
        cb(null);
    }
};

pro.RobotJoinTable = function(userId, seatId, cb){
    var self = this;
    self.CheckRecycle(function(err){
        if(err){
            logger.debug('RobotJoinTable, CheckRecycle error, userId:'+userId);
            cb(err);
            return;
        }
        self.m_pLogic.OnRobotJoin(userId, seatId, function(err, result){
            logger.debug(err+',RobotJoinTable, OnRobotJoin result:'+result);
            if(!err){
                self.m_nRecycleTime = 0;
                cb(null);
            }else{
                if(result != consts.JoinTable.join_table_failed_already_join){
                    lobby.PushRobotToList(userId);
                    self.m_pLogic.RemovePlayer(userId);
                }
                cb(err, result);
            }
        })
    })
};

pro.JoinTable = function(userId, seatId, cb){
    var self = this;
    self.CheckRecycle(function(err){
        if(err){
            logger.debug('JoinTable, CheckRecycle error, userId:'+userId);
            cb(err);
            return;
        }
        self.m_pLogic.OnUserJoin(userId, seatId, function(err, result){
            logger.debug(err+',JoinTable, OnUserJoin result:'+result);
            if(!err){
                self.SendClientMsgTo(userId, consts.MSG.MSGID_JOIN_TABLE|consts.MSG.ID_ACK, {'result':consts.JoinTable.join_table_success});
                self.m_pLogic.OnNotifyBoardInfo(userId);
                self.m_nRecycleTime = 0;
                cb(null);
            }else{
                var eState = self.m_pLogic.OnGetUserState(userId);
                if(eState != consts.UserState.user_state_unknown){
                    self.Reconnect(userId, seatId);
                    cb(null);
                }else{
                    cb(err, result);
                }
            }
        })
    })
};

pro.Reconnect = function(userId, seatId){
    var self = this;
    self.SendClientMsgTo(userId, consts.MSG.MSGID_JOIN_TABLE | consts.MSG.ID_ACK, {'result':consts.JoinTable.join_table_reconnect});
    self.m_pLogic.OnNotifyBoardInfo(userId);
    self.m_nRecycleTime = 0;
};

pro.LeaveTable = function(userId, cb){
    var self = this;
    self.m_pLogic.OnUserLeave(userId, function(err, result){
        if(!err){
            self.SendClientMsgTo(userId, consts.MSG.MSGID_LEAVE_TABLE|consts.MSG.ID_ACK, {'result':consts.LeaveTable.leave_table_success});
        }
        cb(err, result);
    });
};

pro.Ready = function(userId, cb){
    var self = this;
    self.m_pLogic.OnReady(userId, function(err, result){
        if(!err){
            self.SendClientMsgTo(userId, consts.MSG.MSGID_READY|consts.MSG.ID_ACK, {'result':consts.Ready.ready_success});
        }
        cb(err, result);
    });
};

pro.Offline = function(userId, cb){
    var self = this;
    self.m_pLogic.OnOffline(userId, function(err){
        cb(err);
    })
};

pro.SendClientMsgTo = function(userId, msgId, msg){
    var self = this;
    self.gameService.GetPlayerByID(userId, function(err, player){
        if(!err){
            player.SendMsg(msgId, msg);
        }
    })
};

pro.NotifyEvent = function(msgId, msg){
    var self = this;
    var allMap = self.m_pLogic.OnGetAllPlayer(false);
    for(var userId in allMap){
        if(allMap[userId] == consts.UserIdentity.identity_type_player){
            self.SendClientMsgTo(userId, msgId, msg);
        }
    }
};

pro.NotifyEventTo = function(userId, msgId, msg){
    var self = this;
    if(!self.m_pLogic.IsRobot(userId)){
        self.SendClientMsgTo(userId, msgId, msg);
    }
};

pro.OnClientMsg = function(userId, msgId, msg){
    var self = this;
    self.m_pLogic.OnClientMsg(userId, msgId, msg);
};

pro.KickOffUser = function(userId, reason, kickedUserId, desc){
    var self = this;
    var eventList = [];
    eventList.push({eventType:consts.TableEvent.table_event_kick_off, userId:userId, kickedUserId:kickedUserId, kickReason:reason, desc:desc});
    self.NotifyEventTo(kickedUserId, consts.MSG.MSGID_TABLE_EVENT | consts.MSG.ID_NTF, {'eventList':eventList});
    self.gameService.GetPlayerByID(kickedUserId, function(err, player){
        if(!err){
            player.LeaveTable();
        }
    })
};

pro.SetRecycleFlag = function(){
    var self = this;
    self.m_nRecycleTime = new Date().getTime()/1000;
    logger.debug('====================================SetRecycleFlag,tableId:'+self.m_nTableId);
};

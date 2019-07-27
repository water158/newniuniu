/**
 * Created by ddz-001 on 2015/9/21.
 */
var stPlayerInfo = require('./stPlayerInfo');
var stUserInfo = require('./stUserInfo');
var lobby = require('../lobby');
var consts = require('../../consts/consts');
var logger = require('pomelo-logger').getLogger('logic_bairen', __filename);

var NN_CHECK_SVRD_ADD_TIME = 1;
var logic = function(app, pTable){
    var self = this;
    self.app = app;
    self.m_pTable = pTable;
    self.tableInfo = {};//桌子信息
    self.roomInfo = {}; //房间信息
    self.playersInfo = []; //庄家、天、地、玄、黄五个位置的信息
    for(var i = 0; i < 5; i++){
        var tempPlayer = new stPlayerInfo();
        self.playersInfo.push(tempPlayer);
    }
    self.allCards = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51];
    self.leftCards = [];
    self.allCardsList = [];
    self.allCardsListIndex = 0;
    for(var i = 0; i < 10; i++){
        self.allCardsList.push([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51]);
    }
    self.Shuffle();

    self.bInitOK = false;  //未初始化
    self.usersMap = {};    //所有进入房间的玩家
    self.checkTime = 0;
    self.checkType = consts.BaiTimeOutType.timeout_type_unknown;
    self.gameStatus = consts.BaiGameStatus.game_status_unknown;
    self.hInterval = null;

    self.bankerCoinsChg = 0;                       //本局庄家输赢金币
    self.totalXiaZhuCoins = {1:0,2:0,3:0,4:0};     //所有玩家在各个位置的下注金额
    self.totalXiaZhuDetail = {1:[],2:[],3:[],4:[]};//所有的下注
    self.waitXiaZhuDetail = {1:[],2:[],3:[],4:[]}; //等待处理的下注
    self.winHistory = [];                          //胜负历史记录
    self.incomeRank = [];                          //收益排行
    self.totalPlayerNum = lobby.GetRandomNum(65, 75);//总的玩家人数
    self.broadcastList = [];                       //本局的广播列表
};

module.exports = logic;
pro = logic.prototype;

pro.debug = function(data){
    var self = this;
    logger.debug('T'+self.m_pTable.GetTableId()+': '+data);
};

pro.error = function(data){
    var self = this;
    logger.error('T'+self.m_pTable.GetTableId()+': '+data);
};

pro.SetTimeOut = function(type, time){
    var self = this;
    self.checkType = type;
    self.checkTime = time;
};

pro.SetGameStatus = function(status){
    var self = this;
    self.gameStatus = status;
};

pro.CheckCoins = function(){
    var self = this;
    for(var userId in self.usersMap){
        (function(userId){
            var userInfo = self.usersMap[userId];
            if(userInfo){
                if(userInfo.eIdentity == consts.UserIdentity.identity_type_robot){
                    if(userInfo.coins < self.roomInfo['chips'][3]){
                        self.debug('CheckCoins,coins small kick off robotId:'+userId);
                        self.RemovePlayer(userId);
                    }
                }else{
                    //判断每天的输赢
                    lobby.GetDayInfo(userId, function(err, dayInfo){
                        if(!err && dayInfo && dayInfo.winCoins){
                            var winCoins = parseInt(dayInfo.winCoins);
                            if(winCoins > self.roomInfo['limitWinCoins']){
                                self.debug('CheckCoins,kick off userId:'+userId+',winCoins:'+winCoins);
                                var desc = '您今日的输赢金币已经超过限制，为保护您的账户安全，请明日再来继续游戏！';
                                self.m_pTable.KickOffUser(-1, consts.KickReason.kick_reason_win_limit_max, userId, desc);
                                self.RemovePlayer(userId);
                                return;
                            }
                            if(winCoins < -self.roomInfo['limitWinCoins']){
                                self.debug('CheckCoins,kick off userId:'+userId+',winCoins:'+winCoins);
                                var desc = '您今日的输赢金币已经超过限制，为保护您的账户安全，请明日再来继续游戏！';
                                self.m_pTable.KickOffUser(-1, consts.KickReason.kick_reason_win_limit_min, userId, desc);
                                self.RemovePlayer(userId);
                            }
                        }
                    })
                }
            }
        })(userId)
    }
};

pro.CheckGameStatus = function(){
    var self = this;
    lobby.GetBirdDataByField('gameStatus', function(err, gameStatus){
        if(!err && gameStatus){
            if(parseInt(gameStatus) == 2){
                for(var userId in self.usersMap){
                    (function(userId){
                        self.debug('CheckGameStatus,kick off userId:'+userId);
                        var desc = '百人牛牛游戏正在维护中！';
                        self.m_pTable.KickOffUser(-1, consts.KickReason.kick_reason_game_close, userId, desc);
                        self.RemovePlayer(userId);
                    })(userId)
                }
            }
        }
    })
};

pro.RobotReqXiaZhu = function(userId, haveJoinedCoins, totalCoins){
    var self = this;
    var address = lobby.GetRandomNum(1,4);
    var maxChipIndex = self.GetMaxChipIndex(haveJoinedCoins, totalCoins, self.roomInfo['playerMultiple']);
    if(maxChipIndex < 0){
        return;
    }
    var chipIndex = 0;
    var randNum = lobby.GetRandomNum(1, 100);
    if(maxChipIndex >= 4){
        if(randNum >= 85){
            chipIndex = 4;
        }else if(randNum >= 50){
            chipIndex = 3;
        }else{
            chipIndex = 2;
        }
    }else if(maxChipIndex >= 3){
        if(randNum >= 90){
            chipIndex = 3;
        }else if(randNum >= 40){
            chipIndex = 2;
        }else{
            chipIndex = 1;
        }
    }else if(maxChipIndex >= 2){
        if(randNum >= 30){
            chipIndex = 2;
        }else{
            chipIndex = 1;
        }
    }else if(maxChipIndex >= 1){
        chipIndex = 1;
    }
    self.ProcessRobotXiaZhu(userId, address, chipIndex);
};

pro.ProcessCheckXiaZhu = function(){
    var self = this;
    if(self.checkTime <= self.roomInfo['xiaZhuTime'] - 2 && self.checkTime >= 2){
        for(var userId in self.usersMap){
            var userInfo = self.usersMap[userId];
            if(userInfo && userInfo.eIdentity == consts.UserIdentity.identity_type_robot){
                if(++userInfo.nClockTime == userInfo.nXiaZhuHappen){
                    //机器人进行下注，并重置时间
                    var xiaZhuCoins = 0;
                    for(var i in userInfo.xiaZhuCoins){
                        xiaZhuCoins += userInfo.xiaZhuCoins[i];
                    }
                    self.RobotReqXiaZhu(userId, xiaZhuCoins, userInfo.coins);
                    userInfo.nClockTime = 0;
                    userInfo.nXiaZhuHappen = lobby.GetRandomNum(1, 3);
                }
            }
        }
    }
    self.ProcessXiaZhu();
    self.checkTime--;
    if(self.checkTime <= 0){
        self.SetGameStatus(consts.BaiGameStatus.game_status_fapai);
        self.SetTimeOut(consts.BaiTimeOutType.timeout_type_fapai, parseInt(self.roomInfo['faPaiTime']));
        self.debug('================================================================change gameStatus faPai');
        self.SetFaPai();
    }
};

pro.ProcessCheckFaPai = function(){
    var self = this;
    self.checkTime--;
    if(self.checkTime == self.roomInfo['faPaiTime'] - 3){
        self.Shuffle();
    }
    if(self.checkTime <= 0){
        self.SetGameStatus(consts.BaiGameStatus.game_status_jiesuan);
        self.SetTimeOut(consts.BaiTimeOutType.timeout_type_jiesuan, parseInt(self.roomInfo['jiesuanTime']));
        self.debug('================================================================change gameStatus jiesuan');
        self.SetGameEnd();
    }
};

pro.ProcessCheckJiesuan = function(){
    var self = this;
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo && userInfo.eState == consts.UserState.user_state_ready){
            continue;
        }
        if(++userInfo.nNoReadyTime >= self.roomInfo['jiesuanTime']){
            self.debug('ProcessCheckJiesuan,kick off userId:'+userId+',nNoReadyTime:'+userInfo.nNoReadyTime);
            self.m_pTable.KickOffUser(-1, consts.KickReason.kick_reason_no_ready, userId, '长时间未准备！');
            self.RemovePlayer(userId);
        }
    }
    self.checkTime--;
    if(self.checkTime == 2){
        self.CheckGameStatus();
        self.CheckCoins();
    }
    if(self.checkTime == self.roomInfo['jiesuanTime'] - 3){
        self.Shuffle();
    }
    if(self.checkTime <= 0){
        //结算倒计时结束，踢掉断线玩家，重置游戏局面
        self.KickOfflineUsers();
        self.ResetParams();
        self.SetGameStatus(consts.BaiGameStatus.game_status_xiazhu);
        self.SetTimeOut(consts.BaiTimeOutType.timeout_type_xiazhu, parseInt(self.roomInfo['xiaZhuTime']));
        self.debug('================================================================change gameStatus xiaZhu');
        self.SetGameStart();
    }
};

pro.OnTimer = function(ptr){
    var self = ptr;
    self.debug('================================================================checkTime:'+self.checkTime);
    if(self.gameStatus == consts.BaiGameStatus.game_status_xiazhu) {//下注时间
        self.ProcessCheckXiaZhu();
    }else if(self.gameStatus == consts.BaiGameStatus.game_status_fapai){//发牌时间
        self.ProcessCheckFaPai();
    }else if(self.gameStatus == consts.BaiGameStatus.game_status_jiesuan){//结算时间
        self.ProcessCheckJiesuan();
    }
};

pro.OnInit = function(cb){
    var self = this;
    //桌子不会回收，这个函数只会调用一次
    self.GetTableInfo(function(err){
        if(err){
            cb(err);
            return;
        }
        self.SetGameStatus(consts.BaiGameStatus.game_status_xiazhu);
        self.SetTimeOut(consts.BaiTimeOutType.timeout_type_xiazhu, parseInt(self.roomInfo['xiaZhuTime']));
        self.debug('================================================================change gameStatus xiaZhu');
        self.SetGameStart();
        if(!self.hInterval){
            self.hInterval = setInterval(self.OnTimer, 1000, self);
        }
        self.bInitOK = true;
        cb(null);
    });
};

pro.GetTableInfo = function(cb){
    var self = this;
    var tableId = self.m_pTable.GetTableId();
    lobby.GetTableInfo(tableId, function(err, tableInfo){
        if(err){
            self.error(err+',GetTableInfo, GetTableInfo error');
            cb('get tableinfo error');
            return;
        }
        if(!tableInfo['roomId']){
            self.error('GetTableInfo, tableinfo error');
            cb('tableinfo error');
            return;
        }
        self.tableInfo['roomId'] = parseInt(tableInfo['roomId']);
        lobby.GetRoomInfo(tableInfo['roomId'], function(err, roomInfo){
            if(err || !roomInfo){
                self.error(err+',GetTableInfo, GetRoomInfo error');
                cb('get roominfo error');
                return;
            }
            if(!roomInfo['xiaZhuTime'] || !roomInfo['faPaiTime'] || !roomInfo['jiesuanTime'] || !roomInfo['minCoins'] || !roomInfo['maxCoins'] || !roomInfo['addressMaxCoins'] || !roomInfo['limitWinCoins'] || !roomInfo['chips'] || !roomInfo['playerMultiple'] || !roomInfo['broadcastCoins'] || !roomInfo['list'] || !roomInfo['changeCardsRate']){
                self.error('GetTableInfo, roominfo error');
                cb('roominfo error');
                return;
            }
            self.roomInfo['xiaZhuTime'] = parseInt(roomInfo['xiaZhuTime']) + NN_CHECK_SVRD_ADD_TIME;
            self.roomInfo['faPaiTime'] = parseInt(roomInfo['faPaiTime']) + NN_CHECK_SVRD_ADD_TIME;
            self.roomInfo['jiesuanTime'] = parseInt(roomInfo['jiesuanTime']) + NN_CHECK_SVRD_ADD_TIME;
            self.roomInfo['minCoins'] = parseInt(roomInfo['minCoins']);
            self.roomInfo['maxCoins'] = parseInt(roomInfo['maxCoins']);
            self.roomInfo['addressMaxCoins'] = parseInt(roomInfo['addressMaxCoins']);
            self.roomInfo['limitWinCoins'] = parseInt(roomInfo['limitWinCoins']);
            self.roomInfo['chips'] = JSON.parse(roomInfo['chips']);
            self.roomInfo['playerMultiple'] = parseInt(roomInfo['playerMultiple']);
            self.roomInfo['broadcastCoins'] = parseInt(roomInfo['broadcastCoins']);
            self.roomInfo['list'] = JSON.parse(roomInfo['list']);
            self.roomInfo['changeCardsRate'] = parseFloat(roomInfo['changeCardsRate']);
            cb(null);
        })
    })
};

pro.RemovePlayer = function(userId){
    var self = this;
    if(self.IsRobot(userId)){
        //机器人，回收就可以了
        lobby.PushRobotToList(userId);
        self.debug('RemovePlayer, PushRobotToList, userId:'+userId);
    }
    delete self.usersMap[userId];
    if(self.totalPlayerNum >= 1 ){
        self.totalPlayerNum--;
    }
    //从桌子信息中踢出
    lobby.KickUserOff_lua(userId, self.tableInfo['roomId'], self.m_pTable.GetTableId(), function(err, seatId, beforeCnt, afterCnt){
        if(err){
            self.debug(err+',RemovePlayer failed, userId:'+userId);
        }else{
            self.debug(err+',RemovePlayer success, userId:'+userId+',seatId:'+seatId);
        }
    })
};

pro.IsUserPlaying = function(userId){
    var self = this;
    var userInfo = self.usersMap[userId];
    if(userInfo && (userInfo.eState >= consts.UserState.user_state_playing || userInfo.eState == consts.UserState.user_state_getout || userInfo.eState == consts.UserState.user_state_offline)){
        return true;
    }
    return false;
};

pro.OnUserLeave = function(userId, cb){
    var self = this;
    var userInfo = self.usersMap[userId];
    self.debug('OnUserLeave,userId:'+userId);
    if(!userInfo){
        self.debug('OnUserLeave,no userInfo');
        cb('no find user',consts.LeaveTable.leave_table_failed_not_join);
        return;
    }
    if(!self.IsUserPlaying(userId)){
        self.RemovePlayer(userId);
        self.debug('OnUserLeave,success userId:'+userId);
        cb(null);
    }else{
        userInfo.eState = consts.UserState.user_state_getout;
        self.debug('OnUserLeave,success userId:'+userId);
        cb('user playing', consts.LeaveTable.leave_table_failed_playing);
    }
};

pro.OnOffline = function(userId, cb){
    var self = this;
    self.debug('OnOffline,userId:'+userId);
    var userInfo = self.usersMap[userId];
    if(!userInfo){
        self.debug('OnOffline,no userInfo');
        cb('no find user');
        return;
    }
    if(!self.IsUserPlaying(userId)){
        self.RemovePlayer(userId);
        self.debug('OnOffline,success userId:'+userId);
        cb(null);
    }else{
        userInfo.eState = consts.UserState.user_state_offline;
        self.debug('OnOffline,success userId:'+userId);
        cb('user playing');
    }
};

pro.OnReady = function(userId, cb){
    var self = this;
    self.debug('OnReady,userId:'+userId);
    var userInfo = self.usersMap[userId];
    if(!userInfo){
        self.debug('OnReady,no userInfo');
        cb('no find user',consts.Ready.ready_failed_error_not_join);
        return;
    }
    if(userInfo.eState != consts.UserState.user_state_free && userInfo.eState != consts.UserState.user_state_sit && userInfo.eState != consts.UserState.user_state_ready){
        self.debug('OnReady,eState error eState:'+userInfo.eState);
        cb('error state',consts.Ready.ready_failed_not_sit_down);
        return;
    }
    userInfo.eState = consts.UserState.user_state_ready;
    self.debug('OnReady,success userId:'+userId);
    cb(null);
};

pro.OnGetUserState = function(userId){
    var self = this;
    var userInfo = self.usersMap[userId];
    if(!userInfo){
        return consts.UserState.user_state_unknown;
    }
    return userInfo.eState;
};

pro.IsJoinTableLegal = function(userId, cb){
    var self = this;
    lobby.GetLocation(userId, function(err, location){
        if(err || !location){
            self.debug('IsJoinTableLegal,GetLocation failed');
            cb(err);
            return;
        }
        if(location['tableId'] != self.m_pTable.GetTableId()){
            self.debug('IsJoinTableLegal,tableId not right');
            cb('tableId not right');
            return;
        }
        cb(null);
    })
};

pro.OnUserJoin = function(userId, seatId, cb){
    var self = this;
    self.debug('OnUserJoin,userId:'+userId+',seatId:'+seatId);
    if(!self.bInitOK){
        self.debug('OnUserJoin, no init');
        cb('no init', consts.JoinTable.join_table_failed_unknown);
        return;
    }
    if (self.usersMap[userId]){
        self.debug('OnUserJoin, already join');
        cb('already join', consts.JoinTable.join_table_failed_already_join);
        return;
    }
    self.GetTableInfo(function(err){
        if(err){
            self.debug('OnUserJoin, GetTableInfo error:'+err);
            cb(err, consts.JoinTable.join_table_failed_unknown);
            return;
        }
        self.IsJoinTableLegal(userId, function(err){
            if(err){
                self.debug('OnUserJoin, IsJoinTableLegal error:'+err);
                cb(err, consts.JoinTable.join_table_failed_unknown);
                return;
            }
            lobby.GetBirdUserInfo(userId, function(err, userInfo){
                if(err){
                    self.debug('OnUserJoin, GetBirdUserInfo error:'+err);
                    cb(err, consts.JoinTable.join_table_failed_unknown);
                    return;
                }
                var coins = parseInt(userInfo['chip']);
                var nick = userInfo['nick'];
                var minCoins = parseInt(self.roomInfo['minCoins']);
                var maxCoins = parseInt(self.roomInfo['maxCoins']);
                var limitWinCoins = parseInt(self.roomInfo['limitWinCoins']);
                if(minCoins > 0 && minCoins > coins){
                    self.debug('OnUserJoin, coins small');
                    cb('money small', consts.JoinTable.join_table_failed_limit_min);
                    return;
                }
                if(maxCoins > 0 && maxCoins < coins){
                    self.debug('OnUserJoin, coins big');
                    cb('money big', consts.JoinTable.join_table_failed_limit_max);
                    return;
                }
                self.totalPlayerNum++;
                lobby.UpdateUserStatus(userId, 1);
                self.usersMap[userId] = new stUserInfo({coins:coins, nick:userInfo['nick'], nSeatID:-1, eState:consts.UserState.user_state_ready, eIdentity:consts.UserIdentity.identity_type_player});
                self.debug('OnUserJoin, success userId:'+userId);
                cb(null);
            })
        })
    })
};

pro.OnRobotJoin = function(userId, seatId, cb){
    var self = this;
    self.debug('OnRobotJoin,userId:'+userId+',seatId:'+seatId);
    if(!self.bInitOK){
        self.debug('OnRobotJoin, no init');
        cb('no init', consts.JoinTable.join_table_failed_unknown);
        return;
    }
    if(userId >= 20000){
        self.debug('OnRobotJoin, userId error');
        cb('userId error', consts.JoinTable.join_table_failed_unknown);
        return;
    }
    if (self.usersMap[userId]){
        self.debug('OnRobotJoin, already join');
        cb('already join', consts.JoinTable.join_table_failed_already_join);
        return;
    }
    self.GetTableInfo(function(err){
        if(err){
            self.debug('OnRobotJoin, GetTableInfo error:'+err);
            cb(err, consts.JoinTable.join_table_failed_unknown);
            return;
        }
        lobby.GetGameInfo(userId, function(err, gameInfo){
            if(err){
                self.debug('OnRobotJoin, GetGameInfo error:'+err);
                cb(err, consts.JoinTable.join_table_failed_unknown);
                return;
            }
            var coins = parseInt(gameInfo['coins']);
            lobby.GetUserInfo(userId, function(err, userInfo){
                if(err){
                    self.debug('OnRobotJoin, GetUserInfo error:'+err);
                    cb(err, consts.JoinTable.join_table_failed_unknown);
                    return;
                }
                self.totalPlayerNum++;
                self.usersMap[userId] = new stUserInfo({coins:coins, nick:userInfo['nick'], nSeatID:-1, eState:consts.UserState.user_state_ready, eIdentity:consts.UserIdentity.identity_type_robot});
                self.usersMap[userId].gamesLimit = lobby.GetRandomNum(8, 12);
                self.debug('OnRobotJoin, success userId:'+userId);
                cb(null);
            })
        })
    })
};

pro.OnClientMsg = function(userId, msgId, msg){
    var self = this;
    switch (msgId){
        case consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_REQ:
        {
            self.HandleClientXiaZhu(userId, msg);
            break;
        }
        case consts.MSG.MSGID_BAI_WIN_HISTORY | consts.MSG.ID_REQ:
        {
            self.HandleClientWinHistory(userId, msg);
            break;
        }
        case consts.MSG.MSGID_BAI_UPDATE_COINS | consts.MSG.ID_REQ:
        {
            self.HandleClientUpdateCoins(userId, msg);
            break;
        }
        default:
        {
            break;
        }
    }
};

pro.IsRobot = function(userId){
    var self = this;
    var userInfo = self.usersMap[userId];
    if(userInfo && userInfo.eIdentity == consts.UserIdentity.identity_type_robot){
        return true;
    }
    return false;
};

pro.NotifyTo = function(userId, msgId, data){
    var self = this;
    if(!self.IsRobot(userId)){
        self.m_pTable.SendClientMsgTo(userId, msgId, data);
    }
};

pro.Notify = function(msgId, data){
    var self = this;
    for(var userId in self.usersMap){
        self.NotifyTo(userId, msgId, data);
    }
};

pro.NotifyExcept = function(targetUserId, msgId, data){
    var self = this;
    for(var userId in self.usersMap){
        if(targetUserId != userId){
            self.NotifyTo(userId, msgId, data);
        }
    }
};

pro.OnNotifyBoardInfo = function(userId){
    var self = this;
    self.debug('OnNotifyBoardInfo,userId:'+userId);
    var userInfo = self.usersMap[userId];
    if(!userInfo){
        self.error('OnNotifyBoardInfo, no userInfo');
        return;
    }
    var ntf = {};
    ntf.gameStatus = self.gameStatus;
    ntf.leftTime = self.checkTime > NN_CHECK_SVRD_ADD_TIME ? self.checkTime - NN_CHECK_SVRD_ADD_TIME : 0;
    ntf.totalPlayerNum = self.totalPlayerNum;
    ntf.coins = userInfo.coins;
    if(self.gameStatus == consts.BaiGameStatus.game_status_xiazhu){
        ntf.xiaZhuCoins = [];
        ntf.totalXiaZhuCoins = [];
        ntf.totalXiaZhuDetail = [[],[],[],[]];
        for(var address = 1; address < 5; address++){
            ntf.xiaZhuCoins.push(userInfo.xiaZhuCoins[address]);
            ntf.totalXiaZhuCoins.push(self.totalXiaZhuCoins[address]);
            for(var i = 0; i < self.totalXiaZhuDetail[address].length; i++){
                ntf.totalXiaZhuDetail[address-1].push(self.totalXiaZhuDetail[address][i].chipIndex);
            }
        }
    }else if(self.gameStatus == consts.BaiGameStatus.game_status_fapai){
        ntf.xiaZhuCoins = [];
        ntf.totalXiaZhuCoins = [];
        ntf.totalXiaZhuDetail = [[],[],[],[]];
        for(var address = 1; address < 5; address++){
            ntf.xiaZhuCoins.push(userInfo.xiaZhuCoins[address]);
            ntf.totalXiaZhuCoins.push(self.totalXiaZhuCoins[address]);
            for(var i = 0; i < self.totalXiaZhuDetail[address].length; i++){
                ntf.totalXiaZhuDetail[address-1].push(self.totalXiaZhuDetail[address][i].chipIndex);
            }
        }
        var cardsData = [];
        for(var i = 0; i < 5; i++){
            cardsData.push({cards:self.playersInfo[i].cardSet, niuCnt:self.playersInfo[i].niuCnt, winFan:self.playersInfo[i].winFan});
        }
        ntf.cardsData = cardsData;
        ntf.coinsChg = userInfo.coinsChg;
        ntf.coins = userInfo.coins;
        ntf.bankerCoinsChg = self.bankerCoinsChg;
        ntf.incomeRank = self.incomeRank;
    }else if(self.gameStatus == consts.BaiGameStatus.game_status_jiesuan){
        ntf.xiaZhuCoins = [];
        ntf.totalXiaZhuCoins = [];
        ntf.totalXiaZhuDetail = [[],[],[],[]];
        for(var address = 1; address < 5; address++){
            ntf.xiaZhuCoins.push(userInfo.xiaZhuCoins[address]);
            ntf.totalXiaZhuCoins.push(self.totalXiaZhuCoins[address]);
            for(var i = 0; i < self.totalXiaZhuDetail[address].length; i++){
                ntf.totalXiaZhuDetail[address-1].push(self.totalXiaZhuDetail[address][i].chipIndex);
            }
        }
        var cardsData = [];
        for(var i = 0; i < 5; i++){
            cardsData.push({cards:self.playersInfo[i].cardSet, niuCnt:self.playersInfo[i].niuCnt, winFan:self.playersInfo[i].winFan});
        }
        ntf.cardsData = cardsData;
        ntf.coinsChg = userInfo.coinsChg;
        ntf.coins = userInfo.coins;
        ntf.bankerCoinsChg = self.bankerCoinsChg;
        ntf.incomeRank = self.incomeRank;
    }
    //先修改用户状态，否则断线或者逃跑的玩家，发送不出去消息
    if(userInfo.eState == consts.UserState.user_state_getout || userInfo.eState == consts.UserState.user_state_offline){
        userInfo.eState = consts.UserState.user_state_playing;
    }
    self.NotifyTo(userId, consts.MSG.MSGID_BAI_BOARDINFO | consts.MSG.ID_NTF, ntf);
    self.debug('OnNotifyBoardInfo,success userId:'+userId+',boardInfo:'+JSON.stringify(ntf)+',userInfo:'+JSON.stringify(userInfo));
};

pro.GetMaxChipIndex = function(haveJoinedCoins, totalCoins, multiple){
    var self = this;
    var nLen = self.roomInfo['chips'].length;
    for(var i = nLen - 1; i >= 0; i--){
        if(haveJoinedCoins + self.roomInfo['chips'][i] <= (totalCoins + haveJoinedCoins)/multiple){
            return i;
        }
    }
    return -1;
};

//定时通知前端，其他人的下注情况
pro.ProcessXiaZhu = function(){
    var self = this;
    var xiaZhuDetail = [];
    var totalXiaZhuCoins = [];
    var bNotify = false;
    for(var address = 1; address < 5; address++){
        var list = [];
        for(var i in self.waitXiaZhuDetail[address]){
            list.push(self.waitXiaZhuDetail[address][i].userId);
            list.push(self.waitXiaZhuDetail[address][i].chipIndex);
        }
        if(list.length > 0){
            self.waitXiaZhuDetail[address] = [];
            bNotify = true;
        }
        xiaZhuDetail[address-1] = list;
        totalXiaZhuCoins.push(self.totalXiaZhuCoins[address]);
    }
    if(bNotify){
        self.debug('ProcessXiaZhu,xiaZhuDetail:'+JSON.stringify(xiaZhuDetail)+',totalXiaZhuCoins:'+JSON.stringify(totalXiaZhuCoins));
        self.Notify(consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_NTF, {xiaZhuDetail:xiaZhuDetail, totalXiaZhuCoins:totalXiaZhuCoins});
    }
};

E_XIAZHU_PARAM_CHIPLIST = 1;    //筹码列表非法
E_XIAZHU_SELF_HANGUP_FAILED = 2;//挂机失败
E_XIAZHU_SELF_COINS_LIMIT = 3;  //你已达到投注上限(可选最低的筹码)
E_XIAZHU_ADDRESS_COINS_LIMIT = 4;  //你已达到该位置投注上限
pro.HandleClientXiaZhu = function(userId, data){
    var self = this;
    var chipList = data.chipList;
    self.debug('==================HandleClientXiaZhu, req userId:'+userId+',chipList:'+chipList);
    if(self.gameStatus != consts.BaiGameStatus.game_status_xiazhu){
        self.debug('HandleClientXiaZhu, gameStatus error');
        return;
    }
    if(chipList.length < 2 || chipList.length %2 != 0){
        self.error('HandleClientXiaZhu, chipList error');
        self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {'result':E_XIAZHU_PARAM_CHIPLIST});
        return;
    }
    var isHangUp = false;
    var reqChipIndex = -1;
    if(chipList.length == 2){
        reqChipIndex = chipList[1];
    }else{
        isHangUp = true;
    }
    //解析数据
    var addressList = [];
    var chipIndexList = [];
    for(var i = 0; i < chipList.length; i+=2){
        addressList.push(chipList[i]);
        chipIndexList.push(chipList[i+1]);
    }

    //检查地址列表
    for(var i = 0; i < addressList.length; i++){
        if([1,2,3,4].indexOf(addressList[i]) < 0){
            self.error('HandleClientXiaZhu, addressList error');
            self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {'result':E_XIAZHU_PARAM_CHIPLIST});
            return;
        }
    }

    //检查筹码索引列表
    var totalChip = 0;
    for(var i = 0; i < chipIndexList.length; i++){
        var chipIndex = chipIndexList[i];
        if(chipIndex < 0 || chipIndex >= self.roomInfo['chips'].length){
            self.error('HandleClientXiaZhu, chipIndexList error');
            self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {'result':E_XIAZHU_PARAM_CHIPLIST});
            return;
        }else{
            totalChip += self.roomInfo['chips'][chipIndex];
        }
    }
    var userInfo = self.usersMap[userId];
    if(!userInfo) {
        self.debug('HandleClientXiaZhu, no user');
        return;
    }

    //开始下注
    var xiaZhuCoins = 0;
    for(var i in userInfo.xiaZhuCoins){
        xiaZhuCoins += userInfo.xiaZhuCoins[i];
    }
    //是否挂机下注
    if(isHangUp){
        if(xiaZhuCoins + totalChip > (userInfo.coins + xiaZhuCoins)/self.roomInfo['playerMultiple']){
            self.error('HandleClientXiaZhu, hangup failed');
            self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {'result':E_XIAZHU_SELF_HANGUP_FAILED});
            return;
        }
    }else{
        //超过自身金币限制，选择合适筹码，替用户下注
        if(userInfo.xiaZhuCoins[addressList[0]] + totalChip > self.roomInfo['addressMaxCoins']){
            self.debug('HandleClientXiaZhu, addressMaxCoins limit');
            self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {'result':E_XIAZHU_ADDRESS_COINS_LIMIT});
            return;
        }
        if(xiaZhuCoins + totalChip > (userInfo.coins + xiaZhuCoins)/self.roomInfo['playerMultiple']){
            var chipIndex = self.GetMaxChipIndex(xiaZhuCoins, userInfo.coins, self.roomInfo['playerMultiple']);
            if(chipIndex < 0){
                self.debug('HandleClientXiaZhu, selfCoins limit');
                self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {'result':E_XIAZHU_SELF_COINS_LIMIT});
                return;
            }
            chipIndexList[0] = chipIndex;
            chipList[1] = chipIndex;
        }
    }

    var oldCoins = userInfo.coins;
    totalChip = 0;
    for(var i = 0; i < addressList.length; i++){
        var address = addressList[i];
        var chipIndex = chipIndexList[i];
        self.waitXiaZhuDetail[address].push({userId:parseInt(userId), chipIndex:chipIndex});
        self.totalXiaZhuDetail[address].push({userId:userId, chipIndex:chipIndex});
        var chip = self.roomInfo['chips'][chipIndex];
        self.totalXiaZhuCoins[address] += chip;
        userInfo.xiaZhuCoins[address] += chip;
        userInfo.totalXiaZhuCoins += chip;
        userInfo.coins -= chip;
        totalChip += chip;
    }

    //更新玩家状态为游戏中，下注了，需要有断线重连
    if(xiaZhuCoins <= 0){
        userInfo.eState = consts.UserState.user_state_playing;
        lobby.UpdateUserStatus(userId, 2);
        lobby.GameBirdLock(userId);
    }
    self.NotifyTo(userId, consts.MSG.MSGID_BAI_XIAZHU | consts.MSG.ID_ACK, {result:0, chipList:chipList, reqChipIndex:reqChipIndex, coins:userInfo.coins});
    self.debug('HandleClientXiaZhu, success userId:'+userId+',chipList:'+chipList+',reqChipIndex:'+reqChipIndex);
    lobby.statCoinsChg(userId, consts.COINSCHG.COINSCHG_XIAZHU, -totalChip, oldCoins, userInfo.coins, '');
    lobby.IncrbyBirdChip(userId, -totalChip, function(err, tempUserId, data){
        self.debug(err+',IncrbyBirdChip, userId:'+tempUserId+',data:'+JSON.stringify(data));
    });
};

pro.ProcessRobotXiaZhu = function(userId, address, chipIndex){
    var self = this;
    //self.debug('ProcessRobotXiaZhu, req userId:'+userId+',address:'+address+',chipIndex:'+chipIndex);
    if([1,2,3,4].indexOf(address) < 0){
        self.error('ProcessRobotXiaZhu, address error');
        return;
    }
    if(chipIndex < 0 || chipIndex >= self.roomInfo['chips'].length){
        self.error('ProcessRobotXiaZhu, chipIndex error');
        return;
    }
    var chip = self.roomInfo['chips'][chipIndex];
    if(self.gameStatus != consts.BaiGameStatus.game_status_xiazhu){
        self.debug('ProcessRobotXiaZhu, gameStatus error');
        return;
    }
    var userInfo = self.usersMap[userId];
    if(!userInfo){
        self.debug('ProcessRobotXiaZhu, no user');
        return;
    }

    //开始下注
    var xiaZhuCoins = 0;
    for(var i in userInfo.xiaZhuCoins){
        xiaZhuCoins += userInfo.xiaZhuCoins[i];
    }
    if(xiaZhuCoins + chip > (userInfo.coins + xiaZhuCoins)/self.roomInfo['playerMultiple']){
        chipIndex = self.GetMaxChipIndex(xiaZhuCoins, userInfo.coins, self.roomInfo['playerMultiple']);
        if(chipIndex < 0){
            self.debug('ProcessRobotXiaZhu, selfCoins limit');
            return;
        }
        chip = self.roomInfo['chips'][chipIndex];
    }

    //下注成功
    self.waitXiaZhuDetail[address].push({userId:parseInt(userId), chipIndex:chipIndex});
    self.totalXiaZhuDetail[address].push({userId:userId, chipIndex:chipIndex});
    self.totalXiaZhuCoins[address] += chip;
    userInfo.xiaZhuCoins[address] += chip;
    userInfo.totalXiaZhuCoins += chip;

    //更新玩家状态为游戏中，下注了，需要有断线重连
    if(xiaZhuCoins <= 0){
        userInfo.eState = consts.UserState.user_state_playing;
    }
    //self.debug('ProcessRobotXiaZhu, success userId:'+userId);
};

//获取输赢历史记录
pro.HandleClientWinHistory = function(userId, data){
    var self = this;
    self.NotifyTo(userId, consts.MSG.MSGID_BAI_WIN_HISTORY | consts.MSG.ID_ACK, {'result':0, 'winHistory':self.winHistory});
};

//更新金币
pro.HandleClientUpdateCoins = function(userId, data){
    var self = this;
    self.debug('HandleClientUpdateCoins, userId:'+userId);
    lobby.GetBirdUserInfo(userId, function(err, tempUserInfo){
        self.debug(err+',HandleClientUpdateCoins,userId:'+userId+',data:'+JSON.stringify(tempUserInfo));
        if(err){
            self.debug('HandleClientUpdateCoins, GetBirdUserInfo error:'+err);
            return;
        }
        var userInfo = self.usersMap[userId];
        if(!userInfo){
            self.debug('HandleClientUpdateCoins, no user');
            return;
        }
        userInfo.coins = parseInt(tempUserInfo['chip']);
        self.NotifyTo(userId, consts.MSG.MSGID_BAI_UPDATE_COINS | consts.MSG.ID_ACK, {'result':0, 'coins':userInfo.coins});
    })
};

pro.BeginCheckNoReady = function(type, userInfo){
    var self = this;
    userInfo.timeOutType = type;
    if(type == consts.BaiTimeOutType.timeout_type_no_ready){
        userInfo.nNoReadyTime = 0;
    }
};

pro.ResetParams = function(){
    var self = this;
    for(var i = 0; i < 5; i++){
        self.playersInfo[i].init();
    }
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo){
            userInfo.init();
            lobby.UpdateUserStatus(userId, 1);
        }
    }
    self.bankerCoinsChg = 0;                       //本局庄家输赢金币
    self.totalXiaZhuCoins = {1:0,2:0,3:0,4:0};     //所有玩家在各个位置的下注金额
    self.totalXiaZhuDetail = {1:[],2:[],3:[],4:[]};//所有玩家在各个位置的下注次数
    self.waitXiaZhuDetail = {1:[],2:[],3:[],4:[]}; //等待处理的下注
    self.incomeRank = [];                          //收益排行
    self.broadcastList = [];                       //本局的广播列表
};

pro.UpdateTablePlayerNum = function(){
    var self = this;
    var playerNum = 0;
    var robotNum = 0;
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo){
            if(userInfo.eIdentity == consts.UserIdentity.identity_type_robot){
                robotNum++;
            }else{
                playerNum++;
            }
        }
    }
    lobby.ModifyTableInfoByField(self.m_pTable.GetTableId(), 'playerNum', playerNum);
    lobby.ModifyTableInfoByField(self.m_pTable.GetTableId(), 'robotNum', robotNum);
    if(robotNum > 15){
        robotNum = parseInt(robotNum * 2.5);
        self.totalPlayerNum = playerNum + robotNum;
    }
};

pro.SetGameStart = function(){
    var self = this;
    lobby.UpdateTableStatus(self.m_pTable.GetTableId(), 2);
    self.DealCards();
    self.UpdateTablePlayerNum();
};

pro.PrintCards = function(){
    var self = this;
    for(var i = 0; i < 5; i++){
        self.debug('PrintCards,seat'+i+' cards:'+JSON.stringify(self.playersInfo[i].cardSet)+',niuCnt:'+self.playersInfo[i].niuCnt);
    }
    self.debug('PrintCards, leftCards:'+JSON.stringify(self.leftCards));
};

pro.Shuffle = function(){
    var self = this;
    var tmBegin = new Date().getTime();
    for(var k = 0; k < self.allCardsList.length; k++){
        var randNum = lobby.GetRandomNum(100, 200);
        for(var i = 0; i < randNum; i++){
            var temp = lobby.GetRandomNum(1,100)/100;
            self.allCardsList[k].sort(function(){return Math.random() > temp ? -1 : 1;});
        }
    }
    for(var k = 0; k < self.allCardsList.length; k++){
        var randNum = lobby.GetRandomNum(30, 60);
        for(var m = 0; m < randNum; m++){
            for(var i = 0;i < self.allCardsList[k].length; i++){
                var randPos = lobby.GetRandomNum(0, self.allCardsList[k].length - 1);
                if(i != randPos){
                    var temp = self.allCardsList[k][i];
                    self.allCardsList[k][i] = self.allCardsList[k][randPos];
                    self.allCardsList[k][randPos] = temp;
                }
            }
        }
    }
    for(var k = 0; k < self.allCardsList.length; k++){
        var randNum = lobby.GetRandomNum(50, 100);
        for(var i = 0; i < randNum; i++){
            var nRandPos = lobby.GetRandomNum(1, self.allCardsList[k].length-1);
            self.allCardsList[k] = self.allCardsList[k].slice(nRandPos).concat(self.allCardsList[k].slice(0, nRandPos));
        }
    }
    var tmEnd = new Date().getTime();
    self.debug('Shuffle, tmGrep:' + (tmEnd - tmBegin));
};

pro.DealCards = function(){
    var self = this;
    //洗牌
    self.Shuffle();
    self.allCardsListIndex = (self.allCardsListIndex++)%self.allCardsList.length;
    self.allCards = self.allCardsList[self.allCardsListIndex++];
    self.debug('DealCards, allCards:'+JSON.stringify(self.allCards)+',allCardsListIndex:'+self.allCardsListIndex+',allCardsList:'+JSON.stringify(self.allCardsList));

    //发牌、剩余牌
    for(var i = 0; i < 5; i++){
        self.playersInfo[i].cardSet = self.PinNiu(self.allCards.slice(i*5, i*5+5));
        self.playersInfo[i].niuCnt = self.CountNiu(self.playersInfo[i].cardSet);
    }
    self.leftCards = self.allCards.slice(5*5);

    var status = 0;
    if(self.winHistory.length > 4){
        if(self.winHistory[0] > 0 && self.winHistory[1] > 0 && self.winHistory[2] > 0 && self.winHistory[3] > 0){
            status = 1;
        }else if(self.winHistory[0] < 0 && self.winHistory[1] < 0 && self.winHistory[2] < 0 && self.winHistory[3] < 0){
            status = 2;
        }
    }
    if(status == 1 || status == 2){
        var bChangeCards = false;
        var addressList = [0,0,0,0,0];
        var bankerCardInfo = self.AnalyzeCardInfo(self.playersInfo[0].cardSet);
        var bankerNiu = self.playersInfo[0].niuCnt;
        for(var i = 1; i < 5; i++){
            var tempNiu = self.playersInfo[i].niuCnt;
            if(tempNiu > bankerNiu){
                addressList[i] = 1;
            }else if(tempNiu < bankerNiu){
                addressList[i] = -1;
            }else{
                var tempCardInfo = self.AnalyzeCardInfo(self.playersInfo[i].cardSet);
                if(bankerCardInfo.maxCardValue > tempCardInfo.maxCardValue){
                    addressList[i] = -1;
                }else if(bankerCardInfo.maxCardValue < tempCardInfo.maxCardValue){
                    addressList[i] = 1;
                }else{
                    if(bankerCardInfo.maxCardCode < tempCardInfo.maxCardCode){
                        addressList[i] = -1;
                    }else{
                        addressList[i] = 1;
                    }
                }
            }
        }
        if(status == 1 && addressList[1] > 0 && addressList[2] > 0 && addressList[3] > 0 && addressList[4] > 0){
            bChangeCards = true;
        }else if(status == 2 && addressList[1] < 0 && addressList[2] < 0 && addressList[3] < 0 && addressList[4] < 0){
            bChangeCards = true;
        }
        if(bChangeCards){
            self.debug('changeCardsSystem, status:'+status+',addressList:'+JSON.stringify(addressList));
            for(var i = 0; i < 5; i++){
                var temp = self.allCards[i];
                self.allCards[i] = self.allCards[5*5 + i];
                self.allCards[5*5 + i] = temp;
            }
            self.playersInfo[0].cardSet = self.PinNiu(self.allCards.slice(0, 5));
            self.playersInfo[0].niuCnt = self.CountNiu(self.playersInfo[0].cardSet);
            self.leftCards = self.allCards.slice(5*5);
        }
    }

    //如果当前庄家没牛,有一定几率换牌
    if(self.playersInfo[0].niuCnt <= 0){
        if(lobby.GetRandomNum(1, 100) <= self.roomInfo['changeCardsRate'] * 100){
            self.debug('changeCardsRate:'+self.roomInfo['changeCardsRate']);
            for(var i = 0; i < 5; i++){
                var temp = self.allCards[i];
                self.allCards[i] = self.allCards[5*5 + i];
                self.allCards[5*5 + i] = temp;
            }
            self.playersInfo[0].cardSet = self.PinNiu(self.allCards.slice(0, 5));
            self.playersInfo[0].niuCnt = self.CountNiu(self.playersInfo[0].cardSet);
            self.leftCards = self.allCards.slice(5*5);
        }
    }
    self.PrintCards();

    lobby.GetBirdDayInfo(new Date(), function(err, birdDayInfo){
        self.debug(err+',GetBirdDayInfo, birdDayInfo:'+JSON.stringify(birdDayInfo));
        var rate = 0;
        if(!err && birdDayInfo && birdDayInfo.bankerWinCoins){
            var bankerWinCoins = parseInt(birdDayInfo.bankerWinCoins);
            for(var i = 0; i < self.roomInfo['list'].length; i++){
                var minCoins = parseInt(self.roomInfo['list'][i].min);
                var maxCoins = parseInt(self.roomInfo['list'][i].max);
                self.debug('GetBirdDayInfo, bankerWinCoins:'+bankerWinCoins+',minCoins:'+minCoins+',maxCoins:'+maxCoins);
                if(bankerWinCoins >= minCoins && bankerWinCoins <= maxCoins){
                    rate = parseFloat(self.roomInfo['list'][i].rate);
                    self.debug('rate:'+rate);
                    break;
                }
            }
        }
        if(rate > 0){
            //闲家开牛牛
            if(lobby.GetRandomNum(1, 10000) <= rate * 10000){
                var address = lobby.GetRandomNum(1, 4);
                self.debug('ChangeCards, address:'+address);
                self.ChangeCards(address, 10);
                self.PrintCards();
            }
        }else if(rate < 0){
            //庄家开牛牛
            if(lobby.GetRandomNum(1, 10000) <= -rate * 10000){
                self.debug('ChangeCards, address:0');
                self.ChangeCards(0, 10);
                self.PrintCards();
            }
        }
        self.Notify(consts.MSG.MSGID_BAI_STATUS|consts.MSG.ID_NTF, {status:consts.BaiGameStatus.game_status_xiazhu, totalPlayerNum:self.totalPlayerNum});
    })
};

/****
 * 计算牛的函数
 * 10：牛牛
 * 其他 1--9牛
 * ****/
pro.CountNiu = function(cards){
    var self = this;
    var tempCards = [];
    var JQK = 0;
    for(var i = 0; i < cards.length; i++){
        tempCards[i] = cards[i]%13 + 1;
        if(tempCards[i] >= 11 && tempCards[i] <= 13){
            JQK++;
        }
    }

    //计算牛一到牛牛
    for(var i = 0; i < tempCards.length; i++){
        if(tempCards[i] > 10){
            tempCards[i] = 10;
        }
    }
    var niuCnt = 0;//默认没牛
    for(var i = 0; i < tempCards.length; ++i){
        for(var j = i + 1;j < tempCards.length; ++j){
            for(var k = j+1; k < tempCards.length; ++k){
                var sum = tempCards[i] + tempCards[j] + tempCards[k];
                if(sum%10 == 0){
                    niuCnt = (tempCards[0] + tempCards[1] + tempCards[2] + tempCards[3] + tempCards[4]) % 10;
                    if(niuCnt == 0){
                        niuCnt = 10;
                    }
                    break;
                }
            }
        }
    }
    return niuCnt;
};

pro.PinNiu = function(cards){
    var self = this;
    var niuCnt = self.CountNiu(cards);
    if(niuCnt == 0){
        return cards;
    }

    //牛一到牛牛，进行拼牌
    var pinCards = [];
    for(var i = 0; i < cards.length; ++i){
        for(var j = i + 1;j < cards.length; ++j){
            for(var k = j + 1; k < cards.length; ++k){
                var card1 = (cards[i]%13 + 1) > 10 ? 10 : (cards[i]%13 + 1);
                var card2 = (cards[j]%13 + 1) > 10 ? 10 : (cards[j]%13 + 1);
                var card3 = (cards[k]%13 + 1) > 10 ? 10 : (cards[k]%13 + 1);
                if((card1 + card2 + card3)%10 == 0){
                    pinCards.push(cards[i]);
                    pinCards.push(cards[j]);
                    pinCards.push(cards[k]);
                    for(var m = 0; m < cards.length; m++){
                        if(pinCards.indexOf(cards[m]) < 0){
                            pinCards.push(cards[m]);
                        }
                    }
                    return pinCards;
                }
            }
        }
    }
    return cards;
};

pro.ChangeCards = function(address, niuCnt){
    var self = this;
    var cards = self.leftCards.slice(0);
    cards.concat(self.playersInfo[address].cardSet);
    cards.sort(function(){return Math.random() > 0.5 ? -1 : 1;});

    //牛牛~牛一、没牛
    var targetCards = [];
    if(niuCnt >= 0 && niuCnt <= 10){
        //没牛到牛牛
        var count = 0;
        var bFind = false;
        for(var i = 0; i < cards.length && !bFind; i++){
            for(var j = i + 1; j < cards.length && !bFind; j++){
                for(var k = j + 1; k < cards.length && !bFind; k++){
                    for(var m = k +1; m < cards.length && !bFind; m++){
                        for(var n = m + 1; n < cards.length && !bFind; n++){
                            if(self.CountNiu([cards[i], cards[j], cards[k], cards[m], cards[n]]) == niuCnt){
                                targetCards.push(cards[i]);
                                targetCards.push(cards[j]);
                                targetCards.push(cards[k]);
                                targetCards.push(cards[m]);
                                targetCards.push(cards[n]);
                                bFind = true;
                            }
                            if(++count > 10000){
                                bFind = true;
                            }
                        }
                    }
                }
            }
        }
    }
    if(targetCards.length != 5){
        return false;
    }
    self.debug('ChangeCards,targetCards:'+JSON.stringify(targetCards));
    for(var i = 0; i < targetCards.length; i++){
        cards.splice(cards.indexOf(targetCards[i]), 1);
    }
    self.leftCards = cards.slice(0);
    self.playersInfo[address].cardSet = targetCards.slice(0);
    self.playersInfo[address].niuCnt = niuCnt;
    return true;
};

pro.IsUserOffline = function(userId){
    var self = this;
    var userInfo = self.usersMap[userId];
    if(userInfo){
        if(userInfo.eState == consts.UserState.user_state_getout || userInfo.eState == consts.UserState.user_state_offline){
            return true;
        }
    }
    return false;
};

pro.SetFaPai = function(){
    var self = this;
    self.CalcResult();

    var cardsData = [];
    for(var i = 0; i < 5; i++){
        cardsData.push({cards:self.playersInfo[i].cardSet, niuCnt:self.playersInfo[i].niuCnt, winFan:self.playersInfo[i].winFan});
    }
    var totalXiaZhuCoins = [];
    for(var i = 1; i < 5; i++){
        totalXiaZhuCoins.push(self.totalXiaZhuCoins[i]);
    }
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo){
            var xiaZhuCoins = [];
            for(var i = 1; i < 5; i++){
                xiaZhuCoins.push(userInfo.xiaZhuCoins[i]);
            }
            self.NotifyTo(userId, consts.MSG.MSGID_BAI_STATUS|consts.MSG.ID_NTF, {status:consts.BaiGameStatus.game_status_fapai, xiaZhuCoins:xiaZhuCoins, totalXiaZhuCoins:totalXiaZhuCoins, cardsData:cardsData, coinsChg:userInfo.coinsChg, coins:userInfo.coins, bankerCoinsChg:self.bankerCoinsChg, incomeRank:self.incomeRank});
        }
    }
};

pro.SetGameEnd = function(){
    var self = this;
    var cardsData = [];
    for(var i = 0; i < 5; i++){
        cardsData.push({cards:self.playersInfo[i].cardSet, niuCnt:self.playersInfo[i].niuCnt, winFan:self.playersInfo[i].winFan});
    }
    var totalXiaZhuCoins = [];
    for(var i = 1; i < 5; i++){
        totalXiaZhuCoins.push(self.totalXiaZhuCoins[i]);
    }
    //通知所有人结算信息
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo){
            var xiaZhuCoins = [];
            for(var i = 1; i < 5; i++){
                xiaZhuCoins.push(userInfo.xiaZhuCoins[i]);
            }
            self.NotifyTo(userId, consts.MSG.MSGID_BAI_STATUS|consts.MSG.ID_NTF, {status:consts.BaiGameStatus.game_status_jiesuan, xiaZhuCoins:xiaZhuCoins, totalXiaZhuCoins:totalXiaZhuCoins, cardsData:cardsData, coinsChg:userInfo.coinsChg, coins:userInfo.coins, bankerCoinsChg:self.bankerCoinsChg, incomeRank:self.incomeRank});
            self.debug('SetGameEnd, userId:'+userId+',result:'+JSON.stringify({status:consts.BaiGameStatus.game_status_jiesuan, xiaZhuCoins:xiaZhuCoins, totalXiaZhuCoins:totalXiaZhuCoins, cardsData:cardsData, coinsChg:userInfo.coinsChg, coins:userInfo.coins, bankerCoinsChg:self.bankerCoinsChg, incomeRank:self.incomeRank}));
        }
    }

    //广播
    //self.broadcast();

    //设置准备定时器
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo){
            if(userInfo.eIdentity == consts.UserIdentity.identity_type_robot){
                userInfo.eState = consts.UserState.user_state_ready;
            }else{
                userInfo.eState = consts.UserState.user_state_free;
            }
            self.BeginCheckNoReady(consts.BaiTimeOutType.timeout_type_no_ready, userInfo);
        }
    }
};

pro.KickOfflineUsers = function(){
    var self = this;
    for(var userId in self.usersMap){
        if(self.IsUserOffline(userId)){
            self.debug('KickOfflineUsers, nUserID:'+userId);
            self.m_pTable.KickOffUser(-1, consts.KickReason.kick_reason_offline, userId, '已断线！');
            self.RemovePlayer(userId);
        }
    }
};

pro.AnalyzeCardInfo = function(cards){
    var self = this;
    var max_card_value = 0;
    var max_card_code = 0;
    for(var i = 0; i < cards.length; i++){
        var temp = cards[i]%13;
        if(temp > max_card_value){
            max_card_value = temp;
            max_card_code = cards[i];
        }else if(temp == max_card_value){
            if(cards[i] < max_card_code){
                max_card_value = temp;
                max_card_code = cards[i];
            }
        }
    }
    return {maxCardValue:max_card_value, maxCardCode:max_card_code};
};

pro.broadcast = function(){
    var self = this;
    if(self.broadcastList.length > 0){
        var msg = '\20' + '\20' + '\20' + JSON.stringify({'game':{'ts':parseInt(new Date().getTime()/1000), 'list':self.broadcastList}});
        var connServices = self.app.getServersByType('connector');
        for(var i = 0; i < connServices.length; i++){
            this.app.rpc.connector.connectorRemote.OnInterMsg(connServices[i].id, -1, consts.MSG.MSG_SYS_LED | consts.MSG.ID_NTF, msg, function(err){
            });
        }
    }
};

pro.UpdateGameInfoChg = function(userId){
    var self = this;
    var winChg = 0;
    var loseChg = 0;
    var breakChg = 0;
    var escapeChg = 0;
    var coinsChg = 0;
    var userInfo = self.usersMap[userId];
    if(userInfo){
        if(userInfo.coinsChg > 0){
            winChg = 1;
        }else{
            loseChg = 1;
        }
        if(userInfo.eState == consts.UserState.user_state_offline){
            breakChg = 1;
        }else if(userInfo.eState == consts.UserState.user_state_getout){
            escapeChg = 1;
        }
        coinsChg = userInfo.coinsChg + userInfo.totalXiaZhuCoins;
        userInfo.win += winChg;
        userInfo.lose += loseChg;
        var oldCoins = userInfo.coins;
        userInfo.coins += coinsChg;
        if(userInfo.coins < 0){
            userInfo.coins = 0;
        }
        if(userInfo.eIdentity == consts.UserIdentity.identity_type_robot){
            lobby.UpdateGameResults(self.tableInfo['roomId'], userId, self.IsRobot(userId), coinsChg, 0, winChg, loseChg, breakChg, escapeChg, function(err, res, isBust){
            })
        }else{
            lobby.HincrbyDayInfo(userId, 'winCoins', userInfo.coinsChg);
            lobby.GameBirdUnLock(userId);
            (function(oldCoins, coinsChg){
                lobby.IncrbyBirdChip(parseInt(userId), coinsChg, function(err, tempUserId, res){
                    var userInfo = self.usersMap[tempUserId];
                    if(userInfo){
                        lobby.statCoinsChg(tempUserId, consts.COINSCHG.COINSCHG_CAL, coinsChg, oldCoins, userInfo.coins, res['chip']);
                        self.debug(err+',IncrbyBirdChip,userId:'+tempUserId+',userInfoCoins:'+userInfo.coins+',platCoins:'+res['chip']+',coinsChg:'+userInfo.coinsChg+',xiaZhuCoins:'+JSON.stringify(userInfo.xiaZhuCoins));
                        if(!err){
                            userInfo.coins = parseInt(res['chip']);
                        }else{
                            userInfo.coins = 0;
                        }
                    }
                });
            })(oldCoins, coinsChg)
        }
    }
};

pro.compareCoinsChg = function(propertyName){
    var self = this;
    return function(obj1, obj2){
        var value1 = obj1[propertyName];
        var value2 = obj2[propertyName];
        if(value2 <= value1){
            return -1;
        }else{
            return 1;
        }
    }
};

pro.UpdateWinHistory = function(){
    var self = this;
    for(var i = 4; i > 0; i--){
        if(self.playersInfo[i].winFan > 0){
            self.winHistory.unshift(1);
        }else{
            self.winHistory.unshift(-1);
        }
    }
    if(self.winHistory.length > 40){
        self.winHistory.splice(40, 4);
    }
};

pro.CalcResult = function(){
    var self = this;
    var bankerCardInfo = self.AnalyzeCardInfo(self.playersInfo[0].cardSet);
    var bankerNiu = self.playersInfo[0].niuCnt;

    for(var i = 1; i < 5; i++){
        var tempNiu = self.playersInfo[i].niuCnt;
        if(tempNiu > bankerNiu){
            self.playersInfo[i].winFan = 1;
        }else if(tempNiu < bankerNiu){
            self.playersInfo[i].winFan = 0;
        }else{
            var tempCardInfo = self.AnalyzeCardInfo(self.playersInfo[i].cardSet);
            if(bankerCardInfo.maxCardValue > tempCardInfo.maxCardValue){
                self.playersInfo[i].winFan = 0;
            }else if(bankerCardInfo.maxCardValue < tempCardInfo.maxCardValue){
                self.playersInfo[i].winFan = 1;
            }else{
                if(bankerCardInfo.maxCardCode < tempCardInfo.maxCardCode){
                    self.playersInfo[i].winFan = 0;
                }else{
                    self.playersInfo[i].winFan = 1;
                }
            }
        }
    }

    //每一个位置翻的倍数
    var bankerFan = self.getWindFan(bankerNiu);
    for(var i = 1; i < 5; i++){
        if(self.playersInfo[i].winFan == 1){
            self.playersInfo[i].winFan = self.getWindFan(self.playersInfo[i].niuCnt);
        }else{
            self.playersInfo[i].winFan = -bankerFan;
        }
    }

    var totalUserWinCoins = 0;//所有玩家的输赢金币
    var winUsers = [];//赢的玩家列表
    var loseUsers = [];//输的玩家列表
    //计算庄家和所有下注玩家的输赢金币情况
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo && userInfo.totalXiaZhuCoins > 0){
            //计算该用户的金币变化量
            //超过广播的金币要求，并且该位置是牛牛，该位置是赢的最多的
            var bBroadCast = false;
            var nBroadCastCoins = 0;
            var nMaxCoins = 0;
            for(var address in userInfo.xiaZhuCoins){
                var coins = userInfo.xiaZhuCoins[address];
                if(coins != 0){
                    var coinsChg = coins * self.playersInfo[address].winFan;
                    userInfo.coinsChg += coinsChg;
                    if(coinsChg > 0 && self.playersInfo[address].niuCnt == 10){
                        bBroadCast = true;
                        nBroadCastCoins += coinsChg;
                    }
                    if(coinsChg > nMaxCoins){
                        nMaxCoins = coinsChg;
                    }
                }
            }
            if(bBroadCast && (nBroadCastCoins > coinsChg && nBroadCastCoins > self.roomInfo['broadcastCoins'])){
                self.broadcastList.push('恭喜\"'+userInfo.nick+'\"在百人牛牛中赢得了'+nBroadCastCoins+'金币');
            }
            if(userInfo.coinsChg < 0){
                self.bankerCoinsChg += -userInfo.coinsChg;
            }else{
                self.bankerCoinsChg -= userInfo.coinsChg;
            }
            //统计所有玩家的输赢金币
            if(userInfo.eIdentity == consts.UserIdentity.identity_type_player){
                totalUserWinCoins += userInfo.coinsChg;
            }
        }
    }

    //玩家结算
    for(var userId in self.usersMap){
        var userInfo = self.usersMap[userId];
        if(userInfo && userInfo.totalXiaZhuCoins > 0){
            if(userInfo.coinsChg > 0){
                winUsers.push({nick:userInfo.nick, coinsChg:userInfo.coinsChg});
            }else if(userInfo.coinsChg < 0){
                loseUsers.push({nick:userInfo.nick, coinsChg:userInfo.coinsChg});
            }
            self.UpdateGameInfoChg(userId);
        }
    }
    //庄家结算
    lobby.HincrbyBirdDataByField('bankerWinCoins', -totalUserWinCoins);
    lobby.HincrbyBirdDayInfo('bankerWinCoins', -totalUserWinCoins);

    //收益排行
    if(winUsers.length > 0){
        if(winUsers.length == 1){
            self.incomeRank.push({nick:winUsers[0].nick, coinsChg:winUsers[0].coinsChg});
        }else{
            //金币从大到小排列
            winUsers.sort(self.compareCoinsChg("coinsChg"));
            for(var i = 0; i < winUsers.length && i <= 4; i++){
                self.incomeRank.push({nick:winUsers[i].nick, coinsChg:winUsers[i].coinsChg});
            }
        }
    }
    if(self.incomeRank.length < 4 && loseUsers.length > 0){
        if(loseUsers.length == 1){
            self.incomeRank.push({nick:loseUsers[0].nick, coinsChg:loseUsers[0].coinsChg});
        }else{
            loseUsers.sort(self.compareCoinsChg("coinsChg"));
            for(var i = loseUsers.length - 1; i >= 0 && self.incomeRank.length <= 4; i--){
                self.incomeRank.push({nick:loseUsers[i].nick, coinsChg:loseUsers[i].coinsChg});
            }
        }
    }
    //更新历史记录
    self.UpdateWinHistory();
};

pro.getWindFan = function(niu){
    if(niu == 10){
        return 5;
    }else if(niu == 9){
        return 3;
    }else if(niu >= 7 && niu <= 8){
        return 2;
    }else{
        return 1;
    }
};

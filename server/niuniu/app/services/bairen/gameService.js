/**
 * Created by wjl on 2015/7/7.
 */

var player = require('./player');
var table = require('./table');
var logger = require('pomelo-logger').getLogger('logic_bairen', __filename);

var gameService = function(app) {
    var self = this;
    self.app = app;
    self.playerMng = {};
    self.tableMng = {};
    setInterval(self.OnTimer, 15000, self);
};

module.exports = gameService;
pro = gameService.prototype;

pro.OnMsg = function(remoteServerId, userId, msgId, data){
    var self = this;
    self.CreatePlayer(userId, function(err, tempPlayer){
        if(err){
            return;
        }
        tempPlayer.OnMsg(remoteServerId, userId, msgId, data);
    })
};

pro.CreatePlayer = function(userId, cb){
    var self = this;
    if (self.playerMng[userId]){
        cb(null, self.playerMng[userId]);
        return;
    }
    self.playerMng[userId] = new player(userId, self.app, self);
    cb(null, self.playerMng[userId]);
};

pro.CreateTable = function(tableId, cb){
    var self = this;
    if (self.tableMng[tableId]){
        cb(null, self.tableMng[tableId]);
        return;
    }
    logger.log('======================================CreateTable,tableId:'+tableId+',pTable:'+self.tableMng[tableId]);
    self.tableMng[tableId] = new table(tableId, self.app, self);
    self.tableMng[tableId].Init(function(err){
        if(err){
            delete self.tableMng[tableId];
            cb(err);
            return;
        }
        cb(null, self.tableMng[tableId]);
    })
};

pro.GetTableByID = function(tableId, cb){
    var self = this;
    if (self.tableMng[tableId]){
        cb(null, self.tableMng[tableId]);
        return
    }
    cb('table not exists');
};

pro.GetPlayerByID = function(playerId, cb){
    var self = this;
    if (self.playerMng[playerId]){
        cb(null, self.playerMng[playerId]);
        return;
    }
    cb('player not exists');
};

pro.OnTimer = function(ptr){
    var self = ptr;
    self.DeleteOverduePlayer();
};

pro.DeleteOverduePlayer = function(){
    var self = this;
    for(var playerId in self.playerMng){
        self.GetPlayerByID(playerId, function(err, player){
            if(!err && player.m_nRecycleTime != 0){
                logger.debug('DeleteOverduePlayer,userId:'+playerId+',m_nRecycleTime:'+player.m_nRecycleTime);
                delete self.playerMng[playerId];
            }
        })
    }
};

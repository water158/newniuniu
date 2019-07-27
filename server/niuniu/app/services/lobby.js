/**
 * Created by ddz-001 on 2015/9/9.
 */
var pomelo = require('pomelo');
var redis = require('redis');
var userDao = require('../dao/userDao');
var consts = require('../consts/consts');
var macro = require('./macro');
var http = require('http');
var crypto = require('crypto');
var mysql = require('mysql');
var querystring = require("querystring");
var logger = require('pomelo-logger').getLogger('niuniu', __filename);

var lobby = module.exports;

lobby.GetRandomNum = function(Min, Max){
    var range = Max - Min;
    return Min + Math.round(Math.random()*range);
};

lobby.GetServerType = function(roomId){
    return 'gameBaiRen';
};

lobby.GetUserIDByUserName = function(userName, idType, cb){
    var strKey = 'username:' + idType + ':' + userName;
    pomelo.app.get('redisUser').hget(strKey, 'userId', function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        if(strVal){
            cb(null, parseInt(strVal));
            return;
        }
        var sql = 'select userId from user where userName = ? and idType = ?';
        var args = [userName, idType];
        userDao.query('select', sql, args, function(err, results){
            if(err){
                cb('db error');
                return;
            }
            if(results.length == 0){
                cb('user no find');
                return;
            }
            pomelo.app.get('redisUser').hmset(strKey, {'userId':results[0].userId});
            cb(null, results[0].userId);
        })
    });
};

lobby.DeleteUserName = function(userName, idType){
    var strKey = 'username:' + idType + ':' + userName;
    pomelo.app.get('redisUser').del(strKey);
};

lobby.InsertGameInfo = function(userId, cb){
    var sql = 'insert gameinfo set userId = ?, coins = ?, score = ?, game = ?, win = ?, lose = ?, break = ?, escape = ?, safeCoins = ?, safeToken = ?, firstPurchase = ?, scoreGift = ?';
    var args = [userId, 5000, 0, 0, 0, 0, 0, 0, 0, '', 0, 0];
    userDao.query('insert', sql, args, function(err, results){
        if(err){
            cb('db error');
            return;
        }
        cb(null);
    })
};

lobby.CreateUser = function(dictInfo, cb){
    var sex = lobby.GetRandomNum(0, 1);
    var avatar = lobby.GetRandomNum(1, consts.Macro.MAX_AVATAR);
    var sql = 'insert user set userName = ?, idType = ?, sex = ?, avatar = ?, nick = ?, token = ?, deviceId = ?, createIP = ?, createTime = now(), channel = ?, lastLoginTime = now()';
    var args = [dictInfo['userName'], dictInfo['idType'], sex, avatar, dictInfo['nick'], dictInfo['token'], dictInfo['deviceId'], dictInfo['createIP'], dictInfo['channel']];
    userDao.query('insert', sql, args, function(err, results){
        if(err){
            cb('db error');
            return;
        }
        lobby.GetUserIDByUserName(dictInfo['userName'], dictInfo['idType'], function(err, userId){
            if(err){
                cb('db error');
                return;
            }
            lobby.InsertGameInfo(userId, function(err){
                if(err){
                    cb('db error');
                    return;
                }
                cb(null);
            })
        })
    })
};

lobby.UpdateUserLastLoginTime = function(userId, channel){
    var sql = 'update user set lastLoginTime = now() where userId = ?';
    var args = [userId];
    userDao.query('update', sql, args, function(err, results){
    })
};

lobby.ModifyUserInfoByField = function(userId, field, value){
    var sql = 'update user set ' + field + ' = ? ' + ' where userId = ?';
    var args = [value, userId];
    userDao.query('update', sql, args, function(err, results){
        if(!err){
            lobby.DeleteUserInfo(userId);
        }
    })
};

lobby.ModifyGameInfoByField = function(userId, field, value, cb){
    lobby.GetGameInfo(userId, function(err, gameInfo){
        if(err){
            cb(err);
            return;
        }
        var strKey = 'gameinfo:'+userId;
        pomelo.app.get('redisGame').hset(strKey, field, value, function(err, res){
            if(err){
                cb(err);
                return;
            }
            var sql = 'update gameinfo set ' + field + ' = ? ' + ' where userId = ?';
            var args = [value, userId];
            userDao.query('update', sql, args, function(err, results){
                cb(null);
            })
        });
    })
};

lobby.UpdateGameResults = function(roomId, userId, isRobot, coinsChg, scoreChg, winChg, loseChg, breakChg, escapeChg, cb){
    lobby.GetGameInfo(userId, function(err, gameInfo){
        if(err){
            cb(err);
            return;
        }
        var coins = parseInt(gameInfo.coins) + coinsChg;
        if(coins < 0){
            coins = 0;
            coinsChg = -parseInt(gameInfo.coins);
        }
        var score = parseInt(gameInfo.score) + scoreChg;
        var game = parseInt(gameInfo.game) + 1;
        var win = parseInt(gameInfo.win) + winChg;
        var lose = parseInt(gameInfo.lose) + loseChg;
        var break2 = parseInt(gameInfo.break) + breakChg;
        var escape = parseInt(gameInfo.escape) + escapeChg;
        var isBust = 0;
        if(coins + parseInt(gameInfo.safeCoins) < 1000){
            isBust = 1;
        }
        var strKey = 'gameinfo:'+userId;
        var strVal = {'coins':coins, 'score':score, 'game':game, 'win':win, 'lose':lose, 'break':break2, 'escape':escape};
        pomelo.app.get('redisGame').hmset(strKey, strVal, function(err, res){
            if(err){
                cb(err);
                return;
            }
            var sql = 'update gameinfo set coins = ?, score = ?, game = ?, win = ?, lose = ?, break = ?, escape = ? where userId = ?';
            var args = [coins, score, game, win, lose, break2, escape, userId];
            userDao.query('update', sql, args, function(err, results){
                cb(null, strVal, isBust);
            })
        });
    })
};

lobby.GetUserInfo = function(userId, cb){
    var strKey = 'userinfo:' + userId;
    pomelo.app.get('redisUser').hgetall(strKey, function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        if (strVal){
            cb(null, strVal);
            return;
        }
        var sql = 'select * from user where userId = ?';
        var args = [userId];
        userDao.query('select', sql, args, function(err, results){
            if(err){
                cb('db error');
                return;
            }
            if(results.length == 0){
                cb('user not find');
                return;
            }
            var result = results[0];
            strVal = {'userName': result.userName, 'idType': result.idType, 'sex': result.sex, 'avatar': result.avatar, 'status': result.status, 'nick': result.nick, 'token': result.token, 'status':result.status};
            pomelo.app.get('redisUser').hmset(strKey, strVal);
            cb(null, strVal);
        })
    });
};

lobby.DeleteUserInfo = function(userId){
    var strKey = 'userinfo:' + userId;
    pomelo.app.get('redisUser').del(strKey);
};

lobby.GetRoomInfo = function(roomId, cb){
    var strKey = 'roominfo:' + roomId;
    pomelo.app.get('redisCache').hgetall(strKey, function(err, strVal) {
        if (err) {
            cb('redis error');
            return;
        }
        if (strVal) {
            cb(null, strVal);
            return;
        }
        var roomInfo = null;
        var roomConfig = require('../ownConfig/roomConfig');
        for(var i in roomConfig){
            if(roomId == roomConfig[i].roomId){
                roomInfo = roomConfig[i];
            }
        }
        if(!roomInfo){
            cb('no find roomInfo');
            return;
        }
        pomelo.app.get('redisCache').hmset(strKey,roomInfo,function(err){
            if(err){
                cb('redis err');
                return;
            }
            pomelo.app.get('redisCache').hgetall(strKey, function(err, res){
                if (err || !res) {
                    cb('redis error');
                    return;
                }
                cb(null, res);
            })
        })
    });
};

lobby.SetUserToken = function(userId, token, cb){
    var strKey = 'token:' + userId;
    pomelo.app.get('redisGame').hmset(strKey, {'token': token}, function(err, res){
        if(err){
            cb(err);
            return;
        }
        pomelo.app.get('redisGame').expire(strKey, 48*60*60);
        cb(null);
    });
};

lobby.GetUserToken = function(userId, cb){
    var strKey = 'token:' + userId;
    pomelo.app.get('redisGame').hget(strKey, 'token', function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        if(!strVal){
            cb('not find token');
            return;
        }
        cb(null, strVal);
    });
};

lobby.GetLocation = function(userId, cb){
    var strKey = 'location:' + userId;
    pomelo.app.get('redisCache').hgetall(strKey, function(err,strVal){
        if (err) {
            cb('redis error');
            return;
        }
        cb(null, strVal);
    })
};

lobby.SetLocation = function(userId, serverId, roomId, tableId, seatId, cb){
    var strKey = 'location:' + userId;
    var strVal = {'serverId': serverId, 'roomId':roomId, 'tableId':tableId, 'seatId':seatId, 'status':0, 'freshTime':parseInt(new Date().getTime()/1000)};
    pomelo.app.get('redisCache').hmset(strKey, strVal, function(err, res){
        if(err){
            cb('redis error');
            return;
        }
        cb(null);
    });
};

lobby.DelLocation = function(userId, cb){
    var strKey = 'location:' + userId;
    pomelo.app.get('redisCache').del(strKey, function(err, res){
        if(err){
            cb('redis error');
            return;
        }
        cb(null);
    });
};

lobby.UpdateUserStatus = function(userId, status){
    var strKey = 'location:' + userId;
    lobby.GetLocation(userId, function(err, locaion){
        if(err){
            return;
        }
        if(!locaion){
            return;
        }
        locaion.status = status;
        locaion.freshTime = parseInt(new Date().getTime()/1000);
        pomelo.app.get('redisCache').hmset(strKey, locaion);
    })
};

lobby.GetUserStatus = function(userId, cb){
    lobby.GetLocation(userId, function(err, strVal){
        if(err){
            cb(err);
            return;
        }
        if(strVal){
            var isValidUser = true;
            var status = 0;
            var freshTime = 0;
            if(!strVal.serverId || !strVal.roomId || !strVal.tableId || !strVal.seatId || !strVal.status || !strVal.freshTime){
                isValidUser = false;
            }else{
                status = parseInt(strVal['status']);
                freshTime = parseInt(strVal['freshTime']);
                var nowTime = parseInt(new Date().getTime()/1000);
                if((status == consts.UserStatus.user_status_connect_gamesvrd) && (nowTime - freshTime > 30)){
                    isValidUser = false;
                }else if((status == consts.UserStatus.user_status_sit) && (nowTime - freshTime > 10*60)){
                    isValidUser = false;
                }else if((status == consts.UserStatus.user_status_playing) && (nowTime - freshTime > 10*60)){
                    isValidUser = false;
                }
            }
            if(isValidUser == false){
                lobby.DelLocation(userId, function(err){
                    logger.debug(err+',GetUserStatus, isValidUser false, userId:'+userId+',location:'+JSON.stringify(strVal));
                    cb(null, 0, null);
                })
            }else{
                cb(null, status, strVal);
            }
        }else{
            cb(null, 0, null);
        }
    })
};

lobby.PresentCoins = function(userId, coins, type, extraData, cb){
    lobby.GetGameInfo(userId, function(err, gameInfo){
        if(err){
            cb(err);
            return;
        }
        if(coins < 0 && parseInt(coins) + parseInt(gameInfo['coins']) < 0){
            cb('coins small');
            return;
        }
        var strKey = 'gameinfo:'+userId;
        pomelo.app.get('redisGame').hincrby(strKey, 'coins', coins, function(err, newCoins){
            if(err){
                cb('redis error');
                return;
            }
            if(newCoins < 0){
                pomelo.app.get('redisGame').hincrby(strKey, 'coins', -coins);
                cb('coins small');
            }else{
                var sql = 'update gameinfo set coins = ? where userId = ?';
                var args = [newCoins, userId];
                userDao.query('update', sql, args, function(err, results){
                    cb(null, newCoins);
                })
            }
        })
    })
};

lobby.GetGameInfo = function(userId, cb){
    var strKey = 'gameinfo:'+userId;
    pomelo.app.get('redisGame').hgetall(strKey, function(err, strVal){
        if(err){
            cb(err);
            return;
        }
        if(strVal){
            cb(null, strVal);
            return;
        }
        var sql = 'select * from gameinfo where userId = ?';
        var args = [userId];
        userDao.query('select', sql, args, function(err, results){
            if(err){
                cb('db error');
                return;
            }
            if(results.length == 0){
                cb('no find gameinfo');
                return;
            }
            var result = results[0];
            strVal = {'coins': result.coins, 'score': result.score, 'game': result.game, 'win': result.win, 'lose': result.lose, 'break': result.break, 'escape': result.escape, 'safeCoins':result.safeCoins, 'safeToken':result.safeToken, 'firstPurchase':result.firstPurchase, 'scoreGift':result.scoreGift};
            pomelo.app.get('redisGame').hmset(strKey, strVal);
            cb(null, strVal);
        })
    })
};

lobby.GetTableList = function(roomId, playerNum, cb){
    var strKey = 'tablelist:0';
    if(playerNum != 0){
        strKey = 'tablelist:'+roomId+':'+playerNum;
    }
    pomelo.app.get('redisCache').lrange(strKey, 0, -1, function(err, strVal){
        if(err){
            cb(err);
            return;
        }
        cb(null, strVal);
    })
};

lobby.UpdateTableStatus = function(tableId, status){
    var strKey = 'tableinfo:' + tableId;
    var strVal = {'status':status, 'freshTime':parseInt(new Date().getTime()/1000)};
    pomelo.app.get('redisCache').hmset(strKey, strVal);
};

lobby.ModifyTableInfoByField = function(tableId, field, value){
    var strKey = 'tableinfo:' + tableId;
    pomelo.app.get('redisCache').hset(strKey, field, value);
};

lobby.HincrbyTableInfoByField = function(tableId, field, value){
    var strKey = 'tableinfo:' + tableId;
    pomelo.app.get('redisCache').hincrby(strKey, field, value);
};

lobby.GetTableInfo = function(tableId, cb){
    var strKey = 'tableinfo:' + tableId;
    pomelo.app.get('redisCache').hgetall(strKey, function(err,strVal){
        if (err) {
            cb('redis error');
            return;
        }
        if(!strVal){
            cb('no tableinfo');
            return;
        }
        cb(null, strVal);
    })
};

lobby.LoadRobotList = function(cb){
    var strKey = 'robotlist';
    pomelo.app.get('redisCache').exists(strKey, function(err, isExists) {
        if (err) {
            cb(err);
            return;
        }
        if(isExists){
            cb(null);
            return;
        }
        var sql = 'select userId from user where idType = 20';
        var args = [];
        userDao.query('select', sql, args, function(err, results){
            if(err){
                cb('db error');
                return;
            }
            if(results.length > 0){
                results.sort(function(){return Math.random() > 0.5 ? -1 : 1;});
            }
            pomelo.app.get('redisCache').del(strKey, function(err){
                if(!err){
                    for(var i = 0; i < results.length; i++){
                        pomelo.app.get('redisCache').rpush(strKey, results[i].userId);
                    }
                }
                cb(null);
            })
        })
    })
};

lobby.GetRobotList = function(cb){
    lobby.LoadRobotList(function(err){
        if(err){
            cb(err);
            return;
        }
        var strKey = 'robotlist';
        pomelo.app.get('redisCache').lrange(strKey, 0, -1, function(err, strVal){
            if(err){
                cb(err);
                return;
            }
            cb(null, strVal);
        })
    })
};

lobby.RemRobotFromList = function(robotId){
    var strKey = 'robotlist';
    pomelo.app.get('redisCache').lrem(strKey, 0, robotId);
};

lobby.PushRobotToList = function(robotId){
    var strKey = 'robotlist';
    pomelo.app.get('redisCache').rpush(strKey, robotId);
};

lobby.PopRobotFromList = function(cb){
    lobby.LoadRobotList(function(err){
        if(err){
            cb(err);
            return;
        }
        var strKey = 'robotlist';
        pomelo.app.get('redisCache').lpop(strKey, function(err, strVal){
            if(err){
                cb(err);
                return;
            }
            if(!strVal){
                cb('no robot');
                return;
            }
            pomelo.app.get('redisCache').lrem(strKey, 0, strVal, function(err){
                cb(null, strVal);
            })
        })
    })
};

lobby.IsRobotCoinsOK = function(minCoins, maxCoins, coins){
    if(minCoins > 0 && coins < minCoins){
        return false;
    }
    if(maxCoins > 0 && coins > maxCoins){
        return false;
    }
    return true;
};

lobby.GetRobotFromIdleList_bairen = function(roomId, robotType, cb){
    lobby.GetRoomInfo(roomId, function(err, roomInfo) {
        if (err) {
            cb(err);
            return;
        }
        lobby.PopRobotFromList(function (err, robotId) {
            if (err) {
                cb(err);
                return;
            }
            var robotCoins = 0;
            var randNum = lobby.GetRandomNum(1, 100);
            if(parseInt(roomId) == 101){
                if (robotType == consts.BaiRobotType.robot_type_stand) {
                    if(randNum >= 80){
                        //20%的概率超过100万
                        robotCoins = 10000 * lobby.GetRandomNum(100, 999) + lobby.GetRandomNum(1, 10000);
                    }else if(randNum >= 25){
                        //55%的概率超过10万
                        robotCoins = 10000 * lobby.GetRandomNum(10, 99) + lobby.GetRandomNum(1, 10000);
                    }else{
                        //25%概率超过5万
                        robotCoins = 10000 * lobby.GetRandomNum(5, 9) + lobby.GetRandomNum(1, 1000);
                    }
                }else{
                    cb('error robotType');
                    return;
                }
            }else{
                cb('error roomId');
                return;
            }
            lobby.ModifyGameInfoByField(robotId, 'coins', robotCoins, function (err) {
                if (err) {
                    cb(err);
                    return;
                }
                cb(null, robotId);
            })
        })
    })
};

lobby.GetScriptHash = function(hashName, cb){
    pomelo.app.get('redisCache').hget('nn_lua_script_hash', hashName, function(err, script_hash){
        if(err){
            cb('redis error');
            return;
        }
        if(script_hash){
            cb(null, script_hash);
            return;
        }
        var script = null;
        if(hashName == 'join2table'){
            script = macro.GetJoin2Table_script();
        }else if(hashName == 'join2table_automatch'){
            script = macro.GetJoin2Table_autoMatch_script();
        }else if(hashName == 'kickoff'){
            script = macro.GetKickUserOff_script();
        }else if(hashName == 'join2table_bairen'){
            script = macro.GetJoin2TableBaiRen_script();
        }
        if(!script){
            cb('hashName error');
            return;
        }
        pomelo.app.get('redisCache').script('load', script, function(err, script_hash){
            if(err || !script_hash){
                cb('redis error');
                return;
            }
            pomelo.app.get('redisCache').hset('nn_lua_script_hash', hashName, script_hash, function(err, strVal){
                if(err){
                    cb('redis error');
                    return;
                }
                cb(null, script_hash);
            });
        })
    });
};

lobby.Join2Table_lua = function(userId, roomId, services, lastTableId, cb){
    var hashName = 'join2table';
    if(lobby.GetServerType(roomId) == 'gameBaiRen'){
        hashName = 'join2table_bairen';
    }
    lobby.GetScriptHash(hashName, function(err, script_hash){
        if(err){
            cb(err);
            return;
        }
        pomelo.app.get('redisCache').evalsha(script_hash, 5, userId, roomId, services, lastTableId, parseInt(new Date().getTime()/1000), function(err, res){
            console.log(err+',Join2Table_lua,res:'+JSON.stringify(res));
            if(err){
                cb('redis error');
                return;
            }
            cb(null, res[0], res[1], res[2], res[3], res[4], res[5]);
        });
    })
};

lobby.Join2Table_autoMatch_lua = function(userId, roomId, tableId, cb){
    var hashName = 'join2table_automatch';
    lobby.GetScriptHash(hashName, function(err, script_hash){
        if(err){
            cb(err);
            return;
        }
        pomelo.app.get('redisCache').evalsha(script_hash, 3, userId, roomId, tableId, function(err, res){
            console.log(err+',Join2Table_autoMatch_lua,res:'+JSON.stringify(res));
            if(err){
                cb('redis error');
                return;
            }
            cb(null, res[0], res[1], res[2]);
        });
    })
};

lobby.KickUserOff_lua = function(userId, roomId, tableId, cb){
    lobby.GetScriptHash('kickoff', function(err, script_hash){
        if(err){
            cb(err);
            return;
        }
        pomelo.app.get('redisCache').evalsha(script_hash, 3, userId, roomId, tableId, function(err, res){
            if(err){
                cb('redis error');
                return;
            }
            cb(null, res[0], res[1], res[2]);
        });
    })
};

lobby.GetUserReqSitList = function(cb){
    var strKey = 'reqsit_userlist';
    pomelo.app.get('redisCache').lrange(strKey, 0, -1, function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        cb(null, strVal);
    });
};

lobby.RemUserFromReqSitList = function(userId){
    var strKey = 'reqsit_userlist';
    pomelo.app.get('redisCache').lrem(strKey, 0, userId);
};

lobby.reqWebSvrd = function(host, port, path, data, cb){
    var self = this;
    var content = JSON.stringify(data);
    var options = {
        host:host,
        port:port,
        method:'POST',
        path:path,
        headers: {
            "Content-Type": 'application/x-www-form-urlencoded',
            "Content-Length": content.length
        }
    };
    var req = http.request(options, function(res) {
        var ackData = '';
        res.on('data', function (data) {
            ackData += data;
        });
        res.on('end', function () {
            cb(null, ackData);
        });
        res.on('error', function (data) {
            cb(null, ackData);
        })
    });
    req.on('error', function (e) {
        cb('http error');
    });
    console.log('======================================content:'+content+',options:'+JSON.stringify(options));
    req.write(content);
    req.end();
};

lobby.reqWebSvrd2 = function(host, port, path, data, cb){
    var self = this;
    var content = querystring.stringify(data);
    var options = {
        host:host,
        port:port,
        method:'POST',
        path:path,
        headers: {
            "Content-Type": 'application/x-www-form-urlencoded',
            "Content-Length": content.length
        }
    };
    var req = http.request(options, function(res) {
        var ackData = '';
        res.on('data', function (data) {
            ackData += data;
        });
        res.on('end', function () {
            cb(null, ackData);
        });
        res.on('error', function (data) {
            cb(null, ackData);
        })
    });
    req.on('error', function (e) {
        cb('http error');
    });
    console.log('======================================content:'+content+',options:'+JSON.stringify(options));
    req.write(content);
    req.end();
};

lobby.HincrbyBirdDataByField = function(field, value){
    var strKey = 'birddata';
    pomelo.app.get('redisGame').hincrby(strKey, field, value);
};

lobby.SetBirdDataByField = function(field, value, cb){
    var strKey = 'birddata';
    pomelo.app.get('redisGame').hset(strKey, field, value, function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        cb(null);
    });
};

lobby.GetBirdDataByField = function(field, cb){
    var strKey = 'birddata';
    pomelo.app.get('redisGame').hget(strKey, field, function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        cb(null, strVal);
    });
};

lobby.GetBirdUserInfo = function(userId, cb){
    lobby.GetBirdDataByField('http', function(err, http){
        if(err){
            cb('redis error');
            return;
        }
        var list = http.split('http://');
        list = list[1].split(':');
        var host = list[0];
        var port = list[1];
        var ts = parseInt(new Date().getTime()/1000);
        var signData = 'gameId=' + consts.BIRD.GAMEID + '&token=' + consts.BIRD.TOKEN + '&ts=' + ts;
        var sign = crypto.createHash('md5').update(signData).digest('hex');
        lobby.reqWebSvrd(host, port, '/v1/game/third/user/info', {'gameId':2, 'ts':ts, 'sign':sign, 'userId':userId, 'appId':consts.BIRD.GAMEID}, function(err, data){
            console.log(err+',GetBirdUserInfo:'+JSON.stringify(data));
            if(err){
                cb(err);
                return;
            }
            data = JSON.parse(data);
            if(data.error){
                cb(data.error);
                return;
            }
            cb(null, data);
        });
    })
};

lobby.IncrbyBirdChip = function(userId, chipChg, cb){
    lobby.GetBirdDataByField('http', function(err, http){
        if(err){
            cb('redis error');
            return;
        }
        var list = http.split('http://');
        list = list[1].split(':');
        var host = list[0];
        var port = list[1];
        var ts = parseInt(new Date().getTime()/1000);
        var signData = 'gameId=' + consts.BIRD.GAMEID + '&token=' + consts.BIRD.TOKEN + '&ts=' + ts;
        var sign = crypto.createHash('md5').update(signData).digest('hex');
        lobby.reqWebSvrd(host, port, '/v1/game/third/incr/chip', {'gameId':2, 'ts':ts, 'sign':sign, 'appId':consts.BIRD.GAMEID, 'userId':userId, 'delta':chipChg}, function(err, data){
            console.log(err+',===========================IncrbyBirdChip:'+JSON.stringify(data)+',userId:'+userId);
            if(err){
                cb(err);
                return;
            }
            data = JSON.parse(data);
            if(data.error){
                cb(data);
                return;
            }
            cb(null, userId, data);
        });
    })
};

lobby.FormatDate = function(time){
    var self = this;
    var date = new Date(time*1000);
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    var hour = date.getHours();
    var min = date.getMinutes();
    var second = date.getSeconds();
    if(month < 10){
        month = '0'+month.toString();
    }
    if(day < 10){
        day = '0'+day.toString();
    }
    if(hour < 10){
        hour = '0'+hour.toString();
    }
    if(min < 10){
        min = '0'+min.toString();
    }
    if(second < 10){
        second = '0'+second.toString();
    }
    var strDate = year.toString() + '-' + month + '-' + day + ' ' + hour + ':' + min + ':' + second;
    return strDate;
};

lobby.statCoinsChg = function(userId, type, coinsChg, oldCoins, newCoins, extraData){
    var createTimeStamp = parseInt(new Date().getTime()/1000);
    var createTime = lobby.FormatDate(createTimeStamp);
    var sql = 'call p_coins_chg(?,?,?,?,?,?,?,?)';
    var args = [userId, type, coinsChg, oldCoins, newCoins, mysql.escape(extraData), mysql.escape(createTime), createTimeStamp];
    userDao.query('call', sql, args, function(err, results){
    })
};

lobby.GetDayInfo = function(userId, cb){
    var date = new Date();
    var strKey = 'dayinfo:'+userId+':'+date.getFullYear()+':'+(date.getMonth()+1)+':'+date.getDate();
    pomelo.app.get('redisGame').hgetall(strKey, function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        cb(null, strVal);
    });
};

lobby.HincrbyDayInfo = function(userId, field, value){
    var date = new Date();
    var strKey = 'dayinfo:'+userId+':'+date.getFullYear()+':'+(date.getMonth()+1)+':'+date.getDate();
    pomelo.app.get('redisGame').hincrby(strKey, field, value);
    pomelo.app.get('redisGame').expire(strKey, 7*24*60*60);
};

lobby.HincrbyBirdDayInfo = function(field, value){
    var date = new Date();
    var strKey = 'birddayinfo:'+date.getFullYear()+':'+(date.getMonth()+1)+':'+date.getDate();
    pomelo.app.get('redisGame').hincrby(strKey, field, value);
};

lobby.GetBirdDayInfo = function(date, cb){
    var strKey = 'birddayinfo:'+date.getFullYear()+':'+(date.getMonth()+1)+':'+date.getDate();
    pomelo.app.get('redisGame').hgetall(strKey, function(err, strVal){
        if(err){
            cb('redis error');
            return;
        }
        cb(null, strVal);
    });
};

lobby.GameBirdLock = function(userId){
    lobby.GetBirdDataByField('http', function(err, http){
        if(err){
            return;
        }
        var list = http.split('http://');
        list = list[1].split(':');
        var host = list[0];
        var port = list[1];
        var ts = parseInt(new Date().getTime()/1000);
        var signData = 'gameId=' + consts.BIRD.GAMEID + '&token=' + consts.BIRD.TOKEN + '&ts=' + ts;
        var sign = crypto.createHash('md5').update(signData).digest('hex');
        lobby.reqWebSvrd(host, port, '/v1/game/third/playing/lock', {'gameId':2, 'ts':ts, 'sign':sign, 'appId':consts.BIRD.GAMEID, 'userId':userId, 'time':45}, function(err, data){
            console.log(err+',===========================GameBirdLock:'+JSON.stringify(data)+',userId:'+userId);
        });
    })
};

lobby.GameBirdUnLock = function(userId){
    lobby.GetBirdDataByField('http', function(err, http){
        if(err){
            return;
        }
        var list = http.split('http://');
        list = list[1].split(':');
        var host = list[0];
        var port = list[1];
        var ts = parseInt(new Date().getTime()/1000);
        var signData = 'gameId=' + consts.BIRD.GAMEID + '&token=' + consts.BIRD.TOKEN + '&ts=' + ts;
        var sign = crypto.createHash('md5').update(signData).digest('hex');
        lobby.reqWebSvrd(host, port, '/v1/game/third/playing/unlock', {'gameId':2, 'ts':ts, 'sign':sign, 'appId':consts.BIRD.GAMEID, 'userId':userId}, function(err, data){
            console.log(err+',===========================GameBirdUnLock:'+JSON.stringify(data)+',userId:'+userId);
        });
    })
};

lobby.GetBirdLockStatus = function(userId, cb){
    lobby.GetBirdDataByField('http', function(err, http){
        if(err){
            cb('redis error');
            return;
        }
        var list = http.split('http://');
        list = list[1].split(':');
        var host = list[0];
        var port = list[1];
        var ts = parseInt(new Date().getTime()/1000);
        var signData = 'gameId=' + consts.BIRD.GAMEID + '&token=' + consts.BIRD.TOKEN + '&ts=' + ts;
        var sign = crypto.createHash('md5').update(signData).digest('hex');
        lobby.reqWebSvrd(host, port, '/v1/game/third/playing/query', {'gameId':2, 'ts':ts, 'sign':sign, 'appId':consts.BIRD.GAMEID, 'userId':userId}, function(err, data){
            console.log(err+',===========================GetBirdLockStatus:'+JSON.stringify(data)+',userId:'+userId);
            if(err){
                cb(err);
                return;
            }
            data = JSON.parse(data);
            if(data.gameId){
                cb(null, parseInt(data.gameId));
                return;
            }
            cb(null, 0);
        });
    })
};
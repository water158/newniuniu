var pomelo = require('pomelo');
var redis = require('redis');
var gateService = require('./app/services/gateService');
var connectorService = require('./app/services/connectorService');
var gameBaiRenService = require('./app/services/bairen/gameService');
var quickStartService = require('./app/services/quickStartService');
var autoMatchService = require('./app/services/autoMatchService');
var lobby = require('./app/services/lobby');
var routeUtil = require('./app/util/routeUtil');
var logger = require('pomelo-logger').getLogger('niuniu', __filename);
/**
 * Init app for client.
 */
var app = pomelo.createApp();
app.set('name', 'niuniu');

// app configuration
app.configure('development', 'connector', function(){
  app.set('connectorConfig',
    {
      connector : pomelo.connectors.hybridconnector,
      heartbeat : 3,
      useDict : true,
      useProtobuf : true,
      disconnectOnTimeout: true
    });
});

//网关服务器
app.configure('development', 'gate', function(){
    var server = app.curServer;
    var netPort = server.netPort;
    console.log('gate netPort = '+netPort);
    app.set('gateService', new gateService(app, netPort));
});

//连接服务器
app.configure('development', 'connector', function(){
    var server = app.curServer;
    var netPort = server.netPort;
    var host = server.host;
    var id = server.id;
    console.log('connector netPort = '+netPort);
    console.log('connector host = '+host);
    console.log('connector id = '+id);
    app.set('connectorService', new connectorService(app, host, netPort));
});

//百人场游戏服务器
app.configure('development', 'gameBaiRen', function(){
    var server = app.curServer;
    var netPort = server.netPort;
    var host = server.host;
    var id = server.id;
    console.log('gameBaiRen netPort = '+netPort);
    console.log('gameBaiRen host = '+host);
    console.log('gameBaiRen id = '+id);

    app.set('gameBaiRenService', new gameBaiRenService(app));
});

app.route('connector', routeUtil.route);
app.route('gameBaiRen', routeUtil.route);

//配桌服务器
app.configure('development', 'quickStart', function(){
    var server = app.curServer;
    var id = server.id;
    console.log('quickStart id = '+id);

    app.set('quickStartService', new quickStartService(app));
});

//投放机器人服务器
app.configure('development', 'autoMatch', function(){
    var server = app.curServer;
    var id = server.id;
    console.log('autoMatch id = '+id);

    app.set('autoMatchService', new autoMatchService(app));
});

app.loadConfig('mysql', app.getBase() + '/config/mysql.json');
var mysqlConfig = app.get('mysql');
var data_db_master = mysqlConfig.data_db_master;
var dbDataClient_master = require('./app/dao/mysqlData_master').init(data_db_master["host"], data_db_master["name"], data_db_master["user"], data_db_master["password"]);
app.set('dbDataClient_master', dbDataClient_master);
var data_db_slave = mysqlConfig.data_db_slave;
var dbDataClient_slave = require('./app/dao/mysqlData_slave').init(data_db_slave["host"], data_db_slave["name"], data_db_slave["user"], data_db_slave["password"]);
app.set('dbDataClient_slave', dbDataClient_slave);
var data_db_log = mysqlConfig.data_db_log;
console.log('data_db_log:'+JSON.stringify(data_db_log));
var dbDataClient_log = require('./app/dao/mysqlData_log').init(data_db_log["host"], data_db_log["name"], data_db_log["user"], data_db_log["password"]);
app.set('dbDataClient_log', dbDataClient_log);

app.loadConfig('redis', app.getBase() + '/config/redis.json');
var redisConfig = app.get("redis");
var redis_user = redisConfig.redis_user;
var redis_game = redisConfig.redis_game;
var redis_cache = redisConfig.redis_cache;
var redisUser = redis.createClient(redis_user['port'], redis_user['host'], {connect_timeout:1});
redisUser.on('error', function(error,response){
    console.log(error);
});
redisUser.select(redis_user['db']);
var redisGame = redis.createClient(redis_game['port'], redis_game['host'], {connect_timeout:1});
redisGame.on('error', function(error,response){
    console.log(error);
});
redisGame.select(redis_game['db']);
var redisCache = redis.createClient(redis_cache['port'], redis_cache['host'], {connect_timeout:1});
redisCache.on('error', function(error,response){
    console.log(error);
});
redisCache.select(redis_cache['db']);
redisCache.flushdb();
app.set('redisUser', redisUser);
app.set('redisGame', redisGame);
app.set('redisCache', redisCache);

// start app
app.start();

lobby.GetRoomInfo(101, function(err, roomInfo){});

//lobby.reqWebSvrd('211.155.95.182', 9006, '/v1/game/third/user/info', {'gameId':10003, 'ts':1469589403, 'sign':'7538cf7d3948b43a09bed65df32fb6fd', 'userId':20301}, function(err, data){
//    console.log(err+',0000000000000000000000000000000000000, data:'+data);
//});

process.on('uncaughtException', function (err) {
    logger.debug(' Caught exception: ' + err.stack);
});

/**
 * Created by yelong on 14-6-9.
 */

var async = require("async");
var _poolModule = require('generic-pool');
var debug = require('../util/debug');
var mysql = require('mysql');
var queues = require('mysql-queues');
const DEBUG = true;

/*
 * Create mysql connection pool.
 */
var createMysqlPool = function(address, dbName, user, password) {
    return _poolModule.Pool({
        name: 'mysql',
        create: function(callback) {
            var client = mysql.createConnection({
                host: address,
                user: user,
                password: password,
                database: dbName,
                insecureAuth:true
            });
            callback(null, client);
        },
        destroy: function(client) {
            client.end();
        },
        max: 10,
        idleTimeoutMillis : 30000,
        log : false
    });
};

// mysql CRUD
var sqlclient = module.exports;
var _pool = null;
var NND = {};

/**
 * Init sql connection pool
 * @param {Object} app The app for the server.
 */
NND.init = function(address, dbName, user, password){
    //Add Whole Server DB
    _pool = createMysqlPool(address, dbName, user, password);
    if (!!_pool){
        //debug.log("mysql create dao ", dbkey);
    }
};

/**
 * Excute sql statement
 * @param {String} sql Statement The sql need to excute.
 * @param {Object} args The args for the sql.
 * @param {fuction} cb Callback function.
 *
 */
NND.query = function(sql, args, cb){
    _pool.acquire(function(err, client) {
        if (!!err) {
            console.error('[sqlqueryErr] '+err.stack);
            return;
        }
        //debug.log("Get Pool DB Client ", JSON.stringify(sql), JSON.stringify(args));
        client.query(sql, args, function(err, res) {
            _pool.release(client);
            cb(err, res);
        });
    });
};

NND.transaction = function(sqlPacks, callback){
    _pool.acquire(function(err, client) {
        if (!!err) {
            console.error('[sqlqueryErr] '+err.stack);
            return;
        }
        // 获取事务
        queues(client, DEBUG);
        var trans = client.startTransaction();

        functions = [];
        for (var i in sqlPacks){
            functions.push( (function(index){
                return function(cb){
                    trans.query(sqlPacks[index].sql, sqlPacks[index].args, function(err, res){
                        cb(err, res);
                    });
                };
            })(i) );
        };
        async.series(functions, function(err, results) {
            if (err) {
                debug.error("rollback");
                trans.rollback();
            } else {
                debug.log("commit");
                trans.commit();
                _pool.release(client);
                callback(err, results);
            };
        });
        debug.log('execute');
        trans.execute();
    });
};

/**
 * Close connection pool.
 */
NND.shutdown = function(){
    if (!!_pool){
        _pool.destroyAllNow();
    };
};

/**
 * @class init database
 * @app 当前app context
 * @dbkey 标记当前数据库的类型
 */
sqlclient.init = function(address, dbName, user, password) {
    if (!!_pool){
        //debug.log("mysql inited!");
        return sqlclient;
    } else {
        //debug.log("mysql initialising!");
        NND.init(address, dbName, user, password);
        sqlclient.insert = NND.query;
        sqlclient.update = NND.query;
        sqlclient.remove = NND.query; //IDE makes warning if we use "delete" symbol
        sqlclient.query = NND.query;
        sqlclient.transaction = NND.transaction;
        return sqlclient;
    };
};

/**
 * shutdown database
 */
sqlclient.shutdown = function() {
    NND.shutdown();
};

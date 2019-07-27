/**
 * Created by yelong on 2015/7/4.
 */
var pomelo = require("pomelo");
var userDao = module.exports;

userDao.query = function(option, sql, args, cb){
    db = pomelo.app.get('dbDataClient_master');
    if(option == 'select'){
        db = pomelo.app.get('dbDataClient_slave');
    }

    db.query(sql, args, function(err, results){
        cb(err, results);
    });
};

userDao.queryLog = function(option, sql, args, cb){
    db = pomelo.app.get('dbDataClient_log');
    db.query(sql, args, function(err, results){
        cb(err, results);
    });
};

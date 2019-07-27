/**
 * Created by yelong on 2015/4/15.
 */
var http = require('http');
var defaultConfig = require('../ownConfig/defaultConfig');
var debug = require("../util/debug");

//var DATA_SERVER = defaultConfig["DATA_SERVER"];
//var DATA_PORT = defaultConfig["DATA_PORT"];

var DATA_SERVER = "192.168.1.133";
var DATA_PORT = "22221";

var getUserKV = function(userId, ids, cb){
    var options = {
        hostname:DATA_SERVER,
        port: DATA_PORT,
        method: 'POST'
    };

    var req = http.request(options, function(res) {
        res.on('data', function (chunk) {
            debug.log("on buffer "+ chunk);
            var dataOb = JSON.parse(chunk);
            var result = dataOb.result;
            var results = dataOb.results;
            if(result === 1){
                cb(null, results);
            }else{
                cb(1);
            }
        });
    });

    req.on('error', function(e) {
        debug.log('getUserKV problem with request: ' + e.message);
    });


    var DATA = JSON.stringify({id:2,data:{key:userId,ids:ids}});
    debug.log("getUserKV send data = " + DATA);
    req.write(DATA);
    req.end();
}

var setUserKV = function(userId, kvs, cb){
    var options = {
        hostname:DATA_SERVER,
        port: DATA_PORT,
        method: 'POST'
    };

    var req = http.request(options, function(res) {
        res.on('data', function (chunk) {
            debug.log("setUserKV on buffer "+ chunk);
            var dataOb = JSON.parse(chunk);
            var result = dataOb.result;
            if(result === 1){
                cb(null);
            }else{
                cb(1);
            }
        });
    });

    req.on('error', function(e) {
        debug.log('setUserKV problem with request: ' + e.message);
    });


    //[{id:id,v:value}]
    var DATA = JSON.stringify({id:1,data:{key:userId, kvs:kvs}});
    debug.log("setUserKV send data = " + DATA);
    req.write(DATA);
    req.end();
}

exports.getUserKV = getUserKV;
exports.setUserKV = setUserKV;

/*getUserKV(133, [1,3,7], function(err, result){
    if(err === null){
        var dt = result["7"];
        console.log("dt = "+dt);
        if(parseInt(dt) === 0){
            console.log("=0");
        }
    }
});*/
/*var tt = [{gd:7,gb:1},
    {gd:8,gb:0},
    {gd:9,gb:1},
    {gd:10,gb:0},
    {gd:11,gb:1},
    {gd:12,gb:0},
    {gd:13,gb:1},
    {gd:14,gb:1}]

var tmp = JSON.stringify(tt);
console.log("temp = "+ tmp);
console.log("temp lenth = "+ tmp.length);
//tmp = '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789'

setUserKV(10, [{id:105,v:3},{id:104,v:tmp}], function(err, data){
    hall_logger.debug("setUserGoodsConfig err = " + JSON.stringify(err));
});*/
/*var data1 = {6:0,7:0};
setUserGoodsConfig(1, JSON.stringify(data1), function(err, data){
    hall_logger.debug("setUserGoodsConfig data = " + JSON.stringify(data));
});*/




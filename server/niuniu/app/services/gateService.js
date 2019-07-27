/**
 * Created by wjl on 2015/7/6.
 */
var http = require('http');
var url = require("url");
var router = require('./route');
var user = require('./user');
var logger = require('pomelo-logger').getLogger('niuniu', __filename);

var handle = {
    '/v1/user/registerRobot':user.registerRobot,
    '/game_info':user.game_info,
    '/game_start':user.game_start
};

var gateService = function(app, netPort) {
    this.app = app;
    var self = this;

    self.server = http.createServer(function (req, res) {
        var pathname = url.parse(req.url).pathname;
        // 关闭nodejs 默认访问 favicon.ico
        if (!pathname.indexOf('/favicon.ico')) {
            return;
        }
        req.setEncoding('utf-8');
        var postData = '';
        req.on('data', function(data) {
            postData += data;
        });
        req.on('end', function(){
            logger.debug("Request for " + pathname + ", postData:"+postData);
            router.route(self.app, handle, pathname, postData, req.connection.remoteAddress, function(err, result){
                var backData = JSON.stringify(result);
                if(err == -100){
                    backData = result;
                }
                logger.debug("Response for " + pathname + ":" + backData);
                res.write(backData);
                res.end();
            });
        });
    });

    logger.debug("gate server start port = "+ netPort);
    this.server.listen(netPort);
};

module.exports = gateService;

module.exports = function(app) {
	return new autoMatchRemote(app, app.get('autoMatchService'));
};

var autoMatchRemote = function(app, autoMatchService) {
	this.app = app;
	this.autoMatchService = autoMatchService;
};

pro = autoMatchRemote.prototype;

pro.OnMsg = function(userId, msgId, data, cb){
    var self = this;
    self.autoMatchService.OnMsg(userId, msgId, data, function(ackData){
        cb(ackData);
    });
};

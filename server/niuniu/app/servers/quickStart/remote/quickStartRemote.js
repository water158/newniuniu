module.exports = function(app) {
	return new quickStartRemote(app, app.get('quickStartService'));
};

var quickStartRemote = function(app, quickStartService) {
	this.app = app;
	this.quickStartService = quickStartService;
    console.log("quickStartRemote start +++++++++++++++++++++++++++++++++++");
};

pro = quickStartRemote.prototype;

pro.OnMsg = function(remoteServerId, userId, msgId, data, cb){
    var self = this;
    self.quickStartService.OnMsg(remoteServerId, userId, msgId, data);
    cb(null);
};

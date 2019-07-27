module.exports = function(app) {
	return new connectorRemote(app, app.get('connectorService'));
};

var connectorRemote = function(app, connectorService) {
	this.app = app;
	this.connectorService = connectorService;
    console.log("connectorRemote start")
};

pro = connectorRemote.prototype;

pro.OnInterMsg = function(userId, msgId, msg, cb){
    var self = this;
    self.connectorService.OnInterMsg(userId, msgId, msg);
    cb(null);
};

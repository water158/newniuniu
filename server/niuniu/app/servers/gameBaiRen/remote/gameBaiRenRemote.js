module.exports = function(app) {
	return new gameRemote(app, app.get('gameBaiRenService'));
};

var gameRemote = function(app, gameService) {
	this.app = app;
	this.gameService = gameService;
    console.log("gameBaiRenRemote start +++++++++++++++++++++++++++++++++++");
};

pro = gameRemote.prototype;

pro.OnMsg = function(remoteServerId, userId, msgId, data, cb){
    var self = this;
    self.gameService.OnMsg(remoteServerId, userId, msgId, data);
    cb(null);
};

module.exports = function(app) {
	return new gateRemote(app, app.get('gateService'));
};

var gateRemote = function(app, gateService) {
	this.app = app;
	this.gateService = gateService;
    console.log("gateRemote start")
};

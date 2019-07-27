var exp = module.exports;

exp.route = function(serverId, msg, app, cb) {
	cb(null, serverId);
};
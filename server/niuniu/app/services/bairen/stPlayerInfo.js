/**
 * Created by yelong on 2015/7/8.
 */
var util = require('util');

var player = function(){
    this.cardSet = [];
    this.niuCnt = 0;
    this.winFan = 0;
};

pro = player.prototype;
module.exports = player;

pro.reset = function(){
    this.cardSet = [];
    this.niuCnt = 0;
    this.winFan = 0;
};

pro.init = function(){
    this.cardSet = [];
    this.niuCnt = 0;
    this.winFan = 0;
};




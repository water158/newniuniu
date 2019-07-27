/**
 * Created by yelong on 2015/7/4.
 */
var EventEmitter = require('events').EventEmitter;
var util = require('util');
var net = require('net');

var socketClient = function(host, port){
    var self = this;
    self.is_connected = false;
    self.is_register = false;
    self.buffer_list = [];      //收到的消息缓存
    //self.will_receive = 0;      //将要收到的字节数
    //TCP客户端(socket)
    self.tcpClient = net.connect({host:host, port:port}, function() {
        console.log('connect to svrd success');
        self.is_connected = true;
        self.emit('on_connect');
    });
    self.tcpClient.on('data', function(data) {
        self.ProcessRecv(data);
        //self.emit('on_data', data);
    });
    self.tcpClient.on('end', function() {
        console.log('svrd receive end event');
        self.is_connected = false;
        self.is_register = false;
    });
};

util.inherits(socketClient, EventEmitter);
var pro = socketClient.prototype;

pro.ProcessRecv = function(data){
    var self = this;
    if(self.buffer_list.length !== 0){
        self.buffer_list.push(data); //收到消息压入缓存
        var buff_l = 0;
        for(var i = 0; i < self.buffer_list.length; i++){
            buff_l += self.buffer_list[i].length;
        }
//        if(buff_l < self.will_receive){
//            return;
//        }

        data = Buffer.concat(self.buffer_list, buff_l);
        self.buffer_list = [];
        //self.will_receive = 0;
    }

    //不够一个数据包的数据暂时压入缓存，等待下次接收处理
    if(data.length < 12){
        self.buffer_list.push(data);
        return;
    }

    var size_buff = new Buffer(12);
    data.copy(size_buff, 0, 0, 12);
    var msg_size = size_buff.readUInt32LE(4, 4);

    //console.log('msg_size = '+msg_size);

    if(0 === msg_size){
        if(data.length > 12){ //心跳包后边包括其他数据包
            var next_buff = new Buffer(data.length-12);
            data.copy(next_buff, 0, 12, data.length);
            self.ProcessRecv(next_buff);//迭代处理剩下的消息
        }
    }else{
        var data_length = data.length-12;
        //console.log('data_length = '+data_length);
        if(data_length >= msg_size){
            var body_buff = new Buffer(msg_size+12);
            data.copy(body_buff, 0, 0, msg_size+12);//取出完整的数据报的数据
            //console.log('body_buff = '+ body_buff.toString());
            self.emit('on_data', body_buff);//发送收到消息事件
            if(data_length > msg_size){//粘连的数据包
                var next_buff = new Buffer(data.length-12-msg_size);
                data.copy(next_buff, 0, 12+msg_size, data.length);//取出剩余的数据
                self.ProcessRecv(next_buff);//迭代处理剩下的消息
            }
        }else{
            self.buffer_list.push(data);//不够一个数据包的数据暂时压入缓存，等待下次接收处理
            //self.will_receive = msg_size;
        }
    }
};

pro.setRegister = function(bRegister){
    var self = this;
    self.is_register = bRegister;
};

pro.socketSend = function(buffer, cb){
    var self = this;
    if(self.is_connected){
        self.tcpClient.write(buffer);
        cb(null);
    }else{
        console.log('socket is_connected false');
        cb('err disconnect');
    }
};

module.exports = socketClient;

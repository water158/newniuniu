/**
 * Created by yelong on 2015/8/19.
 */
var common = module.exports;

common.getJSON = function(str_input, outData){
    var out_put = [];
    var outJSON = {};
    while(true){
        var t = str_input.indexOf('&');
        //console.log(t);
        if(t < 0){
            break;
        }

        var tt = str_input.substr(0, t);
        var k = tt.indexOf('=');
        var kk = tt.substr(0, k);
        var value = tt.substr(k+1, tt.length);
        out_put.push(kk);
        outJSON[kk] = value;
        //console.log(tt);
        str_input = str_input.substr(t+1, str_input.length);
        //console.log('str_input= '+ str_input);
    }
    var tt = str_input;
    var k = tt.indexOf('=');
    var kk = tt.substr(0, k);
    var value = tt.substr(k+1, tt.length);
    out_put.push(kk);
    outJSON[kk] = value;

    out_put.sort();
    for(var i = 0; i < out_put.length; i++){
        var t = out_put[i];
        outData[t] = outJSON[t];
    }
}


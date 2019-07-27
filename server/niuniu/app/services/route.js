/**
 * Created by wjl on 2015/9/9.
 */

// 路由模块,针对不同的请求,做出不同的响应
// handle 处理请求方法

function route(app, handle, pathname, postData, remoteAddress, cb) {
    //console.log("About to route a request for " + pathname + ',content:' + JSON.stringify(postData));

    // 检查给定的路径对应的请求处理程序是否存在，如果存在的话直接调用相应的函数
    if (typeof handle[pathname] == "function") {
        handle[pathname](app, postData, remoteAddress, function(err, result){
            cb(err, result);
        });
    } else {
        //console.log("No request handler found for " + pathname);
        cb(null, {'result': 404});
    }
}

exports.route = route;
var http = require('http');

var HttpRequest = function () {
	this.proxyinfo={
		"host":"112.124.211.29"
		,"intl_port":18089
		,"dom_port":18085
	};	// this.proxyinfo={
		// "host":"127.0.0.1"
		// ,"intl_port":8087
		// ,"dom_port":8087
	// };
	this.user_agent="Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-CN; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10";
}

exports.HttpRequest = HttpRequest;

/**
 * if timeout, emit "timeout" event, abort request, and emit "abort" event for response
 * @param options
 * @param timeout
 * @param callback
 */
HttpRequest.prototype.httpGetWithTimeoutSupport = function(options,parameter, timeout, data, callback) {
    var timeoutEvent;
    
    
    if(!options.method){
	options.method="GET";
    }
   
    // var hostname=options.hostname;	
    // options.path=options.href;
    // options.host=this.proxyinfo.host;
    // if(options.hostname=="www.kayak.com"){
    	// options.port=this.proxyinfo.intl_port;
	// }
	// else{
		// options.port=this.proxyinfo.dom_port;
	// }
// 
    // if(!options.headers){
		// var headers={};
		// options.headers=headers;
    // }
//     
    // if(!options.headers["User-Agent"]){
		// options.headers["User-Agent"]=this.user_agent;
    // }
// 
    // options.headers.host=options.hostname;
// 	
    // delete options.pathname;
    // delete options.hostname;
    // delete options.hash;
    // delete options.auth;
    // delete options.protocol;
    // delete options.slashes;
    // delete options.search;
    // delete options.query;
    // delete options.href;
    if(options.hostname=="www.kayak.com"){
	    var hostname=options.hostname;	
	    options.path=options.href;
	    options.host=this.proxyinfo.host;
	    if(options.hostname=="www.kayak.com"){
	    	options.port=this.proxyinfo.intl_port;
		}
		else{
			options.port=this.proxyinfo.dom_port;
		}
	
	    if(!options.headers){
			var headers={};
			options.headers=headers;
	    }
	    
	    if(!options.headers["User-Agent"]){
			options.headers["User-Agent"]=this.user_agent;
	    }
	
	    options.headers.host=options.hostname;
		
	    delete options.pathname;
	    delete options.hostname;
	    delete options.hash;
	    delete options.auth;
	    delete options.protocol;
	    delete options.slashes;
	    delete options.search;
	    delete options.query;
	    delete options.href;
   }
   else{
   		
   }

   // console.info(JSON.stringify(options));
   // console.info("port",options.port);    

    var req = http.request(options, function(res) {
    	console.info("--------[request info]--------");
        console.info("request url："+options.path);
        if(data!=null && data!=""){
            console.info("request data："+data);
        }
        console.info("request status："+res.statusCode);
        // console.info("------------------------------");		// var fs=require("fs");
		// fs.writeFileSync("./123.txt","");
		// fs.appendFileSync("./123.txt",options.path+":"+res.statusCode+"\r\n");
        if(res.statusCode!=200 && res.statusCode!=302){
		//console.info("http error:");
		clearTimeout(timeoutEvent);
		var user_error={"statusCode":res.statusCode,"message":res.statusCode};
		callback(res,parameter,user_error);
	}
	else{

		res.on("end", function() {
           	 clearTimeout(timeoutEvent);
           	 // console.log("end");
       		 })
        res.on("close", function(e) {
            clearTimeout(timeoutEvent);
            // console.log("close");
        })

        res.on("abort", function() {
        	
        });
	        
        callback(res,parameter);
	}
    });

    req.on("timeout", function() {
        // console.log("timeout received");
        if (req.res) {
            req.res.emit("abort");
        }

        req.abort();
    });
    
    req.on("error", function(error) {
    	clearTimeout(timeoutEvent);
		//console.info("[httprequest.js]request error:"+error);
    	callback(req,parameter,error);
    });

    timeoutEvent = setTimeout(function() {
        req.emit("timeout");
    }, timeout);

	if(options.headers && options.method && options.method.toLowerCase()=="post" && data){
		req.write(data);
	}
	
	req.end();

    return req;
}

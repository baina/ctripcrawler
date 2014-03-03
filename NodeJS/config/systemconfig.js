var SystemConfig = function(){
};

exports.SystemConfig = SystemConfig;

/**
 * 数据抓取地址配置
 */
SystemConfig.prototype.Get_Request_Config=function(){
	return {
	"ow":"http://flights.ctrip.com/international/SearchFlights.aspx"
		,"rt":"http://flights.ctrip.com/international/SearchFlights.aspx"
		,"index":"http://flights.ctrip.com/international/"
		,"poll":"http://www.kayak.com/s/jsresults?ss=1&poll=$poll$&final=false&updateStamp=$timestamp$"
		,"detail":"http://www.kayak.com/s/run/inlineDetails/flight"
		,"nextpage":"http://www.kayak.com/s/jsresults?ss=1"
	};
};

/**
 * 系统基本配置
 */
SystemConfig.prototype.Get_System_Config=function(){
	return {
		"reconnect_count":3
	};
};

/**
 * 云端成功通知接口配置
 */
SystemConfig.prototype.Get_Notify_Config=function(){
	return {
		"url":"http://cloudavh.sinaapp.com/checker/?"
		,"key":"5P826n55x3LkwK5k88S5b3XS4h30bTRg"
	};
};

/**
 * 又拍云配置
 */
SystemConfig.prototype.Get_UpYun_Config=function(){
	return {
		"username":"langzuwentai"
		,"password":"admin.&*&bcDD"
		,"spacename":"biyifei"
		,"uploadpath":"/besftly/"
	};
};

/**
 * 任务中心配置
 */
SystemConfig.prototype.Get_TaskCenter_Config=function(){
	return {
		"url":"http://api.bestfly.cn/task-queues",
		"parameger":{
			"qbody": "",
		    "queues": "intl:kayak",
		    "type": 1
		}
	};
};

/**
 * 页码大小（从0开始计算）
 */
SystemConfig.prototype.GetPageMax=function(){
	return 2;
};

/**
 * 页码大小（从0开始计算）
 */
SystemConfig.prototype.GetInfoLevel=function(){
	return "debug";
};

var HttpRequest = new (require("./util/httprequest").HttpRequest);
var URL = require('url');
var fs = require('fs');
var os = require("os");
var zlib = require("zlib");
var Safe = new (require('./util/safe').Safe);
var ConfigClass = (new (require('./config/systemconfig').SystemConfig));
var iconv = require('iconv-lite');

/*-----获取配置信息-----*/
var Request_Config = ConfigClass.Get_Request_Config();
var System_Config = ConfigClass.Get_System_Config();
var Notice_Config = ConfigClass.Get_Notify_Config();
var UpYunInfo = ConfigClass.Get_UpYun_Config();
var TaskCenterConfig = ConfigClass.Get_TaskCenter_Config();
var level = ConfigClass.GetInfoLevel();
var MessageLevel = ConfigClass.Get_Request_Config();

var $ = null;
os.platform().match(/win32/i) ? $ = require("jquery_win32") : $ = require("jquery")(require('jsdom').jsdom().createWindow());

var Model_SearchInfo = {
	dst : null,
	org : null,
	date : null,
	edate : "",
	type : "ow",
	error_count : 0
};

var Class_Temp = {
	url : null,
	redire_url_host : "http://flights.ctrip.com/",
	page_now : 0,
	CorrelationId : null,
	VIEWSTATE : null
};

//获取运行参数
var arguments = process.argv.splice(2);
var searchid = null;
var currentsortid = null;
var poll = 1;
var detail_data = [];
var filghtitems = [];
var filghtitems_source = [];
var bund_index = {
	"Economy" : {
		"ClassGrade" : "Economy"
	},
	"Business" : {
		"ClassGrade" : "Business"
	},
	"First" : {
		"ClassGrade" : "First"
	},
	"Premium" : {
		"ClassGrade" : "Premium"
	}
};

//生成日志
function GetLogFilePath(path) {
	if (!path) {
		path = "./";
	}
	return path + new Date().getFullYear().toString() + "-" + (new Date().getMonth() + 1).toString() + "-" + new Date().getDate().toString();
}

var GetWebDate = {
	ResponseEnd : function() {
		console.info("  end:" + new Date().toString());
	},
	/**
	 *获取搜索页首页信息
	 */
	GetIndexPageInfo : function(num) {
		if (num <= System_Config.reconnect_count) {
			//获取请求参数
			var options = URL.parse(Class_Temp.url);
			options.headers = {};
			options.headers["User-Agent"] = "Mozilla/5.0 (Windows; U; Windows NT 6.1; zh-CN; rv:1.9.2.10) Gecko/20100914 Firefox/3.6.10";
			options.headers["Accept"] = "text/html, */*; q=0.01";
			options.headers["Accept-Language"] = "zh-cn,zh;q=0.5";
			// options.headers["Accept-Encoding"]="gzip,deflate";
			options.headers["Accept-Charset"] = "GB2312,utf-8;q=0.7,*;q=0.7";
			HttpRequest.httpGetWithTimeoutSupport(options, null, 150000, null, function(response, hashkey, error) {
				if (error) {
					console.info("frist index page error" + error);
					GetWebDate.NotifyTaskCenter(GetWebDate.ResponseEnd);
				} else {
					var buffer = [];
					var maxlength = 0;
					response.on("readable", function() {
						var m = response.read();
						if (m) {
							buffer.push(m);
							maxlength += buffer[buffer.length - 1].length;
						}
					});
					response.on("end", function() {
						var indexpage_data = Buffer.concat(buffer, maxlength);
						indexpage_data = iconv.decode(indexpage_data, 'GBK');
						//写入第一程文件
						//fs.writeFileSync("./"+Model_SearchInfo.dst+Model_SearchInfo.org+"_"+Model_SearchInfo.date+(Model_SearchInfo.edate==""?"":"."+Model_SearchInfo.edate)+"_index.html",indexpage_data+"\n");
						Class_Temp.CorrelationId = $(indexpage_data).find("#CorrelationId").val();
						Class_Temp.VIEWSTATE = $(indexpage_data).find("#__VIEWSTATE").val();
						if (Class_Temp.CorrelationId != null && Class_Temp.VIEWSTATE != null) {
							GetWebDate.GetSearchPageInfo(0);
						} else {
							GetWebDate.NotifyTaskCenter(GetWebDate.ResponseEnd);
						}
					});
				}
			});
		} else {
			GetWebDate.NotifyTaskCenter(GetWebDate.ResponseEnd);
		}
	},
	GetSearchPageInfo : function(num) {
		if (num <= System_Config.reconnect_count) {
			var options = URL.parse(Request_Config[Model_SearchInfo.type]);
			// var post_data={
			// "CurrentFirstDomain":"ctrip.com"
			// ,"__VIEWSTATE":Class_Temp.VIEWSTATE
			// ,"CorrelationId":Class_Temp.CorrelationId
			// ,"ctl00$MainContentPlaceHolder$drpFlightWay":"S"
			// ,"ctl00$MainContentPlaceHolder$txtDCity":"广州(CAN)"
			// ,"ctl00$MainContentPlaceHolder$dest_city_1":"伦敦(英国)(LON)"
			// ,"ctl00$MainContentPlaceHolder$txtDDatePeriod1":Model_SearchInfo.date
			// ,"ctl00$MainContentPlaceHolder$txtADatePeriod1":(Model_SearchInfo.edate==null?"":Model_SearchInfo.edate)
			// ,"ctl00$MainContentPlaceHolder$txtBeginAddress1":"广州(CAN)"
			// ,"ctl00$MainContentPlaceHolder$txtEndAddress1":"伦敦(英国)(LON)"
			// ,"ctl00$MainContentPlaceHolder$txtDatePeriod1":Model_SearchInfo.date
			// ,"ctl00$MainContentPlaceHolder$txtBeginCityCode1":32
			// ,"ctl00$MainContentPlaceHolder$txtEndCityCode1":338
			// ,"ctl00$MainContentPlaceHolder$txtBeginAddress2":""
			// ,"ctl00$MainContentPlaceHolder$txtEndAddress2":""
			// ,"ctl00$MainContentPlaceHolder$txtDDatePeriod2":""
			// ,"ctl00$MainContentPlaceHolder$txtBeginCityCode2":""
			// ,"ctl00$MainContentPlaceHolder$txtEndCityCode2":""
			// ,"ctl00$MainContentPlaceHolder$txtBeginAddress3":""
			// ,"ctl00$MainContentPlaceHolder$txtEndAddress3":""
			// ,"ctl00$MainContentPlaceHolder$txtDDatePeriod3":""
			// ,"ctl00$MainContentPlaceHolder$txtBeginCityCode3":""
			// ,"ctl00$MainContentPlaceHolder$txtEndCityCode3":""
			// ,"ctl00$MainContentPlaceHolder$drpQuantity":1
			// ,"ctl00$MainContentPlaceHolder$ticket_city":""
			// ,"ctl00$MainContentPlaceHolder$txtSourceCityID":""
			// ,"ctl00$MainContentPlaceHolder$drpSubClass:Y":""
			// ,"ctl00$MainContentPlaceHolder$selUserType:ADT":""
			// ,"txtAirline:":""
			// ,"ctl00$MainContentPlaceHolder$btnSearchFlight":"搜索"
			// ,"ctl00$MainContentPlaceHolder$txtDCityID":32
			// ,"ctl00$MainContentPlaceHolder$txtDestcityID":338
			// ,"ctl00$MainContentPlaceHolder$txtOpenJawCityID3":""
			// ,"ctl00$MainContentPlaceHolder$txtOpenJawCityID4":""
			// ,"FlightWay":"D""
			// ,"HomeCity":""
			// ,"DestCity1":""
			// ,"DestCity2":""
			// ,"TicketAgency_List":""
			// ,"DDatePeriod1":""
			// ,"startPeriod":"All"
			// ,"ADatePeriod1":""
			// ,"startPeriod2":"All""
			// ,"ChildType":"ADU"
			// ,"DSeatClass":"Y""
			// ,"Quantity":1
			// ,"strCorpID":""
			// ,"Airline":"All"
			// ,"ExpenseType":"PUB"
			// ,"IsFavFull":""
			// };
			var post_data = "CurrentFirstDomain=ctrip.com" + "&__VIEWSTATE=" + encodeURIComponent(Class_Temp.VIEWSTATE);
			post_data += "&CorrelationId=" + Class_Temp.CorrelationId + "&ctl00$MainContentPlaceHolder$drpFlightWay=S";
			post_data += "&ctl00$MainContentPlaceHolder$txtDCity=" + encodeURIComponent("广州(CAN)");
			post_data += "&ctl00$MainContentPlaceHolder$dest_city_1=" + encodeURIComponent("伦敦(英国)(LON)");
			post_data += "&ctl00$MainContentPlaceHolder$txtDDatePeriod1=" + Model_SearchInfo.date;
			post_data += "&ctl00$MainContentPlaceHolder$txtADatePeriod1=" + (Model_SearchInfo.edate == null ? "" : Model_SearchInfo.edate);
			post_data += "&ctl00$MainContentPlaceHolder$txtBeginAddress1=" + encodeURIComponent("广州(CAN)");
			post_data += "&ctl00$MainContentPlaceHolder$txtEndAddress1=" + encodeURIComponent("伦敦(英国)(LON)");
			post_data += "&ctl00$MainContentPlaceHolder$txtDatePeriod1=" + Model_SearchInfo.date;
			post_data += "&ctl00$MainContentPlaceHolder$txtBeginCityCode1=32";
			post_data += "&ctl00$MainContentPlaceHolder$txtEndCityCode1=338";
			post_data += "&ctl00$MainContentPlaceHolder$txtBeginAddress2=&ctl00$MainContentPlaceHolder$txtEndAddress2=";
			post_data += "&ctl00$MainContentPlaceHolder$txtDDatePeriod2=&ctl00$MainContentPlaceHolder$txtBeginCityCode2=&ctl00$MainContentPlaceHolder$txtEndCityCode2=&ctl00$MainContentPlaceHolder$txtBeginAddress3=&ctl00$MainContentPlaceHolder$txtEndAddress3=";
			post_data += "&ctl00$MainContentPlaceHolder$txtDDatePeriod3=&ctl00$MainContentPlaceHolder$txtBeginCityCode3=&ctl00$MainContentPlaceHolder$txtEndCityCode3=";
			post_data += "&ctl00$MainContentPlaceHolder$drpQuantity=1&ctl00$MainContentPlaceHolder$ticket_city=&ctl00$MainContentPlaceHolder$txtSourceCityID=";
			post_data += "&ctl00$MainContentPlaceHolder$drpSubClass:Y=&ctl00$MainContentPlaceHolder$selUserType:ADT=&txtAirline=";
			post_data += "&ctl00$MainContentPlaceHolder$btnSearchFlight=" + encodeURIComponent("搜索");
			post_data += "&ctl00$MainContentPlaceHolder$txtDCityID=32";
			post_data += "&ctl00$MainContentPlaceHolder$txtDestcityID=338";
			post_data += "&ctl00$MainContentPlaceHolder$txtOpenJawCityID3=&ctl00$MainContentPlaceHolder$txtOpenJawCityID4=";
			post_data += "&FlightWay=D&HomeCity=&DestCity1=&DestCity2=&TicketAgency_List=&DDatePeriod1=&startPeriod=All";
			post_data += "&ADatePeriod1=&startPeriod2=All&ChildType=ADU&DSeatClass=Y&Quantity=1&strCorpID=&Airline=All";
			post_data += "&ExpenseType=PUB&IsFavFull=";
			var cookies_json={
				"multipleRound":"S"
				,"moreflightMin":3
				,"flightintl_startcity_single":"广州(CAN)|32|GUANGZHOU，CHINA"
				,"flightintl_arrivalcity_single":"伦敦(英国)(LON)|338"
				,"flightintl_startdate_single":Model_SearchInfo.date
				,"flightintl_backdate_single":(Model_SearchInfo.edate == null ? "" : Model_SearchInfo.edate)
			};
			options.method = "post";
			options.headers = {};
			options.headers = {
				"Accept:text/html" : "application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
				// "Accept-Encoding" : "gzip,deflate,sdch",
				"Accept-Language" : "zh-CN,zh;q=0.8,en;q=0.6",
				"Cache-Control" : "max-age=0",
				"Connection" : "keep-alive",
				"Content-Length" : post_data.length,
				"Content-Type" : "application/x-www-form-urlencoded"
				,"Cookie":"waitStatus="+new Date().getTime()+";"+
					"DomesticUserHostCity="+Model_SearchInfo.dst.toUpperCase()+"|%b9%e3%d6%dd;__zpr=flights.ctrip.com%7C;utmcsr=qunar.com|utmccn=(referral)|utmcmd=referral|utmcct=/booksystem/Booking_Main.jsp;"+
					'flightintl_searchBoxVals_gb2312='+encodeURIComponent(JSON.stringify(cookies_json))+';'
			};
			HttpRequest.httpGetWithTimeoutSupport(options, null, 150000, post_data, function(response, hashkey, error) {
				if (error) {
					console.info("get search page info error:" + error);
					GetWebDate.NotifyTaskCenter(GetWebDate.ResponseEnd);
				}
				else {
					var buffer = [];
					var maxlength = 0;
					response.on("readable", function() {
						var m = response.read();
						if (m) {
							buffer.push(m);
							maxlength += buffer[buffer.length - 1].length;
						}
					});
					response.on("end", function() {
                		var searchpageinfo_data = Buffer.concat(buffer, maxlength);
						searchpageinfo_data = iconv.decode(searchpageinfo_data, 'GBK');
						//fs.writeFileSync("./"+Model_SearchInfo.dst+Model_SearchInfo.org+"_"+Model_SearchInfo.date+(Model_SearchInfo.edate==""?"":"."+Model_SearchInfo.edate)+"_searchindex.html",searchpageinfo_data+"\n");
					});
				}
			});
		}
		else{
			GetWebDate.GetSearchPageInfo(num+1);
		}
	},
	/**
	 *通知任务中心任务失败
	 */
	NotifyTaskCenter : function(callback) {
		if (MessageLevel == "public") {
			var options = URL.parse(TaskCenterConfig.url);
			//设置data
			TaskCenterConfig.parameger.qbody = Model_SearchInfo.dst + "/" + Model_SearchInfo.org + "/" + Model_SearchInfo.date.replace(/-/gi, '') + (Model_SearchInfo.edate.replace(/-/gi, '') == "" ? "" : "/" + Model_SearchInfo.edate.replace(/-/gi, '')) + "/" + (Model_SearchInfo.error_count + 1);
			var data = JSON.stringify(TaskCenterConfig.parameger);
			//设置POST等header参数
			options.method = "POST";
			options.headers = {};
			options.headers["Content-Length"] = data.length;
			HttpRequest.httpGetWithTimeoutSupport(options, null, 150000, data, function(response, hashkey, error) {
				callback();
			});
		} else {
			callback();
		}
	},
	/**
	 *判断是否获取详情完成
	 */
	CheckFinish : function(cookies) {
		if (detail_data.length == filghtitems_source.length) {
			GetWebDate.MakeFightsInfo(cookies);
		}
	},
	/**
	 *生成标准航线信息json
	 */
	MakeFightsInfo : function(cookies) {
		for (var i = 0; i < filghtitems_source.length; i++) {
			//fs.writeFileSync("./"+page_now.toString()+"."+i.toString()+".html",filghtitems_source[i]);
			var data = filghtitems_source[i];
			var flights = {
				"bunks_idx" : [],
				"prices_data" : []
			};
			var segments_array = [[], []];
			var segmentslist = [];
			var fltcomb = "";

			var m = 0;
			$.each($(data).find(".takeoff"), function(index, val) {
				var segments = {};
				if ($(data).find(".first").eq(index).prev().prev().find("td").eq(0).find("div").html() == "Return") {
					m = 1;
				}

				var div_fltcomb = $(data).find(".first").eq(index);
				if (fltcomb != "") {
					fltcomb += "-";
				}
				var air_code = $(div_fltcomb).find("img").attr("src");
				air_code = air_code.substring(air_code.lastIndexOf("/") + 1);
				air_code = air_code.substring(0, air_code.indexOf("."));
				var air_no = $(div_fltcomb).find(">td:eq(0)").html();

				var rule = new RegExp('Flight[ ]?[0-9]*');
				air_no = air_no.match(rule);
				if (air_no != null) {
					air_no = air_no[0];
					air_no = air_no.replace(/Flight/gi, '').replace(/ /gi, '');
					fltcomb += air_code + air_no;
				}

				var aval = $(data).find(".landing").eq(index);
				var DTime = GetWebDate.FormatGetTime($.trim($(val).find(".time").html().split(" ")[1]));
				var ATime = GetWebDate.FormatGetTime($.trim($(aval).find(".time").html().split(" ")[1]));
				var DPort = $.trim($(val).find(".airport").html()).substring(0, 3);
				var APort = $.trim($(aval).find(".airport").html()).substring(0, 3);
				segments["DTime"] = DTime;
				segments["ATime"] = ATime;
				segments["DPort"] = DPort;
				segments["APort"] = APort;
				// segmentslist[segmentslist.length]=segments;
				segments_array[m][segments_array[m].length] = segments;
			});
			flights["fltcomb"] = fltcomb;
			var flightline_id_content = "";
			for (var index = 0; index < segments_array.length; index++) {
				if (segments_array[index].length > 0) {
					if (flightline_id_content != "") {
						flightline_id_content += ",";
					}
					flightline_id_content += GetWebDate.GetFligthIdContent(segments_array[index]);
				}
			}
			flights["flightline_id_content"] = flightline_id_content;
			flights["flightline_id"] = Safe.MD5(flightline_id_content);
			$.each($(data).find(".fareInformation"), function(index, val) {
				var bunk_index = bund_index[$(val).attr("data-cabin")];
				if (!bunk_index) {
					bunk_index = {
						"ClassGrade" : $(val).attr("data-cabin")
					};
				}
				var tbodylist = $(val).find("tbody");
				var price_list = [];
				for (var m = 0; m < tbodylist.length; m++) {
					var price_data = {};
					if ($.trim($(tbodylist[m]).find(".name>div").html()) == "") {
						continue;
					}
					var company = $.trim($(tbodylist[m]).find(".name>div").html().replace(/<[^>].*?>/g, "").replace(/\n/g, "").replace(/	/g, "").replace(/  /g, "").replace(/Hacker Fare1/g, ""));
					var price = $.trim($(tbodylist[m]).find(".total>a").html());
					if (price != "") {
						var link = Class_Temp.redire_url_host + $.trim($(tbodylist[m]).find(".total>a").attr("href"));
						price_data[company] = {
							"priceinfo" : {
								"Price" : price
							},
							"salelimit" : {
								"RedirectURI" : link
							}
						};
						price_list[price_list.length] = price_data;
					}
				}
				if (price_list.length > 0) {
					flights["bunks_idx"][flights["bunks_idx"].length] = bunk_index;
					flights["prices_data"][flights["prices_data"].length] = price_list;
				}
			});
			if (flights.prices_data.length > 0) {
				filghtitems[filghtitems.length] = flights;
			}
		}
		Class_Temp.page_now++;
		if (Class_Temp.page_now <= page_max) {
			GetWebDate.GetNextDay(cookies);
		} else {
			//fs.writeFileSync("./"+dst+org+date+edate+".json",JSON.stringify(filghtitems));
			GetWebDate.UpdateToCloudSpace(0);
		}
	},
	/**
	 *左边填充0
	 * @param {Object} txt	内容
	 * @param {Object} len  长度
	 */
	FillStringLeft : function(txt, len) {
		var rs = txt.toString();
		if (txt.toString().length < len) {
			for (var i = 0; i < (len - txt.toString().length); i++) {
				rs = "0" + rs;
			}
		}
		return rs;
	},
	/**
	 * 格式化获取返回 的时间格式 dd:mm t
	 * @param {Object} val
	 */
	FormatGetTime : function(val) {
		if (val.indexOf("p") >= 0) {
			val = val.replace(/p/gi, "");
			val = GetWebDate.FillStringLeft(parseInt(val.split(":")[0]) + 12, 2) + val.split(":")[1];
		} else {
			val = val.replace(/a/gi, "");
			val = GetWebDate.FillStringLeft(parseInt(val.split(":")[0]), 2) + val.split(":")[1];
		}
		return val;
	},
	/**
	 * 生成flightid
	 * @param {Object} obj
	 */
	GetFligthIdContent : function(obj) {
		var flightid_str = "";
		for (var j = 0; j < obj.length; j++) {
			if (flightid_str != "") {
				flightid_str += "-";
			}
			flightid_str += obj[j].DPort + obj[j].DTime + "/" + obj[j].APort + obj[j].ATime;
		}
		return flightid_str;
	},
	UpdateToCloudSpace : function(num) {
		var UPYun = require('./upyunapi/upyun').UPYun;
		var upyun = new UPYun(UpYunInfo.spacename, UpYunInfo.username, UpYunInfo.password);
		var timestamp = parseInt(new Date().getTime() / 1000).toString();
		var datedir = Model_SearchInfo.date.replace(/-/gi, '') + (Model_SearchInfo.edate.replace(/-/gi, '') == "" ? "" : "." + Model_SearchInfo.edate.replace(/-/gi, ''));
		var newpath = UpYunInfo.uploadpath + "intl/kayak/" + datedir + "/" + Model_SearchInfo.dst + Model_SearchInfo.org + "/" + timestamp + "/main.json";
		newpath = newpath.toLowerCase();
		console.info("--------[request info]--------");
		console.info("upaiyun filepath:" + newpath);
		var file_md5 = Safe.MD5(JSON.stringify(filghtitems));
		upyun.writeFile(newpath, JSON.stringify(filghtitems), true, function(err, data) {
			if (err) {
				if (num <= System_Config.reconnect_count) {
					num++;
					GetWebDate.UpdateToCloudSpace(num);
				} else {
					console.info("upload to yun error:" + err);
					GetWebDate.NotifyTaskCenter(GetWebDate.ResponseEnd);
				}
			} else {
				GetWebDate.NotifyFinish(timestamp, file_md5, 0);
			}
		});
	},
	NotifyFinish : function(uploadtimestamp, file_md5, num) {
		if (num <= System_Config.reconnect_count) {
			var options = URL.parse(Notice_Config.url);
			var timestamp = parseInt(new Date().getTime() / 1000 + 3600).toString();
			options.method = "POST";
			options.headers = {};
			options.headers["Auth-Signature"] = Safe.MD5(Notice_Config.key + timestamp);
			options.headers["Auth-Timestamp"] = timestamp;
			options.headers["Content-Length"] = (file_md5 + uploadtimestamp).toString().length;
			HttpRequest.httpGetWithTimeoutSupport(options, [uploadtimestamp, file_md5, num], 150000, file_md5 + uploadtimestamp, function(response, hashkey, error) {
				if (error) {
					GetWebDate.NotifyFinish(hashkey[0], hashkey[1], (parseInt(hashkey[2]) + 1));
				} else {
					var buffer = [];
					var maxlength = 0;
					response.on("readable", function() {
						var m = response.read();
						if (m) {
							buffer.push(m);
							maxlength += buffer[buffer.length - 1].length;
						}
					});
					response.on("end", function() {
						var data = Buffer.concat(buffer, maxlength);
						data = data.toString("utf8", 0, data.length);
						console.info(data);
						GetWebDate.ResponseEnd();
					});
				}
			});
		} else {
			GetWebDate.NotifyTaskCenter(GetWebDate.ResponseEnd);
		}
	},
	//格式化输入参数日期
	FormatStringDate : function(str) {
		if (str.toString().length == 8) {
			return str.toString().substring(0, 4) + "-" + str.toString().substring(4, 6) + "-" + str.toString().substring(6, 8);
		} else {
			return null;
		}
	}
};

function Reset_SearchInfo() {
	Model_SearchInfo = {
		dst : null,
		org : null,
		date : null,
		edate : "",
		type : "ow",
		error_count : 0
	};
}

function Validate_Input_Object(input_array) {
	Model_SearchInfo.dst = input_array[0];
	Model_SearchInfo.org = input_array[1];
	Model_SearchInfo.date = GetWebDate.FormatStringDate(input_array[2]);
	if (input_array.length >= 4 && input_array.length <= 5) {
		if (input_array[3].length < 4) {
			Model_SearchInfo.error_count = parseInt(input_array[3]);
		} else {
			Model_SearchInfo.edate = GetWebDate.FormatStringDate(input_array[3]);
			Model_SearchInfo.type = "rt";
			if (input_array.length == 5) {
				Model_SearchInfo.error_count = parseInt(input_array[4]);
			}
		}
	} else {
		Reset_SearchInfo();
	}
}

arguments = arguments[0].split("/");

if (arguments.length >= 4 && arguments.length <= 5) {
	Validate_Input_Object(arguments);
	if (Model_SearchInfo.error_count >= System_Config.reconnect_count) {
		console.info("---------------------");
		console.info("error:more than error count!");
		console.info("---------------------");
	} else if (Model_SearchInfo.org == null || Model_SearchInfo.dst == null || Model_SearchInfo.date == null) {
		console.info("---------------------");
		console.info("error:parameter format error!");
		console.info("---------------------");
	} else {
		var temp_timestamp = parseInt(new Date().getTime() / 1000).toString();
		Class_Temp.url = Request_Config["index"];

		Notice_Config.url = Notice_Config.url + "intl/kayak/" + Model_SearchInfo.date.replace(/-/gi, '') + (Model_SearchInfo.type == "ow" ? "" : "." + Model_SearchInfo.edate.replace(/-/gi, '')) + "/" + Model_SearchInfo.dst.toLowerCase() + Model_SearchInfo.org.toLowerCase();
		var options = URL.parse(Notice_Config.url);
		var timestamp = parseInt(new Date().getTime() / 1000 + 3600).toString();
		options.headers = {};
		options.headers["Auth-Signature"] = Safe.MD5(Notice_Config.key + timestamp);
		options.headers["Auth-Timestamp"] = timestamp;
		HttpRequest.httpGetWithTimeoutSupport(options, null, 150000, null, function(response, hashkey, error) {
			console.info("  start:" + new Date().toString());
			//开始获取第一段
			GetWebDate.GetIndexPageInfo(Model_SearchInfo.error_count);
		});
	}
} else {
	console.info("---------------------");
	console.info("error:task center parameter error!");
	console.info("---------------------");
}

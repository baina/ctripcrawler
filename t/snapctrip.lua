-- jijilu <huangqi@travelsky.com> 20140223 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- ctrip agent service of crawler for bestfly service
-- load library
local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
local md5 = require 'md5'
local zlib = require 'zlib'
local base64 = require 'base64'
local crypto = require 'crypto'
package.path = "/usr/local/webserver/lua/lib/?.lua;";
local deflate = require 'compress.deflatelua'
function sleep(n)
   socket.select(nil, nil, n)
end
-- Cloud set.
function urlencode(s) return s and (s:gsub("[^a-zA-Z0-9.~_-]", function (c) return string.format("%%%02x", c:byte()); end)); end
function urldecode(s) return s and (s:gsub("%%(%x%x)", function (c) return char(tonumber(c,16)); end)); end
local function _formencodepart(s)
	return s and (s:gsub("%W", function (c)
		if c ~= " " then
			return format("%%%02x", c:byte());
		else
			return "+";
		end
	end));
end
function formencode(form)
	local result = {};
 	if form[1] then -- Array of ordered { name, value }
 		for _, field in ipairs(form) do
 			-- t_insert(result, _formencodepart(field.name).."=".._formencodepart(field.value));
			table.insert(result, field.name .. "=" .. tostring(field.value));
 		end
 	else -- Unordered map of name -> value
 		for name, value in pairs(form) do
 			-- table.insert(result, _formencodepart(name).."=".._formencodepart(value));
			table.insert(result, name .. "=" .. tostring(value));
 		end
 	end
 	return table.concat(result, "&");
end
-- Obtain key
function fatchkey (exUrl, exProxy)
	-- init response table
	local resp = {};
	-- local body, code, headers = http.request(baseurl .. md5uri)
	local body, code, headers, status = http.request {
	-- local ok, code, headers, status, body = http.request {
		-- url = "http://cloudavh.com/data-gw/index.php",
		url = exUrl,
		proxy = exProxy,
		timeout = 3000,
		method = "GET", -- POST or GET
		-- add post content-type and cookie
		headers = {
			["Host"] = "flights.ctrip.com",
			["Accept-Language"] = "zh-CN",
			-- ["SOAPAction"] = "http://ctrip.com/Request",
			["Cache-Control"] = "no-cache",
			-- ["Auth-Timestamp"] = filet,
			-- ["Auth-Signature"] = md5.sumhexa(sinakey .. filet),
			["Accept-Encoding"] = "gzip, deflate",
			-- ["Accept"] = "*/*",
			["Connection"] = "keep-alive",
			["Accept"] = "text/html, application/xhtml+xml, */*",
			["DNT"] = 1,
			["User-Agent"] = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0; Touch)"
			-- ["Content-Length"] = string.len(request)
		},
		-- body = formdata,
		-- source = ltn12.source.string(form_data);
		-- source = ltn12.source.string(request),
		sink = ltn12.sink.table(resp)
	}
	if code == 200 then
		local resbody = "";
		local reslen = table.getn(resp)
		for i = 1, reslen do
			-- print(respbody[i])
			resbody = resbody .. resp[i]
		end
		local output = {}
		deflate.gunzip {
		  input = resbody,
		  output = function(byte) output[#output+1] = string.char(byte) end
		}
		resbody = table.concat(output)
		return code, resbody, headers
	else
		return code, status, headers
	end
end
-- static
local tsproxy = "http://172.16.30.229:8088"
-- local tsproxy = "http://10.123.77.144:808"
local no01 = "http://flights.ctrip.com/international/";
local CorrelationId = "";
local __VIEWSTATE = "";
local sid = "";
-- ASP.NET_SessionId=rtx1igbp4bzbwpwlhulbczz2;
local axf = "";
-- AX-20480-flights_international
while true do
	local codenum, resbody, ch = fatchkey (no01, tsproxy)
	-- local codenum, resbody, ch = fatchkey (no01)
	if codenum == 200 then
		-- print(resbody)
		local tmpcookie = ch["set-cookie"];
		-- print(tmpcookie)
		-- print("--------------")
		local t = {}
		for x, y in string.gmatch(tmpcookie, "(%D+)=(%w+)") do
			t[x]=y
		end
		for k in string.gmatch(resbody, '<input type="hidden" id="CorrelationId" name="CorrelationId" value="(%w+)"/>') do
			CorrelationId = k;
		end
		-- <input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="" />
		for j in string.gmatch(resbody, '<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(.+)=" />') do
		-- for j in string.gmatch(resbody, '<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(^%w+)" />') do
			__VIEWSTATE = j .. "=";
		end
		if string.len(CorrelationId) > 3 then
			sid = t["ASP.NET_SessionId"]
			axf = t["-flights_international"]
			break;
		end
	end
end
print(CorrelationId);
print("--------------")
print(__VIEWSTATE);
print("--------------")
print(sid, axf);
print("--------------")
--flightintl_searchBoxVals_gb2312
--{"multipleRound":"S","flightintl_startcity_single":"上海(SHA)|2","flightintl_arrivalcity_single":"悉尼(澳大利亚)(SYD)|501|SYDNEY，AUSTRALIA","flightintl_startdate_single":"2014-03-21"}
--{"multipleRound":"S","flightintl_startcity_single":"东京(TYO)|228|TOKYO，JAPAN","flightintl_arrivalcity_single":"悉尼(澳大利亚)(SYD)|501|SYDNEY，AUSTRALIA","flightintl_startdate_single":"2014-03-21"}
local timestamp = os.time();
local flightintl_searchBoxVals_gb2312 = '{"multipleRound":"S","flightintl_startcity_single":"广州(CAN)|32|GUANGZHOU，CHINA","flightintl_arrivalcity_single":"首尔(SEL)|274|SEOUL，SOUTH KOREA","flightintl_startdate_single":"2014-05-01"}';
local ck = ([=[waitStatus=%s; ASP.NET_SessionId=%s; AX-20480-flights_domestic=DHACAIAKFAAA; _abtest_=df0cdedd-db43-404a-8bc5-533ea77ff5eb; userSearchClassGrade=Y; __utma=1.%s.%s.%s.%s.%s; __utmb=1.2.10.%s; __utmc=1; __utmz=1.1393644154.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _bfa=1.1393644154172.s0d8ck.1.1393644154172.1393649400916.2.3; _bfs=1.1; i_v=o=0&i=yluegr&p=3&l=sh02svr2503.4xugw6fe4&s=2; i_s=i=3duueav; i_b=i=hs8bqwjb; pv_id=v=2014030103276201; _bfi=p1=104002&p2=104002&v1=3&v2=2; AX-20480-flights_international=%s; flightintl_searchBoxVals_gb2312=%s; __lpi=p=104002&p2=104001
]=]):format(timestamp, sid, axf, flightintl_searchBoxVals_gb2312)
print(ck)

local formdata = {};

table.insert(formdata, "CurrentFirstDomain=ctrip.com");
table.insert(formdata, "__VIEWSTATE=" .. __VIEWSTATE);
table.insert(formdata, "CorrelationId=" .. CorrelationId);

table.insert(formdata, "ctl00$MainContentPlaceHolder$drpFlightWay=S");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDCity=广州(CAN)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$dest_city_1=首尔(SEL)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDDatePeriod1=2014-05-01");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtADatePeriod1=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginAddress1=广州(CAN)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndAddress1=首尔(SEL)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDatePeriod1=2014-05-01");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginCityCode1=32");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndCityCode1=274");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginAddress2=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndAddress2=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDDatePeriod2=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginCityCode2=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndCityCode2=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginAddress3=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndAddress3=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDDatePeriod3=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginCityCode3=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndCityCode3=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$drpQuantity=1");
table.insert(formdata, "ctl00$MainContentPlaceHolder$ticket_city=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtSourceCityID=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$drpSubClass=Y");
table.insert(formdata, "ctl00$MainContentPlaceHolder$selUserType=ADT");
table.insert(formdata, "txtAirline=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$btnSearchFlight=搜索");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDCityID=32");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDestcityID=274");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtOpenJawCityID3=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtOpenJawCityID4=");
table.insert(formdata, "FlightWay=D");
table.insert(formdata, "HomeCity=");
table.insert(formdata, "DestCity1=");
table.insert(formdata, "DestCity2=");
table.insert(formdata, "TicketAgency_List=");
table.insert(formdata, "DDatePeriod1=");
table.insert(formdata, "startPeriod=All");
table.insert(formdata, "ADatePeriod1=");
table.insert(formdata, "startPeriod2=All");
table.insert(formdata, "ChildType=ADU");
table.insert(formdata, "DSeatClass=Y");
table.insert(formdata, "Quantity=1");
table.insert(formdata, "strCorpID=");
table.insert(formdata, "Airline=All");
table.insert(formdata, "ExpenseType=PUB");
table.insert(formdata, "IsFavFull=");

local form_data = table.concat(formdata, "&");

request = urlencode(form_data)
local baseurl = "http://flights.ctrip.com/";
-- international/FlightResult.aspx
local intluri = "international/SearchFlights.aspx";
local nextreq = ""
print(baseurl .. intluri)
print(request)

-- init response table
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://gwn.bestfly.cn/login",
	url = baseurl .. intluri,
	-- proxy = "http://172.16.30.223:8088",
	proxy = tsproxy,
	timeout = 3000,
	method = "POST", -- POST or GET
	-- add post content-type and cookie
	headers = {
		["Host"] = "flights.ctrip.com",
		-- ["Host"] = "gwn.bestfly.cn",
		["Accept-Language"] = "zh-CN",
		["Referer"] = "http://flights.ctrip.com/international/",
		["Accept-Encoding"] = "gzip, deflate",
		["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		["Proxy-Connection"] = "keep-alive",
		["Content-Type"] = "application/x-www-form-urlencoded",
		["Cookie"] = urlencode(ck),
		["Content-Length"] = string.len(request),
		["DNT"] = 1,
		["Pragma"] = "no-cache",
		-- ["Content-Length"] = string.len(form_data),
		["User-Agent"] = "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; WOW64; Trident/6.0; Touch)"
	},
	-- body = formdata,
	-- source = ltn12.source.string(form_data);
	source = ltn12.source.string(request),
	sink = ltn12.sink.table(respbody)
}
local resxml = "";
local reslen = table.getn(respbody)
-- print(reslen)
for i = 1, reslen do
	-- print(respbody[i])
	resxml = resxml .. respbody[i]
end
local output = {}
deflate.gunzip {
  input = resxml,
  output = function(byte) output[#output+1] = string.char(byte) end
}
resxml = table.concat(output)
print(code)
print(status)
print("--------------")
print(urlencode(ck))
print("--------------")
print(resxml)
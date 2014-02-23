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
		timeout = 10000,
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
		return code, resbody
	else
		return code, status
	end
end
-- static
local tsproxy = "http://172.16.30.223:8088"
local no01 = "http://flights.ctrip.com/international/";
local CorrelationId = "";
local __VIEWSTATE = "";
while true do
	-- local codenum, resbody = fatchkey (no01, tsproxy)
	local codenum, resbody = fatchkey (no01)
	if codenum == 200 then
		for k in string.gmatch(resbody, '<input type="hidden" id="CorrelationId" name="CorrelationId" value="(%w+)"/>') do
			CorrelationId = k;
		end
		-- <input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="" />
		for j in string.gmatch(resbody, '<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(.+)==" />') do
		-- for j in string.gmatch(resbody, '<input type="hidden" name="__VIEWSTATE" id="__VIEWSTATE" value="(^%w+)" />') do
			__VIEWSTATE = j .. "==";
		end
		if string.len(CorrelationId) > 3 then
			break;
		end
	end
end
print(CorrelationId);
print("--------------")
print(__VIEWSTATE);

local formdata = {};

table.insert(formdata, "CurrentFirstDomain=ctrip.com");
table.insert(formdata, "__VIEWSTATE=" .. __VIEWSTATE);
table.insert(formdata, "CorrelationId=" .. CorrelationId);

table.insert(formdata, "ctl00$MainContentPlaceHolder$drpFlightWay=S");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDCity=广州(CAN)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$dest_city_1=首尔(SEL)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDDatePeriod1=2014-03-01");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtADatePeriod1=");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtBeginAddress1=广州(CAN)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtEndAddress1=首尔(SEL)");
table.insert(formdata, "ctl00$MainContentPlaceHolder$txtDatePeriod1=2014-03-01");
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
--[[
Accept	text/html, application/xhtml+xml, */*
Accept: image/jpeg, image/gif, image/pjpeg, application/x-ms-application, application/xaml+xml, application/x-ms-xbap, */*
Referer: http://www.ctrip.com/
Accept-Language: zh-CN
User-Agent: Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Win64; x64; Trident/4.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729; .NET CLR 3.0.30729)
Content-Type: application/x-www-form-urlencoded
UA-CPU: AMD64
Accept-Encoding: gzip, deflate
Proxy-Connection: Keep-Alive
Content-Length: 550
Host: flights.ctrip.com
Pragma: no-cache
Cookie: _bfa=1.1390629488954.z2g51s.1.1393053851217.1393130314914.5.21; zdata=zdata=LYWfe7+2VyJy9JxTgN5QTWO6yk4=; i_v=o=0&i=xenway&p=17&l=sh02svr2481.4xs31p4kb&s=5; __utma=1.914592533.1390629491.1393053852.1393130316.6; __utmz=1.1393051876.4.2.utmcsr=bing|utmccn=(organic)|utmcmd=organic|utmctr=%E6%B5%B7%E5%8F%A3%E9%85%92%E5%BA%97; HotelCityID=206split%E9%95%BF%E6%B2%99splitChangshasplit2014-1-25split2014-01-26split0; _abtest_=89af67b9-a172-4b09-95ab-83c546991dd1; __zpa=9.2.1393051877.1393051946.1.387149; bid=bid=F; zdatactrip=zdatactrip=dff7094c0bed35a3; flightintl_searchBoxVals_gb2312=%7B%22multipleRound%22%3A%22S%22%2C%22flightintl_startcity_single%22%3A%22%5Cu9999%5Cu6e2f(HKG)%7C58%22%2C%22flightintl_arrivalcity_single%22%3A%22%5Cu5df4%5Cu9ece(PAR)%7C192%22%2C%22flightintl_startdate_single%22%3A%222014-03-01%22%2C%22moreflightMin%22%3A3%7D; Session=smartlinkcode=U130727&smartlinklanguage=zh&SmartLinkKeyWord=&SmartLinkQuary=&SmartLinkHost=; Union=AllianceID=4902&SID=130727&OUID=; __zpr=hotels.ctrip.com%7C; AX_WWW-20480=BFACAIAKFAAA; _bfs=1.1; _bfi=p1%3D100101991%26p2%3D0%26v1%3D21%26v2%3D0; __utmb=1.1.10.1393130316; __utmc=1; i_s=i=3dfdes3; i_b=i=hrzttm2z; pv_id=v=2014022302773741; __lpi=p=100101991&p2=100101991; AX-20480-flights_domestic=EPACAIAKFAAA; AX-20480-flights_international=ELACAIAKFAAA
--]]
-- init response table
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://gwn.bestfly.cn/login",
	url = baseurl .. intluri,
	-- proxy = "http://172.16.30.223:8088",
	-- proxy = "http://" .. tostring(arg[2]),
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
-- print(resxml)
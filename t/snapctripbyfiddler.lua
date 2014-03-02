-- jijilu <huangqi@travelsky.com> 20140223 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- ctrip agent service of crawler for bestfly service
-- load library
local socket = require 'socket'
local http = require 'socket.http'
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
local __VIEWSTATE = '/wEPDwUKMTc1MDI0OTEzMA9kFgJmD2QWAgIBDxYCHgZhY3Rpb24FFC4vU2VhcmNoRmxpZ2h0cy5hc3B4FgJmD2QWCGYPFgIeB1Zpc2libGVoFgICBQ8WAh8BaGQCBg8PZBYCHhVtb2RfY2FsZW5kYXJfcmFuZ2VFbmQFCDIwMTUtMy0yZAIHDw9kFgIfAgUIMjAxNS0zLTJkAisPD2QWAh4IZGlzYWJsZWQFBHRydWVkGAEFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYFBSljdGwwMCRNYWluQ29udGVudFBsYWNlSG9sZGVyJGZsaWdodF93YXlfcwUpY3RsMDAkTWFpbkNvbnRlbnRQbGFjZUhvbGRlciRmbGlnaHRfd2F5X3MFKWN0bDAwJE1haW5Db250ZW50UGxhY2VIb2xkZXIkZmxpZ2h0X3dheV9kBSljdGwwMCRNYWluQ29udGVudFBsYWNlSG9sZGVyJGZsaWdodF93YXlfbwUpY3RsMDAkTWFpbkNvbnRlbnRQbGFjZUhvbGRlciRmbGlnaHRfd2F5X28='
local CorrelationId = '5501158513947432219'
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
print(form_data)
print("--------------")
local request = urlencode(form_data)
print(request)
print("--------------")

local ck = 'waitStatus=1393740395194; _bfa=1.1390629488954.z2g51s.1.1393657215921.1393739144135.7.29; i_v=o=0&i=xenway&p=25&l=sh02svr2506.4xuvxfcp8&s=7; __utma=1.914592533.1390629491.1393657216.1393739144.8; __utmz=1.1393051876.4.2.utmcsr=bing|utmccn=(organic)|utmcmd=organic|utmctr=%E6%B5%B7%E5%8F%A3%E9%85%92%E5%BA%97; _abtest_=89af67b9-a172-4b09-95ab-83c546991dd1; __zpa=9.2.1393051877.1393051946.1.387149; zdatactrip=zdatactrip=dff7094c0bed35a3; flightintl_searchBoxVals_gb2312=%7B%22multipleRound%22%3A%22S%22%2C%22flightintl_startcity_single%22%3A%22%5Cu5e7f%5Cu5dde(CAN)%7C32%7CGUANGZHOU%5Cuff0cCHINA%22%2C%22flightintl_arrivalcity_single%22%3A%22%5Cu9996%5Cu5c14(SEL)%7C274%7CSEOUL%5Cuff0cSOUTH%20KOREA%22%2C%22flightintl_startdate_single%22%3A%222014-05-01%22%2C%22moreflightMin%22%3A3%7D; Session=smartlinkcode=U130727&smartlinklanguage=zh&SmartLinkKeyWord=&SmartLinkQuary=&SmartLinkHost=; __utmb=1.8.10.1393739144; _bfs=1.4; i_s=i=3dwasa4; __utmc=1; _bfi=p1%3D104001%26p2%3D0%26v1%3D29%26v2%3D0; LoginPagePassed=; i_b=i=hs9wzxlh; pv_id=v=2014030203425751; __lpi=p=104001&p2=104001; ASP.NET_SessionId=v211k1re0urc2ifvggdssdbb; AX-20480-flights_international=DNACAIAKFAAA'
-- local request = 'CurrentFirstDomain=ctrip.com&__VIEWSTATE=%2FwEPDwUKMTc1MDI0OTEzMA9kFgJmD2QWAgIBDxYCHgZhY3Rpb24FFC4vU2VhcmNoRmxpZ2h0cy5hc3B4FgJmD2QWCGYPFgIeB1Zpc2libGVoFgICBQ8WAh8BaGQCBg8PZBYCHhVtb2RfY2FsZW5kYXJfcmFuZ2VFbmQFCDIwMTUtMy0yZAIHDw9kFgIfAgUIMjAxNS0zLTJkAisPD2QWAh4IZGlzYWJsZWQFBHRydWVkGAEFHl9fQ29udHJvbHNSZXF1aXJlUG9zdEJhY2tLZXlfXxYFBSljdGwwMCRNYWluQ29udGVudFBsYWNlSG9sZGVyJGZsaWdodF93YXlfcwUpY3RsMDAkTWFpbkNvbnRlbnRQbGFjZUhvbGRlciRmbGlnaHRfd2F5X3MFKWN0bDAwJE1haW5Db250ZW50UGxhY2VIb2xkZXIkZmxpZ2h0X3dheV9kBSljdGwwMCRNYWluQ29udGVudFBsYWNlSG9sZGVyJGZsaWdodF93YXlfbwUpY3RsMDAkTWFpbkNvbnRlbnRQbGFjZUhvbGRlciRmbGlnaHRfd2F5X28%3D&CorrelationId=5501158513947432219&ctl00%24MainContentPlaceHolder%24drpFlightWay=S&ctl00%24MainContentPlaceHolder%24txtDCity=%B9%E3%D6%DD%28CAN%29&ctl00%24MainContentPlaceHolder%24dest_city_1=%CA%D7%B6%FB%28SEL%29&ctl00%24MainContentPlaceHolder%24txtDDatePeriod1=2014-05-01&ctl00%24MainContentPlaceHolder%24txtADatePeriod1=&ctl00%24MainContentPlaceHolder%24txtBeginAddress1=%B9%E3%D6%DD%28CAN%29&ctl00%24MainContentPlaceHolder%24txtEndAddress1=%CA%D7%B6%FB%28SEL%29&ctl00%24MainContentPlaceHolder%24txtDatePeriod1=2014-05-01&ctl00%24MainContentPlaceHolder%24txtBeginCityCode1=32&ctl00%24MainContentPlaceHolder%24txtEndCityCode1=274&ctl00%24MainContentPlaceHolder%24txtBeginAddress2=&ctl00%24MainContentPlaceHolder%24txtEndAddress2=&ctl00%24MainContentPlaceHolder%24txtDDatePeriod2=&ctl00%24MainContentPlaceHolder%24txtBeginCityCode2=&ctl00%24MainContentPlaceHolder%24txtEndCityCode2=&ctl00%24MainContentPlaceHolder%24txtBeginAddress3=&ctl00%24MainContentPlaceHolder%24txtEndAddress3=&ctl00%24MainContentPlaceHolder%24txtDDatePeriod3=&ctl00%24MainContentPlaceHolder%24txtBeginCityCode3=&ctl00%24MainContentPlaceHolder%24txtEndCityCode3=&ctl00%24MainContentPlaceHolder%24drpQuantity=1&ctl00%24MainContentPlaceHolder%24ticket_city=&ctl00%24MainContentPlaceHolder%24txtSourceCityID=&ctl00%24MainContentPlaceHolder%24drpSubClass=Y&ctl00%24MainContentPlaceHolder%24selUserType=ADT&txtAirline=&ctl00%24MainContentPlaceHolder%24btnSearchFlight=%CB%D1%CB%F7&ctl00%24MainContentPlaceHolder%24txtDCityID=32&ctl00%24MainContentPlaceHolder%24txtDestcityID=274&ctl00%24MainContentPlaceHolder%24txtOpenJawCityID3=&ctl00%24MainContentPlaceHolder%24txtOpenJawCityID4=&FlightWay=D&HomeCity=&DestCity1=&DestCity2=&TicketAgency_List=&DDatePeriod1=&startPeriod=All&ADatePeriod1=&startPeriod2=All&ChildType=ADU&DSeatClass=Y&Quantity=1&strCorpID=&Airline=All&ExpenseType=PUB&IsFavFull='
local baseurl = "http://flights.ctrip.com/";
-- http://flights.ctrip.com/international/FlightResult.aspx
-- http://flights.ctrip.com/international/SearchFlights.aspx
local intluri = "international/SearchFlights.aspx";
-- local intluri = "international/FlightResult.aspx";
print(baseurl .. intluri)
-- init response table
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://gwn.bestfly.cn/login",
	url = baseurl .. intluri,
	proxy = "http://172.16.30.234:8088",
	timeout = 3000,
	method = "POST", -- POST or GET
	-- add post content-type and cookie
	headers = {
		["Host"] = "flights.ctrip.com",
		-- ["Host"] = "gwn.bestfly.cn",
		["Accept-Language"] = "en-US,en;q=0.8,zh-CN;q=0.6,zh-TW;q=0.4",
		["Referer"] = "http://flights.ctrip.com/international/",
		-- ["Accept-Encoding"] = "gzip, deflate",
		["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		["Cache-Control"] = "max-age=0",
		["Origin"] = "http://flights.ctrip.com",
		["Proxy-Connection"] = "keep-alive",
		["Content-Type"] = "application/x-www-form-urlencoded",
		["Cookie"] = ck,
		["Content-Length"] = string.len(request),
		["DNT"] = 1,
		["Pragma"] = "no-cache",
		-- ["Content-Length"] = string.len(form_data),
		["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.117 Safari/537.36"
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

print(code)
print(status)
print("--------------")
print(resxml)


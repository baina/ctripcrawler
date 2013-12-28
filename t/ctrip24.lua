local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
local md5 = require 'md5'
local zlib = require 'zlib'
local base64 = require 'base64'
local crypto = require 'crypto'
-- local client = require 'soap.client'
package.path = "/usr/local/webserver/lua/lib/?.lua;";
local xml = require 'LuaXml'
--[[
local redis = require 'redis'
local params = {
    host = 'sin.bestfly.cn',
    port = 61088,
}
local client = redis.connect(params)
client:select(0) -- for testing purposes
-- commands defined in the redis.commands table are available at module
-- level and are used to populate each new client instance.
redis.commands.hset = redis.command('hset')
redis.commands.hset = redis.command('hget')
redis.commands.incr = redis.command('incr')
redis.commands.setnx = redis.command('setnx')
redis.commands.hset = redis.command('hsetnx')
redis.commands.sadd = redis.command('sadd')
redis.commands.zadd = redis.command('zadd')
redis.commands.smembers = redis.command('smembers')
redis.commands.keys = redis.command('keys')
redis.commands.sdiff = redis.command('sdiff')
--]]
local deflate = require 'compress.deflatelua'
-- local baselua = require 'base64'
-- local t = {}
-- t.input = baselua.decode("string", "H4sIAAAAAAAACw3DhwnAMAwAMP8P2Rdk9s1KoBQR2WK12R1Ol9vj9fn5A/luZ4Y4AAAA")
-- t.output = function(byte) print(string.char(byte)) end
-- deflate.gunzip(t)
-- print("+++++++++++++++++")
-- originality
local error001 = JSON.encode({ ["resultCode"] = 1, ["description"] = "No response because you has inputted airports"});
local error002 = JSON.encode({ ["resultCode"] = 2, ["description"] = "Get Prices from extension is no response"});
function error003 (mes)
	local res = JSON.encode({ ["resultCode"] = 3, ["description"] = mes});
	return res
end
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
function fatchkey (exProxy)
	local sinaurl = "http://yougola.sinaapp.com/";
	local md5uri = "fatchkey/";
	-- local sinakey = "5P826n55x3LkwK5k88S5b3XS4h30bTRg";
	print("--------------")
	print(sinaurl .. md5uri);
	print("--------------")
	-- init response table
	local respsina = {};
	-- local body, code, headers = http.request(baseurl .. md5uri)
	local body, code, headers, status = http.request {
	-- local ok, code, headers, status, body = http.request {
		-- url = "http://cloudavh.com/data-gw/index.php",
		url = sinaurl .. md5uri,
		proxy = exProxy,
		-- proxy = "http://10.123.74.137:808",
		-- proxy = "http://" .. tostring(arg[2]),
		timeout = 10000,
		method = "GET", -- POST or GET
		-- add post content-type and cookie
		headers = {
			-- ["Proxy-Authorization"] = "123",
			["Host"] = "yougola.sinaapp.com",
			-- ["SOAPAction"] = "http://ctrip.com/Request",
			["Cache-Control"] = "no-cache",
			-- ["Auth-Timestamp"] = filet,
			-- ["Auth-Signature"] = md5.sumhexa(sinakey .. filet),
			-- ["Accept-Encoding"] = "gzip",
			-- ["Accept"] = "*/*",
			["Connection"] = "keep-alive",
			-- ["Content-Type"] = "text/xml; charset=utf-8",
			-- ["Content-Length"] = string.len(request)
		},
		-- body = formdata,
		-- source = ltn12.source.string(form_data);
		-- source = ltn12.source.string(request),
		sink = ltn12.sink.table(respsina)
	}
	if code == 200 then
		local resjson = "";
		local reslen = table.getn(respsina)
		for i = 1, reslen do
			-- print(respbody[i])
			resjson = resjson .. respsina[i]
		end
		if JSON.decode(resjson).ret_code == 0 then
			return 200, resjson
		else
			return 401, resjson
		end
	else
		return code, JSON.null
	end
end
local apikey = ""
local siteid = ""
local unicode = ""
while true do
	local codenum, resbody = fatchkey ()
	if codenum == 200 then
		resbody = JSON.decode(resbody);
		unicode = resbody.aid
		apikey = tostring(resbody.api_key)
		siteid = resbody.sid
		break;
	end
end
print(apikey, siteid, unicode);
-- retry to do the mission again
function retry(mission)
	local queuesurl = "http://api.bestfly.cn/";
	local md5uri = "task-queues";
	-- local sinakey = "5P826n55x3LkwK5k88S5b3XS4h30bTRg";
	print("--------------")
	print(queuesurl .. md5uri, mission);
	print("--------------")
	-- init response table
	local resp = {};
	-- local body, code, headers = http.request(baseurl .. md5uri)
	local body, code, headers, status = http.request {
	-- local ok, code, headers, status, body = http.request {
		-- url = "http://cloudavh.com/data-gw/index.php",
		url = queuesurl .. md5uri,
		-- proxy = exProxy,
		-- proxy = "http://10.123.74.137:808",
		-- proxy = "http://" .. tostring(arg[2]),
		timeout = 10000,
		method = "POST", -- POST or GET
		-- add post content-type and cookie
		headers = {
			["Host"] = "api.bestfly.cn",
			-- ["SOAPAction"] = "http://ctrip.com/Request",
			["Cache-Control"] = "no-cache",
			-- ["Auth-Timestamp"] = filet,
			-- ["Auth-Signature"] = md5.sumhexa(sinakey .. filet),
			-- ["Accept-Encoding"] = "gzip",
			-- ["Accept"] = "*/*",
			["Connection"] = "keep-alive",
			-- ["Content-Type"] = "text/xml; charset=utf-8",
			["Content-Length"] = string.len(mission)
		},
		-- body = formdata,
		-- source = ltn12.source.string(form_data);
		source = ltn12.source.string(mission),
		sink = ltn12.sink.table(resp)
	}
	if code == 200 then
		return code
	else
		return 400
	end
end
local ak = "8fed80908d9683600e1d30f2a64006f2"
local sk = "8047E3D8b60e2887d1d866b4b12028c6"
local org = string.sub(arg[1], 1, 3);
local dst = string.sub(arg[1], 5, 7);
local tkey = string.sub(arg[1], 9, -3);
local expiret = os.time({year=string.sub(tkey, 1, 4), month=tonumber(string.sub(tkey, 5, 6)), day=tonumber(string.sub(tkey, 7, 8)), hour="00"})
local date = string.sub(arg[1], 9, 12) .. "-" .. string.sub(arg[1], 13, 14) .. "-" .. string.sub(arg[1], 15, 16);
local date24 = string.sub(arg[1], 9, 12) .. "/" .. string.sub(arg[1], 13, 14) .. "/" .. string.sub(arg[1], 15, 16);
local today = os.date("%Y-%m-%d", os.time());
-- 2.4:http://{API_Url}/Flight/IntlFlight/OAE_IntlFlightSearch.asmx
local baseurl = "http://openapi.ctrip.com"
-- local domuri = "/Flight/DomesticFlight/OTA_FlightSearch.asmx"
-- local intluri = "/Flight/IntlFlight/OTA_IntlFlightSearch.asmx"
local intluri = "/Flight/IntlFlight/OAE_IntlFlightSearch.asmx"
-- Signature=Md5(TimeStamp+AllianceID+MD5(密钥).ToUpper()+SID+RequestType).ToUpper()
local ts = os.time()
-- local ts = "1380250839"
local sign = string.upper(md5.sumhexa(ts .. unicode .. string.upper(md5.sumhexa(apikey)) .. siteid .. "OAE_IntlFlightSearch"))
print("-----------------")
-- print(ts)
-- print(sign)
print(string.upper(org), string.upper(dst), date, today)
print("------------------------------------------")
--[[
local domxml = ([=[
<Request>
  <Header>
    <AllianceID>%s</AllianceID>
    <SID>%s</SID>
    <TimeStamp>%s</TimeStamp>
    <RequestType>OTA_IntlFlightSearch</RequestType>
    <Signature>%s</Signature>
  </Header>
  <FlightSearchRequest>
    <SearchType>S</SearchType>
    <BookDate>%s</BookDate>
    <OrderBy>DepartTime</OrderBy>
    <Direction>ASC</Direction>
    <Routes>
      <FlightRoute>
        <DepartCity>%s</DepartCity>
        <ArriveCity>%s</ArriveCity>
        <DepartDate>%s</DepartDate>
        <AirlineDibitCode></AirlineDibitCode>
      </FlightRoute>
    </Routes>
  </FlightSearchRequest>
</Request>]=]):format(unicode, siteid, ts, sign, today, string.upper(org), string.upper(dst), date)
domxml = string.gsub(domxml, "<", "&lt;")
--]]
-- domxml = string.gsub(domxml, ">", "&gt;")
-- domxml = string.gsub(domxml, "\n", "")
--[[
local intlxml = ([=[
<Request>
	<Header>
		<AllianceID>%s</AllianceID>
		<SID>%s</SID>
		<TimeStamp>%s</TimeStamp>
		<RequestType>OTA_IntlFlightSearch</RequestType>
		<Signature>%s</Signature>
	</Header>
	<IntlFlightSearchRequest>
		<TripType>OW</TripType>
		<PassengerType>ADT</PassengerType>
		<PassengerCount>1</PassengerCount>
		<Eligibility>ALL</Eligibility>
		<BusinessType>OWN</BusinessType>
		<ClassGrade>Y</ClassGrade>
		<SalesType>Online</SalesType>
		<FareType>All</FareType>
		<ResultMode>All</ResultMode>
		<OrderBy>Price</OrderBy>
		<Direction>Asc</Direction>
		<SegmentInfos>
			<SegmentInfo>
				<DCode>%s</DCode>
				<ACode>%s</ACode>
				<DDate>%s</DDate>
				<TimePeriod>All</TimePeriod>
			</SegmentInfo>
		</SegmentInfos>
	</IntlFlightSearchRequest>
</Request>]=]):format(unicode, siteid, ts, sign, string.upper(org), string.upper(dst), date)
-- domxml = string.gsub(domxml, "<", "&lt;")
-- ]]
-- ctrip 2.4 update 201312
local intlxml = ([=[
<Request>
	<Header>
		<AllianceID>%s</AllianceID>
		<SID>%s</SID>
		<TimeStamp>%s</TimeStamp>
		<RequestType>OAE_IntlFlightSearch</RequestType>
		<Signature>%s</Signature>
	</Header>
	<IntlFlightSearchRequest>
	    <SearchCriteria>
	        <OrigDestRequestList>
	            <OrigDestRequest>
	                <Date>%s</Date>
	                <ORIG>%s</ORIG>
	                <DEST>%s</DEST>
	            </OrigDestRequest>
	        </OrigDestRequestList>
	        <TravelerRequestList>
	            <TravelerRequest>
	                <TravelerCategoryCode>Adult</TravelerCategoryCode>
	                <TravelerCount>1</TravelerCount>
	                <TravelerEligibilityCode>ADT</TravelerEligibilityCode>
	            </TravelerRequest>
	        </TravelerRequestList>
	        <CabinClass>Economy</CabinClass>
	        <RequestedCabinClassOnly>false</RequestedCabinClassOnly>
	        <TicketDeliveryCityID>0</TicketDeliveryCityID>
	    </SearchCriteria>
	    <ResultControl>
	        <MaxResultCount>10</MaxResultCount>
	        <SortInstruction>
	            <SortingField>Price</SortingField>
	            <Direction>ASC</Direction>
	        </SortInstruction>
	        <TransferType>0</TransferType>
	        <DefaultPriceOnly>true</DefaultPriceOnly>
	        <LowestPriceOnly>true</LowestPriceOnly>
	    </ResultControl>
	</IntlFlightSearchRequest>
</Request>]=]):format(unicode, siteid, ts, sign, date24, string.upper(org), string.upper(dst))
intlxml = string.gsub(intlxml, "<", "&lt;")
-- intlxml = string.gsub(intlxml, ">", "&gt;")
-- soap
local request = ([=[<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<xsd:Request xmlns:xsd="http://ctrip.com/">
<xsd:requestXML>%s</xsd:requestXML>
</xsd:Request>
</soapenv:Body>
</soapenv:Envelope>]=]):format(intlxml)
print(request)
print("-----------------")
-- init response table
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://cloudavh.com/data-gw/index.php",
	url = baseurl .. intluri .. "?WSDL",
	-- proxy = "http://10.123.74.137:808",
	-- proxy = "http://" .. tostring(arg[2]),
	timeout = 30000,
	method = "POST", -- POST or GET
	-- add post content-type and cookie
	-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
	-- headers = { ["Host"] = "flight.itour.cn", ["X-AjaxPro-Method"] = "GetFlight", ["Cache-Control"] = "no-cache", ["Accept-Encoding"] = "gzip,deflate,sdch", ["Accept"] = "*/*", ["Origin"] = "chrome-extension://fdmmgilgnpjigdojojpjoooidkmcomcm", ["Connection"] = "keep-alive", ["Content-Type"] = "application/json", ["Content-Length"] = string.len(JSON.encode(request)), ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36" },
	headers = {
		["Host"] = "openapi.ctrip.com",
		["SOAPAction"] = "http://ctrip.com/Request",
		["Cache-Control"] = "no-cache",
		["Accept-Encoding"] = "gzip",
		["Accept"] = "*/*",
		["Connection"] = "keep-alive",
		["Content-Type"] = "text/xml; charset=utf-8",
		["Content-Length"] = string.len(request),
		["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36"
	},
	-- body = formdata,
	-- source = ltn12.source.string(form_data);
	source = ltn12.source.string(request),
	sink = ltn12.sink.table(respbody)
}
if code == 200 then
	local resxml = "";
	local reslen = table.getn(respbody)
	-- print(reslen)
	for i = 1, reslen do
		-- print(respbody[i])
		resxml = resxml .. respbody[i]
	end
	-- resxml = deflate.gunzip(resxml)
	-- change to use compress.deflatelua
	local output = {}
	deflate.gunzip {
	  input = resxml,
	  output = function(byte) output[#output+1] = string.char(byte) end
	}
	resxml = table.concat(output)
	-- resxml = zlib.decompress(resxml)
	resxml = string.gsub(resxml, "&lt;", "<")
	resxml = string.gsub(resxml, "&gt;", ">")
	print(resxml);
else
	print(code)
	print("-----ctrip api return status is NOT 200-----")
	print(status)
	print(body)
	local todo = JSON.encode({ ["type"] = 1, ["queues"] = "intl:", ["qbody"] = string.sub(arg[1], 1, -2) .. tostring(tonumber(string.sub(arg[1], -1, -1))+1) });
	local t = 0;
	while true do
		local code = retry(todo)
		t = t + 1;
		if code == 200 or t > 3 then
			sleep(0.5)
			break;
		end
	end
end
--[[
print("--------------")
print(domxml)
local ns, meth, ent = client.call {
	url = baseurl .. domuri,
	soapaction = "http://ctrip.com/Request",
	namespace = "http://ctrip.com",
	method = "Request",
	entries = {
		{ tag = "xsd:requestXML", domxml },
	}
}
local resxml = ""
print("namespace = ", ns, "element name = ", meth)
print(type(ent[2]))
for i, elem in ipairs (ent[1]) do
	-- print(elem)
	resxml = resxml .. elem
end
print(resxml)
--]]
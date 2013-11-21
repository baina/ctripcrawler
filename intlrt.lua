local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
local md5 = require 'md5'
local zlib = require 'zlib'
local base64 = require 'base64'
local crypto = require 'crypto'
local client = require 'soap.client'
package.path = "/usr/local/webserver/lua/lib/?.lua;";
local xml = require 'LuaXml'
local redis = require 'redis'
local params = {
    --- host = 'sin.bestfly.cn',
	host = '127.0.0.1',
    port = 6389,
}
local client = redis.connect(params)
client:select(0) -- for testing purposes
-- commands defined in the redis.commands table are available at module
-- level and are used to populate each new client instance.
redis.commands.hset = redis.command('hset')
redis.commands.hset = redis.command('hget')
redis.commands.incr = redis.command('incr')
redis.commands.setnx = redis.command('setnx')
redis.commands.sadd = redis.command('sadd')
redis.commands.zadd = redis.command('zadd')
redis.commands.smembers = redis.command('smembers')
redis.commands.keys = redis.command('keys')
redis.commands.sdiff = redis.command('sdiff')
local deflate = require 'compress.deflatelua'
-- local baselua = require 'base64'
-- local t = {}
-- t.input = baselua.decode("string", "H4sIAAAAAAAACw3DhwnAMAwAMP8P2Rdk9s1KoBQR2WK12R1Ol9vj9fn5A/luZ4Y4AAAA")
-- t.output = function(byte) print(string.char(byte)) end
-- deflate.gunzip(t)
-- print("+++++++++++++++++")
-- originality
local error001 = JSON.encode({ ["resultCode"] = 1, ["description"] = "No response because you has inputted airports"});
local error002 = JSON.encode({ ["resultCode"] = 2, ["description"] = "Caculate Prices from extension is failure"});
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
local ak = "8fed80908d9683600e1d30f2a64006f2"
local sk = "8047E3D8b60e2887d1d866b4b12028c6"
local org = string.sub(arg[1], 1, 3);
local dst = string.sub(arg[1], 5, 7);
local tkey = string.sub(arg[1], 9, -11); -- can/bjs/20131030/20131130/
local rtkey = string.sub(arg[1], 9, -2);
rtkey = string.gsub(rtkey, "/", ".");
local expiret = os.time({year=string.sub(tkey, 1, 4), month=tonumber(string.sub(tkey, 5, 6)), day=tonumber(string.sub(tkey, 7, 8)), hour="00"})
local gdate = string.sub(arg[1], 9, 12) .. "-" .. string.sub(arg[1], 13, 14) .. "-" .. string.sub(arg[1], 15, 16);
local bdate = string.sub(arg[1], 18, 21) .. "-" .. string.sub(arg[1], 22, 23) .. "-" .. string.sub(arg[1], 24, 25);
local today = os.date("%Y-%m-%d", os.time());
local baseurl = "http://openapi.ctrip.com"
-- local domuri = "/Flight/DomesticFlight/OTA_FlightSearch.asmx"
local intluri = "/Flight/IntlFlight/OTA_IntlFlightSearch.asmx"
local apikey = "C7EE9407-A619-4474-B519-95B0196B5CD2"
local siteid = "287634"
local unicode = "11108"
-- Signature=Md5(TimeStamp+AllianceID+MD5(密钥).ToUpper()+SID+RequestType).ToUpper()
local ts = os.time()
-- local ts = "1380250839"
local sign = string.upper(md5.sumhexa(ts .. unicode .. string.upper(md5.sumhexa(apikey)) .. siteid .. "OTA_IntlFlightSearch"))
-- print("-----------------")
-- print(ts)
-- print(sign)
print(string.upper(org), string.upper(dst), gdate, bdate, today)
print("--------------------------------------------------------------------")
-- domxml = string.gsub(domxml, ">", "&gt;")
-- domxml = string.gsub(domxml, "\n", "")
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
		<TripType>RT</TripType>
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
			<SegmentInfo>
				<DCode>%s</DCode>
				<ACode>%s</ACode>
				<DDate>%s</DDate>
				<TimePeriod>All</TimePeriod>
			</SegmentInfo>
		</SegmentInfos>
	</IntlFlightSearchRequest>
</Request>]=]):format(unicode, siteid, ts, sign, string.upper(org), string.upper(dst), gdate, string.upper(dst), string.upper(org), bdate)
-- domxml = string.gsub(domxml, "<", "&lt;")
intlxml = string.gsub(intlxml, "<", "&lt;")
-- make the rt subrequest
function dortreq(unicode, siteid, ts, sign, shopping, org, dst, gdate, bdate, groute)
	--[[
		r.setDCode(f.getDCity());
		r.setACode(f.getACity());
		r.setDAirport(f.getDPort());
		r.setAAirport(f.getAPort());
		r.setAirline(f.getAirline());
		r.setSeatClass(flightBaseInfos.get(i).getSubClass());
		r.setFlightNo(f.getFlightNo());
		r.setSegmentInfoNo(flightsInfo.getSegmentInfoNo());
		r.setNo(f.getNo());
	--]]
	-- test shopping for rt subrequest
	-- local shopping = "[1/2[BJS-OS-L-VIE-OS-L-LON(NOA,N41856277G,S6863A,C1776)]+1/2[LON-OS-L-VIE-OS-L-BJS(NOA,N41856277G,S6863A,C1776)]|NOR]{OS064BJSVIE11111,1|OS455VIELON11111,1|}";
	local bintlxml = ([=[
	<Request>
		<Header>
			<AllianceID>%s</AllianceID>
			<SID>%s</SID>
			<TimeStamp>%s</TimeStamp>
			<RequestType>OTA_IntlFlightSearch</RequestType>
			<Signature>%s</Signature>
		</Header>
		<IntlFlightSearchRequest>
			<TripType>RT</TripType>
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
			<ShoppingInfoID>%s</ShoppingInfoID>
			<SegmentInfos>
				<SegmentInfo>
					<DCode>%s</DCode>
					<ACode>%s</ACode>
					<DDate>%s</DDate>
					<TimePeriod>All</TimePeriod>
				</SegmentInfo>
				<SegmentInfo>
					<DCode>%s</DCode>
					<ACode>%s</ACode>
					<DDate>%s</DDate>
					<TimePeriod>All</TimePeriod>
				</SegmentInfo>
			</SegmentInfos>%s
		</IntlFlightSearchRequest>
	</Request>]=]):format(unicode, siteid, ts, sign, shopping, string.upper(org), string.upper(dst), gdate, string.upper(dst), string.upper(org), bdate, groute)
	bintlxml = string.gsub(bintlxml, "<", "&lt;")
	-- soap
	local request = ([=[<?xml version='1.0' encoding='UTF-8'?>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
	<soapenv:Body>
	<xsd:Request xmlns:xsd="http://ctrip.com/">
	<xsd:requestXML>%s</xsd:requestXML>
	</xsd:Request>
	</soapenv:Body>
	</soapenv:Envelope>]=]):format(bintlxml)
	-- return request;
	-- init response table
	local respbody = {};
	-- local hc = http:new()
	local body, code, headers, status = http.request {
	-- local ok, code, headers, status, body = http.request {
		-- url = "http://cloudavh.com/data-gw/index.php",
		url = baseurl .. intluri .. "?WSDL",
		-- proxy = "http://172.16.30.179:8088",
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
			["Content-Length"] = string.len(request)
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
		return 200, status, resxml
	else
		return code, status, body
	end
end
-- soap
local request = ([=[<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<xsd:Request xmlns:xsd="http://ctrip.com/">
<xsd:requestXML>%s</xsd:requestXML>
</xsd:Request>
</soapenv:Body>
</soapenv:Envelope>]=]):format(intlxml)
--[[
-- soap for back
request = ([=[<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<xsd:Request xmlns:xsd="http://ctrip.com/">
<xsd:requestXML>%s</xsd:requestXML>
</xsd:Request>
</soapenv:Body>
</soapenv:Envelope>]=]):format(bintlxml)
--]]
-- print(request)
-- print("-----------------")
-- init response table and begin to do the gorequest of rt
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://cloudavh.com/data-gw/index.php",
	url = baseurl .. intluri .. "?WSDL",
	-- proxy = "http://172.16.30.179:8088",
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
		["Content-Length"] = string.len(request)
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
	local md5res = md5.sumhexa(resxml);
	local filet = os.time();
	-- print(md5res, filet);
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
	-- print(resxml)
	local pr_xml = xml.eval(resxml);
	local xscene = pr_xml:find("IntlFlightSearchResponse");
	-- xscene maybe nil
	if xscene ~= nil then
		local orixml = xml.str(xscene);
		-- caculate md5 of IntlFlightSearchResponse
		local md5res = md5.sumhexa(orixml);
		local filet = os.time();
		local proceed = false;
		local res, err = client:hget('intl:ctrip:' .. rtkey, org .. dst)
		if res ~= nil and res ~= JSON.null and res ~= "" then
			if string.sub(res, 1, 32) ~= md5res then
				proceed = true;-- del old hash value
				-- client:hdel('intl:ctrip:' .. tkey, org .. dst);
				print(string.sub(res, 1, 32))
				print(md5res)
			end
		else
			proceed = true;-- nil did not need to del
			print("-------自动过期REDIS空值-------")
		end
		if proceed == true then
			local records = tonumber(xscene[1][1]);
			if records > 0 then
				print("+++ { " .. records .. " } Lines 往返总量+++");
				-- ow data of the rt response
				print("--------------------------------------------------------------------")
				-- init the whole table
				local wholepri = {};
				local RecordsCount = 0;
				for r = 1, records do
					-- from the lowest price data
					-- subrequest rt base xscene[1][1]
					-- local xscene = pr_xml:find("ShoppingResultInfo");
					print("-- begin to do the {" .. r .. "} line data...")
					-- rt request needs shoppingID
					local shopping = "";
					local bunktb = {};
					-- price & salelimit and bunk
					local polnum = table.getn(xscene[2][r][2]);
					local polidx = 1;
					while polidx <= polnum do
						local idxtab = {};
						local tmppri = {};
						local tbunks = {};
						for k, v in pairs(xscene[2][r][2][polidx]) do
							if k > 0 then
								if type(v) == "table" then
									-- if v[0] ~= "FlightBaseInfos" and v[0] ~= "PriceInfos" and v[0] ~= "NoSalesStr" then
									if v[0] == "ShoppingInfoID" then
										-- print(v[0], v[1]);
										shopping = v[1];
									else
										if v[0] == "FlightBaseInfos" then
											-- ngx.say(table.getn(v))
											for i = 1, table.getn(v) do
												local tmpbunk = {};
												for k, v in pairs(v[i]) do
													if k > 0 then
														if type(v) == "table" then
															-- ngx.say(v[0], v[1])
															if v[0] == "ClassGrade" then
																-- print(v[0], v[1])
																tmpbunk[v[0]] = v[1]
															end
														end
													end
												end
												table.insert(tbunks, tmpbunk)
											end
										end
									end
								end
							end
						end
						table.insert(bunktb, tbunks)
						-- break after get the first pricedata;
						break;
						-- polidx = polidx + 1;
					end
					-- get the segment data from xml of {r}
					local routes = {};
					local seginf = {};
					-- get the go segment;
					for i = 1, 1 do
						local tmpfid = "";
						for j = 1, table.getn(xscene[2][r][1][i][3]) do
							-- print(type(xscene[1][i][3][j]))
							local tmpseg = {};
							local fltkey = {};
							local x = xml.new("Routing")
							for k, v in pairs(xscene[2][r][1][i][3][j]) do
								if k > 0 then
									if type(v) == "table" then
										if v[0] == "DCity" then
											-- tmpseg["DCode"] = v[1];
											x:append("DCode")[1] = v[1];
										end
										if v[0] == "ACity" then
											-- tmpseg["ACode"] = v[1];
											x:append("ACode")[1] = v[1];
										end
										if v[0] == "DPort" then
											-- tmpseg["DAirport"] = v[1];
											x:append("DAirport")[1] = v[1];
											-- fltkey[1] = v[1];
										end
										if v[0] == "APort" then
											-- tmpseg["AAirport"] = v[1];
											x:append("AAirport")[1] = v[1];
											-- fltkey[3] = v[1];
										end
										if v[0] == "AirlineCode" then
											-- tmpseg["Airline"] = v[1];
											x:append("Airline")[1] = v[1];
										end
										if v[0] == "FlightNo" then
											-- tmpseg["FlightNo"] = v[1];
											x:append("FlightNo")[1] = v[1];
										end
										if v[0] == "No" then
											-- tmpseg["No"] = v[1];
											x:append("No")[1] = v[1];
										end
									end
								end
							end
							-- tmpseg["SegmentInfoNo"] = xscene[2][r][1][i][1][1]
							x:append("SegmentInfoNo")[1] = xscene[2][r][1][i][1][1]
							-- tmpseg["SeatClass"] = bunktb[1][j]["ClassGrade"]
							x:append("SeatClass")[1] = bunktb[1][j]["ClassGrade"]
							-- print(type(x))
							table.insert(routes, x)
							-- table.insert(seginf, tmpseg);
							-- seginf["Routing"] = tmpseg;
						end
						-- table.insert(routes, seginf)
					end
					-- print("--------------")
					-- print(xml.str(routes, 0, "Routings"))
					local groute = "\n" .. xml.str(routes, 12, "Routings")
					-- print(groute)
					-- print("--------------")
					-- print(JSON.encode(bunktb))
					-- do the rt request for rt+ow data
					print("---- begin to rt request of {" .. r .. "} line...")
					sleep(0.1)
					local codenum, status, xmldata = dortreq(unicode, siteid, ts, sign, shopping, org, dst, gdate, bdate, groute)
					-- if xmldata ~= JSON.null then
					if codenum == 200 then
						-- print(xmldata)
						-- print("--------------")
						local pr_xml = xml.eval(xmldata);
						local xscene = pr_xml:find("IntlFlightSearchResponse");
						if xscene ~= nil then
							local rtcords = tonumber(xscene[1][1]);
							if rtcords > 0 then
								RecordsCount = RecordsCount + rtcords
								print("---- sucess to Get the rt response of {" .. r .. "}")
								for rr = 1, rtcords do
									table.insert(wholepri, xscene[2][rr])
								end
							else
								print(codenum, status)
								print("--------------")
								print(xmldata)
								print("++++RT api result intldata {" .. r .. "} is NULL++++")
							end
						else
							print(code)
							print("++++RT api result xml {" .. r .. "} is wrong++++")
							print(status)
							print(shopping)
							print(groute)
						end
					else
						print(codenum, status)
						print("++++RT api return status {" .. r .. "} is NOT 200++++")
						print(xmldata);
					end
					sleep(1)
				end
				if table.getn(wholepri) > 0 then
					-- print(xml.str(wholepri));
					print(RecordsCount, table.getn(wholepri));
					-- ctrip result xml logged.
					local wname = "/data/logs/rholog.txt"
					local wfile = io.open(wname, "w+");
					wfile:write("\r\n---------------------\r\n");
					wfile:write(xml.str(wholepri));
					wfile:write("\r\n---------------------\r\n");
					io.close(wfile);
				else
					print(code, status)
					print("--------------")
					print(body)
					print("-----caculate result is NULL-------")
				end
			else
				print(code, status)
				print("--------------")
				print(resxml)
				print("----ctrip api result intldata is NULL-----")
			end
		else
			print("-----EOF{".. md5res .. "|" .. filet .."}-----")
		end
	else
		print(code, status)
		print("--------------")
		print(resxml)
		print("-----ctrip api result xml is wrong-----")
	end
else
	print(code)
	print("-----ctrip api return status is NOT 200-----")
	print(status)
	print(body)
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
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
    host = 'rhosouth001',
    port = 6388,
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
local ak = "8fed80908d9683600e1d30f2a64006f2"
local sk = "8047E3D8b60e2887d1d866b4b12028c6"

local org = string.sub(arg[1], 1, 3);
local dst = string.sub(arg[1], 5, 7);
local tkey = string.sub(arg[1], 9, -11); -- can/bjs/20131030/20131130/
local expiret = os.time({year=string.sub(tkey, 1, 4), month=tonumber(string.sub(tkey, 5, 6)), day=tonumber(string.sub(tkey, 7, 8)), hour="00"})
local gdate = string.sub(arg[1], 9, 12) .. "-" .. string.sub(arg[1], 13, 14) .. "-" .. string.sub(arg[1], 15, 16);
local bdate = string.sub(arg[1], 18, 21) .. "-" .. string.sub(arg[1], 22, 23) .. "-" .. string.sub(arg[1], 24, 25);
local today = os.date("%Y-%m-%d", os.time());
local baseurl = "http://openapi.ctrip.com"
-- local domuri = "/Flight/DomesticFlight/OTA_FlightSearch.asmx"
local intluri = "/Flight/IntlFlight/OTA_IntlFlightSearch.asmx"
local apikey = "15AAF13C-2CDB-4078-AADE-FC5D6307394C"
local siteid = "328547"
local unicode = "9134"
-- Signature=Md5(TimeStamp+AllianceID+MD5(密钥).ToUpper()+SID+RequestType).ToUpper()
local ts = os.time()
-- local ts = "1380250839"
local sign = string.upper(md5.sumhexa(ts .. unicode .. string.upper(md5.sumhexa(apikey)) .. siteid .. "OTA_IntlFlightSearch"))
-- print("-----------------")
-- print(ts)
-- print(sign)
print(string.upper(org), string.upper(dst), gdate, bdate, today)
print("-----------------")
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
		--- proxy = "http://127.0.0.1:8888",
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
		return code, status, JSON.null
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
-- init response table
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://cloudavh.com/data-gw/index.php",
	url = baseurl .. intluri .. "?WSDL",
	--- proxy = "http://127.0.0.1:8888",
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
	-- print(resxml)
	local pr_xml = xml.eval(resxml);
	local xscene = pr_xml:find("IntlFlightSearchResponse");
	-- xscene maybe nil
	if xscene ~= nil then
		print(xscene[1][1])
		print("--------------")
		for r = 1, xscene[1][1] do
			-- subrequest rt base xscene[1][1]
			-- local xscene = pr_xml:find("ShoppingResultInfo");
			local shopping = "";
			local bunktb = {};
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
				break;
			end
			local routes = {};
			local seginf = {};
			for i = 1, 1 do
				local tmpfid = "";
				for j = 1, table.getn(xscene[2][r][1][i][3]) do
					-- ngx.say(type(xscene[1][i][3][j]))
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
			local codenum, status, xmldata = dortreq(unicode, siteid, ts, sign, shopping, org, dst, gdate, bdate, groute)
			-- if xmldata ~= JSON.null then
			if codenum == 200 then
				-- print(xmldata)
				-- print("--------------")
				local pr_xml = xml.eval(xmldata);
				local xscene = pr_xml:find("IntlFlightSearchResponse");
				if xscene ~= nil then
					local bigtab = {};
					for r = 1, xscene[1][1] do
						-- local xscene = pr_xml:find("ShoppingResultInfo");
						local pritab = {};
						local bunktb = {};
						local polnum = table.getn(xscene[2][r][2]);
						local polidx = 1;
						while polidx <= polnum do
							local idxtab = {};
							local tmppri = {};
							local tbunks = {};
							for k, v in pairs(xscene[2][r][2][polidx]) do
								if k > 0 then
									if type(v) == "table" then
										if v[0] ~= "FlightBaseInfos" and v[0] ~= "PriceInfos" then
											idxtab[v[0]] = v[1];
										else
											if v[0] == "PriceInfos" then
												for k, v in pairs(v[1]) do
													if k > 0 then
														if type(v) == "table" then
															tmppri[v[0]] = v[1]
														end
													end
												end
											end
											if v[0] == "FlightBaseInfos" then
												-- ngx.say(table.getn(v))
												for i = 1, table.getn(v) do
													local tmpbunk = {};
													for k, v in pairs(v[i]) do
														if k > 0 then
															if type(v) == "table" then
																-- ngx.say(v[0], v[1])
																tmpbunk[v[0]] = v[1]
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
							local priceinfo = {};
							local tmppritab = {};
							priceinfo["priceinfo"] = tmppri;
							priceinfo["salelimit"] = idxtab;
							tmppritab["ctrip"] = priceinfo;
							table.insert(pritab, tmppritab)
							table.insert(bunktb, tbunks)
							polidx = polidx + 1;
							-- ngx.say(JSON.encode(idxtab))
							-- ngx.say(JSON.encode(tmppri))
						end
						local gseginf = {};
						local bseginf = {};
						local gfid = "";
						local bfid = "";
						local fid = "";
						local fltscore = "";
						for i = 1, 2 do
							local tmpfid = "";
							for j = 1, table.getn(xscene[2][r][1][i][3]) do
								-- ngx.say(type(xscene[1][i][3][j]))
								local tmpseg = {};
								local fltkey = {};
								for k, v in pairs(xscene[2][r][1][i][3][j]) do
									if k > 0 then
										if type(v) == "table" then
											tmpseg[v[0]] = v[1];
											if v[0] == "DPort" then
												fltkey[1] = v[1];
											end
											if v[0] == "DTime" then
												fltkey[2] = v[1];
											end
											if v[0] == "APort" then
												fltkey[3] = v[1];
											end
											if v[0] == "ATime" then
												fltkey[4] = v[1];
											end
										end
									end
								end
								if string.len(fid) == 0 then
									table.insert(gseginf, tmpseg);
								else
									table.insert(bseginf, tmpseg);
								end
								if string.len(tmpfid) == 0 then
									tmpfid = fltkey[1] .. fltkey[2] .. "/" .. fltkey[3] .. fltkey[4];
									fltscore = tonumber(fltkey[2]);
								else
									tmpfid = tmpfid .. "-" .. fltkey[1] .. fltkey[2] .. "/" .. fltkey[3] .. fltkey[4];
								end
							end
							if string.len(fid) == 0 then
								fid = tmpfid;
								gfid = tmpfid;
							else
								fid = fid .. "," .. tmpfid;
								bfid = tmpfid;
							end
							tmpfid = "";
						end
						-- Caculate FlightLineID
						local FlightLineID = md5.sumhexa(fid)
						local ctrip = {};
						ctrip["bunks_idx"] = bunktb;
						-- ctrip["limit"] = limtab;
						ctrip["prices_data"] = pritab;
						ctrip["flightline_id"] = FlightLineID;
						table.insert(bigtab, ctrip)
					end
					if table.getn(bigtab) > 0 then
						print(JSON.encode(bigtab));
					else
						print(error002);
					end
					print("--------------")
				else
					print(code)
					print("--------------")
					print(status)
					print(body)
				end
			else
				print(codenum)
				print("--------------")
				print(status)
			end
			sleep(3)
		end
	else
		print(code)
		print("--------------")
		print(status)
		print(body)
	end
else
	print(code)
	print("--------------")
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
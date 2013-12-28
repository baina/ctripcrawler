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
local today = os.date("%Y-%m-%d", os.time());
local baseurl = "http://openapi.ctrip.com"
-- local domuri = "/Flight/DomesticFlight/OTA_FlightSearch.asmx"
local intluri = "/Flight/IntlFlight/OTA_IntlFlightSearch.asmx"
-- Signature=Md5(TimeStamp+AllianceID+MD5(密钥).ToUpper()+SID+RequestType).ToUpper()
local ts = os.time()
-- local ts = "1380250839"
local sign = string.upper(md5.sumhexa(ts .. unicode .. string.upper(md5.sumhexa(apikey)) .. siteid .. "OTA_IntlFlightSearch"))
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
intlxml = string.gsub(intlxml, "<", "&lt;")
-- soap
local request = ([=[<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<xsd:Request xmlns:xsd="http://ctrip.com/">
<xsd:requestXML>%s</xsd:requestXML>
</xsd:Request>
</soapenv:Body>
</soapenv:Envelope>]=]):format(intlxml)
-- print(request)
-- print("-----------------")
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
	local pr_xml = xml.eval(resxml);
	local xscene = pr_xml:find("IntlFlightSearchResponse");
	-- xscene maybe nil
	if xscene ~= nil then
		local orixml = xml.str(xscene);
		-- print(orixml);
		-- ctrip result xml logged.
		--[[
		local wname = "/data/logs/rholog.txt"
		local wfile = io.open(wname, "w+");
		wfile:write("\r\n---------------------\r\n");
		wfile:write(orixml);
		wfile:write("\r\n---------------------\r\n");
		io.close(wfile);
		--]]
		-- caculate md5 of IntlFlightSearchResponse
		local md5res = md5.sumhexa(orixml);
		local filet = os.time() + 3600;
		-- Redis
		--[[
		local proceed = false;
		local res, err = client:hget('intl:ctrip:' .. tkey, org .. dst)
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
		--]]
		-- RVDB
		local sinaapp = false;
		local sinaurl = "http://yougola.sinaapp.com/";
		local md5uri = "checker/?intl/ctrip/" .. tkey .. "/" .. org .. dst;
		local sinakey = "5P826n55x3LkwK5k88S5b3XS4h30bTRg";
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
			-- proxy = "http://10.123.74.137:808",
			-- proxy = "http://" .. tostring(arg[2]),
			timeout = 10000,
			method = "GET", -- POST or GET
			-- add post content-type and cookie
			headers = {
				["Host"] = "yougola.sinaapp.com",
				-- ["SOAPAction"] = "http://ctrip.com/Request",
				["Cache-Control"] = "no-cache",
				["Auth-Timestamp"] = filet,
				["Auth-Signature"] = md5.sumhexa(sinakey .. filet),
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
			-- print(resjson)
			if string.sub(resjson, 1, 32) ~= md5res then
				sinaapp = true;
				print(string.sub(resjson, 1, 32))
				print(md5res)
			end
		else
			sinaapp = true;
			print(code, status);
			print("-------注意认证SINA失败-------")
		end
		-- if proceed == true and sinaapp == true then
		if sinaapp == true then
			local rfid = {};
			local imax = {};
			local bigtab = {};
			local union = {};
			local records = tonumber(xscene[1][1]);
			if records > 0 then
				print(records)
				print("--------------")
				for r = 1, records do
					-- from the lowest price data
					-- local xscene = pr_xml:find("ShoppingResultInfo");
					local pritab = {};
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
									if v[0] ~= "FlightBaseInfos" and v[0] ~= "PriceInfos" and v[0] ~= "NoSalesStr" then
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
						-- NoSalesStr
						priceinfo["salelimit"] = idxtab;
						tmppritab["ctrip"] = priceinfo;
						table.insert(pritab, tmppritab)
						table.insert(bunktb, tbunks)
						-- break after get the first pricedata;
						break;
						-- polidx = polidx + 1;
						-- ngx.say(JSON.encode(idxtab))
						-- ngx.say(JSON.encode(tmppri))
					end
					-- get the segment data from xml of {r}
					local seginf = {};
					local fid = "";
					local fltscore = "";
					-- ow data the whole number is 1;
					for i = 1, 1 do
						local tmpfid = "";
						for j = 1, table.getn(xscene[2][r][1][i][3]) do
							-- ngx.say(type(xscene[1][i][3][j]))
							local tmpseg = {};
							local fltkey = {};
							for k, v in pairs(xscene[2][r][1][i][3][j]) do
								if k > 0 then
									if type(v) == "table" then
										if v[0] ~= "Stops" then
											tmpseg[v[0]] = v[1];
										end
										if v[0] == "Stops" and v[1] ~= nil then
											-- print(type(v[1]))
											-- print(table.getn(v[1]))
											-- print("--------------")
											-- print(table.getn(v))
											local tmpstops = {};
											for i = 1, table.getn(v) do
												local tmp = {};
												for j = 1, table.getn(v[i]) do
													tmp[v[i][j][0]] = v[i][j][1]
													-- print(v[i][j][0], v[i][j][1])
												end
												table.insert(tmpstops, tmp)
											end
											tmpseg[v[0]] = tmpstops;
										end
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
							table.insert(seginf, tmpseg);
							if string.len(tmpfid) == 0 then
								tmpfid = fltkey[1] .. fltkey[2] .. "/" .. fltkey[3] .. fltkey[4];
								fltscore = tonumber(fltkey[2]);
							else
								tmpfid = tmpfid .. "-" .. fltkey[1] .. fltkey[2] .. "/" .. fltkey[3] .. fltkey[4];
							end
						end
						if string.len(fid) == 0 then
							fid = tmpfid;
						else
							fid = fid .. "," .. tmpfid;
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
					ctrip["checksum_seg"] = seginf;
					-- Do NOT check
					table.insert(bigtab, r)
					-- begin to check ctrip ifl data if it has union airline carrier
					local pfid = {};
					local jmax = {};
					-- print(rfid[FlightLineID]) -- init is nil
					if rfid[FlightLineID] == nil then
						table.insert(pfid, ctrip)
						rfid[FlightLineID] = pfid
						jmax = ctrip;
						imax[FlightLineID] = jmax
						-- table.insert(rfid, pfid)
						-- rfid["ifl:" .. FlightLineID] = true
					else
						ctrip["flightline_id"] = "*" .. FlightLineID;
						print("--------------")
						print(ctrip["flightline_id"])
						print("--------------")
						pfid = rfid[FlightLineID]
						jmax = imax[FlightLineID]
						print(jmax["flightline_id"])
						print("--------------")
						jmax["flightline_id"] = "*" .. FlightLineID
						print(jmax["flightline_id"])
						-- make imax's price is lower
						if tonumber(jmax.prices_data[1].ctrip.priceinfo.SalesPrice) > tonumber(pritab[1].ctrip.priceinfo.SalesPrice) then
							-- jmax = {};
							-- table.insert(jmax, ctrip)
							imax[FlightLineID] = ctrip
							-- table.insert(pfid, jmax)
						else
							imax[FlightLineID] = jmax
							local tmp = {};
							for k, v in pairs(pfid) do
								if v ~= jmax then
									table.insert(tmp, v)
								end
							end
							-- table.remove(pfid, jmax)
							table.insert(tmp, ctrip)
							rfid[FlightLineID] = tmp
						end
						-- IsShared
						local check = true;
						for k, v in pairs(union) do
							if v == FlightLineID then
								check = false;
							end
						end
						if check ~= false then
							table.insert(union, FlightLineID)
						end
						-- print(JSON.encode(seginf))
						-- table.insert(pfid, ctrip)
					end
					-- ifl data check ended
					-- begin to store into redis
					--[[
					-- cancel store into redis because splitting the crawler and caculate program;
					local fltid = "";
					local farehkey = string.lower(string.sub(base64.encode(FlightLineID), 1, 2));
					local getfidres, getfiderr = client:hget("flt:" .. farehkey, FlightLineID)
					-- local getfidres, getfiderr = client:get("flt:" .. FlightLineID .. ":id")
					-- local res, err = client:hget('dom:itour:' .. tkey, org .. dst)
					if not getfidres then
						print(error003("failed to get the flt:" .. FlightLineID .. ":id: ", getfiderr))
						return
					end
					-- split the FlightLineID
					local farehkey = string.sub(string.format("%011d", value1), 1, 8);
					local res, err = red:hmset("PERIODS:fid:" .. farehkey, value1, fid)
					if not res then
						ngx.say("failed to hmset the hashes data : [PERIODS:fid:" .. farehkey .. "]", err);
						return
					end
					if tonumber(getfidres) == nil then
						-- fare:id INCR
						-- local farecounter, cerror = red:incr("next.fare.id")
						local farecounter, cerror = client:incr("flt:id")
						if not farecounter then
							print(error003("failed to INCR flt Line: ", cerror));
							return
						else
							-- local resultsetnx, fiderror = client:setnx("flt:" .. FlightLineID .. ":id", farecounter)
							local resultsetnx, fiderror = client:hsetnx("flt:" .. farehkey, FlightLineID, farecounter)
							if not resultsetnx then
								print(error003("failed to HSETNX FlightLineID: " .. FlightLineID, fiderror));
								return
							end
							-- ngx.print("INCR fare result: ", farecounter);
							-- ngx.print("\r\n---------------------\r\n");
							-- ngx.print("SETNX fid result: ", resultsetnx);
							-- ngx.print("\r\n---------------------\r\n");
							-- if resultsetnx ~= 1 that is SETNX is NOT sucess.
							if resultsetnx == 1 then
								fltid = farecounter;
							else
								-- fltid = client:get("flt:" .. FlightLineID .. ":id");
								fltid = client:hget("flt:" .. farehkey, FlightLineID);
							end
							if fltid ~= "" and fltid ~= nil and fltid ~= JSON.null then
								farehkey = string.lower(string.sub(base64.encode(fltid), 1, 2));
								client:hset("flt:" .. farehkey, fltid, FlightLineID)
								-- start to store the fltinfo.
								local res, err = client:zadd("ow:" .. string.upper(org) .. ":" .. string.upper(dst), fltscore, fltid)
								if not res then
									print(error003("failed to add FlightLine into " .. string.upper(org) .. "/" .. string.upper(dst) .. ":" .. fltid, err));
									return
								end
								-- checksum_seg
								-- ngx.say(JSON.encode(seginf))
							end
							local segstr = JSON.encode(seginf);
							local res, err = client:hset("seg:" .. fltid, md5.sumhexa(segstr), segstr)
							-- local res, err = client:hset("seg:" .. fltid, r, segstr)
							if not res then
								print(error003("failed to HSET checksum_seg info: " .. fltid, err));
								return
							end
							-- table.insert(bigtab, ctrip)
							local res, err = client:hset("pri:ow:" .. fltid, date, JSON.encode(ctrip))
							if not res then
								print(error003("failed to HSET prices_data info: " .. fltid, err));
								return
							else
								-- ngx.print(JSON.encode(ctrip))
								table.insert(bigtab, ctrip)
							end
						end
					else
						-- ngx.say(JSON.encode(seginf))
						-- ngx.say(JSON.encode(pritab))
						-- ngx.say(JSON.encode(bunktb))
						-- table.insert(bigtab, ctrip)
						fltid = tonumber(getfidres);
						-- checksum_seg
						local segstr = JSON.encode(seginf);
						-- local res, err = client:hset("seg:" .. fltid, md5.sumhexa(segstr), segstr)
						local data, error = client:hget("seg:" .. fltid, md5.sumhexa(segstr))
						if data == nil then
							-- local res, err = client:hset("seg:" .. fltid, r, segstr)
							local res, err = client:hset("seg:" .. fltid, md5.sumhexa(segstr), segstr)
							if not res then
								print(error003("failed to HSET checksum_seg info: " .. fltid, err));
								return
							end
						end
						-- local res, err = red:set("pri:ow:" .. fltid, JSON.encode(ctrip))
						local res, err = client:hset("pri:ow:" .. fltid, date, JSON.encode(ctrip))
						if not res then
							print(error003("failed to HSET prices_data info: " .. fltid, err));
							return
						else
							-- ngx.print(JSON.encode(ctrip))
							table.insert(bigtab, ctrip)
						end
					end
					-- ngx.say(JSON.encode(seginf))
					-- ngx.say(fid)
					-- ngx.say(FlightLineID)
					-- ngx.say(fltid)
					--]]
				end
				print("----------------------------")
				-- print(JSON.encode(imax));
				-- print("----------------------------")
				print(md5.sumhexa(JSON.encode(imax)))
				print("++++++++++++++++++++++++++++")
				if table.getn(bigtab) > 0 then
					-- print ctrip ifl data number
					print(JSON.encode(bigtab));
					print("--------------")
					local unilen = table.getn(union)
					if unilen > 0 then
						print(unilen);
						print("----------------------------")
						local timestamp = os.date("%a, %d %b %Y %X GMT", os.time())
						for k, v in pairs(union) do
							-- upload every union data into cloud first and cover old union data[pfiles bunket]
							local everyunion = JSON.encode(rfid[v]);
							print("---- begin to set union data into pfiles in baidu");
							local obj = "/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. v .. ".json";
							local cl = string.len(everyunion);
							-- api post file.
							local respup = {};
							local requri = "/pfiles" .. obj;
							local Content= "MBO" .. "\n" .. "Method=PUT" .. "\n" .. "Bucket=pfiles" .. "\n" .. "Object=" .. obj .. "\n"
							local Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)))
							-- sign = md5.sumhexa("PUT&" .. requri .. "&" .. timestamp .. "&" .. cl .. "&" .. md5.sumhexa("b6x7p6b6x7p6"));
							-- local hc = http:new()
							-- print(sign)
							print(cl)
							-- print(md5.sumhexa("b6x7p6b6x7p6"))
							print(requri)
							print(urlencode(requri))
							-- print(timestamp)
							print("--------------")
							-- PUT uncompressed JSON file into duapp.
							local body, code, headers, status = http.request {
							-- local ok, code, headers, status, body = http.request {
								-- url = "http://v0.api.upyun.com" .. requri,
								url = "http://bcs.duapp.com/pfiles" .. obj .. "?sign=MBO:" .. ak .. ":" .. Signature,
								-- proxy = "http://10.123.74.137:808",
								timeout = 10000,
								method = "PUT", -- POST or GET
								-- add post content-type and cookie
								-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
								-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
								-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
								headers = { ["Host"] = "bcs.duapp.com", ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
								-- body = formdata,
								-- source = ltn12.source.string(form_data);
								source = ltn12.source.string(everyunion),
								sink = ltn12.sink.table(respup)
							}
							if code == 200 then
								local upyun = "";
								local len = table.getn(respup)
								for i = 1, len do
									upyun = upyun .. respup[i]
								end
								print(upyun)
								print("------ set union data {" .. v .. "} ok");
							else
								print(code)
								print("---- set union data {" .. v .. "} failure");
								print(status)
								print(body)
							end
							-- history union data
							print("---- begin to set compress union data into baidu");
							sleep(0.1)
							local data = zlib.compress(JSON.encode(rfid[v]));
							cl = string.len(data);
							-- api post file.
							respup = {};
							obj = "/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. filet .. "/" .. v .. ".json";
							requri = "/bestfly" .. obj;
							Content= "MBO" .. "\n" .. "Method=PUT" .. "\n" .. "Bucket=bestfly" .. "\n" .. "Object=" .. obj .. "\n"
							Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)))
							-- local sign = md5.sumhexa("PUT&" .. requri .. "&" .. timestamp .. "&" .. cl .. "&" .. md5.sumhexa("b6x7p6b6x7p6"));
							-- local hc = http:new()
							-- print(sign)
							print(cl)
							print(md5.sumhexa("b6x7p6b6x7p6"))
							print(requri)
							print(urlencode(requri))
							print(timestamp)
							print("--------------")
							-- PUT compressed JSON file into duapp.
							local body, code, headers, status = http.request {
							-- local ok, code, headers, status, body = http.request {
								-- url = "http://v0.api.upyun.com" .. requri,
								url = "http://bcs.duapp.com/bestfly" .. obj .. "?sign=MBO:" .. ak .. ":" .. Signature,
								-- proxy = "http://10.123.74.137:808",
								timeout = 10000,
								method = "PUT", -- POST or GET
								-- add post content-type and cookie
								-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
								-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
								-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
								headers = { ["Host"] = "bcs.duapp.com", ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
								-- body = formdata,
								-- source = ltn12.source.string(form_data);
								source = ltn12.source.string(data),
								sink = ltn12.sink.table(respup)
							}
							if code == 200 then
								print("------ set history union data ok");
								local upyun = "";
								local len = table.getn(respup)
								for i = 1, len do
									upyun = upyun .. respup[i]
								end
								print(upyun)
								--[[
								-- Do NOT store union data into redis because splitting the crawler and caculate program;
								-- after into baidu, begin store into redis
								local farehkey = string.lower(string.sub(base64.encode(v), 1, 2));
								-- local fltkey, err = client:get("flt:" .. v .. ":id")
								local fltkey, err = client:hget("flt:" .. farehkey, v)
								if tonumber(fltkey) ~= nil then
									-- client:hdel("uni:" .. string.upper(org) .. ":" .. string.upper(dst), fltkey);
									-- local res, err = client:hset("uni:" .. string.upper(org) .. ":" .. string.upper(dst), fltkey, JSON.encode(rfid[v]))
									client:hdel("uni:" .. string.upper(org) .. ":" .. string.upper(dst) .. ":" .. fltkey, tkey);
									-- local res, err = client:hset("uni:" .. string.upper(org) .. ":" .. string.upper(dst) .. ":" .. fltkey, tkey, JSON.encode(rfid[v]));
									-- cancel large data body
									local res, err = client:hset("uni:" .. string.upper(org) .. ":" .. string.upper(dst) .. ":" .. fltkey, tkey, filet)
									-- local res, err = client:hset("seg:" .. fltid, r, segstr)
									if not res then
										print(error003("failed to HSET union info: " .. v, err));
										return
									else
										print("-------well done " .. v .. "--------")
									end
								else
									-- first hset into
									local res, err = client:hset("uni:" .. string.upper(org) .. ":" .. string.upper(dst) .. ":" .. fltkey, tkey, filet)
									-- local res, err = client:hset("seg:" .. fltid, r, segstr)
									if not res then
										print(error003("failed to HSET union info: " .. v, err));
										return
									else
										print("-------well done " .. v .. "--------")
									end
								end
								--]]
							else
								print("----++failed to set compress union data {" .. v .. "} into baidu");
							end
							sleep(0.1)
						end
					else
						print("---- uni data is null of {" .. JSON.encode(bigtab) .. "}")
					end
					-- print imax with the lowest price
					-- print(JSON.encode(imax))
					bigtab = {};
					for k, v in pairs(imax) do
						table.insert(bigtab, v)
					end
					-- print("--------------")
					-- print the result
					-- print(JSON.encode(bigtab));
					-- store into baidu
					local pfiles = JSON.encode(bigtab);
					local data = zlib.compress(pfiles);
					-- see the gloabal timestamp at line[552]
					-- local filet = os.time();
					local cl = string.len(data);
					-- api post file.
					local respup = {};
					local timestamp = os.date("%a, %d %b %Y %X GMT", os.time())
					local requri = "/besftly/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. filet .. "/main.json";
					local obj = "/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. filet .. "/main.json";
					local Content= "MBO" .. "\n" .. "Method=PUT" .. "\n" .. "Bucket=bestfly" .. "\n" .. "Object=" .. obj .. "\n"
					local Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)))
					local sign = md5.sumhexa("PUT&" .. requri .. "&" .. timestamp .. "&" .. cl .. "&" .. md5.sumhexa("b6x7p6b6x7p6"));
					-- local hc = http:new()
					print(sign)
					print(cl)
					print(md5.sumhexa("b6x7p6b6x7p6"))
					print(requri)
					print(urlencode(requri))
					print(timestamp)
					print("--------------")
					sleep(0.1)
					-- PUT compressed JSON file into duapp.
					local body, code, headers, status = http.request {
					-- local ok, code, headers, status, body = http.request {
						-- url = "http://v0.api.upyun.com" .. requri,
						url = "http://bcs.duapp.com/bestfly" .. obj .. "?sign=MBO:" .. ak .. ":" .. Signature,
						-- proxy = "http://10.123.74.137:808",
						timeout = 10000,
						method = "PUT", -- POST or GET
						-- add post content-type and cookie
						-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
						-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
						-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
						headers = { ["Host"] = "bcs.duapp.com", ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
						-- body = formdata,
						-- source = ltn12.source.string(form_data);
						source = ltn12.source.string(data),
						sink = ltn12.sink.table(respup)
					}
					if code == 200 then
						local upyun = "";
						local len = table.getn(respup)
						for i = 1, len do
							upyun = upyun .. respup[i]
						end
						print(upyun)
						-- local djson = zlib.compress(JSON.encode(bigtab))
						-- print(type(zlib.compress(JSON.encode(bigtab))))
						-- local djson = JSON.encode(bigtab)
						--[[
						local res, err = client:hget('intl:ctrip:' .. tkey, org .. dst)
						if res ~= nil and res ~= JSON.null and res ~= "" then
							client:hdel('intl:ctrip:' .. tkey, org .. dst);
							local res, err = client:hset('intl:ctrip:' .. tkey, org .. dst, filet)
							if not res then
								print("-------Failed to hset " .. arg[1] .. "--------")
							else
								client:expire('intl:ctrip:' .. tkey, (expiret - os.time()))
								print("-------well done " .. arg[1] .. "--------")
							end
							-- local tobj = tostring(res)
							local tobj = "/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. tostring(res) .. ".json"
							local Content= "MBO" .. "\n" .. "Method=DELETE" .. "\n" .. "Bucket=bestfly" .. "\n" .. "Object=" .. tobj .. "\n"
							local Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)))
							local respup = {};
							local body, code, headers, status = http.request {
							-- local ok, code, headers, status, body = http.request {
								-- url = "http://v0.api.upyun.com" .. requri,
								url = "http://bcs.duapp.com/bestfly" .. tobj .. "?sign=MBO:" .. ak .. ":" .. Signature,
								--- proxy = "http://127.0.0.1:8888",
								timeout = 10000,
								method = "DELETE", -- POST or GET
								-- add post content-type and cookie
								-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
								-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
								-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
								-- headers = { ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
								-- body = formdata,
								-- source = ltn12.source.string(form_data);
								-- source = ltn12.source.string(data),
								sink = ltn12.sink.table(respup)
							}
							if code == 200 then
								client:hdel('intl:ctrip:' .. tkey, org .. dst);
								local res, err = client:hset('intl:ctrip:' .. tkey, org .. dst, filet)
								if not res then
									print("-------Failed to hset " .. arg[1] .. "--------")
								else
									client:expire('intl:ctrip:' .. tkey, (expiret - os.time()))
									print("-------well done " .. arg[1] .. "--------")
								end
							else
								print(code)
								print("-------Failed to DELETE " .. tobj .. "--------")
								print(status)
								print(body)
							end
						else
							local res, err = client:hset('intl:ctrip:' .. tkey, org .. dst, filet)
							if not res then
								print("-------Failed to hset " .. arg[1] .. "--------")
							else
								client:expire('intl:ctrip:' .. tkey, (expiret - os.time()))
								print("-------well done " .. arg[1] .. "--------")
							end
						end
						-- begin to set newest data to pfiles in baidu
						client:hdel('intl:ctrip:' .. tkey, org .. dst);
						local newdata = md5res .. filet;
						local res, err = client:hset('intl:ctrip:' .. tkey, org .. dst, newdata)
						if not res then
							print("-------Failed to hset " .. arg[1] .. "--------")
						else
							client:expire('intl:ctrip:' .. tkey, (expiret - os.time()))
							print("-------well done " .. arg[1] .. "--------")
						end
						--]]
						local newdata = md5res .. filet;
						-- init response table
						local respbody = {};
						print(newdata);
						print("-------开始发送POST请求-------")
						print(sinaurl .. md5uri);
						print("--------------")
						-- local body, code, headers = http.request(baseurl .. md5uri)
						local body, code, headers, status = http.request {
						-- local ok, code, headers, status, body = http.request {
							-- url = "http://cloudavh.com/data-gw/index.php",
							url = sinaurl .. md5uri,
							-- proxy = "http://10.123.74.137:808",
							-- proxy = "http://" .. tostring(arg[2]),
							timeout = 10000,
							method = "POST", -- POST or GET
							-- add post content-type and cookie
							-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
							-- headers = { ["Host"] = "flight.itour.cn", ["X-AjaxPro-Method"] = "GetFlight", ["Cache-Control"] = "no-cache", ["Accept-Encoding"] = "gzip,deflate,sdch", ["Accept"] = "*/*", ["Origin"] = "chrome-extension://fdmmgilgnpjigdojojpjoooidkmcomcm", ["Connection"] = "keep-alive", ["Content-Type"] = "application/json", ["Content-Length"] = string.len(JSON.encode(request)), ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36" },
							headers = {
								["Host"] = "yougola.sinaapp.com",
								-- ["SOAPAction"] = "http://ctrip.com/Request",
								["Cache-Control"] = "no-cache",
								["Auth-Timestamp"] = filet,
								["Auth-Signature"] = md5.sumhexa(sinakey .. filet),
								-- ["Accept-Encoding"] = "gzip",
								-- ["Accept"] = "*/*",
								["Connection"] = "keep-alive",
								-- ["Content-Type"] = "text/xml; charset=utf-8",
								["Content-Length"] = string.len(newdata)
							},
							-- body = formdata,
							-- source = ltn12.source.string(form_data);
							source = ltn12.source.string(newdata),
							sink = ltn12.sink.table(respbody)
						}
						print(code, status, body)
						for k, v in pairs(headers) do
							print(k, v)
						end
						print("--------------")
						print(body)
						print("--------------")
						print(status)
						print("--------------")
						local resjson = "";
						local reslen = table.getn(respbody)
						print(reslen)
						for i = 1, reslen do
							-- print(respbody[i])
							resjson = resjson .. respbody[i]
						end
						print(resjson)
						print("+++++++++++++++++++++++++++++++++++++++++++++++")
						--[[
						-- save price data history forever.
						print("-- begin to DEL old data from pfiles");
						local tobj = "/intl/ctrip/" .. tkey .. "/" .. org .. dst .. ".json"
						local Content= "MBO" .. "\n" .. "Method=DELETE" .. "\n" .. "Bucket=pfiles" .. "\n" .. "Object=" .. tobj .. "\n"
						local Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)))
						local respup = {};
						local body, code, headers, status = http.request {
						-- local ok, code, headers, status, body = http.request {
							-- url = "http://v0.api.upyun.com" .. requri,
							url = "http://bcs.duapp.com/bestfly" .. tobj .. "?sign=MBO:" .. ak .. ":" .. Signature,
							--- proxy = "http://127.0.0.1:8888",
							timeout = 10000,
							method = "DELETE", -- POST or GET
							-- add post content-type and cookie
							-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
							-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
							-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
							-- headers = { ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
							-- body = formdata,
							-- source = ltn12.source.string(form_data);
							-- source = ltn12.source.string(data),
							sink = ltn12.sink.table(respup)
						}
						if code == 200 then
							print("-- Del ok.")
						--]]
						print("---- begin to set newest data into pfiles in baidu");
						sleep(0.1)
						obj = "/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/main.json";
						cl = string.len(pfiles);
						-- api post file.
						respup = {};
						-- local timestamp = os.date("%a, %d %b %Y %X GMT", os.time())
						requri = "/pfiles/intl/ctrip/" .. tkey .. "/" .. org .. dst .. "/main.json";
						-- local obj = "/" .. filet .. ".json";
						Content= "MBO" .. "\n" .. "Method=PUT" .. "\n" .. "Bucket=pfiles" .. "\n" .. "Object=" .. obj .. "\n"
						Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)))
						sign = md5.sumhexa("PUT&" .. requri .. "&" .. timestamp .. "&" .. cl .. "&" .. md5.sumhexa("b6x7p6b6x7p6"));
						-- local hc = http:new()
						print(sign)
						print(cl)
						-- print(md5.sumhexa("b6x7p6b6x7p6"))
						print(requri)
						print(urlencode(requri))
						-- print(timestamp)
						print("--------------")
						-- PUT uncompressed JSON file into duapp.
						local body, code, headers, status = http.request {
						-- local ok, code, headers, status, body = http.request {
							-- url = "http://v0.api.upyun.com" .. requri,
							url = "http://bcs.duapp.com/pfiles" .. obj .. "?sign=MBO:" .. ak .. ":" .. Signature,
							-- proxy = "http://10.123.74.137:808",
							timeout = 10000,
							method = "PUT", -- POST or GET
							-- add post content-type and cookie
							-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
							-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
							-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
							headers = { ["Host"] = "bcs.duapp.com", ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
							-- body = formdata,
							-- source = ltn12.source.string(form_data);
							source = ltn12.source.string(pfiles),
							sink = ltn12.sink.table(respup)
						}
						if code == 200 then
							local upyun = "";
							local len = table.getn(respup)
							for i = 1, len do
								upyun = upyun .. respup[i]
							end
							print(upyun)
							print("---- set main pricedata ok");
						else
							print(code)
							print("---- set main pricedata failure");
							print(status)
							print(body)
						end
					else
						print(code)
						print("-----upload to baidu failure-------")
						print(status)
						print(body)
					end
				else
					print(code)
					print("-----caculate result is NULL-------")
					print(status)
					print(body)
				end
				-- print("--------------")
				-- print check data of ifl
				-- print(JSON.encode(rfid))
			else
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
				print("-- ctrip api result intldata is NULL-----")
			end
		else
			print("-----EOF{".. md5res .. "|" .. filet .."}-----")
		end
	else
		print(code, status)
		print("--------------")
		print(resxml)
		print("-----ctrip api result xml is wrong-----")
		local todo = JSON.encode({ ["type"] = 1, ["queues"] = "intl:", ["qbody"] = string.sub(arg[1], 1, -2) .. tostring(tonumber(string.sub(arg[1], -1, -1))+1) });
		local t = 0;
		while true do
			local code = retry(todo)
			t = t + 1;
			print(t, code)
			print("-------------")
			if code == 200 or t > 3 then
				sleep(0.5)
				break;
			end
		end
	end
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
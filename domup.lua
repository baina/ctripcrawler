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
local tkey = string.sub(arg[1], 9, -2);
local expiret = os.time({year=string.sub(tkey, 1, 4), month=tonumber(string.sub(tkey, 5, 6)), day=tonumber(string.sub(tkey, 7, 8)), hour="00"})
local date = string.sub(arg[1], 9, 12) .. "-" .. string.sub(arg[1], 13, 14) .. "-" .. string.sub(arg[1], 15, 16);
local today = os.date("%Y-%m-%d", os.time());
local baseurl = "http://openapi.ctrip.com"
local domuri = "/Flight/DomesticFlight/OTA_FlightSearch.asmx"
local apikey = "15AAF13C-2CDB-4078-AADE-FC5D6307394C"
local siteid = "328547"
local unicode = "9134"
-- Signature=Md5(TimeStamp+AllianceID+MD5(密钥).ToUpper()+SID+RequestType).ToUpper()
local ts = os.time()
-- local ts = "1380250839"
local sign = string.upper(md5.sumhexa(ts .. unicode .. string.upper(md5.sumhexa(apikey)) .. siteid .. "OTA_FlightSearch"))
-- print("-----------------")
-- print(ts)
-- print(sign)
print(string.upper(org), string.upper(dst), date, today)
print("-----------------")
local domxml = ([=[
<Request>
  <Header>
    <AllianceID>%s</AllianceID>
    <SID>%s</SID>
    <TimeStamp>%s</TimeStamp>
    <RequestType>OTA_FlightSearch</RequestType>
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
-- domxml = string.gsub(domxml, ">", "&gt;")
-- domxml = string.gsub(domxml, "\n", "")
local request = ([=[<?xml version='1.0' encoding='UTF-8'?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
<soapenv:Body>
<xsd:Request xmlns:xsd="http://ctrip.com/">
<xsd:requestXML>%s</xsd:requestXML>
</xsd:Request>
</soapenv:Body>
</soapenv:Envelope>]=]):format(domxml)
-- print(request)
-- print("-----------------")
-- init response table
local respbody = {};
-- local hc = http:new()
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://cloudavh.com/data-gw/index.php",
	url = baseurl .. domuri .. "?WSDL",
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
	--[[
	-- ctrip result xml logged.
	local wname = "/data/logs/rholog.txt"
	local wfile = io.open(wname, "w+");
	wfile:write("\r\n---------------------\r\n");
	wfile:write(resxml);
	wfile:write("\r\n---------------------\r\n");
	io.close(wfile);
	print(code)
	print("--------------")
	print(status)
	print(body)
	--]]
	resxml = string.gsub(resxml, "&lt;", "<")
	resxml = string.gsub(resxml, "&gt;", ">")
	-- print(resxml)
	local tbody = resxml;
	-- search for substatement having the tag "RequestResponse"
	local idx1 = string.find(tbody, "<RequestResponse");
	local idx2 = string.find(tbody, "</RequestResponse>");
	local prdata = string.sub(tbody, idx1, idx2+17);
	local pr_xml = xml.eval(prdata);
	local xscene = pr_xml:find("DomesticFlightRoute");
	if xscene ~= nil then
		-- after catch data from ctrip, get itour data
		local itour = {};
		local pfileurl = "http://rhosouth001/pfile/dom/itour/";
		local pfileuri = string.gsub(arg[1], "bjs", "bbb")
		pfileuri = string.gsub(pfileuri, "sha", "sss")
		pfileuri = string.gsub(pfileuri, "sia", "xiy")
		while pfileurl and pfileuri do
			local body, code, headers = http.request(pfileurl .. pfileuri)
			if code == 200 and body ~= nil then
				local tmpbody = JSON.decode(body)
				if tmpbody.resultCode == nil then
					for k, v in pairs(tmpbody) do
						itour[v.flightline_id] = v.prices_data[1].itour
					end
				else
					print("--------itour NO data---------")
				end
				break;
			end
		end
		local rcs = tonumber(xscene[1][1]);
		local rc = 1;
		local rfid = {};
		local dfid = {};
		while rc <= rcs do
			-- echo segments info at 20130706 by huangqi.
			local seginf = {};
			-- echo policy info of limitinfo and prices & tax
			local limtab = {};
			local pritab = {};
			-- echo bunks_idx for price.
			local bunktb = {};
			local fltkey = {};
			local fid = "";
			for k, v in pairs(xscene[4][rc]) do
				-- local tmpseg = {};
				if k > 0 then
					if type(v) == "table" then
						if v[0] == "DPortCode" then
							fltkey[1] = v[1];
							seginf[v[0]] = v[1];
						end
						if v[0] == "TakeOffTime" then
							local t = string.find(v[1], "T")
							local m = string.sub(v[1], t+1, -4);
							t = string.find(m, ":")
							fltkey[2] = string.sub(m, 1, t-1) .. string.sub(m, t+1, -1)
							seginf[v[0]] = v[1];
						end
						if v[0] == "APortCode" then
							fltkey[3] = v[1];
							seginf[v[0]] = v[1];
						end
						if v[0] == "ArriveTime" then
							local t = string.find(v[1], "T")
							local m = string.sub(v[1], t+1, -4);
							t = string.find(m, ":")
							fltkey[4] = string.sub(m, 1, t-1) .. string.sub(m, t+1, -1)
							seginf[v[0]] = v[1];
						end
						if v[0] == "DepartCityCode" or v[0] == "ArriveCityCode" or v[0] == "CraftType" or v[0] == "AirlineCode" or v[0] == "MealType" or v[0] == "StopTimes" then
							seginf[v[0]] = v[1];
						end
						if v[0] == "Flight" then
							seginf["FlightNo"] = v[1];
						end
						if v[0] == "Class" or v[0] == "SubClass" or v[0] == "DisplaySubclass" or v[0] == "Quantity" or v[0] == "IsStandardClass" then
							bunktb[v[0]] = v[1];
						end
						if v[0] == "Rate" or v[0] == "Price" or v[0] == "StandardPrice" or v[0] == "ChildStandardPrice" or v[0] == "BabyStandardPrice" or v[0] == "AdultTax" or v[0] == "BabyTax" or v[0] == "ChildTax" or v[0] == "AdultOilFee" or v[0] == "BabyOilFee" or v[0] == "ChildOilFee" or v[0] == "PriceType" or v[0] == "ProductType" or v[0] == "IsLowestPrice" or v[0] == "IsLowestCZSpecialPrice" then
							pritab[v[0]] = v[1];
						end
						if v[0] == "Nonrer" or v[0] == "Nonend" or v[0] == "Nonref" or v[0] == "Rernote" or v[0] == "Endnote" or v[0] == "Refnote" or v[0] == "Remarks" or v[0] == "BeforeFlyDate" or v[0] == "InventoryType" or v[0] == "NeedApplyString" or v[0] == "CanUpGrade" or v[0] == "CanSeparateSale" or v[0] == "OnlyOwnCity" or v[0] == "PolicyID" then
							limtab[v[0]] = v[1];
						end
					end
				end
			end
			-- caculate the fid
			-- PEK1830/CAN2140 ow example.
			fid = fltkey[1] .. fltkey[2] .. "/" .. fltkey[3] .. fltkey[4];
			-- put the fids into rfid instead of redis sets
			if rfid[fid] ~= true then
				rfid[fid] = true
			end
			-- echo bunks_index.
			local tmptab = {};
			-- local bolfid = byfs:get(fid .. ":bunks");
			-- local bolfid = {};
			local bolfid = dfid[fid .. ":bunks"]
			if bolfid == nil then
				local cntmp = {};
				table.insert(cntmp, bunktb)
				table.insert(tmptab, cntmp)
				-- byfs:set(fid .. ":bunks", JSON.encode(tmptab));
				dfid[fid .. ":bunks"] = tmptab;
			else
				-- local tmpfid = JSON.decode(bolfid);
				local tmpfid = bolfid;
				local cntmp = {};
				table.insert(cntmp, bunktb)
				table.insert(tmpfid, cntmp)
				-- byfs:replace(fid .. ":bunks", JSON.encode(tmpfid));
				dfid[fid .. ":bunks"] = tmpfid;
			end
			-- combinate the price & limit.
			local priceinfo = {};
			-- local tcnprices = {};
			local goalprice = {};
			priceinfo["priceinfo"] = pritab;
			priceinfo["salelimit"] = limtab;
			-- 20130708 by huangqi
			-- table.insert(tcnprices, priceinfo)
			goalprice["ctrip"] = priceinfo;
			-- begin to insert other ota price.
			-- 20130726 by huangqi
			-- get data by seginf["FlightNo"]
			local paddelong = {};
			paddelong["ctrip"] = priceinfo;
			if itour[md5.sumhexa(fid)] ~= nil then
				paddelong["itour"] = itour[md5.sumhexa(fid)];
			end
			-- more ota insert first index.
			local tmppri = {};
			local bolfid = dfid[fid .. ":price"]
			-- local bolfid = byfs:get(fid .. ":price");
			if bolfid == nil then
				table.insert(tmppri, paddelong)
				-- ngx.say(JSON.encode(tmppri));
				-- byfs:set(fid .. ":price", JSON.encode(tmppri));
				dfid[fid .. ":price"] = tmppri;
			else
				-- local tmpfid = JSON.decode(bolfid);
				local tmpfid = bolfid;
				table.insert(tmpfid, goalprice)
				-- byfs:replace(fid .. ":price", JSON.encode(tmpfid));
				dfid[fid .. ":price"] = tmpfid;
			end
			-- echo seginfo.
			-- local bolfid = byfs:get(fid .. ":seg");
			local bolfid = dfid[fid .. ":seg"]
			if bolfid == nil then
				-- byfs:set(fid .. ":seg", JSON.encode(seginf));
				dfid[fid .. ":seg"] = seginf;
			end
			-- table.insert(seginf, tmpseg)
			rc = rc + 1;
			-- table.insert(bigtab, limtab)
			-- table.insert(bigtab, pritab)
		end
		-- echo the result in bigtab.
		local bigtab = {};
		for k, v in pairs(rfid) do
			-- ngx.print(k)
			local ctrip = {};
			-- local tmpbunkstab = byfs:get(k .. ":bunks");
			-- local tmpbunkstab = dfid[fid .. ":bunks"];
			-- table.insert(bigbunks, JSON.decode(tmptab))
			-- ctrip["bunks_idx"] = JSON.decode(tmpbunkstab);
			-- print(table.getn(dfid[k .. ":bunks"]), table.getn(dfid[k .. ":price"]))
			ctrip["bunks_idx"] = dfid[k .. ":bunks"][1]
			-- byfs:delete(k .. ":bunks");
			-- ngx.print(fids[fidi], tmptab);
			-- local bigprice = {};
			-- local tmppricetab = byfs:get(k .. ":price");
			-- local ctripdata = {};
			-- local tmppritab = {};
			-- tmppritab["ctrip"] = JSON.decode(tmppricetab);
			-- table.insert(ctripdata, JSON.decode(tmppricetab))
			-- ctrip["prices_data"] = JSON.decode(tmppricetab);
			ctrip["prices_data"] = dfid[k .. ":price"][1]
			-- table.insert(bigprice, JSON.decode(tmptab))
			-- byfs:delete(k .. ":price");
			-- segments
			local tmpseginfo = {};
			-- local tmpsegtab = byfs:get(k .. ":seg");
			-- local tmpsegtab = dfid[fid .. ":seg"]
			table.insert(tmpseginfo, dfid[k .. ":seg"])
			-- byfs:delete(k .. ":seg");
			ctrip["checksum_seg"] = tmpseginfo;
			ctrip["flightline_id"] = md5.sumhexa(k);
			table.insert(bigtab, ctrip)
		end
		if table.getn(bigtab) > 0 then
			-- print(JSON.encode(bigtab));
			local data = zlib.compress(JSON.encode(bigtab));
			local filet = os.time();
			local cl = string.len(data)
		
			-- api post file.
			local respup = {};
			local timestamp = os.date("%a, %d %b %Y %X GMT", os.time())
			local requri = "/besftly/dom/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. filet .. ".json";
			local obj = "/dom/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. filet .. ".json";
			-- local obj = "/" .. filet .. ".json";
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
			-- PUT JSON file into duapp.
			local body, code, headers, status = http.request {
			-- local ok, code, headers, status, body = http.request {
				-- url = "http://v0.api.upyun.com" .. requri,
				url = "http://bcs.duapp.com/bestfly" .. obj .. "?sign=MBO:" .. ak .. ":" .. Signature,
				--- proxy = "http://127.0.0.1:8888",
				timeout = 10000,
				method = "PUT", -- POST or GET
				-- add post content-type and cookie
				-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
				-- headers = { ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Mkdir"] = "true", ["Content-Type"] = "application/json" },
				-- headers = { ["Mkdir"] = "true", ["Date"] = timestamp, ["Authorization"] = "UpYun bestfly:" .. sign, ["Content-Length"] = cl, ["Content-Type"] = "application/json" },
				headers = { ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
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
				local res, err = client:hget('dom:ctrip:' .. tkey, org .. dst)
				if res ~= nil and res ~= JSON.null and res ~= "" then
					-- local tobj = tostring(res)
					local tobj = "/dom/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. tostring(res) .. ".json"
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
						client:hdel('dom:ctrip:' .. tkey, org .. dst);
						local res, err = client:hset('dom:ctrip:' .. tkey, org .. dst, filet)
						if not res then
							print("-------Failed to hset " .. arg[1] .. "--------")
						else
							client:expire('dom:ctrip:' .. tkey, (expiret - os.time()))
							print("-------well done " .. arg[1] .. "--------")
						end
					else
						print(code)
						print("-------Failed to DELETE " .. tobj .. "--------")
						print(status)
						print(body)
					end
				else
					local res, err = client:hset('dom:ctrip:' .. tkey, org .. dst, filet)
					if not res then
						print("-------Failed to hset " .. arg[1] .. "--------")
					else
						client:expire('dom:ctrip:' .. tkey, (expiret - os.time()))
						print("-------well done " .. arg[1] .. "--------")
					end
				end
			else
				print(code)
				print(status)
				print(body)
			end
		else
			print(error002);
		end
		-- print(xml.str(xscene));
		-- print(idx1, idx2)
		-- print(prdata)
	else
		print(error002);
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
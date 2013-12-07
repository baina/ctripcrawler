-- buyhome <huangqi@rhomobi.com> 20131114 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- price agent of extension for bestfly service
--[[
{
    "ret_code": 0,
    "error": "",
    "id": 6,
    "sid": 275356,
    "aid": 10786,
    "api_key": "4898D402-90D7-4483-8D37-C79817ACF30D",
    "total": 0,
    "update_time": "2013-09-05 00:00:00",
    "ip": "112.124.58.108"
}

{
    "ret_code": 2,
    "error": "Sorry, No Data Found.",
    "ip": "8.35.201.34"
}
--]]
local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
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
	local codenum, resbody = fatchkey ("http://172.16.30.174:8088")
	if codenum == 200 then
		resbody = JSON.decode(resbody);
		unicode = resbody.aid
		apikey = tostring(resbody.api_key)
		siteid = resbody.sid
		break;
	end
end
print(apikey, siteid, unicode)
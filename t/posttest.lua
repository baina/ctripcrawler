-- buyhome <huangqi@rhomobi.com> 20131118 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- sinaapp test program of extension for bestfly service
local socket = require 'socket'
local http = require 'socket.http'
-- local JSON = require 'cjson'
local md5 = require 'md5'
-- local zlib = require 'zlib'
local base64 = require 'base64'
-- local crypto = require 'crypto'
-- local client = require 'soap.client'
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
-- http://yougola.sinaapp.com/checker/?/intl/ctrip/20131201.20131231/shalon
-- http://yougola.sinaapp.com/checker/?intl/ctrip/20131130.20131230/bjslon
local sinaapp = false;
local baseurl = "http://cloudavh.sinaapp.com/";
local md5uri = "checker/?intl/kayak/20131130.20131230/bjslon";
local sinakey = "5P826n55x3LkwK5k88S5b3XS4h30bTRg";
local timestamp = os.time() + 3600;
print(timestamp);
print(md5.sumhexa(sinakey .. timestamp))
print(urlencode(baseurl .. md5uri));
print("--------------")
print(md5.sumhexa("BJS0650/DXB1150-DXB1445/LON1825,LON1335/DXB0035-DXB0335/BJS1445"))
-- init response table
local respbody = {};
-- local wname = "C:\\Lua\\5.1\\changes.txt"
local wname = "/data/logs/ngxlua.html"
local wfile = io.open(wname, "r");
local request = wfile:read("*a");
print("--------------")
print(string.len(request));
print("--------------")
-- request = md5.sumhexa(request) .. timestamp .. string.len(request);
-- request = base64.encode(request);
local form_data = string.sub(request, 1, -1) .. "8"
print(request);
print("--------------")
print("-------开始发送POST请求-------")
-- local body, code, headers = http.request(baseurl .. md5uri)
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	-- url = "http://cloudavh.com/data-gw/index.php",
	-- url = baseurl .. md5uri,
	-- url = "http://rhomobi.com:18081/rholog",
	url = "http://172.16.30.1:3000/citycns",
	-- proxy = "http://112.124.211.29:18085",
	-- proxy = "http://" .. tostring(arg[2]),
	timeout = 3000,
	method = "POST", -- POST or GET
	-- add post content-type and cookie
	-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
	-- headers = { ["Host"] = "flight.itour.cn", ["X-AjaxPro-Method"] = "GetFlight", ["Cache-Control"] = "no-cache", ["Accept-Encoding"] = "gzip,deflate,sdch", ["Accept"] = "*/*", ["Origin"] = "chrome-extension://fdmmgilgnpjigdojojpjoooidkmcomcm", ["Connection"] = "keep-alive", ["Content-Type"] = "application/json", ["Content-Length"] = string.len(JSON.encode(request)), ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.65 Safari/537.36" },
	headers = {
		-- ["Host"] = "yougola.sinaapp.com",
		-- ["SOAPAction"] = "http://ctrip.com/Request",
		["Cache-Control"] = "no-cache",
		["Auth-Timestamp"] = timestamp,
		["Auth-Signature"] = md5.sumhexa(sinakey .. timestamp),
		-- ["Accept-Encoding"] = "gzip",
		-- ["Accept"] = "*/*",
		["Connection"] = "keep-alive",
		-- ["Content-Type"] = "text/xml; charset=utf-8",
		["Content-Length"] = string.len(form_data)
	},
	-- body = formdata,
	source = ltn12.source.string(form_data);
	-- source = ltn12.source.string(request),
	sink = ltn12.sink.table(respbody)
}
print(code, status, body)
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
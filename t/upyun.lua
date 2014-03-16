-- jijilu <huangqi@travelsky.com> 20140124 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- upyun api test for ctripcrawler
-- load library
local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
local md5 = require 'md5'
local zlib = require 'zlib'
local base64 = require 'base64'
local crypto = require 'crypto'

function urlencode(s) return s and (s:gsub("[^a-zA-Z0-9.~_-]", function (c) return string.format("%%%02x", c:byte()); end)); end
function urldecode(s) return s and (s:gsub("%%(%x%x)", function (c) return char(tonumber(c,16)); end)); end

local data = "cac:a54c7a3b89fe377803a3efa30af43d8e::::::::::avhids,8fed80908d9683600e1d30f2a64006f2,8fed80908d9683600e1d30f2a64006f2"
-- print(table.getn(data))
-- sk & ak from baidu
-- local ak = "8fed80908d9683600e1d30f2a64006f2"
-- local sk = "8047E3D8b60e2887d1d866b4b12028c6"
local tsproxy = "http://10.123.77.144:8088"
local tkey = 20130101;

local cl = string.len(data)
local filet = os.time();
-- api post file.
local respup = {};
local timestamp = os.date("%a, %d %b %Y %X GMT", os.time() - 8*60*60)
local requri = "/biyifei/intl/itour/" .. tkey .. "/BJS/LON/" .. filet .. ".json";
-- local obj = "/intl/itour/" .. tkey .. "BJS/LON/" .. filet .. ".json";
-- local requri = "/besftly/dom/ctrip/" .. tkey .. "/" .. org .. dst .. "/" .. filet .. ".json";
-- local Content= "MBO" .. "\n" .. "Method=PUT" .. "\n" .. "Bucket=bestfly" .. "\n" .. "Object=" .. obj .. "\n"
-- local Signature = urlencode(base64.encode(crypto.hmac.digest('sha1', Content, sk, true)));
local sign = md5.sumhexa("PUT&" .. requri .. "&" .. timestamp .. "&" .. cl .. "&" .. md5.sumhexa("b6x7p6b6x7p6"));
local body, code, headers, status = http.request {
-- local ok, code, headers, status, body = http.request {
	url = "http://v0.api.upyun.com" .. requri,
	-- url = "http://v0.api.upyun.com",
	-- url = "http://localhost:3000/citycns",
	-- url = "http://rhomobi.com:18081/rholog" .. requri,
	-- url = "http://bcs.duapp.com/bestfly" .. obj .. "?sign=MBO:" .. ak .. ":" .. Signature,
	-- proxy = tsproxy,
	--- proxy = "http://127.0.0.1:8888",
	timeout = 4000,
	method = "PUT", -- POST or GET
	-- add post content-type and cookie
	-- headers = { ["Content-Type"] = "application/x-www-form-urlencoded", ["Content-Length"] = string.len(form_data) },
	headers = {
		["Host"] = "v0.api.upyun.com",
		-- ["Host"] = "rhomobi.com",
		["Date"] = timestamp,
		["Connection"] = "keep-alive",
		["Authorization"] = "UpYun buyhome:" .. sign, 
		["Content-Length"] = cl,
		["Mkdir"] = "true",
		-- ["Content-Type"] = "application/json",
		["Content-Type"] = "text/plain"
		-- ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36"
	},
	-- headers = { ["Content-Length"] = cl, ["Content-Type"] = "text/plain" },
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
	print(code)
	print(status)
	print(body)
else
	print(code)
	print(status)
	print(body)
end
-- buyhome <huangqi@rhomobi.com> 20130705 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- price of extension for elong website : http://flight.elong.com/beijing-shanghai/cn_day19.html
-- load library
local JSON = require("cjson");
-- local xml = require("LuaXml");
local redis = require "resty.redis"
local http = require "resty.http"
-- local ltn12 = require "ltn12"
-- originality
local error001 = JSON.encode({ ["resultCode"] = 1, ["description"] = "No response because you has inputted error"});
local error002 = JSON.encode({ ["resultCode"] = 2, ["description"] = "Get cityDicts from ctrip.com is no response"});
-- function
function error003 (mes)
	local res = JSON.encode({ ["resultCode"] = 3, ["description"] = mes});
	return res
end
-- cancel chinese check of function
function urlencode(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str
end
function urldecode(str)
  str = string.gsub (str, "+", " ")
  str = string.gsub (str, "%%(%x%x)",
      function(h) return string.char(tonumber(h,16)) end)
  str = string.gsub (str, "\r\n", "\n")
  return str
end
-- function urlencode(s) return s and (s:gsub("[^a-zA-Z0-9.~_-]", function (c) return string.format("%%%02x", c:byte()); end)); end
-- function urldecode(s) return s and (s:gsub("%%(%x%x)", function (c) return char(tonumber(c,16)); end)); end
-- function end
-- ready to connect to master redis.
local red, err = redis:new()
if not red then
	ngx.say("failed to instantiate main redis: ", err)
	return
end
--[[
local ota, err = redis:new()
if not red then
	ngx.say("failed to instantiate otas redis: ", err)
	return
end
--]]
-- lua socket timeout
-- Sets the timeout (in ms) protection for subsequent operations, including the connect method.
red:set_timeout(1000) -- 1 sec
-- ota:set_timeout(1000) -- 1 sec
-- nosql connect
local ok, err = red:connect("127.0.0.1", 6388)
if not ok then
	ngx.say("failed to connect main redis: ", err)
	return
end
--[[
local ok, err = ota:connect("10.124.20.131", 6389)
if not ok then
	ngx.say("failed to connect otas redis: ", err)
	return
end
--]]
-- end of nosql init.
-- service main
if ngx.var.request_method == "GET" then
	local s = ngx.var.qkey
	local hid = ngx.encode_base64(s)
	local hks = ngx.var.char .. ":" .. string.sub(hid, 1, 1)
	-- hid = ngx.md5(hid)
	local res, err = red:hget("dict:" .. hks, hid)
	if not res then
		ngx.say(error003("failed to hget the dictidxs of the query dict:[dict:" .. hid .. "]", err));
		return
	else
		if res ~= JSON.null then
			ngx.print(ngx.decode_base64(res))
		else
			-- cancel chinese check
			local xff80 = string.find(s,"[\x80-\xff]");
			if xff80 == 2 then
				-- s = urlencode(ngx.var.qkey)
				local res = ngx.location.capture("/data-utf2gbk/" .. s .. "/");
				if res.status == 200 then
					s = urlencode(res.body);
					-- ngx.say(s)
				end
			end
			local hc = http:new()
			local ok, code, headers, status, body = hc:request {
				url = "http://flights.ctrip.com/international/tools/GetCities.ashx?s=" .. s .. "&a=0&t=" .. ngx.var.char,
				-- url = "http://labs.rhomobi.com:18081/rholog",
				-- proxy = "http://" .. ngx.decode_base64(ngx.var.proxy),
				timeout = 3000,
				method = "GET", -- POST or GET
				-- add post content-type and cookie
				headers = { ["Host"] = "flight.ctrip.com", ["User-Agent"] = "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6"},
				-- body = ltn12.source.string(form_data),
				-- body = form_data,
			}
			if code == 200 and body ~= nil then
				local i = string.find(body, 'Response=');
				if i ~= nil then
					body = string.sub(body, i+9, -1);
					local res, err = red:hset("dict:" .. hks, hid, ngx.encode_base64(body))
					if not res then
						ngx.say(error003("failed to hset the dictidxs of the query dict:[dict:" .. hid .. "]", err));
						return
					end
					ngx.print(body);
				else
					ngx.print(error002);
				end
			else
				ngx.print(error003(code, status))
			end
		end
	end
else
	ngx.exit(ngx.HTTP_FORBIDDEN);
end
-- put it into the connection pool of size 512,
-- with 0 idle timeout
local ok, err = red:set_keepalive(0, 512)
if not ok then
	ngx.say("failed to set keepalive main redis: ", err)
	return
end
--[[
local ok, err = ota:set_keepalive(0, 512)
if not ok then
	ngx.say("failed to set keepalive otas redis: ", err)
	return
end
--]]
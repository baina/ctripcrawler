-- buyhome <huangqi@rhomobi.com> 20130811 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- price of extension for bestfly service ifl's rt type.
-- load library
local JSON = require("cjson");
-- local xml = require("LuaXml");
local redis = require "resty.redis"
local http = require "resty.http"
-- originality
local error001 = JSON.encode({ ["resultCode"] = 1, ["description"] = "No response because you has inputted fltlineID"});
local error002 = JSON.encode({ ["resultCode"] = 2, ["description"] = "Get Price data from more ota with data-uni is no response"});
function error003 (mes)
	local res = JSON.encode({ ["resultCode"] = 3, ["description"] = mes});
	return res
end
-- ready to connect to master redis.
local red, err = redis:new()
if not red then
	ngx.say("failed to instantiate redis: ", err)
	return
end
-- lua socket timeout
-- Sets the timeout (in ms) protection for subsequent operations, including the connect method.
red:set_timeout(1000) -- 1 sec
-- nosql connect
local ok, err = red:connect("127.0.0.1", 6388)
if not ok then
	ngx.say("failed to connect redis: ", err)
	return
end
-- end of nosql init.
if ngx.var.request_method == "GET" then
	local FlightLineID = ngx.var.fltid;
	local org = ngx.var.org;
	local dst = ngx.var.dst;
	local getfidres, getfiderr = red:get("flt:" .. FlightLineID .. ":id")
	if not getfidres then
		ngx.print(error003("failed to get the flt:" .. FlightLineID .. ":id: ", getfiderr));
		return
	end
	-- ngx.print(getfidres);
	-- ngx.print("\r\n---------------------\r\n");
	-- local fltid = tonumber(getfidres)
	if tonumber(getfidres) == nil then
		ngx.print(error001);
		return
	else
		local fltid = tonumber(getfidres);
		local res, err = red:hget("uni:" .. string.upper(org) .. ":" .. string.upper(dst), fltid)
		if not res then
			ngx.print(error003("failed to HGET more OTA Price data: " .. FlightLineID, err));
			return
		else
			if res ~= nil and res ~= JSON.null then
				ngx.print(res);
			else
				ngx.print(error002);
				return
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
	ngx.say("failed to set keepalive redis: ", err)
	return
end
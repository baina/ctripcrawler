-- buyhome <huangqi@rhomobi.com> 20131125 (v0.5.1)
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
local netcommand = "netstat -tnp | grep "redis-ser" | grep -v "grep" | awk -F ' ' '{print $5}'";
if ngx.var.request_method == "GET" then
	local handle = io.popen(netcommand);
	local resw = handle:read("*a");
	handle:close();
	for line in resw:lines() do
		if string.gmatch(line, "172.0.0.1") then
			line = string.gsub(line, "127.0.0.1", "54.254.157.70")
		end
		ngx.say(line .. "\n");
	end
else
	ngx.exit(ngx.HTTP_FORBIDDEN);
end
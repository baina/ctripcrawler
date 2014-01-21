-- buyhome <huangqi@rhomobi.com> 20131208 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- queues service of crawler for bestfly service
-- load library
local JSON = require("cjson");
local redis = require "resty.redis"
local http = require "resty.http"
-- originality
local error001 = JSON.encode({ ["resultCode"] = 1, ["description"] = "No response because you has inputted airports"});
local error002 = JSON.encode({ ["resultCode"] = 2, ["description"] = "Get Prices from extension is no response"});
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
local ok, err = red:connect("10.160.48.211", 6388)
if not ok then
	ngx.say("failed to connect redis: ", err)
	return
end
-- end of nosql init.
-- init the DICT.
-- local byfs = ngx.shared.biyifei;
local port = ngx.shared.airport;
-- local porg = port:get(string.upper(ngx.var.org));
-- local pdst = port:get(string.upper(ngx.var.dst));
local city = ngx.shared.citycod;
-- local torg = city:get(string.upper(ngx.var.org));
-- local tdst = city:get(string.upper(ngx.var.dst));
if ngx.var.request_method == "GET" then
	ngx.exit(ngx.HTTP_FORBIDDEN);
else
	ngx.req.read_body();
	local pcontent = ngx.req.get_body_data();
	-- local puri = ngx.var.URI;
	-- local args = ngx.req.get_headers();
	if pcontent then
		-- ngx.print(pcontent);
		pcontent = JSON.decode(pcontent)
		local qbody = string.lower(pcontent.qbody)
		local otype = pcontent.type
		local qn = pcontent.queues
		local idx = string.find(qn, ":");
		if idx ~= nil then
			-- string.sub(qn, idx+1, -1)
			local rightstr = string.sub(qn, idx+1, -1)
			local leftstr = string.sub(qn, 1, idx-1)
			if string.len(rightstr) ~= 5 then
				ngx.exit(ngx.HTTP_BAD_REQUEST);
			else
				if leftstr ~= "dom" and leftstr ~= "intl" then
					ngx.exit(ngx.HTTP_BAD_REQUEST);
				else
					if leftstr == "dom" then
						qn = "que:dom"
					end
					if leftstr == "intl" then
						qn = "que:intl"
					end
					if tonumber(otype) == 0 then
						local res, err = red:rpush(qn, rightstr .. "/0/" .. qbody);
						if not res then
							ngx.exit(ngx.HTTP_BAD_REQUEST);
						else
							ngx.exit(ngx.HTTP_OK);
						end
					end
					if tonumber(otype) == 1 then		
						local res, err = red:lpush(qn, rightstr .. "/1/" .. qbody);
						if not res then
							ngx.exit(ngx.HTTP_BAD_REQUEST);
						else
							ngx.exit(ngx.HTTP_OK);
						end
					end
				end
			end
		else
			ngx.exit(ngx.HTTP_BAD_REQUEST);
		end
	end
end
-- buyhome <huangqi@rhomobi.com> 20131208 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- queues service of crawler for bestfly service
-- load library
local JSON = require 'cjson'
local base64 = require 'base64'
package.path = "/usr/local/webserver/lua/lib/?.lua;";
local redis = require "resty.redis"
local http = require "resty.http"
local memcached = require "resty.memcached"
local deflate = require "compress.deflatelua"
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
local ok, err = red:connect("127.0.0.1", 6399)
if not ok then
	ngx.say("failed to connect redis: ", err)
	return
end
local r, e = red:auth("142ffb5bfa1-cn-jijilu-dg-a01")
if not r then
    ngx.say("failed to authenticate: ", e)
    return
end
local memc, err = memcached:new()
if not memc then
    ngx.say("failed to instantiate memc: ", err)
    return
end
memc:set_timeout(1000) -- 1 sec
local ok, err = memc:connect("127.0.0.1", 1978)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end
-- end of nosql init.
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
		-- local qbody = string.lower(pcontent.qbody)
		qbody = pcontent.qbody;
		local otype = pcontent.type
		local qn = string.lower(pcontent.queues)
		local idx = string.find(qn, ":");
		if idx ~= nil then
			-- string.sub(qn, idx+1, -1)
			local rightstr = string.sub(qn, idx+1, -1)
			local dt = string.sub(qn, idx+3, -1)
			local leftstr = string.sub(qn, 1, idx-1)
			if string.len(rightstr) ~= 5 then
				--queues name must be czflt or czpsg
				ngx.exit(ngx.HTTP_BAD_REQUEST);
			else
				if leftstr ~= "dip" then
					--queues name leftstr must be "dip:"
					ngx.exit(ngx.HTTP_BAD_REQUEST);
				else
					--memc data
					local tqdata = rightstr .. "/" .. otype .. "/" .. qbody
					--init ckiNodeKey
					local tk = "";
					-- base64 & gzip
					local data = base64.decode(qbody);
					-- local data = ngx.decode_base64(qbody);
					local output = {}
					deflate.gunzip {
					  input = data,
					  output = function(byte) output[#output+1] = string.char(byte) end
					}
					data = table.concat(output)
					local resjson = JSON.decode(data)
					local timestamp = resjson.version
					if dt ~= "flt" then
						--psg data type
						local lens = table.getn(resjson.ckiPsgSegInfoList)
						if lens ~= 1 then
							for k = 1, lens do
								tk = tk .. resjson.ckiPsgSegInfoList[k].ckiNodeKey
							end
						else
							tk = resjson.ckiPsgSegInfoList[1].ckiNodeKey
						end
					else
						--flt data type
						tk = resjson.ckiNodeKey
					end
					-- local sortkey = base64.encode(tk);
					local sortkey = ngx.md5(tk) .. string.sub(ngx.encode_base64(tk), 1, 6);
					local tscres, err = red:zscore("dip:vals:" .. dt, sortkey)
					if tonumber(tscres) ~= nil then
						if timestamp > tscres then
							local res, err = red:zadd("dip:vals:" .. dt, timestamp, sortkey)
							if not res then
								ngx.print("failed to zadd tk into dip:vals: " .. dt, tk, sortkey)
								return
							end
							local ok = memc:replace(ngx.md5(tk), tqdata)
							if not ok then
								ngx.print("failed to replace qbody originality DATA: ", tk, ngx.md5(tk))
								return
							else
								local tmp, trr = red:lrem("dip:list", 0, ngx.md5(tk))
								local res, err = red:rpush("dip:list", ngx.md5(tk))
								if not res or not tmp then
									ngx.print("failed to rpush tk into dip:list", err)
									return
								else
									ngx.print("sucess to replace: " .. tk);
								end
							end
						else
							ngx.print("nothing to do..for: " .. tk);
							-- return--don't cancel
						end
					else
						local res, err = red:zadd("dip:vals:" .. dt, timestamp, sortkey)
						if not res then
							ngx.print("failed to zadd tk into dip:vals: " .. dt, tk, sortkey)
							return
						end
						local ok = memc:set(ngx.md5(tk), tqdata)
						if not ok then
							ngx.print("failed to set qbody originality DATA: ", tk, ngx.md5(tk))
							return
						else
							local res, err = red:rpush("dip:list", ngx.md5(tk))
							if not res then
								ngx.print("failed to rpush tk into dip:list", err)
								return
							else
								ngx.print("sucess to add: " .. tk);
							end
						end
					end
				end
			end
		else
			ngx.exit(ngx.HTTP_BAD_REQUEST);
		end
	end
end
-- put it into the connection pool of size 512,
-- with 0 idle timeout
local ok, err = red:set_keepalive(0, 512)
if not ok then
	ngx.say("failed to set keepalive redis: ", err)
	return
end
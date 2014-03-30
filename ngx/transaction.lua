-- buyhome <huangqi@travelsky.com> 20140328 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- Redis transaction for dip of travelsky
-- load library
local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
local md5 = require 'md5'
local base64 = require 'base64'
package.path = "/usr/local/webserver/lua/lib/?.lua;";
-- pcall(require, "luarocks.require")
local deflate = require 'compress.deflatelua'
local redis = require 'redis'
local master = {
    host = '192.168.137.191',
    port = 6389,
}
local slave = {
    host = '127.0.0.1',
    port = 6399,
}
local client = redis.connect(master)
local slavec = redis.connect(slave)
-- local authok, autherr = slavec:auth("142ffb5bfa1-cn-jijilu-dg-a01")
-- print(authok, autherr)--true,nil
local authok = slavec:auth("142ffb5bfa1-cn-jijilu-dg-a01")
if not authok then
	print("Redis for slave auth failure: ", authok)
	return
end
client:select(0) -- for testing purposes
slavec:select(0) -- for testing purposes
-- commands defined in the redis.commands table are available at module
-- level and are used to populate each new client instance.
redis.commands.hset = redis.command('auth')
redis.commands.hset = redis.command('hset')
redis.commands.sadd = redis.command('sadd')
redis.commands.zadd = redis.command('zadd')
redis.commands.smembers = redis.command('smembers')
redis.commands.keys = redis.command('keys')
redis.commands.sdiff = redis.command('sdiff')
redis.commands.zrange = redis.command('zrange')
redis.commands.zrank = redis.command('zrank')
-- local memcached = require "resty.memcached"
require 'luamemcached.Memcached'
local memc = Memcached.Connect("127.0.0.1", 1978)
if not memc then
    print("failed to connect tt SRV: ", err)
    return
end
function sleep(n)
   socket.select(nil, nil, n)
end
local i = 0;
local j = 0;
local op = 0;
local begin = os.time();
local idxs = client:llen("que:dip")
-- local idxs = table.getn(data)
print(idxs)
print("--------------")
function totalres(begin, idxs, op)
	local over = os.time();
	local edxs = client:llen("que:dip")
	-- local edxs = table.getn(data)
	local done = idxs - edxs
	local times = over - begin
	print("+++++++Total Read+++++++")
	print(done, times, done/times)
	print("++++++++++++++++++++++++++")
	print("+++++++Total Write+++++++")
	print(op, times, op/times)
	print("++++++++++++++++++++++++++")
end
-- main
while true do
	local tk = "";
	local tv = "";
	data = client:lpop("que:dip")
	tv = data;
	-- print(data)
	local dt = string.sub(data, 3, 5)
	print(dt)
	print("--------------")
	data = string.sub(data, 9, -1)
	data = base64.decode(data)
	local output = {}
	deflate.gunzip {
	  input = data,
	  output = function(byte) output[#output+1] = string.char(byte) end
	}
	data = table.concat(output)
	print(data)
	local resjson = JSON.decode(data)
	local timestamp = resjson.version
	if timestamp == nil or timestamp == JSON.null then
		print(JSON.null)
		break;
	else
		print(timestamp)
		print("--------------")
		if dt ~= "flt" then
			local lens = table.getn(resjson.ckiPsgSegInfoList)
			if lens ~= 1 then
				print("--------------")
				print(JSON.encode(resjson.ckiPsgSegInfoList))
				print("--------------")
				print(resjson.ckiNodeKey, i, j, lens);--当ckiPsgSegInfoList>1外侧ckiNodeKey仍然为空
				for k = 1, lens do
					tk = tk .. resjson.ckiPsgSegInfoList[k].ckiNodeKey
					print(resjson.ckiPsgSegInfoList[k].ckiNodeKey)
					print("++++++")
				end
				-- break;
			else
				tk = resjson.ckiPsgSegInfoList[1].ckiNodeKey
				print(resjson.ckiPsgSegInfoList[1].ckiNodeKey)
				print("--------------")
				i = i + 1;
				print(i)
			end
		else
			-- print(dt)
			-- print("--------------")
			print("--------------")
			j = j + 1;
			print(j)
			tk = resjson.ckiNodeKey
			if tk ~= nil and tk ~= JSON.null then
				print(tk)
			else
				break;
			end
			-- break;
		end
		local res, err = slavec:rpush("dip:list:" .. dt, md5.sumhexa(tk))
		-- op = op + 1;
		if not res then
			print("failed to rpush tk into dip:list: ", err)
			break;
		end
		local res, err = client:sadd("dip:sets:" .. dt, tk)
		op = op + 1;
		if res == nil then
			break;
		end
		local res, err = slavec:zadd("dip:vals:" .. dt, tonumber(timestamp), tk)
		-- op = op + 1;
		if not res then
			print("failed to zadd tk into dip:vals: ", err)
			break;
		end
		local ok = memc:set(md5.sumhexa(tk), tv)
		op = op + 1;
		if not ok then
			print("failed to set tv originality DATA: ", tk)
			break;
		end
		-- if i > 10 or j > 10 then
		if op > 10000 then
			break;
		end
	end
end
totalres(begin, idxs, op)

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
package.path = "/usr/local/webserver/lua/lib/?.lua;";
-- pcall(require, "luarocks.require")
-- local deflate = require 'compress.deflatelua'
local redis = require 'redis'
local master = {
    host = '127.0.0.1',
    port = 6389,
}
local client = redis.connect(master)
local authok = client:auth("142ffb5bfa1-cn-jijilu-dg-a01")
if not authok then
	print("Redis for Master auth failure: ", authok)
	return
end
client:select(0) -- for testing purposes
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
redis.commands.rename = redis.command('rename')
redis.commands.exists = redis.command('exists')
function sleep(n)
   socket.select(nil, nil, n)
end
local tc = "/usr/local/bin/lua /data/www/transaction.lua"
local bolexi = 1
while bolexi ~= 0 do
	client:rename("dip:list", "dip:que")
	bolexi = client:exists("dip:list")
end	
while true do
	local res = os.execute(tc)
	if res ~= 0 then
		print("-----(Errorhappen)-----")
		print(res, type(res))
		-- break;
		sleep(30)
	else
		print("-----(echo result)-----")
		print(res)
		break;
	end
end
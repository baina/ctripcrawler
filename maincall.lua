-- buyhome <huangqi@rhomobi.com> 20130705 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- price of agent for elong website : http://flight.elong.com/beijing-shanghai/cn_day19.html
-- load library
local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
function sleep(n)
   socket.select(nil, nil, n)
end
local url = "http://rhosouth001/task-queues/intl/1/";
while url do
	local body, code, headers = http.request(url)
	if code == 200 then
		-- print(JSON.decode(body).taskQueues[1]);
		if JSON.decode(body).resultCode == 0 then
			local arg = JSON.decode(body).taskQueues[1];
			local xarg = string.sub(arg, 3, -1);
			local xcmd = "/usr/local/bin/lua /data/rails2.3.5/itourcrawler/domup.lua " .. xarg;
			arg = string.gsub(xarg, "bjs", "bbb")
			arg = string.gsub(arg, "sha", "sss")
			arg = string.gsub(arg, "sia", "xiy")
			print(arg)
			print("-------------")
			local cmd = "/usr/local/bin/lua /data/rails2.3.5/itourcrawler/dombae.lua " .. arg .. " " .. "127.0.0.1:8088";
			-- local cmd = "/usr/local/bin/lua /data/rails2.3.5/itourcrawler/dombae.lua " .. arg;
			os.execute(cmd);
			print(xarg)
			print("-------------")
			os.execute(xcmd);
			--[[
			while true do
				local ok, err = client:rpush("price:comb", arg)
				if ok then
					print("----------price:comb ok-----------")
					break;
				end
			end
			local body, code, headers = http.request(dis .. arg)
	                if code == 200 then
				print("---------Distribute sucess-------------")
			else
				print("---------Distribute failer-------------")
			end
			--]]
		else
			print("------------NO mission left-----------")
			sleep(5)
		end
	else
		-- if get no mission sleep 10;
		print("------------NO taskQueues Service-----------")
		sleep(30)
	end
	sleep(0.001)
end
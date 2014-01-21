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
local url = "http://api.bestfly.cn/task-queues/intl/1/";
while url do
	local body, code, headers = http.request(url)
	if code == 200 then
		print(body)
		-- print(JSON.decode(body).taskQueues[1]);
		if JSON.decode(body).resultCode == 0 then
			local arg = JSON.decode(body).taskQueues[1];
			local fail = string.sub(arg, -1, -1);
			print(arg, fail, tonumber(fail))
			-- drop over 3 fails
			if tonumber(fail) > 3 then
				print("++ Droped " .. arg .. " -has failure over 3 ++");
				-- return
			else
				local sourcename = string.sub(arg, 1, 5);
				local xarg = string.sub(arg, 9, -1);
				print("++++++++++++++++")
				print(xarg, string.len(xarg))
				print("++++++++++++++++")
				local cmd = "";
				if sourcename ~= "ctrip" then
					cmd = "/usr/local/bin/node /tmp/" .. sourcename .. "/get.js " .. xarg;
				else
					if string.len(xarg) == 27 then
						-- print("RT")
						cmd = "/usr/local/bin/lua /tmp/ctripcrawler/intlrt.lua " .. xarg;
					end
					if string.len(xarg) == 18 then
						-- print("OW")
						cmd = "/usr/local/bin/lua /tmp/ctripcrawler/intlow.lua " .. xarg;
					end
				end
				os.execute(cmd);
			end
		else
			print("------------NO mission left-----------")
			sleep(8)
		end
	else
		-- if get no mission sleep 10;
		print("------------NO taskQueues Service-----------")
		sleep(30)
	end
	sleep(0.001)
end

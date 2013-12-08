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
			local cmd = "";
			if string.len(xarg) == 26 then
				-- print("RT")
				cmd = "/usr/local/bin/lua /tmp/ctripcrawler/intlrt.lua " .. xarg;
			end
			if string.len(xarg) == 17 then
				-- print("OW")
				cmd = "/usr/local/bin/lua /tmp/ctripcrawler/intlow.lua " .. xarg;
			end
			os.execute(cmd);
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
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
function retry(mission)
	local queuesurl = "http://case.139jia.com/task/www/";
	local md5uri = "index.php?/task/logerr";
	-- local sinakey = "5P826n55x3LkwK5k88S5b3XS4h30bTRg";
	print("--------------")
	print(queuesurl .. md5uri, mission);
	print("--------------")
	-- init response table
	local resp = {};
	-- local body, code, headers = http.request(baseurl .. md5uri)
	local body, code, headers, status = http.request {
	-- local ok, code, headers, status, body = http.request {
		-- url = "http://cloudavh.com/data-gw/index.php",
		url = queuesurl .. md5uri,
		-- proxy = exProxy,
		-- proxy = "http://10.123.74.137:808",
		-- proxy = "http://" .. tostring(arg[2]),
		timeout = 10000,
		method = "POST", -- POST or GET
		-- add post content-type and cookie
		headers = {
			["Host"] = "case.139jia.com",
			-- ["SOAPAction"] = "http://ctrip.com/Request",
			["Cache-Control"] = "no-cache",
			-- ["Auth-Timestamp"] = filet,
			-- ["Auth-Signature"] = md5.sumhexa(sinakey .. filet),
			-- ["Accept-Encoding"] = "gzip",
			-- ["Accept"] = "*/*",
			["Connection"] = "keep-alive",
			-- ["Content-Type"] = "text/xml; charset=utf-8",
			["Content-Length"] = string.len(mission)
		},
		-- body = formdata,
		-- source = ltn12.source.string(form_data);
		source = ltn12.source.string(mission),
		sink = ltn12.sink.table(resp)
	}
	if code == 200 then
		return code
	else
		return 400
	end
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
				local sourcename = string.sub(arg, 1, 5);
				local xarg = string.sub(arg, 9, -1);
				print("++++++++++++++++")
				print(xarg, string.len(xarg))
				print("++++++++++++++++")
				local todo = JSON.encode({ ["type"] = 0, ["queues"] = "intl:" .. sourcename, ["qbody"] = xarg });
				local code = retry(todo)
				print(code)
				-- return
			else
				local sourcename = string.sub(arg, 1, 5);
				local xarg = string.sub(arg, 9, -1);
				print("++++++++++++++++")
				print(xarg, string.len(xarg))
				print("++++++++++++++++")
				local cmd = "";
				if sourcename ~= "ctrip" then
					cmd = "/usr/local/bin/node /mnt/data/iflbase/" .. sourcename .. "/get.js " .. xarg;
				else
					if string.len(xarg) == 27 then
						-- print("RT")
						cmd = "/usr/local/bin/lua /mnt/data/iflbase/ctripcrawler/intlrt.lua " .. xarg;
					end
					if string.len(xarg) == 18 then
						-- print("OW")
						cmd = "/usr/local/bin/lua /mnt/data/iflbase/ctripcrawler/intlow.lua " .. xarg;
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

-- buyhome <huangqi@rhomobi.com> 20131114 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/
-- price agent of extension for bestfly service
local socket = require 'socket'
local http = require 'socket.http'
local JSON = require 'cjson'
function sleep(n)
   socket.select(nil, nil, n)
end
function date2time(tkey)
	return os.time({year=string.sub(tkey, 1, 4), month=tonumber(string.sub(tkey, 5, 6)), day=tonumber(string.sub(tkey, 7, 8)), hour="00"})
end
-- load internationalcityhasline.ini
local cnintl = io.open("/data/rails2.3.5/ctripcrawler/internationalcityhasline.ini", "r");
local linetmp = {};
for line in cnintl:lines() do
	table.insert(linetmp, line);
end
io.close(cnintl);
local len = table.getn(linetmp)
local lkey = {};
local i = 1;
while i <= len do
	local j = date2time(20140301);
	while j <= date2time(20140531) do
		local arg = linetmp[i] .. "/" .. os.date("%Y%m%d", j) .. "/";
		local cmd = "/usr/local/bin/lua /data/rails2.3.5/ctripcrawler/intlow.lua " .. arg;
		os.execute(cmd);
		while true do
			local eof = false;
			local k = j+86400;
			if k > date2time(20140601) then
				break;
			end
			while k <= j+180*86400 do
                cmd = "/usr/local/bin/lua /data/rails2.3.5/ctripcrawler/intlrt.lua " .. arg .. os.date("%Y%m%d", k) .. "/";
                os.execute(cmd);
				k = k + 86400;
				if k > date2time(20140601) then
					eof = true;
					break;
				end
			end
			if eof == true then
				break;
			end
		end
		j = j + 86400;
		sleep(0.1)
	end
	i = i + 1;
end

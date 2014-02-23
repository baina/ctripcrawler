-- buyhome <huangqi@rhomobi.com> 20130511 (v0.5.1)
-- License: same to the Lua one
-- TODO: copy the LICENSE file
-------------------------------------------------------------------------------
-- begin of the idea : http://rhomobi.com/topics/150
local prdata = ([=[
<?xml version="1.0" encoding="UTF-8"?>
<SyncAppOrderReq xmlns="http://www.monternet.com/dsmp/schemas/">
<TransactionID>CSSP13225174</TransactionID>
<MsgType>SyncAppOrderReq</MsgType>
<Version>1.0.0</Version>
<Send_Address>
<DeviceType>200</DeviceType>
<DeviceID>CSSP</DeviceID>
</Send_Address>
<Dest_Address>
<DeviceType>1002</DeviceType>
<DeviceID>f0_0</DeviceID>
</Dest_Address>
<OrderID>11140120112439589068</OrderID>
<CheckID>0</CheckID>
<ActionTime>20140120112439</ActionTime>
<ActionID>1</ActionID>
<MSISDN></MSISDN>
<FeeMSISDN>11543E6565EF7149</FeeMSISDN>
<AppID>300007806339</AppID>
<PayCode>30000780633902</PayCode>
<TradeID>D8D7DC946751EED0E44F54905FCCA849</TradeID>
<Price>500</Price>
<TotalPrice>500</TotalPrice>
<SubsNumb>1</SubsNumb>
<SubsSeq>1</SubsSeq>
<ChannelID>0000000000</ChannelID>
<ExData>wx390|1600400</ExData>
<OrderType>0</OrderType>
<MD5Sign>1093BD7346EFD9C411D67276AFBB6AD9</MD5Sign>
<OrderPayment>1</OrderPayment>
</SyncAppOrderReq>
]=])
-- Rholog interface
function parseargs(s)
  local arg = {}
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    arg[w] = a
  end)
  return arg
end
function collect(s)
  local stack = {}
  local top = {}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
    elseif c == "" then   -- start tag
      top = {label=label, xarg=parseargs(xarg)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[#stack]
      if #stack < 1 then
        error("nothing to close with "..label)
      end
      if toclose.label ~= label then
        error("trying to close "..toclose.label.." with "..label)
      end
      table.insert(top, toclose)
    end
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    error("unclosed "..stack[#stack].label)
  end
  return stack[1]
end
-- main
-- TransactionID、OrderID、FeeMSISDN、TradeID
if prdata then
	local pr_xml = collect(prdata);
	-- print(pr_xml[1])
	-- print(table.getn(pr_xml[2]))
	local SyncReq = {};
	local check = "";
	for i = 1, table.getn(pr_xml[2]) do
		local tmpxml = pr_xml[2][i]
		print(tmpxml["label"])
		if tmpxml["label"] == "MsgType" then
			check = tmpxml[1]
		end
		if tmpxml["label"] == "TransactionID" then
			SyncReq["TransactionID"] = tmpxml[1]
		end
		if tmpxml["label"] == "OrderID" then
			SyncReq["OrderID"] = tmpxml[1]
		end
		if tmpxml["label"] == "FeeMSISDN" then
			SyncReq["FeeMSISDN"] = tmpxml[1]
		end
		if tmpxml["label"] == "TradeID" then
			SyncReq["TradeID"] = tmpxml[1]
		end
	end
end

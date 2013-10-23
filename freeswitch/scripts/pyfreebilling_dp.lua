--# Copyright 2013 Mathias WOLFF
--# This file is part of pyfreebilling.
--# 
--# pyfreebilling is free software: you can redistribute it and/or modify
--# it under the terms of the GNU General Public License as published by
--# the Free Software Foundation, either version 3 of the License, or
--# (at your option) any later version.
--# 
--# pyfreebilling is distributed in the hope that it will be useful,
--# but WITHOUT ANY WARRANTY; without even the implied warranty of
--# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--# GNU General Public License for more details.
--# 
--# You should have received a copy of the GNU General Public License
--# along with pyfreebilling.  If not, see <http://www.gnu.org/licenses/>

-----------------------------------------------
--        WHOLESALE SCRIPT
-----------------------------------------------

-----------------------------------------------
-----------------------------------------------
--        FUNCTIONS
-----------------------------------------------
-----------------------------------------------

-----------------------------------------------
-----------------------------------------------
--        HANGUP
-----------------------------------------------
-----------------------------------------------
function myHangupHook(s, status, arg)
  obCause = session:hangupCause()
  log("Hangup cause :", obCause)
  exit()
end

-----------------------------------------------
-----------------------------------------------
--        LOG
-----------------------------------------------
-----------------------------------------------
function log(name, logval, level, getvar)
  local level = level or "info"
  local getvar = getvar or "0"
  if getvar == "0" then
    freeswitch.consoleLog(level, "------->" .. channel["uuid"] .. " - WS CALL " .. name .. ".....: " .. tostring(logval) .. "<-------------\n");
  else
    freeswitch.consoleLog(level, "-------> uuid is null - WS CALL " .. name .. ".....: " .. tostring(logval) .. "<-------------\n");
  end
end
-----------------------------------------------
-----------------------------------------------
--        GRAB SESSION VARIABLES
-----------------------------------------------
-----------------------------------------------
function get_Variable(call_var)
  local value = session:getVariable(call_var)
  if value then
    log("Got value : ", call_var .. "  :  " .. tostring(value), "debug", 1)
  else
    log("Variable : not set ", call_var, "debug", 1)
  end

  return value
end
-----------------------------------------------
-----------------------------------------------
--        SET SESSION VARIABLES
-----------------------------------------------
-----------------------------------------------
function set_variable(call_var, value, default)
  local message
  if value then
    message = "Set value :"
  else
    value = default
    message = "Set value to default: "
  end
  session:setVariable(call_var, value)
  log(message, call_var.." "..tostring(value), "debug")
end
-----------------------------------------------
-----------------------------------------------
--        EXECUTE DIALPLAN APP
-----------------------------------------------
-----------------------------------------------
function execute(application, data)
  local application = application
  local data = data or ""
  if application then
    log("Executing dialplan application : ", application.." - "..data)
    session:execute(application, data)
  end
end
-----------------------------------------------
-----------------------------------------------
--        CALLER PRIVACY HEADER
-----------------------------------------------
-----------------------------------------------
function set_privacy(privacy)
  if privacy then
    set_variable("cid_type", "none")
    set_variable("sip_h_Privacy", "id")
  else
    set_variable("cid_type", "none")
    set_variable("sip_h_Privacy", "none")
  end
end    
-----------------------------------------------
-----------------------------------------------
function SessionHangupHook(s, status, arg)
  freeswitch.consoleLog("INFO", "wholesale: Call ended! " .. status .. "\n")
  assert(dbh:release())
end
-----------------------------------------------
-----------------------------------------------
local function sv(key, val)
  if session then
    session:setVariable(key, val)
  elseif stream then
    stream:write(string.format("%25s : %s\n", key, val))
  else -- a script executed using luarun does not have a stream
    print(key .. " : " .. val)
  end
end
-----------------------------------------------
-----------------------------------------------
function hangup_call(code, phrase, cause)
  assert(dbh:release())
  session:hangup()
end
-----------------------------------------------
-----------------------------------------------
--        SCRIPT START
-----------------------------------------------
-----------------------------------------------
-----------------------------------------------
--        GET CHANNEL VARIABLES
-----------------------------------------------
--session:execute("info", "")
--session:setHangupHook("myHangupHook")
channel = {}
if session:ready() then
  channel["uuid"] = get_Variable("uuid")
  channel["context"] = get_Variable("context")
  channel["accountcode"] = get_Variable("accountcode")
  channel["user_name"] = get_Variable("user_name")
  channel["sip_authorized"] = get_Variable("sip_authorized")
  channel["destination_number"] = get_Variable("destination_number")
  channel["caller_id_number"] = get_Variable("caller_id_number")
  channel["caller_id_name"] = get_Variable("caller_id_name")
  channel["direction"] = get_Variable("direction")
  channel["session_id"] = get_Variable("session_id")
  channel["sip_from_user"] = get_Variable("sip_from_user")
  channel["sip_received_ip"] = get_Variable("sip_received_ip")
  channel["sip_acl_authed_by"] = get_Variable("sip_acl_authed_by")
  channel["sip_network_ip"] = get_Variable("sip_network_ip")
  channel["auth_acl"] = get_Variable("auth_acl")
  channel["sip_user_agent"] = get_Variable("sip_user_agent")
  if channel["sip_user_agent"] then
    log("Sip_user_agent :", "is OK", "debug")
  else 
    channel["sip_user_agent"] = "not set"
  end
--  channel["FreeSWITCH-IPv4"] = get_Variable("FreeSWITCH-IPv4")
--  channel["FreeSWITCH-Switchname"] = get_Variable("FreeSWITCH-Switchname")
  log("Get session variable :", "done", "debug")
  set_variable("customer", channel["accountcode"])
  set_variable("user_agent", channel["sip_user_agent"])
  set_variable("customer_ip", channel["sip_received_ip"])
  set_variable("cost_rate", "0.000000")
  set_variable("sell_rate", "0.000000")
  set_variable("init_block", "0.000000")
  set_variable("sell_increment", "0")
  set_variable("originating_leg_uuid", channel["uuid"])

  channel["customer_codecs"] = get_Variable("customer_codecs")
  if (channel["customer_codecs"] == "ALL" or channel["customer_codecs"] == nil or channel["customer_codecs"] == "") then
    log("All client codecs", "", "debug")
  else
    log("specific customer codecs", "", "debug")
    channel["ep_codec_string"] = get_Variable("ep_codec_string")
    if ((string.find(channel["ep_codec_string"], 'G729') and string.find(channel["customer_codecs"], 'G729')) or (string.find(channel["ep_codec_string"], 'PCMA') and string.find(channel["customer_codecs"], 'PCMA')) or (string.find(channel["ep_codec_string"], 'PCMU') and string.find(channel["customer_codecs"], 'PCMU'))) then
      log("codec leg A match with customer codec", "", "info")
      execute("export", "nolocal:absolute_codec_string="..channel["customer_codecs"])
    else
      set_variable("proto_specific_hangup_cause", "PFB_CUSTOMER_CODEC_ERROR")
      log("codec leg A mismatch with customer codec!","Exiting","info")
      session:hangup("BEARERCAPABILITY_NOTAVAIL")
      return
    end
  end

end

-----------------------------------------------
--        DATABASE CONNECTION
-----------------------------------------------
if session:ready() then
  if channel["sip_authorized"] then
    dbh = freeswitch.Dbh("odbc://freeswitch")
    if dbh:connected() == false then
      set_variable("proto_specific_hangup_cause", "PFB_DB_ERROR")
      log("Dbh : ", "Database error - Hangup call", "ERROR")
      session:hangup("BEARERCAPABILITY_NOTAVAIL")
      return
    else
      log("Dbh : ", "Database connected")
    end
  else
    log("Customer not authorized")
    set_variable("proto_specific_hangup_cause", "PFB_NOT_AUTH", "INFO")
    if dbh:connected() == true then
      log("DBH Connected : releasing","","debug")
      assert(dbh:release())
    end
    session:hangup("BEARERCAPABILITY_NOTAVAIL")
    return
  end
end
-----------------------------------------------
--        Get Wholesale Customer Settings
-----------------------------------------------
if session:ready() then
  if (channel["caller_id_number"] == nil or channel["caller_id_number"] =="") then
    channel["caller_id_number"] = "anonymous"
  end
  customer = {}
  custok = 0
  local query_cust_sql = "SELECT c.name AS name, c.prepaid AS prepaid, C.credit_limit AS credit_limit, c.customer_balance AS customer_balance, c.max_calls AS max_calls, cnr.prefix AS prefix, cnr.remove_prefix AS remove_prefix, cnr.add_prefix AS add_prefix , ccnr.remove_prefix AS ccnr_remove_prefix, ccnr.add_prefix AS ccnr_add_prefix, dnr.format_num AS dnr_format_num FROM company c LEFT JOIN customer_norm_rules cnr ON cnr.company_id = c.id AND '" .. channel["destination_number"] .. "' LIKE concat(cnr.prefix,'%') LEFT JOIN customer_cid_norm_rules ccnr ON ccnr.company_id = c.id AND '" .. channel["caller_id_number"] .. "' LIKE concat(ccnr.prefix,'%') LEFT JOIN destination_norm_rules dnr ON '" .. channel["destination_number"] .. "' LIKE concat(dnr.prefix,'%') WHERE c.id='"..channel["accountcode"].."' AND c.customer_enabled = TRUE"
  log("SQL: ", query_cust_sql, "debug")
  assert(dbh:query(query_cust_sql, function(row)
    for key, val in pairs(row) do
      customer[key] = val
    end
    custok = 1
  end))
  log("Customer data - num of records", custok, "debug")
  if custok == 0 then
    set_variable("proto_specific_hangup_cause", "PFB_CUSTOMER_NOT_FOUND")
    log("CUSTOMER NOT FOUND!","Exiting")
    session:hangup("BEARERCAPABILITY_NOTAVAIL")
  end
  log("Prepaid / Balance / Credit limit : ".. customer["prepaid"] .." /  ".. tonumber(customer["customer_balance"]) .." / " .. tonumber(customer["credit_limit"]),"")
else
  if dbh:connected() == true then
    log("DBH Connected : releasing","","debug")
    assert(dbh:release())
  end
end

if (session:ready() == true) then 
  if customer["prepaid"] == "0" then
    log("Customer...: postpaid","")
    if tonumber(customer["customer_balance"]) < tonumber(customer["credit_limit"]) then
      set_variable("proto_specific_hangup_cause", "PFB_CUSTOMER_POSTPAID_CREDIT_LIMIT")
      log("CUSTOMER " .. customer["name"] .. " has reach credit limit... rejecting","")
      session:hangup("BEARERCAPABILITY_NOTAVAIL");
    else
      log("Credit limit : ","OK")
    end
  elseif customer["prepaid"] == "1" then
    log("Customer...: prepaid","")
    if tonumber(customer["customer_balance"]) < 0 then
      set_variable("proto_specific_hangup_cause", "PFB_CUSTOMER_PREPAID_NO_MONEY")
      log("CUSTOMER " .. customer["name"] .. " has no money... rejecting","")
      session:hangup("BEARERCAPABILITY_NOTAVAIL")
    else
      log("balance : ","OK")
    end
  end
else
  if dbh:connected() == true then
    log("DBH Connected : releasing","","debug")
    assert(dbh:release())
  end
end
-----------------------------------------------
--        Customer Normalization
-----------------------------------------------
if (session:ready() == true) then
  -- Called Num normalization
  if (customer["remove_prefix"] == "" or customer["remove_prefix"] == nil) then
    customer["remove_prefix"]  = "^"
  end
  if customer["add_prefix"] == nil then
    customer["add_prefix"]  = ""
  end
  channel["destination_number"] = string.gsub(channel["destination_number"], customer["remove_prefix"], customer["add_prefix"], 1)
  set_variable("destination_number", channel["destination_number"])

   -- test format destination number
  if customer["dnr_format_num"] == nil then
    log("Not Destination Number format rule"," : continue","debug")
  else
    if string.match(channel["destination_number"],customer["dnr_format_num"]) == nil then
      set_variable("proto_specific_hangup_cause", "PFB_DESTINATION_NUMBER_WRONG_FORMAT")
      log("Destination number wrong format :","NOK!", "debug")
      session:hangup("UNALLOCATED_NUMBER")
    else
      log("Destination number well formated :","OK!")
    end
  end

  -- CallerID normalization
  log("CallerID Norm - callerID num / rem_prefix / add_prefix : ", channel["caller_id_number"].." / "..customer["ccnr_remove_prefix"].." / "..customer["ccnr_add_prefix"], "debug")
  if (customer["ccnr_remove_prefix"] == "" or customer["ccnr_remove_prefix"] == nil) then
    customer["ccnr_remove_prefix"]  = "^"
  end
  if customer["ccnr_add_prefix"] == nil then
    customer["ccnr_add_prefix"]  = ""
  end
  if (channel["caller_id_number"] == "" or channel["caller_id_number"] == nil) then
    channel["caller_id_number"] = "anonymous"
  else
    channel["caller_id_number"] = string.gsub(channel["caller_id_number"], customer["ccnr_remove_prefix"], customer["ccnr_add_prefix"], 1)
  end
  log("Customer CallerID : ", channel["caller_id_number"])
else
  if dbh:connected() == true then
    log("DBH Connected : releasing","","debug")
    assert(dbh:release())
  end
end

-----------------------------------------------
--        Get Customer Rate
-----------------------------------------------
if (session:ready() == true) then
  rate = {}
  local rateprio = 1
  rateok = 0
  while rateok == 0 do
    log("rateprio / rateok :", rateprio.." / "..rateok)
    if rateprio == 4 then
      break
    else
      local query_rate_sql = "SELECT c.tech_prefix AS tech_prefix, c.ratecard_id AS ratecard_id, c.priority AS priority, c.discount AS discount, c.allow_negative_margin AS allow_negative_margin, rc.lcrgroup_id AS lcrgroup_id, r.destination AS destination, r.prefix AS prefix, lg.name AS lcrgoup, lg.lcrtype AS lcrtype, r.rate AS rate, r.block_min_duration AS block_min_duration, r.init_block AS init_block FROM customer_ratecards c INNER JOIN ratecard rc ON rc.id = c.ratecard_id AND c.company_id = '" .. channel["accountcode"] .. "' AND c.priority = '" .. rateprio .. "' INNER JOIN lcr_group lg ON lg.id = rc.lcrgroup_id INNER JOIN customer_rates r ON rc.id = r.ratecard_id WHERE rc.enabled = TRUE AND r.enabled = true AND now() > r.date_start AND now() < r.date_end AND '" .. channel["destination_number"] .. "' LIKE concat(c.tech_prefix,r.prefix,'%') ORDER BY LENGTH(r.prefix) desc LIMIT 1"
      log("SQL: ", query_rate_sql, "debug")
      assert(dbh:query(query_rate_sql, function(row)
        for key, val in pairs(row) do
          rate[key] = val
        end
        rateok = 1
      end))
      rateprio = rateprio + 1
    end
  end
  log("Customer rate - num of records", rateok, "debug")
  log("Customer rate OK:", rateok)
  if rateok == 0 then
    set_variable("proto_specific_hangup_cause", "PFB_CUSTOMER _RATE_NOT_FOUND")
    log("RATE NOT FOUND! : ", "Exiting")
    session:hangup("BEARERCAPABILITY_NOTAVAIL")
  else
    rate["rate"] = tonumber(rate["rate"])*(1-tonumber(rate["discount"])/100)
    log("Rate", "OK")
    set_variable("sell_rate", tonumber(rate["rate"]))
    set_variable("sell_increment", rate["block_min_duration"])
    set_variable("prefix", rate["prefix"])
    set_variable("init_block", rate["init_block"])
    set_variable("ratecard_id", rate["ratecard_id"])
    set_variable("lcr_group_id", rate["lcrgroup_id"])
    set_variable("sell_destination", rate["destination"])
  end
    -- test block prefix with rate -1
  if rate["rate"] == -1 then
    log("Blocked prefix ! : ", "Exiting")
    set_variable("proto_specific_hangup_cause", "PFB_CUSTOMER_PREFIX_BLOCKED")
    session:hangup("BEARERCAPABILITY_NOTAVAIL")
  else
    log("non blocked prefix : ", "OK!", "debug")
  end

  -- Destination Number - remove tech prefix
  if (rate["tech_prefix"] == "" or rate["tech_prefix"] == nil) then
    log("No tech prefix : "," continue","debug")
  else
    log("tech prefix : "," remove it","debug")
    channel["destination_number"] = string.gsub(channel["destination_number"], rate["tech_prefix"], "", 1)
    set_variable("destination_number", channel["destination_number"])
  end

else
  if dbh:connected() == true then
    log("DBH Connected : releasing","","debug")
    assert(dbh:release())
  end
end

-----------------------------------------------
--        SELECT LCR TYPE
-----------------------------------------------
if (session:ready() == true) then
  log("LCR Type : ", rate["lcrtype"], "debug")
  if rate["lcrtype"] == "p" then
    ratefilter = "cost_rate ASC"
    log("LCR Type : ", "Price", "debug")
  elseif rate["lcrtype"] == "q" then
    ratefilter = "quality DESC"
    log("LCR Type : ", "Quality", "debug")
  elseif rate["lcrtype"] == "r" then
    ratefilter = "reliability DESC"
    log("LCR Type : ", "Reliability", "debug")
  end
-----------------------------------------------
--        Get LCR / Gateway
-----------------------------------------------
   -- route only on cost rate - other routing purpose to be implemented
  lcrok = 1
  lcr = {}
  lcr_channels = {}
  lcr_gwprefix = {}
  lcr_gwsuffix = {}
  lcr_codec = {}
  lcr_gwname = {}
  lcr_sipcidtype = {}
  lcr_lcrname = {}
  lcr_lcrtype = {}
  lcr_digits = {}
  lcr_destination = {}
  lcr_cost_rate = {}
  lcr_block_min_duration = {}
  lcr_init_block = {}
  lcr_carrier = {}
  lcr_lead_strip = {}
  lcr_tail_strip = {}
  lcr_prefix = {}
  lcr_suffix = {}
  lcr_quality = {}
  lcr_reliability = {}
  lcr_gwid = {}
  lcr_remove_prefix = {}
  lcr_add_prefix = {}
  if rate["allow_negative_margin"] == "1" then
    log("Negative margin allowed","","info")
    negativemargin = " "
  else
    log("Negative margin forbidden","","info")
    negativemargin = " WHERE T.cost_rate < "..tonumber(rate["rate"]).." "
  end
  log("rate_lcrgroup_id : ", rate["lcrgroup_id"], "debug")
  local query_cost_sql = "SELECT * FROM (SELECT DISTINCT ON (pr.provider_tariff_id) s.sip_cid_type AS sip_cid_type, s.channels AS channels, s.prefix AS gwprefix, s.suffix AS gwsuffix, s.codec AS codec, s.name AS gwname, s.id AS gwid, ccnr.remove_prefix, ccnr.add_prefix, pr.destination AS destination, pr.digits AS digits, pr.cost_rate AS cost_rate, pr.block_min_duration AS block_min_duration, pr.init_block AS init_block, pt.carrier_id AS carrier_id, pt.lead_strip AS lead_strip, pt.tail_strip AS tail_strip, pt.prefix AS prefix, pt.suffix AS suffix, pt.quality AS quality, pt.reliability AS reliability FROM lcr_providers lp INNER JOIN provider_tariff pt ON pt.id = lp.provider_tariff_id AND pt.enabled = TRUE AND now() > pt.date_start AND now() < pt.date_end INNER JOIN sofia_gateway s ON s.company_id = pt.carrier_id AND s.enabled = TRUE LEFT JOIN carrier_cid_norm_rules ccnr ON ccnr.company_id = pt.carrier_id INNER JOIN provider_rates pr ON pr.provider_tariff_id = pt.id AND pr.enabled = TRUE AND now() > pr.date_start AND now() < pr.date_end AND '" .. channel["destination_number"] .. "' LIKE concat(pr.digits,'%') WHERE lp.lcr_id = '" .. rate["lcrgroup_id"] .. "' ORDER BY pr.provider_tariff_id, LENGTH(pr.digits) DESC) T"..negativemargin.."ORDER BY " .. ratefilter .. ""
  assert(dbh:query(query_cost_sql, function(row)
    lcr_channels[lcrok] = tonumber(row.channels)
    lcr_gwprefix[lcrok] = row.gwprefix
    lcr_gwsuffix[lcrok] = row.gwsuffix
    lcr_codec[lcrok] = row.codec
    lcr_gwname[lcrok] = row.gwname
    lcr_sipcidtype[lcrok] = row.sip_cid_type
    lcr_lcrname[lcrok] = rate["lcrgroup"]
    lcr_lcrtype[lcrok] = rate["lcrtype"]
    lcr_digits[lcrok] = tonumber(row.digits)
    lcr_destination[lcrok] = row.destination
    lcr_cost_rate[lcrok] = tonumber(row.cost_rate)
    lcr_block_min_duration[lcrok] = tonumber(row.block_min_duration)
    lcr_init_block[lcrok] = tonumber(row.init_block)
    lcr_carrier[lcrok] = row.carrier_id
    lcr_lead_strip[lcrok] = row.lead_strip
    lcr_tail_strip[lcrok] = row.tail_strip
    lcr_prefix[lcrok] = row.prefix
    lcr_suffix[lcrok] = row.suffix
    lcr_quality[lcrok] = row.quality
    lcr_reliability[lcrok] = row.reliability
    lcr_gwid[lcrok] = row.gwid
    lcr_remove_prefix[lcrok] = row.remove_prefix
    lcr_add_prefix[lcrok] = row.add_prefix
    lcrok = lcrok + 1
  end))
  log("SQL: ", query_cost_sql, "debug")
  assert(dbh:release())
  lcrok = lcrok - 1
  log("lcr - num of records", lcrok, "debug")
  if lcrok == 0 then  
    set_variable("proto_specific_hangup_cause", "PFB_PROVIDER_RATE_NOT_FOUND")
    session:hangup("BEARERCAPABILITY_NOTAVAIL")
  else
    log("lcr", "OK")
  end
else
  if dbh:connected() == true then
    log("DBH Connected : releasing","","debug")
    assert(dbh:release())
  end
end
if (session:ready() == true) then  
-----------------------------------------------
--        BRIDGING
----------------------------------------------- 
--  set_variable("effective_caller_id_number", channel["caller_id_number"])
  set_variable("effective_caller_id_name", channel["caller_id_name"])
  set_variable("effective_callee_id_number", channel["destination_number"])
  set_variable("effective_callee_id_name", "_undef_")

  set_variable("bypass_media", "false")
  set_variable("hangup_after_bridge", "true")
--    execute("set", "continue_on_fail=1,2,3,6,25,34,38,41,42,44,47,63,66,403,480,488,500,501,503")
  execute("set", "continue_on_fail=true")
  execute("set", "bypass_media=false")
  execute("sched_hangup", "+3600 alloted_timeout")
  execute("set", "inherit_codec=true")
  execute("set", "disable_hold=true")
--    execute("export", "disable_q850_reason=true")
--    execute("nibblebill", "check")
  mydialbridge = ""
  myvarbridge = ""
  
-- currency start : if no rate setup error message - for that add special variable - and prevent executing failed bridge - new special message : PFB_PROVIDER_RATE_FOUND_BUT_NEGATIVE_MARGIN - if negative margin allow bridge, but alert message !!!
-- start for boucle  
  for i=1,lcrok do
    if lcr_lead_strip[i] == "" then
      lcr_lead_strip[i]  = "^"
    end
--    if lcr_cost_rate[lcrok]
    log("WS CALL strip:", lcr_lead_strip[i])
    log("WS CALL prefix:", lcr_prefix[i])
    log("WS CALL dest number:", channel["destination_number"])
    log("WS CALL gwprefix :", lcr_gwprefix[i])
    called_number = string.gsub(channel["destination_number"], lcr_lead_strip[i], lcr_gwprefix[i]..lcr_prefix[i], 1)
    log("WS CALL CallerID strip prefix:", lcr_remove_prefix[i])
    log("WS CALL CallerID number:", channel["caller_id_number"])
    log("WS CALL CallerID add prefix :", lcr_add_prefix[i]) 
    caller_id = string.gsub(channel["caller_id_number"], lcr_remove_prefix[i], lcr_add_prefix[i], 1)
    log("WS CALL CallerID sent to provider: ", caller_id)
    myvarbridge = "\[sip_from_uri=sip:"..caller_id..",origination_caller_id_number="..caller_id..",origination_caller_id_name="..caller_id..",sip_cid_type="..lcr_sipcidtype[i]..",sell_destination="..rate["destination"]..",cost_destination="..lcr_destination[i]..",sell_rate="..tonumber(rate["rate"])..",sell_increment="..rate["block_min_duration"]..",destination_number="..channel["destination_number"]..",user_agent="..channel["sip_user_agent"]..",customer_ip="..channel["sip_received_ip"]..",nibble_rate="..tonumber(rate["rate"])..",nibble_account="..channel["accountcode"]..",nibble_increment="..rate["block_min_duration"]..",customer="..channel["accountcode"]..",gateway="..lcr_gwid[i]..",cost_rate="..lcr_cost_rate[i]..",prefix="..rate["prefix"]..",init_block="..rate["init_block"]..",block_min_duration="..rate["block_min_duration"]..",lcr_carrier_id="..lcr_carrier[i]..",ratecard_id="..rate["ratecard_id"]..",lcr_group_id="..rate["lcrgroup_id"].."\]"
--      myvarbridge = ""
    log("WS CALL dest num with prefix/suffix/strip : ", called_number)
    log("WS CALL my variables bridge : ", myvarbridge)
    if mydialbridge == "" then
      mydialbridge = myvarbridge.."sofia/gateway/" .. lcr_gwname[i] .. "/" .. called_number
    else
      mydialbridge = mydialbridge.."|" .. myvarbridge .. "sofia/gateway/" .. lcr_gwname[i] .. "/" .. called_number
    end
    log("construction bridge : ", mydialbridge, "debug") 
  end
-- end for boucle
  
  log("BRIDGE EXECUTE:", mydialbridge, "debug")
  execute("bridge", mydialbridge)
  session:hangup()          
end
if dbh:connected() == true then
  log("DBH Connected : releasing","","debug")
  assert(dbh:release())
end
freeswitch.consoleLog("info", "WS CALL -> I am now ending... <-----------\n");

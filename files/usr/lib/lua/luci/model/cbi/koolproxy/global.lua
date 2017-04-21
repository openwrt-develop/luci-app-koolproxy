local a=require"nixio.fs"
local e=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local e=luci.model.uci.cursor()
local n=require"luci.sys"
local d=luci.http
local e
local e="1.7"
local r="koolproxy"
local o,t,e
local v=luci.sys.exec("/usr/share/koolproxy/koolproxy -v")
local s=luci.sys.exec("head -3 /usr/share/koolproxy/data/rules/koolproxy.txt | grep rules | awk -F' ' '{print $3,$4}'")
local u=luci.sys.exec("head -4 /usr/share/koolproxy/data/rules/koolproxy.txt | grep video | awk -F' ' '{print $3,$4}'")
local l=luci.sys.exec("grep -v !x /usr/share/koolproxy/data/rules/koolproxy.txt | wc -l")
local i=luci.sys.exec("cat /usr/share/koolproxy/dnsmasq.adblock | wc -l")
local h=luci.sys.exec("grep -v '^!' /usr/share/koolproxy/data/rules/user.txt | wc -l")

local function is_running(name)
	return luci.sys.call("pidof %s >/dev/null" %{name}) == 0
end

local function get_status(name)
	return is_running(name) and translate("RUNNING") or translate("NOT RUNNING")
end

o=Map(r,translate("koolproxy"),translate("A powerful advertisement blocker. <br /><font color=\"red\">Adblock Plus Host list + koolproxy Blacklist mode runs without loss of bandwidth due to performance issues.<br /></font>"))
--o.template="koolproxy/index"
t=o:section(TypedSection,"global",translate("Running Status"))
t.anonymous=true
e=t:option(DummyValue,"_status",translate("Transparent Proxy"))
e.value=get_status("koolproxy")
t=o:section(TypedSection,"global",translate("Global Setting"))
t.anonymous=true
t.addremove=false
t:tab("base",translate("Basic Settings"))
t:tab("cert",translate("Certificate Management"))
t:tab("weblist",translate("Set Backlist Of Websites"))
t:tab("iplist",translate("Set Backlist Of IP"))
t:tab("customlist",translate("Set Backlist Of custom"))
t:tab("logs",translate("View the logs"))
e=t:taboption("base",Flag,"enabled",translate("Enable"))
e.default=0
e.rmempty=false
e=t:taboption("base",Value, "startup_delay", translate("自启动延时"))
e:value(0, translate("禁用"))
for _, v in ipairs({5, 10, 15, 25, 40}) do
	e:value(v, translate("%u 秒") %{v})
end
e.datatype = "uinteger"
e.default = 0
e.rmempty = false
e=t:taboption("base",ListValue,"filter_mode",translate('Default')..translate("Filter Mode"))
e.default="adblock"
e.rmempty=false
e:value("disable",translate("No Filter"))
e:value("global",translate("Global Filter"))
e:value("adblock",translate("AdBlock Filter"))
e=t:taboption("base",Flag,"adblock",translate("Open adblock"))
e.default=0
e:depends("filter_mode","adblock")
e=t:taboption("base",ListValue,"time_update",translate("Timing update rules"))
for t=0,23 do
	e:value(t,translate("每天"..t.."点"))
end
e.default=0
e.rmempty=false
restart=t:taboption("base",Button,"restart",translate("Manually update the koolproxy rule"))
restart.inputtitle=translate("Update manually")
restart.inputstyle="reload"
restart.write=function()
	--luci.sys.call("/usr/share/koolproxy/koolproxyupdate rules 2>&1 >/dev/null")
	luci.sys.call("/usr/share/koolproxy/koolproxyupdate 2>&1 >/dev/null")
	luci.http.redirect(luci.dispatcher.build_url("admin","services","koolproxy"))
end

--[[
update=t:taboption("base",Button,"update",translate("程序更新"))
update.inputtitle=translate("Update manually")
update.inputstyle="reload"
update.description=translate(string.format("程序版本：%s", v))
update.inputstyle="reload"
update.write=function()
	luci.sys.call("/usr/share/koolproxy/koolproxyupdate binary 2>&1 >/dev/null")
	luci.http.redirect(luci.dispatcher.build_url("admin","services","koolproxy"))
end
--]]

e=t:taboption("base",DummyValue,"status0",translate("程序版本"))
e.value=string.format("[ %s ]", v)
e=t:taboption("base",DummyValue,"status1",translate("静态规则"))
e.value=string.format("[ %s共 %s条 ]", s, l)
e=t:taboption("base",DummyValue,"status2",translate("视频规则"))
e.value=string.format("[ %s]", u)
e=t:taboption("base",DummyValue,"status3",translate("自定规则"))
e.value=string.format("[ %s]", h)
e=t:taboption("base",DummyValue,"status4",translate("Host规则"))
e.value=string.format("[ %s]", i)
e=t:taboption("cert",DummyValue,"c1status",translate("<div align=\"left\">Certificate Restore</div>"))
e=t:taboption("cert",FileUpload,"")
e.template="koolproxy/caupload"
e=t:taboption("cert",DummyValue,"",nil)
e.template="koolproxy/cadvalue"
if nixio.fs.access("/usr/share/koolproxy/data/certs/ca.crt")then
	e=t:taboption("cert",DummyValue,"c2status",translate("<div align=\"left\">Certificate Backup</div>"))
	e=t:taboption("cert",Button,"certificate")
	e.inputtitle=translate("Backup Download")
	e.inputstyle="reload"
	e.write=function()
		luci.sys.call("/usr/share/koolproxy/camanagement backup 2>&1 >/dev/null")
		Download()
		luci.http.redirect(luci.dispatcher.build_url("admin","services","koolproxy"))
	end
end
local i="/etc/adblocklist/adblock"
e=t:taboption("weblist",TextValue,"configfile")
e.description=translate("These had been joined websites will use filter,but only blacklist model.Please input the domain names of websites,every line can input only one website domain.For example,google.com.")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
	return a.readfile(i)or""
end
e.write=function(t,t,e)
	a.writefile("/tmp/adblock",e:gsub("\r\n","\n"))
	if(luci.sys.call("cmp -s /tmp/adblock /etc/adblocklist/adblock")==1)then
		a.writefile(i,e:gsub("\r\n","\n"))
		luci.sys.call("/usr/sbin/adblock 2>&1 >/dev/null")
	end
	a.remove("/tmp/adblock")
end
local i="/etc/adblocklist/adblockip"
e=t:taboption("iplist",TextValue,"adconfigfile")
e.description=translate("These had been joined ip addresses will use proxy,but only GFW model.Please input the ip address or ip address segment,every line can input only one ip address.For example,112.123.134.145/24 or 112.123.134.145.")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
	return a.readfile(i)or""
end
e.write=function(t,t,e)
	a.writefile(i,e:gsub("\r\n","\n"))
end
local i="/usr/share/koolproxy/data/rules/user.txt"
e=t:taboption("customlist",TextValue,"configfile1")
e.description=translate("Enter your custom rules, each row.")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
	return a.readfile(i)or""
end
e.write=function(t,t,e)
	a.writefile(i,e:gsub("\r\n","\n"))
end
local i="/var/log/koolproxy.log"
e=t:taboption("logs",TextValue,"configfile2")
e.description=translate("Koolproxy Logs")
e.rows=28
e.wrap="off"
e.cfgvalue=function(t,t)
	return a.readfile(i)or""
end
e.write=function(e,e,e)
end
t=o:section(TypedSection,"acl_rule",translate("koolproxy ACLs"),
translate("ACLs is a tools which used to designate specific IP filter mode,The MAC addresses added to the list will be filtered using https"))
t.template="cbi/tblsection"
t.sortable=true
t.anonymous=true
t.addremove=true
e=t:option(Value,"remarks",translate("Client Remarks"))
e.width="30%"
e.rmempty=true
e=t:option(Value,"ipaddr",translate("IP Address"))
e.width="20%"
e.datatype="ip4addr"
n.net.arptable(function(t)
	e:value(t["IP address"])
end)
e=t:option(Value,"mac",translate("MAC Address"))
e.width="20%"
e.rmempty=true
n.net.mac_hints(function(t,a)
	e:value(t,"%s (%s)"%{t,a})
end)
e=t:option(ListValue,"filter_mode",translate("Filter Mode"))
e.width="20%"
e.default="disable"
e.rmempty=false
e:value("disable",translate("No Filter"))
e:value("global",translate("Global Filter"))
e:value("adblock",translate("AdBlock Filter"))
e:value("ghttps",translate("Global Https Filter"))
e:value("ahttps",translate("AdBlock Https Filter"))

--[[
t=o:section(TypedSection,"rss_rule",translate("koolproxy 规则订阅"), translate("请确保Koolproxy兼容规则"))
t.anonymous=true
t.addremove=true
t.sortable=true
t.template="cbi/tblsection"
e=t:option(Value,"name",translate("规则名称"))
e.width="10%"
e.rmempty=false
e=t:option(Value,"url",translate("规则地址"))
e.width="55%"
e.rmempty=false
e.placeholder="[https|http|ftp]://[Hostname]/[File]"
function e.validate(self, value)
	if not value then
		return nil
	else
		return value
	end
end
e=t:option(DummyValue,"time",translate("更新时间"))
e.width="15%"
e=t:option(Flag,"load",translate("启用"))
e.width="10%"
e.default=0
e.rmempty=false
--]]

function Download()
	local t,e
	t=nixio.open("/tmp/upload/koolproxyca.tar.gz","r")
	luci.http.header('Content-Disposition','attachment; filename="koolproxyCA.tar.gz"')
	luci.http.prepare_content("application/octet-stream")
	while true do
		e=t:read(nixio.const.buffersize)
		if(not e)or(#e==0)then
			break
		else
			luci.http.write(e)
		end
	end
	t:close()
	luci.http.close()
end
local t,e
t="/tmp/upload/"
nixio.fs.mkdir(t)
d.setfilehandler(
function(o,a,i)
	if not e then
		if not o then return end
		e=nixio.open(t..o.file,"w")
		if not e then
			return
		end
	end
	if a and e then
		e:write(a)
	end
	if i and e then
		e:close()
		e=nil
		luci.sys.call("/usr/share/koolproxy/camanagement restore 2>&1 >/dev/null")
	end
end
)
return o

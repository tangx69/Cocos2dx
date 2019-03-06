zzy = zzy or {}

zzy.CocosExtra = cc.CocosExtra
zzy.Socket = cc.Socket
zzy.cUtils = cUtils or {}
zzy.Sdk = Sdk


-- tgx
md5 = {}

--苹果用域名
local servertype = 3

--windows和mac用本地
if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() or
   	   cc.PLATFORM_OS_MAC == cc.Application:getInstance():getTargetPlatform() then
	servertype = 1
end

--安卓用ip不用域名
if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
	servertype = 5
end

servertype = 1

if servertype == 1 then --aren
	JSON_URL = "http://gjlogin.hzfunyou.com/dmw/config.json"
	REG_URL = "http://gjlogin.hzfunyou.com:17199/ucenter/register"
	LOGIN_URL = "http://gjlogin.hzfunyou.com:17199/ucenter/login"
	LOGINSVR_URL = "http://gjlogin.hzfunyou.com:17199/ucenter/loginsvr"
elseif servertype == 3 then --release ios
	JSON_URL = "http://gjlogin.hzfunyou.com/dmw/config.json"
	REG_URL = "http://gjlogin.hzfunyou.com:27199/ucenter/register"
	LOGIN_URL = "http://gjlogin.hzfunyou.com:27199/ucenter/login"
	LOGINSVR_URL = "http://gjlogin.hzfunyou.com:27199/ucenter/loginsvr"
elseif servertype == 5 then --release android
	JSON_URL = "http://115.159.66.225/dmw/config.json"
	REG_URL = "http://115.159.66.225:27199/ucenter/register"
	LOGIN_URL = "http://115.159.66.225:27199/ucenter/login"
	LOGINSVR_URL = "http://115.159.66.225:27199/ucenter/loginsvr"
elseif servertype == 4 then --windows链接android服务器，注意同时还需要修改zzy.cUtils.getCustomParam函数返回的渠道号
	JSON_URL = "http://192.168.1.103/dmw/config.json"
	REG_URL = "http://gjlogin.hzfunyou.com:27199/ucenter/register"
	LOGIN_URL = "http://gjlogin.hzfunyou.com:27199/ucenter/login"
	LOGINSVR_URL = "http://gjlogin.hzfunyou.com:27199/ucenter/loginsvr"
end

local config = {}

-- 调试socket开关
config.openSocketDebug = true

-- ui以demo形式显示
config.RUN_DEMO_UI = false

-- 是否连接socket  如果不连接socket需要客户端自己模拟下行 默认状态是开启
--[[
config.linkSocket = true

-- 是否更新资源  true更新 否不更新
config.updateRes = true 

-- 渠道号
config.ChannelID = "1"

-- 最近登录服务器
config.loginsvr = ""

-- 获取服务器信息的地址(默认为公网测服)
--config.URL_SERVER_INFO = "http://dl.dmw.hardtime.zizaiyouxi.com/wdmw/info/serverinfo.json"
config.URL_SERVER_INFO = "JSON_URL" -- tgx

-- authzzy地址
config.authUrl = "http://account.dmw.hardtime.zizaiyouxi.com/login.php"

--是否是生产模式 1为调试模式  0为生产模式
config.debugMode=1

-- linkServer地址
config.linkServerUrl = ""

-- 登陆信息 sign userid等等
config.loginData = {}

config.host = ""
-- 
config.port = 0
-- 
config.svrid = ""

config.svrname = ""

config.url = ""

config.wykey="DMW2016"

--是否显示开发的服务器
config.showDevSer=false

--是否是审批版本  如果包内版本号大于serverinfo的版本号 则为审批版本
config.check=false

--sdk传回的数据
config.data_sdk=""

--登陆验证时传回的数据 tabel结构
config.data_sdk_server=nil

--登陆接口返回的渠道数据 
config.data_channel=""

--cps渠道id
config.cpsid="99900"

--subpack分包号  appstore可能会分成多个包 不同的包读不同的分类
config.subpack=""

--人民币对外币汇率 默认是1
config.exchange_rate=1

--登陆方式  1游客 2官方账号 3 fb
config.loginType=1

-------------------
----读取APP配置----
-------------------
local appConfig = zzy.StringUtils:splitToTable(zzy.cUtils.getAppConfig())
config.debugMode = appConfig.debugMode or config.debugMode
config.subpack = appConfig.subpack or config.subpack
--正式服
config.ChannelID = appConfig.ChannelID or config.ChannelID
config.cpsid = appConfig.cpsid or config.ChannelID
local url="";
if zzy.Sdk.getFlag()=="DEFAULT" then
     url= "http://www.zizaiyx.com/bigdevil/info/serverinfo.json"
else
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if flag=="HD" then
	     if zzy.Sdk.getFlag()=="HDTX" then 
			url="http://dmwcdn.sail2world.com/dmw/"
		 else
			url="http://dl.dmw.hardtime.zizaiyouxi.com/"
		 end
    elseif flag=="WY" or flag=="WE" then
		 url="http://dl-dmw-sail2world.oss-cn-hongkong.aliyuncs.com/"
	elseif flag=="TJ" then
		 url="http://s3.ap-northeast-2.amazonaws.com/swgdmw/"
	elseif flag=="CY" then
		   url="http://hwdmw.changyou.com/"
	end
   
    if config.debugMode==1 then
        url=url.."w"
    end
    url=url.."dmw"
	if flag=="HD" then
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE 
			or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
			if zzy.Sdk.getFlag()=="HDIOS"  then
				url=url.."a"
			elseif zzy.Sdk.getFlag()=="HDXGS" then
				url=url.."g"
			else
				url=url.."i"
			end
		else
			if  zzy.Sdk.getFlag()=="HDTX" then
				url=url.."y"
			end
		end
	elseif flag=="CY" then
		if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE 
			or cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
			url=url.."a"
		end
	elseif flag=="WE" then
		url=url.."e"
	end
    url=url.."/info/bigdevil_"..string.lower(zzy.Sdk.getFlag()) .."-serverinfo.json"
end    
config.URL_SERVER_INFO = url

--config.updateRes = appConfig.update ~= 0
config.URL_SERVER_INFO = config.URL_SERVER_INFO .. "?" .. os.time()

return config 
]]
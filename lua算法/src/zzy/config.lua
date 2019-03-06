local config = {}

-- 调试socket开关
config.openSocketDebug = false

-- ui以demo形式显示
config.RUN_DEMO_UI = false

-- 是否连接socket  如果不连接socket需要客户端自己模拟下行 默认状态是开启
config.linkSocket = true --tgx 
 
-- 是否更新资源  true更新 否不更新
config.updateRes = false --tgx 

-- 渠道号
config.ChannelID = "1"

-- 最近登录服务器
config.loginsvr = ""

-- authzzy地址
config.authUrl = "http://account.dmw.hardtime.zizaiyouxi.com/login.php"

--是否是生产模式 1为调试模式  0为生产模式
config.debugMode=0

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
config.loginType=1 --tgx 默认是3

-------------------
----读取APP配置----
-------------------
local appConfig = zzy.StringUtils:splitToTable("")
config.debugMode = appConfig.debugMode or config.debugMode
config.subpack = appConfig.subpack or config.subpack
--正式服
config.ChannelID = appConfig.ChannelID or config.ChannelID
config.cpsid = appConfig.cpsid or config.ChannelID

return config 

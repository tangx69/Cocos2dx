---
-- LoginView   登陆
--@module LoginView
local LoginView = {
    gameScene=nil,
    network=nil,
    loginEventId = nil,
    _curServerkey = nil,
    _serverList = nil,
    
    _lastGetConfigTime=nil,--上一次获取配置的时间
    gameViewStart=nil,
    widget_loading=nil,
    _sendInitData=nil,
	_firstStartGame=true
}
---
-- 登陆gameserver
-- @function [parent=#LoginView] init
-- @param #LoginView self
function LoginView:login(func)
    self.network = zzy.NetManager:getInstance()
    self.network.loginStr=self:renderLgnStr()
    zzy.EventManager:listen("S2C_lgn_er",function(sender, evt)
        --evt.data.errcode 错误码   evt.data.msg错误信息
        ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_1..tostring(evt.data.msg),function()__G__ONRESTART__() end)
        if evt.data.type==1 then
            --不再弹出其他的对话框 这时候服务器还会把socket断开
            ch.UIManager.onePoup=true
        end
    end)
    local ckfId
    ckfId = zzy.EventManager:listen("S2C_sys_ckf",function(sender, evt)
        zzy.EventManager:unListen(ckfId)
        local isError = false
        local name
        for k,v in pairs(evt.data) do
            if k~= "f" then
                name = string.upper(string.sub(k,1,1))
                name = name .. string.sub(k,2) .."Config"
                if GameConfig[name].md5 ~= v then
                    isError = true
                    break
                end
            end
        end
        if isError then
            zzy.NetManager:getInstance():disconnect()
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_2..name)
        end
    end)
    
    local lgnId
    lgnId = zzy.EventManager:listen("S2C_ls_lgn",function(sender, evt) 
        if evt.data.ret==0 then
            zzy.EventManager:unListen(lgnId)
            ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_3)
            local gdId
            gdId = zzy.EventManager:listen("S2C_sys_gd",function(sender, evt)
                cclog("登录成功!!")
                
                local loginData = evt.data.d
                role_info_t = {}
                role_info_t.roleId = tostring(loginData.id)
                role_info_t.roleName = tostring(loginData.player.name)
                local maxLevel = loginData.statistics.maxLevel
                if maxLevel == nil or maxLevel == 0 then
                    maxLevel = 1
                end
                role_info_t.roleLevel = tostring(maxLevel)
                role_info_t.roleBalance = tostring(loginData.money["90001"] or "0") --游戏币余额
                role_info_t.roleVip = tostring("1")
                role_info_t.roleGuildName = loginData.guild and loginData.guild.name or tostring("无帮派") --公会名
                if role_info_t.roleGuildName == "" then
                    role_info_t.roleGuildName = tostring("无帮派")
                end
                role_info_t.roleCTime = tostring(loginData.player.registerTime) --角色创建时间
                role_info_t.roleLevelUpTime = tostring(os.time())
                role_info_t.serverId = tostring(loginData.player.zoneId)
                role_info_t.serverName = tostring(zzy.config.svrname or "")
                role_info_t.platformId = tostring("1")
                
                PLAYER_ID = loginData.id
                PALYER_UNID = loginData.player.unid
                USER_ID = loginData.userid
                SERVER_ID = loginData.player.zoneId
            
                local role_info_s = json.encode(role_info_t)
                DEBUG("[report]"..role_info_s)
                cc.libPlatform:getInstance():report("startGame", role_info_s)
                cc.libPlatform:getInstance():report("enterServer", role_info_s)
                cc.libPlatform:getInstance():report("createrole", role_info_s)
                if maxLevel == 1 then
                    cc.libPlatform:getInstance():report("levelup", role_info_s)
                end
                
                zzy.EventManager:unListen(gdId)
                _SERVER_TIME_DIS = evt.data.d.statistics.time - os_clock()

                ch.ModelManager:init(evt.data.d)
                ch.TimerController:start()
                ch.NetworkDebugController:init()
                ch.NetworkController:init()
                ch.GuildWarController:init()
                evt = zzy.Events:createC2SEvent()
                evt.cmd = "time"
                evt.data = {
                    f = "dis",
                    _SERVER_TIME_DIS=tostring(_SERVER_TIME_DIS)
                }
                zzy.EventManager:dispatch(evt)

                ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_4)
                --设置用户数据
                ch.StatisticsManager:sendRoleInfor()
                if func then
                    func()
                end
                
                -- 请求广告页
                local ifOpenAD = cc.UserDefault:getInstance():getStringForKey("openAD")
                if ch.StatisticsModel:getMaxLevel() > 10 and tonumber(ifOpenAD) ~= ch.CommonFunc:getZeroTime(os_time()) then
                    -- 活动提醒每天一次
                    ch.SignModel:setShowEffect(true)
                    ch.ChristmasModel:setShowEffect(true)
                    if  string.sub(zzy.Sdk.getFlag(),1,2) =="HD" then
						local url = 'http://account.'
						if zzy.config.debugMode==1 then
							url=url.."test."
						end
						url = url..'dmw.hardtime.zizaiyouxi.com/adshow'
						if zzy.config.debugMode==1 then
							url=url.."_cefu"
						end
						url = url..'.php'
						zzy.cUtils.getNetString(url, function(err, str)
							if err==0 then
								local  content=json.decode(str)
								if content.ret==0 then
									zzy.config.openADItems = content.items
									cc.UserDefault:getInstance():setStringForKey("openAD",ch.CommonFunc:getZeroTime(os_time()))
								end
							end
						end)
					else
						cc.UserDefault:getInstance():setStringForKey("openAD",ch.CommonFunc:getZeroTime(os_time()))
					end
					
                end 
                     
            end)
            if not self._sendInitData then
                --保证初始化数据的请求只有一次 
                local evt = zzy.Events:createC2SEvent()
                evt.cmd = "sys"
                evt.data = {
                    f = "gd",
                }
                zzy.EventManager:dispatch(evt)
                self._sendInitData=true
            end
        else
            zzy.NetManager:getInstance()._showError=true
            zzy.NetManager:getInstance():disconnect()
            if evt.data.ip and  evt.data.port then
                self.network.loginStr=self:renderLgnStr()
                self.network:init(evt.data.ip,evt.data.port)
            else
                ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_5)
            end
        end
    end)
end


---
-- 将当前服务器设置为上一次登录的服务器
-- @function [parent=#LoginView] _setLastServer
-- @param #LoginView self
function LoginView:_setLastServer()
    INFO("LoginView:_setLastServer")

    if zzy.config.loginsvr=="" then
        local server=cc.UserDefault:getInstance():getStringForKey("lastlySer")
        if server=="" then
            self._curServerkey=ch.GameLoaderModel:getSvridList()[1]
        else
            local lastServerInfo=json.decode(server)
            self._curServerkey=ch.GameLoaderModel:getServerIndBySvrid(lastServerInfo.last1)
        end
    else
        local lastServerInfo=zzy.StringUtils:split(zzy.config.loginsvr,",")
        self._curServerkey=ch.GameLoaderModel:getServerIndBySvrid(lastServerInfo[1])
    end
    if not self._curServerkey then  --sverlist中找不到登录服务器存储的服务器
        self._curServerkey=ch.GameLoaderModel:getSvridList()[1]
    end
    local config = self._serverList[self._curServerkey]
    if config.type==2 then
        --如果是审批服之后默认选择第一个
        self._curServerkey=ch.GameLoaderModel:getSvridList()[1]
        config = self._serverList[self._curServerkey]
    end
    ch.GameLoaderModel:setSelectedSerShow(true)
    zzy.EventManager:dispatch( {type = ch.GameLoaderModel.selServerEventType,data=config})
    zzy.config.host = config.host
    zzy.config.port = config.port
    zzy.config.svrid = config.svrid
    zzy.config.svrname = config.name
end
---
-- 设置显示版本号
-- @function [parent=#LoginView] _setShowVersion
-- @param #LoginView self
function LoginView:_setShowVersion()
    INFO("[LoginView:_setShowVersion]")
    
    IS_IN_GAME = false
    DEBUG("IS_IN_GAME = false")
    
    self:_getServerInfo()
end

---
-- 发送最近登录服务器信息
-- @function [parent=#LoginView] sendLoginSvr
-- @param #LoginView self
function LoginView:sendLoginSvr()
    local url="";
    local ind=ch.GameLoaderModel:getServerIndBySvrid(zzy.config.svrid)
    if ind then
        local info = ch.GameLoaderModel:getServerInfoByInd(ind)
        if info.type==2  then
             --审批服不加入最近登录服务器
             return
        end
    end
    if zzy.Sdk.getFlag()=="DEFAULT" or (PLATFORM_CONFIG and PLATFORM_CONFIG.tag~="DEFAULT") then
		--url="http://account.djyx.zizaiyouxi.com/ucenter/loginsvr.php"
        url=LOGINSVR_URL
    else
        url="http://account."
        url=url..ch.CommonFunc:getProductName().."."..ch.CommonFunc:getDomain().."/".."loginsvr.php"
    end
    local userdata = {uid=zzy.config.loginData.userid,
        svrid=zzy.config.svrid}             
    url = url.. string.format("?userdata=%s",json.encode(userdata))
    zzy.cUtils.getNetString(url, function(err, str)
        if err ~= 0 then
            ERROR("loginsvr failed")
        end
    end)
    
end

---
-- 获取认证地址
-- @function [parent=#LoginView] getAuthUrl
-- @param #LoginView self
-- @return #stirng 认证地址
function LoginView:getAuthUrl()
    INFO("[LoginView:getAuthUrl]")

    local url="";
    if zzy.Sdk.getFlag()=="DEFAULT" then
        url= "http://account.dmw.hardtime.zizaiyouxi.com/login.php"
    else
        url="http://account."
        url=url..ch.CommonFunc:getProductName().."."..ch.CommonFunc:getDomain().."/"..string.lower(zzy.Sdk.getFlag()) .."/"
		if zzy.Sdk.getFlag()=="HDTX" and zzy.config.subpack==1 then
			url=url.."login_ysdk.php"
		elseif zzy.Sdk.getFlag()=="HDOPO" and ch.UpdateManager:_compareVersion(zzy.cUtils.getVersion(),"1.12.0")>0 then
			url=url.."login_v2.php"
		else
			url=url.."login.php"
		end
		
    end

    INFO("[url=%s]", url)

    return url 
end
---
-- 用户认证
-- @function [parent=#LoginView] authToZzy
-- @param #LoginView self
-- @param func function 回调函数
function LoginView:authToZzy(data,func)
    INFO("[LoginView:authToZzy]")

--    zzy.config.loginData = {userid="50152216",t="1438686743",sign="f45c14bdee88edf43a5d085ceb875a44",svrid="mwhdw001"}
--    func(0, zzy.config.loginData.userid)
     if zzy.Sdk.getFlag()=="HDANY" then
        local content=json.decode(data.data)
        zzy.config.loginData = zzy.StringUtils:splitToTable(content.params)
        zzy.config.loginsvr = content.loginsvr
        ch.PlayerModel.channeluser=content.channeluser or 0
        ch.PlayerModel.usertype=content.usertype or 0
        func(0, zzy.config.loginData.userid)
        return
     end 
	local  authFunc=nil
    if zzy.Sdk.PLATFORM_DEFAULT then
        zzy.config.loginData = zzy.StringUtils:splitToTable(data.params)
        func(0, zzy.config.loginData.userid)
    elseif zzy.Sdk.PLATFORM_PLAYYX then
        zzy.config.loginData = zzy.StringUtils:splitToTable(data.params)
        func(0, zzy.config.loginData.userid)
    else
        local userdata = {DeviceID=zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID()),
            DeviceModel=zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel()),
            DeviceSystem=zzy.StringUtils:urlencode(zzy.cUtils.getDeviceSystem()),
                            ChannelID=zzy.config.ChannelID,pack=zzy.Sdk.getFlag()}
							

	--对每个数据做urlencode
	local temp_table = json.decode(data.data)
	for k, v in pairs(temp_table) do
		if type(v)=="string" then 
			temp_table[k] = zzy.StringUtils:urlencode(v)
		end
	end
	data.data = json.encode(temp_table)
    INFO("[LoginView:authToZzy][data.data=%s]", data.data)
		
		
        zzy.config.data_sdk=data.data                    
        local authReq = self:getAuthUrl().. string.format("?sid=%s&userdata=%s",  data.data, json.encode(userdata))
		  authFunc= function()
			zzy.cUtils.getNetString(authReq, function(err, str)
				if err==0 then
					local  content=json.decode(str)
                    INFO("[LoginView:authToZzy][str=%s]", str)
					if content.ret==0 then
						ch.StatisticsManager:sendGameEvent(10009)  
						zzy.config.loginData = zzy.StringUtils:splitToTable(content.params)
						zzy.config.loginsvr = content.loginsvr
						ch.PlayerModel.channeluser=content.channeluser or 0
						ch.PlayerModel.usertype=content.usertype or 0
						zzy.config.data_channel=content.channeldata or ""
						zzy.config.data_sdk_server=content 
						zzy.config.loginData.fbid=ch.SettingModel:getfbid()
						ch.SettingModel:fbDataChangeEvent()
						func(0, zzy.config.loginData.userid)
					else
						if content.ret==2001 and zzy.Sdk.getFlag()=="HDZY" then
							--self:_showLogin(true) 
							ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_6..content.ret,function()self:_showLogin(true) end,nil,Language.MSG_BUTTON_RETRY)
						else
							ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_6..content.ret,function()self:_showLogin() end,nil,Language.MSG_BUTTON_RETRY)
					    end
					end
				else
					ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",function()authFunc() end,nil,Language.MSG_BUTTON_RETRY)
				end
			end)
		end
	end
	if authFunc then
	   authFunc()
	end
end
---
-- 获取配置信息 version等
-- @function [parent=#LoginView] _getServerInfo
-- @param #LoginView self
function LoginView:_getServerInfo()
    if cc.UserDefault:getInstance():getStringForKey("sendUpdateCom")=="1" then
		ch.StatisticsManager:sendGameEvent(10006)
		cc.UserDefault:getInstance():setStringForKey("sendUpdateCom","0")
		cclog("sendUpdateCom")
	end
	
--[[
    if zzy.Sdk.getFlag()~="HDIOS" and  zzy.Sdk.getFlag()~="WYIOS"  and  zzy.Sdk.getFlag()~="HDXGS" and  zzy.Sdk.getFlag()~="CYIOS" and  zzy.Sdk.getFlag()~="TJIOS"  then
        ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_7)
    end
    ch.GameLoaderModel:setLoadingShow(true)
]]
    --检测有无网络
    if zzy.cUtils.getNetworkState() ==0 then
        --无网络
        ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1],function()
            self:_getServerInfo()
        end,nil,Language.MSG_BUTTON_RETRY)
        return
    else
        --发送激活日志
        ch.StatisticsManager:sendActiveLog()
    end
    --加载服务器版本文件
    --ch.StatisticsManager:sendLoadVersionServerLog()
	--ch.StatisticsManager:sendGameEvent(10002)   	
    --ch.CommonFunc:getNetString("http://192.168.100.103/fywbqq_dev/test/1.9.0/ .json", function(err, str)
        
    local updateManager = require("src.adapter.UpdateManager")
    updateManager:checkUpdate(function()
        local showVer=""
        showVer = SHOW_VERSION
        cc.UserDefault:getInstance():setStringForKey("showVersion", showVer)
        ch.GameLoaderModel:setShowVersion(showVer)
        
        --从服务器读取区服列表
        local packageName = zzy.cUtils.getPackageName()
        local channelType = zzy.cUtils.getCustomParam()
        if luaoc then
            _G_URL_SERVER_INFO = "http://gjlogin.hzfunyou.com:27199/ucenter/serverlist"
        else
            _G_URL_SERVER_INFO = "http://115.159.66.225:17199/ucenter/serverlist"
        end
        
        --CESHI
        --channelType = 10011
        --_G_URL_SERVER_INFO = "http://192.168.1.103:17199/ucenter/serverlist"
        --CESHI
        
        _G_URL_SERVER_INFO = string.format("%s?channelType=%s", _G_URL_SERVER_INFO, channelType)
        if IS_BANHAO or IS_IN_REVIEW or packageName == "com.funyou.gjxy.sw.2001" or packageName == "com.funyou.gjsg.sw" then
            _G_URL_SERVER_INFO = string.format("%s&review=%s", _G_URL_SERVER_INFO, 1)
        end

        INFO("[_G_URL_SERVER_INFO]".._G_URL_SERVER_INFO or "")
        ch.CommonFunc:getNetString(_G_URL_SERVER_INFO, function(err, str)
            if err ~= 0 or str == nil then
                ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",function()
                    self:_getServerInfo()
                end,nil,Language.MSG_BUTTON_RETRY)
                return
            end
            local serverInfo = json.decode(str)
            if  serverInfo then
                self._lastGetConfigTime=os_clock()
                self._serverList = serverInfo.servers
                ch.GameLoaderModel.serverList=serverInfo.servers

               ch.StatisticsManager:sendGameEvent(10003)  	
               self:_showLogin()
            else
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_8,function()
                    self:_getServerInfo()
                end,nil,Language.MSG_BUTTON_RETRY)
            end
        end)
    end)
end

---
-- 检查需要更新的资源,根据网络产生提示并更新资源
-- @function [parent=#LoginView] _checkAndStartUpdate
-- @param #LoginView self
function LoginView:_checkAndStartUpdate()
    --对比版本文件
    ch.StatisticsManager:sendVersionCompareLog() 
	local updateManager = require("src.adapter.UpdateManager")
    updateManager:checkUpdate(function(size,err)
       ch.StatisticsManager:sendGameEvent(10004)   	
		if size < 0 then
            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",function()
                self:_checkAndStartUpdate()
            end,nil,Language.MSG_BUTTON_RETRY)
        elseif size > 0 then
            ch.GameLoaderModel:setLoadingShow(true)
            if zzy.cUtils.getNetworkState() ~= 2 then
                size = size/(1024*1024)
                ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_9,function()
                    self:_startUpdate()
                end)
            else
                self:_startUpdate()
            end
        else -- 需要更新的大小为0，可能为ios的整包更新，也需要执行更新
            self:_startUpdate()
        end
    end)
end

---
-- 显示网络错误提示
-- @function [parent=#LoginView] _showNetworkError
-- @param #string status
-- @param #LoginView self
function LoginView:_showNetworkError(status)
    ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..status..")",function()
        __G__ONRESTART__()
    end)
end


---
-- 开始更新资源
-- @function [parent=#LoginView] _startUpdate
-- @param #LoginView self
function LoginView:_startUpdate()
    INFO("[%s]", "LoginView:_startUpdate")
    ch.UpdateManager:startUpdate(function(tp,progress,curLoad,totalLoad)
        INFO("tp="..tp)
        ch.GameLoaderModel:setProgress(progress)
        if  tp==1 then
            --安卓整包更新进度
            if  type(math.floor(ch.GameLoaderModel:getProgress())) =="number" then  
                ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_10.."  "..(math.floor(ch.GameLoaderModel:getProgress()*100)).."%")
            else
                cclog("progress is not a number")
            end
        else
            --分包更新进度
            if  type(math.floor(ch.GameLoaderModel:getProgress())) =="number" then  
                ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_11.."  "..(math.floor(ch.GameLoaderModel:getProgress()*100)).."%".."  (".. curLoad.."/"..totalLoad..")")
            else
                cclog("progress is not a number")
            end
        end


    end, function(status, url)
        INFO("[update]status=%d", status)

        if status <= 0 then
            self:_showNetworkError(status)
        elseif status == 1 then -- 无更新
            --cc.UserDefault:getInstance():setStringForKey("resVer", ch.UpdateManager._versionData.resVer)
            local showVer=""
            showVer=SHOW_VERSION
            cc.UserDefault:getInstance():setStringForKey("showVersion",showVer)
            ch.GameLoaderModel:setShowVersion(showVer)
            self:_showLogin()
        elseif status == 2 then -- 分包更新完成
			cc.UserDefault:getInstance():setStringForKey("sendUpdateCom","1")   
            cclog("分包下载完成")
            cclog("重启开始")
            __G__ONRESTART__()
            cclog("重启结束")
        elseif status == 3 then -- 安卓整包更新
            cclog("安卓整包更新")
			INFO("url="..(url or ""))
            zzy.cUtils.installApk(url)
            cc.Director:getInstance():endToLua()
        elseif status == 4 then -- ios整包更新
            cclog("ios 整包更新")
            ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_12,function()
               --zzy.cUtils.openUrl(url)
               --cc.Director:getInstance():endToLua()
                __G__ONRESTART__()
            end)
        end
    end)
end
---
-- 检查更新完成，显示登录界面
-- @function [parent=#LoginView] _showLogin
-- @param #LoginView self
function LoginView:_showLogin(multi)
    INFO("[%s]", "LoginView:_showLogin")

    ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_13)
    ch.GameLoaderModel:setLoadingShow(false)
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
    if self.loginEventId==nil then
		self.loginEventId = zzy.EventManager:listen(zzy.Sdk.Events.loginDone, function(sender, evt)
			ch.StatisticsManager:sendGameEvent(10008)  
			ch.GameLoaderModel:setLoadingShow(true)
			ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_14)
			ch.GameLoaderModel:setBtnStartVis(false)
			self:authToZzy(evt,function(errorCode,id) 
    		   if zzy.config.check  and  flag~="TJ" and  flag~="CY" and  flag~="WE" and zzy.Sdk.getFlag()~="HDIOS" and zzy.Sdk.getFlag()~="WYIOS"  and  zzy.Sdk.getFlag()~="HDXGS" then
    				ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_15,nil,nil,Language.MSG_BUTTON_OK)
    			end
    			ch.GameLoaderModel:setLoadingShow(false)
    			ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_16)
    			self.widget_loading:setLocalZOrder(999)
    			ch.GameLoaderModel:setBtnStartVis(true)
    			self:_setLastServer()
    			--ch.StatisticsManager:sendRegisterLog(id)
    			ch.GameLoaderModel:setBtnLoginVis(false)
		    end)
		end)
	end
  
    
    --临时修改  PP先logout 再login  打整包时修改整包
   if zzy.Sdk.getFlag()=="HDPP" then
        zzy.Sdk.changeAccount()
    else
        ch.GameLoaderModel:setBtnStartVis(true)
        ch.GameLoaderModel:setBtnLoginVis(true)
        if zzy.Sdk.getFlag()~="HDYYB" and  zzy.Sdk.getFlag()~="HDTX" then
			if multi and zzy.Sdk.getFlag()=="HDZY" and ch.UpdateManager:_compareVersion(zzy.cUtils.getVersion(),"1.11.3")>0 then
				--掌阅登录失败再次登录时需要刷新token
				 local loginInfo={
					f="login",
					data={t="login"}
				}
				zzy.Sdk.extendFunc(json.encode(loginInfo))
            else
				ch.StatisticsManager:sendGameEvent(10007)    
            	zzy.Sdk.openLogin()
            end
        end
    end
  
  
end

---
-- 生成lgn登陆字符串
-- @function [parent=#LoginView] renderLgnStr
-- @param #LoginView self
-- @return #string rect
function LoginView:renderLgnStr()
    
    --ver= 版本号 ,ch= 渠道， account=  账号名
    local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
	local sdkver=""
	local devicemodel=zzy.cUtils.getDeviceModel()
	local chanelid=ch.CommonFunc:getCpsid()
    
    if USER_ID ~= zzy.config.loginData.userid then
        USER_ID = zzy.config.loginData.userid
        INFO("[TalkingData][setAccount]"..tostring(USER_ID))
        cc.libPlatform:getInstance():tdSetAccount(tostring(USER_ID))
        INFO("[TalkingData][tdSetAccountType]"..tostring(0))
        cc.libPlatform:getInstance():tdSetAccountType(0)
        INFO("[TalkingData][setGameServer]"..tostring(zzy.config.svrid))
        cc.libPlatform:getInstance():setGameServer(tostring(zzy.config.svrid))
        
        if zzy.cUtils.tdAdTrace_onLogin then
            zzy.cUtils.tdAdTrace_onLogin(USER_ID)
        end
    end
    
    return string.format("userid=%s,tm=%s,sign=%s,ver=%s,ch=%s,account=%s,svrid=%s,deviceid=%s,channeluser=%s,sdkver=%s,devicemodel=%s",zzy.config.loginData.userid,zzy.config.loginData.t,zzy.config.loginData.sign,showVersion,chanelid,"",zzy.config.svrid,zzy.cUtils.getDeviceID(),ch.PlayerModel.channeluser,sdkver,devicemodel)
end

---
-- 检查本地是否有漏单信息
-- @function [parent=#LoginView] _checkOrder
-- @param #LoginView self
-- @return #string rect
function LoginView:_checkOrder()
	local flag= string.sub(zzy.Sdk.getFlag(),1,2)
	if (flag=="WY"  or flag=="WE" )  and cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
		 local tb_ids={}
		 for k,v in pairs(GameConfig.ShopConfig:getTable()) do
			if v.channelId == zzy.Sdk.getFlag() and v.shopType == 1 and v.type_cost==1 then
				table.insert( tb_ids,v.itemId)
			end
		end
		
		--查询有无未消费商品
		local chargeInfo={
		   f="charge",
		   data={ids=tb_ids,chargetype="google"}
		}
		zzy.Sdk.extendFunc(json.encode(chargeInfo))
		
		--查询本地有无漏单
		local orderInfo=json.decode(cc.UserDefault:getInstance():getStringForKey("orderInfo")) or {}
		for k,v in pairs (orderInfo) do
            if v.count > 3 and os_time() - v.time > 3 * 24 * 3600 then
                orderInfo[k]=nil
            -- else 
            --     ch.CommonFunc:consumption(v) 
            end
		end

        cc.UserDefault:getInstance():setStringForKey("orderInfo",json.encode(orderInfo))
        orderInfo=json.decode(cc.UserDefault:getInstance():getStringForKey("orderInfo")) or {}
        for k,v in pairs (orderInfo) do
            ch.CommonFunc:consumption(v.d)
        end
	end
end
---
-- 开始游戏
-- @function [parent=#LoginView] startGame
-- @param #LoginView self
function LoginView:startGame()
     IS_IN_GAME = true
	 zzy.EventManager:listen("S2C_cue_pop",function(sender, evt)
       if evt.data.func==1 then
        ch.fightRoleLayer:pause()
       end
        ch.UIManager:showMsgBox(evt.data.s,true,evt.data.msg,
        function()
           if evt.data.func==1 then
                os.exit()
           end
        end
        )
        if evt.data.type==1 then
            --不再弹出其他的对话框 这时候服务器还会把socket断开
            ch.UIManager.onePoup=true
        end
    end)

    local ind=ch.GameLoaderModel:getServerIndBySvrid(zzy.config.svrid)
    if ind then
        local info = ch.GameLoaderModel:getServerInfoByInd(ind)
        if info.status==0  and tonumber(ch.PlayerModel.usertype)==0 then
            --维护中
            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[3],function()self._firstStartGame=true end,nil,Language.MSG_BUTTON_OK)
            return
        end
        if info.type==4  and tonumber(ch.PlayerModel.usertype)==0 then
            --待开新服
            ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[3],function()self._firstStartGame=true end,nil,Language.MSG_BUTTON_OK)
            return
        end
    end
	--发送最近登录服务器
    self:sendLoginSvr()
    ch.GameLoaderModel:setLoadingShow(true)
    ch.GameLoaderModel:setSelectedSerShow(false)
    self:login(function()         
        zzy.EventManager:unListen(self.loginEventId)
        --发送登陆成功日志
        ch.StatisticsManager:sendLogInSucLog()
		ch.StatisticsManager:sendGameEvent(10012)  
		local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="WY" or flag=="TJ" or flag=="CY" or flag=="WE" then
			if ch.StatisticsModel:isNewPlayer() then
				local loginInfo={
					f="createrole",
					data={t="newuser",roleid=ch.PlayerModel:getPlayerID()}
				}
				zzy.Sdk.extendFunc(json.encode(loginInfo))
			end
		end
        self.gameViewStart()
    end)
    ch.GameLoaderModel:setBtnStartVis(false)
    zzy.NetManager:getInstance():init(zzy.config.host,zzy.config.port)
	
	 local configInfo={
		debugMode=zzy.config.debugMode,
		check=zzy.config.check
	}
     cc.UserDefault:getInstance():setStringForKey("configInfo", json.encode(configInfo))
end

---
-- 初始化并显示
-- @function [parent=#LoginView] init
-- @param #LoginView self
function LoginView:init(gameScene)
    INFO("[%s]", "LoginView:init")

    self.gameScene=gameScene
    ch.UIManager:init(gameScene)
    -- loading界面

    local processLoad=function(per)
        -- 下载过程 下载完一个触发一次
        ch.GameLoaderModel:setProgress(per)
        ch.GameLoaderModel:setLoadingTxt(Language.src_clickhero_view_LoginView_17.."  "..(math.floor(ch.GameLoaderModel:getProgress()*100)).."%")
    end
    local pre_new={"fuwen/W_FuwenList","baowu/W_BaowuList", "tuteng/W_TutengList","achievement/W_Achievelist","Shop/W_shop","card/W_card_list",
        "achievement/N_Top","cardInstance/W_cardins","Guild/W_NewGuild_guildwar_mainbroad" }

    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/loading/loadingPlist.plist")
    -- 游戏渲染开始
    self.gameViewStart = function()
        ch.GameLoaderModel.curProcess=1
		ch.StatisticsManager:sendGameEvent(10013)  
        ch.UIManager:loadUIRes(processLoad, function()
            ch.MusicManager:preload()
            --ch.SoundManager:preload()
            local cur_new=0
            local func_preNew
            func_preNew=function()
                ch.GameLoaderModel.curProcess=2
                cur_new=cur_new+1
                processLoad(cur_new/#pre_new)
                zzy.uiViewBase:new(pre_new[cur_new], nil, nil, nil, pre_new[cur_new],true)
                if cur_new == #pre_new  then
                    ch.GameLoaderModel.curProcess=3
                    
                    --预加载战斗中的资源
                    ch.fightRoleLayer:preLoadResource(processLoad,function(texture)
                       ch.StatisticsManager:sendGameEvent(10014)  
						self.widget_loading:destory()
                        self.LoadingAni:removeFromParent()
                        if string.sub(zzy.Sdk.getFlag(),1,2)=="TJ" and
                            ch.StatisticsModel:getPlayTime() < 60 then
                            texture:retain()
                            ch.guide:showKorGUild(GameConst.KOR_LOADING_GUILD[1],gameScene,function()
                                ch.guide:showKorGUild(GameConst.KOR_LOADING_GUILD[2],gameScene,function()
                                    texture:release()
                                    self:goinGame()
                                end)
                            end)
                        else
                            self:goinGame()
                        end
                    end)
                else
                    zzy.TimerUtils:setTimeOut(0,func_preNew)
                end
            end
            func_preNew()
            ch.UIManager:getSysPopupLayer():addChild(ch.ChatView:getInstanse():getRenderer())
            ch.ChatView:getInstanse():close()
        end)
    end

    self.loginEventId = nil
    
    self.widget_loading = zzy.uiViewBase:new("loading/loading")
    self.LoadingAni = sp.SkeletonAnimation:create("res/effect/loading.json","res/effect/loading.atlas",1)

    self.LoadingAni:setPosition(0,0)
    self.LoadingAni:addAnimation(1,"animation", true)
    gameScene:addChild(self.LoadingAni)
    gameScene:addChild(self.widget_loading)
    
    local box = cc.LayerColor:create(cc.c4b(255,255,255,255));
    --local s = cc.Sprite:create("res/img/guild_cover.png")

    local s = ccui.ImageView:create()
    s:loadTexture("res/img/guild_cover.png")

    box:setContentSize(s:getContentSize().width, s:getContentSize().height)
    
    box:addChild(s)
    --gameScene:addChild(box)
    box:setPosition(0, 400)
    s:setPosition(s:getContentSize().width/2, s:getContentSize().height/2)


    local function boxClick(sender,eventType)
        if  eventType == ccui.TouchEventType.ended then
            local op = sender:getOpacity() == 0 and 100 or 0
            sender:setOpacity(op)
        end
    end
    --box:addTouchEventListener(boxClick)
    
    self:_setShowVersion()

    local  func_getServerInfo
    local startGameId
    startGameId=zzy.EventManager:listen(ch.GameLoaderModel.startGameEventType,function(obj,evt)
        --zzy.EventManager:unListen(startGameId)
		  if  self._firstStartGame==false then
			return
		  end
		  self._firstStartGame=false
          if os_clock()-self._lastGetConfigTime>60 then -- refresh server status after 60s
            self._lastGetConfigTime=os_clock()
            --更新配置文件
            func_getServerInfo=function() 
                ch.CommonFunc:getNetString(_G_URL_SERVER_INFO, function(err, str)
                    if err ~= 0 or str == nil then
                        ch.UIManager:showMsgBox(1,true,GameConst.NET_ERROR[1].."("..GameConst.NET_ERROR[5]..err..")",function()
                            func_getServerInfo()
                        end,nil,Language.MSG_BUTTON_RETRY)
                        return
                    end
                    local serverInfo = json.decode(str)
                    if  serverInfo then
                        self._serverList = serverInfo.servers
                        ch.GameLoaderModel.serverList=serverInfo.servers
                        self:startGame()
                    else
                        ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_19,function()
                            func_getServerInfo()
                        end,nil,Language.MSG_BUTTON_RETRY)
                    end
                end)	
            end
            
            func_getServerInfo()
          else
            self:startGame()
          end
    end)
end

---
-- 进入游戏界面
-- @function [parent=#LoginView] goinGame
-- @param #LoginView self
function LoginView:goinGame()
    INFO("[%s]", "LoginView:goinGame")
    
    if  zzy.NetManager:getInstance():isWorking() then
        ch.GameLoaderModel.loadingCom = true
        zzy.TimerUtils:setTimeOut(0,function()
            ch.guide:init()
            if ch.guide.firstIn then
                ch.LevelController:init(false)
            else
                ch.LevelController:init(true)
            end
            --                                ch.UIManager:getActiveSkillLayer():addChild(zzy.uiViewBase:new("MainScreen/W3_Skill"))
            ch.UIManager:addActiveSkillView()
            ch.UIManager:addMainView()
            zzy.EventManager:dispatch({type = ch.GameLoaderModel.loadCompletedEvent})
            --检查有无漏单
			self:_checkOrder()
            zzy.TimerUtils:setTimeOut(0, function()
                cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("res/ui/loading/loadingPlist.plist")
            end)
        end)
    end
end


return LoginView
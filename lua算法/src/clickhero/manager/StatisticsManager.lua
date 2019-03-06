---
-- @module StatisticsManager 统计管理
local StatisticsManager = {
    _hdUrl="http://log.hardtime.cn:8080/statis/jsp/log_receive.jsp",
	_wyUrl="http://webdmw.sail2world.com/client.html",
	_weUrl="http://webdmw.sail2world.com/mwme.html",
	_tjUrl="http://gamelogcenter.skylinematrix.com/swgdmw",
    _appkey="dmw",
	_sendreg=false --是否发送过注册日志 防止一次登陆游戏调用多次发送注册日志
}

---
--  获取自在游官方激活日志的url
--@function [parent=#StatisticsManager] getZZYActiveUrl
--@param #StatisticsManager self
--@param url string 网址
function StatisticsManager:getZZYActiveUrl()
    local url="http://account.";
    url=url..ch.CommonFunc:getProductName().."."..ch.CommonFunc:getDomain().."/".."activatelog.php"
    return url 
end
---
--  发送日志(只发送一次)
--@function [parent=#StatisticsManager] sendOnce
--@param #StatisticsManager self
--@param #key string 本地的存储标记
--@param url string 网址
function StatisticsManager:sendOnce(url,key)
    if true then
        return
    end
	--registerLog
    zzy.cUtils.getNetString(url, function(err, str)
        if err==0 then
            cclog("sendOnce log succ")
			if string.sub(zzy.Sdk.getFlag(),1,2)=="WY" or string.sub(zzy.Sdk.getFlag(),1,2)=="WE"  then
			    if key=="registerLog" or key=="activeLog" then
					local  content=json.decode(str)
					if content.ret==0 then
						cc.UserDefault:getInstance():setStringForKey(key,1)
					end
				end
			else
				cc.UserDefault:getInstance():setStringForKey(key,1)
			end
        end
    end)
end

---
--  发送日志
--@function [parent=#StatisticsManager] send
--@param #StatisticsManager self
--@param url string 网址
function StatisticsManager:send(url)
    if true then
        return
    end
    
    zzy.cUtils.getNetString(url, function(err, str)
        if err==0 then
            cclog("send  succ")
        end
    end)
end
---
--  发送激活日志
--@function [parent=#StatisticsManager] sendActiveLog
--@param #StatisticsManager self
function StatisticsManager:sendActiveLog()
    if true then
        return
    end
    
	ch.StatisticsManager:sendGameEvent(10001)  
    local activeLog=cc.UserDefault:getInstance():getStringForKey("activeLog")
    if activeLog=="" 
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="activate"
        local log_hd="?content="..t..","..self._appkey..","..showVersion..","..f..","
            ..ch.CommonFunc:getCpsid()..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())
        local log_zzy="?content="..t..","..self._appkey..","..showVersion..","..f..","
            ..zzy.config.ChannelID..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())
        
		local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="HD" then
			  self:sendOnce(self._hdUrl..log_hd,"activeLog")
		elseif flag=="WY"  then
			 self:sendOnce(self._wyUrl..log_hd,"activeLog")
		elseif flag=="WE" then
			 self:sendOnce(self._weUrl..log_hd,"activeLog")
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log_hd,"activeLog")
		end   	
		if zzy.Sdk.getFlag() ~= "DEFAULT" then
			self:sendOnce(self:getZZYActiveUrl()..log_zzy,"activeLog")
		end
    end
end
---
--  发送网络错误日志
--@function [parent=#StatisticsManager] sendNeterr
--@param #StatisticsManager self
function StatisticsManager:sendNeterr(err,url)
    if true then
        return
    end
    
    if  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
		 local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
		 local NetWork=""
		if zzy.cUtils.getNetworkState() ==1 then 
			NetWork="mobile"
		elseif zzy.cUtils.getNetworkState() ==2 then
			NetWork="wifi"
		end
		local log="http://getinfo.dmw.zizaiyouxi.com/getipinfo.php?content="..ch.CommonFunc:getCpsid()..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
				..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceSystem())..","..NetWork..","..zzy.cUtils.getVersion()..","..err..","..t..","..url
		self:send(log)
	end
end
---
--  发送用户信息给sdk
--@function [parent=#StatisticsManager] sendRoleInfor
--@param #StatisticsManager self
function StatisticsManager:sendRoleInfor()
    if true then
        return
    end
    
    local zoneId = tonumber(string.match(ch.PlayerModel:getZoneID(), "([%d]?[%d]?[%d]?)$")) 
    local zoneName=tostring(zoneId)..Language.src_clickhero_manager_StatisticsManager_1
    local roleInfo={
        roleid=zzy.config.loginData.userid,
		playerid=ch.PlayerModel:getPlayerID(),
        rolename=ch.PlayerModel:getPlayerName(),
        rolelevel=ch.LevelModel:getCurLevel(),
        zoneid=zoneId,
        zonename=zzy.config.svrname,
		gzs=ch.MoneyModel:getDiamond() 
    }
    zzy.Sdk.setRoleInfor(json.encode(roleInfo))
end
---
--  发送注册日志
--@function [parent=#StatisticsManager] sendRegisterLog
--@param #StatisticsManager self
function StatisticsManager:sendRegisterLog(userid) 
    if true then
        return
    end
    
    if self._sendreg then
		return
	end
    local activeLog=cc.UserDefault:getInstance():getStringForKey("registerLog")
    if activeLog=="" 
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
	    self._sendreg=true
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="register"
        local accname=""
        local NetWork=""
        if zzy.cUtils.getNetworkState() ==1 then 
            NetWork="mobile"
        elseif zzy.cUtils.getNetworkState() ==2 then
            NetWork="wifi"
        end
        local log="?content="..t..","..self._appkey..","..showVersion..","..f..","..ch.CommonFunc:getCpsid()
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..userid..","..accname..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceSystem())..","..NetWork
       local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="HD" then
			self:sendOnce(self._hdUrl..log,"registerLog")
		elseif flag=="WY"  then
			 self:sendOnce(self._wyUrl..log..",".. zzy.config.loginType,"registerLog")
		elseif flag=="WE" then
			 self:sendOnce(self._weUrl..log..",".. zzy.config.loginType,"registerLog")
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log,"registerLog")
		end   	
    end
end


---
--  加载服务器版本文件日志
--@function [parent=#StatisticsManager] sendLoadVersionServerLog
--@param #StatisticsManager self
function StatisticsManager:sendLoadVersionServerLog() 
    if true then
        return
    end
    
    if  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="LoadVersionServer"
        local log="?content="..t..","..self._appkey..","..showVersion..","..f..","..ch.CommonFunc:getCpsid()
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
         local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="HD" then
			 self:sendOnce(self._hdUrl..log)
		elseif flag=="WY" then
			 self:sendOnce(self._wyUrl..log)
		elseif flag=="WE" then
			self:sendOnce(self._weUrl..log)
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log)
		end   
    end
end

---
--  发送游戏事件
--@function [parent=#StatisticsManager] sendGameEvent
--@param #StatisticsManager self
function StatisticsManager:sendGameEvent(id) 
    if true then
        return
    end
    
	if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
		zzy.Sdk.extendFunc(json.encode({f="gameevent",data={id=id}}))
	end  
end
---
--  发送游戏事件
--@function [parent=#StatisticsManager] sendGuideStep
--@param #StatisticsManager self
function StatisticsManager:sendGuideStep(step) 
    if true then
        return
    end
    
	if string.sub(zzy.Sdk.getFlag(),1,2)=="CY" then
		zzy.Sdk.extendFunc(json.encode({f="guide",data={step=step}}))
	end  
end
---
--  对比版本文件日志
--@function [parent=#StatisticsManager] sendVersionCompareLog
--@param #StatisticsManager self
function StatisticsManager:sendVersionCompareLog() 
    if true then
        return
    end
    
    if  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="VersionCompare"
        local log="?content="..t..","..self._appkey..","..showVersion..","..f..","..ch.CommonFunc:getCpsid()
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
        local flag= string.sub(zzy.Sdk.getFlag(),1,2)
			if flag=="HD" then
			 self:sendOnce(self._hdUrl..log)
		elseif flag=="WY"  then
			 self:sendOnce(self._wyUrl..log)
		elseif flag=="WE" then
			self:sendOnce(self._weUrl..log)
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log)
		end 
    end
end

---
--  从服务器下载文件
--@function [parent=#StatisticsManager] sendDownLoadResLog
--@param #StatisticsManager self
function StatisticsManager:sendDownLoadResLog() 
    if true then
        return
    end
    
    if  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="DownLoadRes"
        local log="?content="..t..","..self._appkey..","..showVersion..","..f..","..ch.CommonFunc:getCpsid()
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
        local flag= string.sub(zzy.Sdk.getFlag(),1,2)
			if flag=="HD" then
			 self:sendOnce(self._hdUrl..log)
		elseif flag=="WY" then
			 self:sendOnce(self._wyUrl..log)
		elseif flag=="WE" then
			self:sendOnce(self._weUrl..log)
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log)
		end 
    end
end

---
--  本地版本文件更新为服务器版本文件
--@function [parent=#StatisticsManager] sendUpdateLocalVersionLog
--@param #StatisticsManager self
function StatisticsManager:sendUpdateLocalVersionLog() 
    if true then
        return
    end
    
    if  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="UpdateLocalVersion"
        local log="?content="..t..","..self._appkey..","..showVersion..","..f..","..ch.CommonFunc:getCpsid()
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
        local flag= string.sub(zzy.Sdk.getFlag(),1,2)
			if flag=="HD" then
			 self:sendOnce(self._hdUrl..log)
		elseif flag=="WY" then
			 self:sendOnce(self._wyUrl..log)
		elseif flag=="WE" then
			self:sendOnce(self._weUrl..log)
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log)
		end 
    end
end

---
--  登陆成功
--@function [parent=#StatisticsManager] sendLogInSucLog
--@param #StatisticsManager self
function StatisticsManager:sendLogInSucLog() 
    if true then
        return
    end
    
    if  cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
        and
        cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
    then
        local t= zzy.StringUtils:urlencode(os.date("%Y-%m-%d %H:%M:%S",os_time()))
        local showVersion=cc.UserDefault:getInstance():getStringForKey("showVersion")
        local f="LogInSuc"
        local log="?content="..t..","..self._appkey..","..showVersion..","..f..","..ch.CommonFunc:getCpsid()
            ..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceID())..","..zzy.StringUtils:urlencode(zzy.cUtils.getDeviceModel())
        local flag= string.sub(zzy.Sdk.getFlag(),1,2)
		if flag=="HD" then
			 self:sendOnce(self._hdUrl..log)
		elseif flag=="WY"  then
			 self:sendOnce(self._wyUrl..log)
		elseif flag=="WE" then
			self:sendOnce(self._weUrl..log)
		elseif flag=="TJ" then
			 self:sendOnce(self._tjUrl..log)
		end  
    end
end

return StatisticsManager
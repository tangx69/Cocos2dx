---
-- @module UpdateManager
local UpdateManager = {
    _versionData = nil,
    _onCheckCompleted = nil,
    _onProgressChanged = nil,
    _onCompleted = nil,
    _hasCompleted = false, --当提示已经完成后禁用其他提示

    _isNeedCoreUpdate = nil, --是否需要核心版本更新，即整包跟新
    _files = nil,            --分包更新需要更新的资源
    curLoad=0, --当前下载的资源数
    _totalBytes = 0,
    _hasBytes = 0,
    _totalCount = 0,
    _hasCount = 0,
    _retryCount = 0,
    _retryCountMax=6,--重试最大次数
    currentFilename=nil,--当前下载的文件名
    _lastReportProgress = 0,
    _versionJsonStr=""  --服务器上下载的zip资源对应的MD5
}


---
-- 检测需要下载的文件大小,不表式是否需要更新
-- @function [parent=#UpdateManager] checkUpdate
-- @param #UpdateManager self
-- @param #function onCheckCompleted 检测完成回调事件 onCheckCompleted(size), 当size<0,为网络连接失败；size>=0，需要下载的文件大小，当size == 0时不表式不需要更新
function UpdateManager:checkUpdate(onCheckCompleted)
    INFO("[%s]", "UpdateManager:checkUpdate")

    if not HOT_UPDATE then --tgx
        WARNING("[hot update is off!!!]")
        onCheckCompleted(0)
        return
    end

    
    self._onCheckCompleted = onCheckCompleted
    self._isNeedCoreUpdate = nil
    self._files = nil
    self:_getVersionData()
end

---
-- 开始更新资源，必须在checkUpdate之后使用对外接口
-- @function [parent=#UpdateManager] startUpdate
-- @param #UpdateManager self
-- @param #function onProgressChanged 进度改变事件，（progress）progress 进度
-- @param #function onCompleted 完成事件，（statue，url）标示结束原因:0 是失败，1是无更新，2是分包成功完成下载，3是安卓整包完成下载,
--                              4是iso需要整包更新; url,是安卓和ios整包更新的地址，仅在IOS和安卓整包更新时有效
function UpdateManager:startUpdate(onProgressChanged, onCompleted)
    INFO("[%s]", "UpdateManager:startUpdate")
    self._onProgressChanged = onProgressChanged
    self._onCompleted = onCompleted
    self._hasCompleted = false
    if self._isNeedCoreUpdate then
        --self:_startAllUpdate()
		 if zzy.Sdk.getFlag()=="HDIOS" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				if zzy.config.subpack==1 then
					zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1078916150")
				elseif zzy.config.subpack==2 then
					zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1110653889")
				else
					zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1024000494")
				end
			end,nil,nil,nil)
		elseif zzy.Sdk.getFlag()=="HDXGS" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				if zzy.config.subpack==1 then
					zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1121190708")
				elseif zzy.config.subpack==2 then
				
				elseif zzy.config.subpack==3 then
				
				elseif zzy.config.subpack==4 then
				
				elseif zzy.config.subpack==5 then
				
				end
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="HDAND" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("http://dmw.hardtime.cn/")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="WYIOS" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				if zzy.config.subpack==1 then
					zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1112937897")
				else
					zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1087810816")
				end
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="WYAND" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("https://play.google.com/store/apps/details?id=com.yingxiong.ol")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="WYMWOL" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("https://play.google.com/store/apps/details?id=com.swgd.mwol")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="WYMJZ" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("https://play.google.com/store/apps/details?id=com.yzd.el")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="WYGOO" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("https://play.google.com/store/apps/details?id=com.swg.dmw")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="TJAND" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("https://play.google.com/store/apps/details?id=com.skylinematrix.ggplay.swdmwkr")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="TJONE" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("http://tsto.re/0000685181")
			end,nil,nil,nil)
		 elseif zzy.Sdk.getFlag()=="TJNAV" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("http://m.nstore.naver.com/appstore/web/detail.nhn?productNo=2222074")
			end,nil,nil,nil)
		elseif zzy.Sdk.getFlag()=="TJIOS" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1076506600")
			end,nil,nil,nil)
		elseif zzy.Sdk.getFlag()=="CYIOS" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1095939047")
			end,nil,nil,nil)
		elseif zzy.Sdk.getFlag()=="CYAND" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("https://play.google.com/store/apps/details?id=com.cyou.tapstormtrials")
			end,nil,nil,nil)
		elseif zzy.Sdk.getFlag()=="WEIOS" then
			ch.UIManager:showMsgBox(1,false,Language.src_clickhero_manager_UpdateManager_1,function()
				zzy.cUtils.openUrl("itms-apps://itunes.apple.com/app/id1115548500")
			end,nil,nil,nil)
		 else
			 ch.UIManager:showMsgBox(1,true,Language.src_clickhero_manager_UpdateManager_1,function()
				__G__ONRESTART__()
			end,nil,nil,nil)
		 end
    elseif self._files then
        --从服务器下载文件日志
		ch.StatisticsManager:sendGameEvent(10005)   
        ch.StatisticsManager:sendDownLoadResLog()  
        self:_downloadFiles(self._files)
    else
        self:_completed(1)
    end

end

---
-- 从服务器获取版本信息
-- @function [parent=#UpdateManager] _getVersionData
-- @param #UpdateManager self
function UpdateManager:_getVersionData()
    INFO("[%s]", "UpdateManager:_getVersionData")
    zzy.config.url = self._versionData.resUrl
    self._isNeedCoreUpdate = self:_getIsNeedAllUpdate()
    if self._isNeedCoreUpdate then
        self:_checkAllUpdate()
    else
        self:_checkResUpdate()
    end
end

---
-- 检查整包更新
-- @function [parent=#UpdateManager] _checkAllUpdate
-- @param #UpdateManager self
function UpdateManager:_checkAllUpdate()
    INFO("[%s]", "UpdateManager:_checkAllUpdate")
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local path = cc.FileUtils:getInstance():getWritablePath() .. self._versionData.androidUrl.file
        if not cc.FileUtils:getInstance():isFileExist(path) then
--            self._onCheckCompleted(self._versionData.androidUrl.size)
              self._onCheckCompleted(0)
            return
        end
    end
    self._onCheckCompleted(0)
end

---
-- 获取是否需要整包更新
-- @function [parent=#UpdateManager] _getIsNeedAllUpdate
-- @param #UpdateManager self
-- @return #bool 是否需要更新
function UpdateManager:_getIsNeedAllUpdate()
    INFO("[%s]", "UpdateManager:_getIsNeedAllUpdate")
     if  (cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
        and cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC)
		and zzy.config.updateRes 
		and zzy.config.check==false 
		and  self:_compareVersion(self._versionData.forceVer,zzy.cUtils.getVersion())>0
		then
        return true
    end
    return false
end

---
-- 比较版本号大小  
-- @function [parent=#UpdateManager] _compareVersion
-- @param #UpdateManager self
-- @param #string version1 版本1
-- @param #string version2 版本2
-- @return #bool ret
function UpdateManager:_compareVersion(version1,version2)
    INFO("[%s]", "UpdateManager:_compareVersion")
	local tb_version1 = zzy.StringUtils:split(version1, "%.")
	local tb_version2 = zzy.StringUtils:split(version2, "%.")
	local lenth1 = #tb_version1
	local lenth2 = #tb_version2
	local minLenth = lenth1 < lenth2 and lenth1 or lenth2
	--先比较对应位的数字
	for i = 1, minLenth do
		local n1 = tonumber(tb_version1[i])
		local n2 = tonumber(tb_version2[i])
		if n1 == nil or n2 == nil then--字母无效
			break
		end
		
		if n1 > n2 then
			return 1;
		elseif n1 < n2 then
			return -1
		end
	end
	--版本号位数不匹配时，位数多的大
	if lenth1 > lenth2 then
		return 1
	elseif lenth1 < lenth2 then
		return -1
	else
		return 0
	end

	--[[
    local tb_version1 = zzy.StringUtils:split(version1, "%.")
    local tb_version2 = zzy.StringUtils:split(version2, "%.")
    if  tonumber(tb_version1[1])== tonumber(tb_version2[1]) and  tonumber(tb_version1[2])== tonumber(tb_version2[2]) and  tonumber(tb_version1[3])== tonumber(tb_version2[3]) then
        return 0
    end
	if  tonumber(tb_version1[1])> tonumber(tb_version2[1]) then
        return 1
    elseif tonumber(tb_version1[1])< tonumber(tb_version2[1]) then
		 return -1
    end
	
	if  tonumber(tb_version1[2])> tonumber(tb_version2[2]) then
        return 1
	elseif tonumber(tb_version1[2])< tonumber(tb_version2[2]) then
		 return -1
    end
	
	if  tonumber(tb_version1[3])> tonumber(tb_version2[3]) then
        return 1
	elseif tonumber(tb_version1[3])< tonumber(tb_version2[3]) then
		 return -1
    end
	
    return -1
	--]]
end

---
-- 获取最新的version.json，如果需要，开始执行分包更新检测
-- @function [parent=#UpdateManager] _checkResUpdate
-- @param #UpdateManager self
function UpdateManager:_checkResUpdate()
    INFO("[%s]", "UpdateManager:_checkResUpdate")

    self:_initVersion()
    local newConfig = nil
    if cc.UserDefault:getInstance():getStringForKey("resVer") ~= self._versionData.resVer then
        zzy.cUtils.getNetString(zzy.config.url .. "resource/version.json?" .. self._versionData.resVer, function(err, str)
            --if err == 0 and str ~= nil and md5.sumhexa(str) == self._versionData.resVer then
            if err == 0 and str ~= nil then --tgx md5校验不同,跳过了下载
                self._versionJsonStr=str
                newConfig = json.decode(str)
                self:_checkRes(newConfig)
            else
                self._onCheckCompleted(-1,err)
            end
        end)
    else
        self:_checkRes(newConfig)
    end
end

---
-- 根据获取的version.json文件,检测需要更新的文件，开始回调
-- @function [parent=#UpdateManager] _checkRes
-- @param #UpdateManager self
-- @param #table newConfig
function UpdateManager:_checkRes(newConfig)
    INFO("[%s]", "UpdateManager:_checkRes")
    local count,files = self:_getNeedUpdateRes(newConfig)
    if count > 0 then
        self._files = files
    end
    if count > 0 then
        self._onCheckCompleted(1)
    else
        self._onCheckCompleted(0)
    end
end

---
-- 获取需要更新的文件
-- @function [parent=#UpdateManager] _getNeedUpdateRes
-- @param #UpdateManager self
-- @param #table newConfig
-- @return #int 需要更新的文件数量
-- @return #table 需要更新的文件列表
function UpdateManager:_getNeedUpdateRes(newConfig)
    INFO("[%s]", "UpdateManager:_getNeedUpdateRes")

    local config =json.decode(cc.UserDefault:getInstance():getStringForKey("versionJson"))
    newConfig = newConfig or config
    local files = {}
    local fileCount = 0
    for key, var in pairs(newConfig) do
        if cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_MAC
            and
            cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_WINDOWS
            and
            zzy.config.updateRes
            and self:_checkMd5(config,newConfig,key)
            and zzy.config.check==false
        then
--            files[key] = var==
            table.insert(files,{k=key,v=var})
            fileCount = fileCount + 1
        else
            config[key] = newConfig[key]
        end
    end
    return fileCount,files
end

---
-- 检测md5是否一致
-- @function [parent=#UpdateManager] _checkMd5
-- @param #UpdateManager self
-- @param ret string 
function UpdateManager:_checkMd5(config,newConfig,key)
    INFO("[%s]", "UpdateManager:_checkMd5")
    if key=="android_data_zz.zip" and cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_ANDROID then
        return false
    end
    if key=="ios_data_zz.zip" and cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPHONE 
        and cc.Application:getInstance():getTargetPlatform() ~= cc.PLATFORM_OS_IPAD then
        return false
    end
    if not config[key] or config[key] ~= newConfig[key]  then
        return true
    end
    return false
end
---
-- 开始整包更新
-- @function [parent=#UpdateManager] _startAllUpdate
-- @param #UpdateManager self
function UpdateManager:_startAllUpdate()
    INFO("[%s]", "UpdateManager:_startAllUpdate")
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local path = cc.FileUtils:getInstance():getWritablePath() .. self._versionData.androidUrl.file
        if cc.FileUtils:getInstance():isFileExist(path) then
            self:_completed(3, path)
        else
            self:_initDownloadVar()
            self._totalBytes = self._versionData.androidUrl.size
            self:_downloadAPK()
        end
    elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPHONE then
        self:_completed(4, self._versionData.iphoneUrl)
    elseif cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_IPAD then
        self:_completed(4, self._versionData.ipadUrl)
    end
end

---
-- 下载安卓apk文件
-- @function [parent=#UpdateManager] _downloadAPK
-- @param #UpdateManager self
function UpdateManager:_downloadAPK()
    INFO("[%s]", "UpdateManager:_downloadAPK")
    local lastBytes = 0
    zzy.cUtils.download(self._versionData.androidUrl.url, self._versionData.androidUrl.file, self._versionData.androidUrl.md5, function(hasBytes, totalBytes)
        self._hasBytes = self._hasBytes + hasBytes - lastBytes
        lastBytes = hasBytes
        self:_progressChanged()
    end, function(err)
        if err == 0 then
            cclog(string.format("文件%s下载成功...", self._versionData.androidUrl.file))
            local path = cc.FileUtils:getInstance():getWritablePath() .. self._versionData.androidUrl.file
            self:_completed(3, path)
        elseif err < 0 then
            if self._retryCount < self._retryCountMax then   
                self._retryCount = self._retryCount + 1
                self._hasBytes = self._hasBytes - lastBytes
                self:_downloadAPK()
                cclog(string.format("文件%s下载失败,正在重试...%s", self._versionData.androidUrl.file, self._versionData.androidUrl.md5))
            else
                self:_completed(err)
            end
        end
    end)
end

---
-- 下载所有需要更新的文件
-- @function [parent=#UpdateManager] _downloadFiles
-- @param #UpdateManager self
-- @param #table files
function UpdateManager:_downloadFiles(files) 
    INFO("[%s]", "UpdateManager:_downloadFiles")
    self:_initDownloadVar()
    self.curLoad=0
    local config =json.decode(cc.UserDefault:getInstance():getStringForKey("versionJson"))
    local loadFileCom
    loadFileCom =function(fileName,md5)
        if fileName then
            config[fileName] = md5 
            cc.UserDefault:getInstance():setStringForKey("versionJson", json.encode(config))
        end
        self.curLoad=self.curLoad+1
        if self.curLoad>#files then
            cc.UserDefault:getInstance():setStringForKey("versionJson", self._versionJsonStr)
            cc.UserDefault:getInstance():setStringForKey("resVer", self._versionData.resVer)
            cc.UserDefault:getInstance():setStringForKey("showVersion",zzy.cUtils.getVersion().."."..ch.UpdateManager._versionData.devVer)
            --本地版本文件更新为服务器版本文件
            ch.StatisticsManager:sendUpdateLocalVersionLog()
            self:_completed(2)
        else
            self:_downloadFile(files[self.curLoad].k,files[self.curLoad].v,loadFileCom)
        end
    end 
    loadFileCom()
end

---
-- 下载单个文件
-- @function [parent=#UpdateManager] _downloadFile
-- @param #UpdateManager self
-- @param #string fileName
-- @param #string md5
function UpdateManager:_downloadFile(fileName, md5,loadFileCom)
    INFO("[%s]", "UpdateManager:_downloadFile")
    if self.currentFilename~=fileName then
        self._retryCount=0
        self.currentFilename=fileName
    end
    zzy.cUtils.download(zzy.config.url.."resource/", fileName, md5, function(hasBytes, totalBytes) 
    if  totalBytes~=0 and hasBytes~=0 then
        self._onProgressChanged(2,hasBytes/totalBytes,self.curLoad,#self._files)
    end
    end, function(err)
        if err == 0 then
            cclog(string.format("文件%s下载成功...", fileName))
            loadFileCom(fileName,md5)           
        elseif err < 0 then
            cclog(string.format("文件%s下载失败,正在重试... %d,,%s", fileName, err, md5))
            if self._retryCount < self._retryCountMax then
                self._retryCount = self._retryCount + 1
                self:_downloadFile(fileName, md5,loadFileCom)
            else
                self:_completed(err)
				ch.StatisticsManager:sendNeterr(err,zzy.config.url.."resource/"..fileName.."?"..md5)
            end
        end
    end)
end

---
-- 初始化版本信息,即把版本信息还原到最初安装形态
-- @function [parent=#UpdateManager] _initVersion
-- @param #UpdateManager self
function UpdateManager:_initVersion()
    INFO("[%s]", "UpdateManager:_initVersion")

    local ver= cc.UserDefault:getInstance():getStringForKey("resVer")
    local versionJson = cc.UserDefault:getInstance():getStringForKey("versionJson")
    if versionJson=="" then
        local versionJsonStr = cc.FileUtils:getInstance():getStringFromFile("version.json")
        cc.UserDefault:getInstance():setStringForKey("versionJson",versionJsonStr)
    end
end

---
-- 初始化下载需要用到的本地变量
-- @function [parent=#UpdateManager] _initDownloadVar
-- @param #UpdateManager self
function UpdateManager:_initDownloadVar()
    INFO("[%s]", "UpdateManager:_initDownloadVar")

    self._totalCount = 0
    self._hasBytes = 0
    self._hasCount = 0
    self._totalBytes = 0
    self._retryCount = 0
    self._lastReportProgress = 0
end


---
-- 进度改变
-- @function [parent=#UpdateManager] _progressChanged
-- @param #UpdateManager self
function UpdateManager:_progressChanged()
    INFO("[%s]", "UpdateManager:_progressChanged")

    if self._onProgressChanged and (not self._hasCompleted) then
        local progress = 0
        if self._totalBytes ~= 0 and  self._hasBytes~=0 then
            progress = self._hasBytes/self._totalBytes
        end
        if(math.abs(progress - self._lastReportProgress) > 0.01) then
            self._lastReportProgress = progress
            self._onProgressChanged(1,progress)
        end
    end
end

---
-- 更新完成
-- @function [parent=#UpdateManager] _completed
-- @param #UpdateManager self
-- @param #int statue 0 是失败，1是无更新，2是分包下载完成，3是安卓apk完成， 4是ios整包更新
-- @param #string url url, 是安卓和ios整包更新的地址，仅在IOS和安卓整包更新时有效,其他为空
function UpdateManager:_completed(statue, url)
    INFO("[%s]", "UpdateManager:_completed")
    
    if self._onCompleted and (not self._hasCompleted) then
        self._hasCompleted = true
        self._onCompleted(statue, url)
    end
end

return UpdateManager
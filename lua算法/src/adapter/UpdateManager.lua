local UpdateManager = class("UpdateManager")
--local UpdateManager = {}

--更新
local remoteJsonUrl = JSON_URL


function UpdateManager:dtor()
    INFO("UpdateManager:dtor")
end

function UpdateManager:checkUpdate(_finishCallBack)
    --INFO("UpdateManager:onEnterTransitionFinish")
	
	--self.finishCallBack = _finishCallBack
	--self:getRemoteFile()
    
    _finishCallBack(0)
end

function UpdateManager:getRemoteFile()
	local packageVersion = zzy.cUtils.getVersionCode()
    local packageName = zzy.cUtils.getPackageName()
    
	self.isWhiteUser = cc.FileUtils:getInstance():isFileExist("res/w.txt") --是否是热更白名单
    
	--下载并解析远程配置文件
    local function callback(isOk, msg)
		if isOk == true then
			local jsonInfo = json.decode(msg)
			local packageUrl = jsonInfo.packageUrls[packageName] or jsonInfo.packageUrls["default"]
			local curVersion = jsonInfo.versions[packageName] or jsonInfo.versions["default"]
            _G_URL_NOTICE = jsonInfo.notices[packageName] or jsonInfo.notices["default"]
            
            _G_URL_SERVER_INFO = jsonInfo.servers[packageName] or jsonInfo.servers["default"]
            if self:isReviewVersion(packageVersion, curVersion) then
                INFO("是审核")
                IS_IN_REVIEW = true --当前版本是否是IOS审核版本
            else
                INFO("不是审核")
                IS_IN_REVIEW = false
            end
			
			if self.isWhiteUser ~= true then
				HIDE_LOG = true
            else
                ch.PlayerModel.usertype = 1
			end
			
			--是否需要下载最新包
			if self:isNeedDownLoad(packageVersion, curVersion) then
				self:showPackageDownLoadWarning(packageUrl)
			else
				self:hotUpdate()
			end
		else
		    --获取远程文件失败,放弃版本控制和白名单校验,直接开始obb/hotupdate
			self:hotUpdate()
		end
	end
	self:getRemoteInfoAsync(remoteJsonUrl, callback)
end

function UpdateManager:showPackageDownLoadWarning(packageUrl)
	self:junpToDownLoadPackage(packageUrl)
end

function UpdateManager:junpToDownLoadPackage(packageUrl)
    INFO("[junpToDownLoadPackage]url = %s", packageUrl or "")
	--
    ch.UIManager:showMsgBox(1,true,Language.src_clickhero_view_LoginView_12,function()
        if packageUrl then
            cc.Application:getInstance():openURL(packageUrl)
        end
        os.exit()
    end) 
end

function UpdateManager:isNeedDownLoad(packageVersion, curVersion)
	local isNeed = ch.UpdateManager:_compareVersion(packageVersion, curVersion) < 0
	
	return isNeed
end

function UpdateManager:isReviewVersion(packageVersion, curVersion)
    local packageName = zzy.cUtils.getPackageName()
    
    INFO("[packageVersion]"..packageVersion)
    INFO("[curVersion]"..curVersion)
    INFO("[packageName]"..packageName)
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        if (packageName == "com.funyou.wkxxz.sw") then
            INFO("[IS_BANHAO=true]")
            IS_BANHAO = true
        else
            INFO("[IS_BANHAO=false]")
        end
        
        return false
    end
    
    local isReview = ch.UpdateManager:_compareVersion(packageVersion, curVersion) > 0

	return isReview
end

function UpdateManager:hotUpdate()
    INFO("UpdateManager:hotUpdate")
    
    if HOT_UPDATE ~= true then
        WARNING("Hot Update is off!!!")
		self:updateFinish()
		return
	end
	
    --更新列表配置文件
    local manifest_folder = zzy.cUtils.getPackageName()
    local manifest = "src/Manifests/"..manifest_folder.."/project.manifest"
	
    --本地更新包存储目录
    local versionCode = zzy.cUtils.getVersionCode()
    local storagePath = "update_"..versionCode
	if self.isWhiteUser then
		cclog("Manifests_test/project.manifest")
        manifest = "Manifests_test/"..manifest_folder.."/project.manifest"
		storagePath = "update_test_"..versionCode
	end
    local savepath = cc.FileUtils:getInstance():getWritablePath() .. storagePath

    local assetsManagerEx = cc.AssetsManagerEx:create(manifest, savepath)
	assetsManagerEx:retain()
	
    if not assetsManagerEx:getLocalManifest():isLoaded() then
        INFO("Fail to update assets, step skipped.")
    else
        local function onUpdateEvent(event)
            local eventCode = event:getEventCode()
            if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                INFO("No local manifest file found, skip assets update.")

            elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
                local assetId = event:getAssetId()
                local percent = event:getPercent()
                local strInfo = ""

                if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                    strInfo = string.format("Version file: %d%%", percent)

                elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                    strInfo = string.format("Manifest file: %d%%", percent)

                else
                    strInfo = string.format("%d%%", percent)

                end
				
                INFO("percent="..percent)
				
                self:setPercent(percent)  
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
                ERROR("ERROR_DOWNLOAD_MANIFEST")
				assetsManagerEx:release()
                self:updateFinish()
                
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then
                INFO("ALREADY_UP_TO_DATE")
				assetsManagerEx:release()
				self:updateFinish()
				
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                INFO("UPDATE_FINISHED")
				assetsManagerEx:release()
				--self:hotUpdate()
				self:updateFinish()
				--__G__ONRESTART__()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                ERROR("Asset "..event:getAssetId()..", "..event:getMessage())
                
            end
        end
        local listener = cc.EventListenerAssetsManagerEx:create(assetsManagerEx, onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

        assetsManagerEx:update()
    end
end

function UpdateManager:setPercent(percent)
	INFO("[UpdateManager][setPercent]percent="..percent)

    ch.GameLoaderModel:setLoadingTxt("正在热更新!")
    ch.GameLoaderModel:setProgress(math.floor(percent))
end

--更新完成
function UpdateManager:updateFinish()
    INFO("UpdateManager:updateFinish()")
				
	--目录显示标签
	local strpath = ""
	local spath = cc.FileUtils:getInstance():getSearchPaths()
	for i=1, #spath do 
		local tmp = string.format("%d %s\n", i,spath[i])
		strpath = strpath..tmp
	end
    INFO(strpath)
	
    SHOW_VERSION = ""
    local versionCode = zzy.cUtils.getVersionCode()
    SHOW_VERSION = SHOW_VERSION..versionCode
    
    local storagePath = "update_"..versionCode
    if self.isWhiteUser then
		storagePath = "update_test_"..versionCode
	end
    
    local savepath = cc.FileUtils:getInstance():getWritablePath() .. storagePath
    
    local versionFilePath = savepath.."/version.manifest"
    if cc.FileUtils:getInstance():isFileExist(versionFilePath) then
        local versionManifestData = cc.FileUtils:getInstance():getStringFromFile(versionFilePath)
        local versionManifestJson = json.decode(versionManifestData)
        local udpateVer = versionManifestJson.version
        SHOW_VERSION = SHOW_VERSION.."."..udpateVer
    end
    
    
	self.finishCallBack(0)
end

--异步获取远端数据
function UpdateManager:getRemoteInfoAsync(url, callback)
    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    
    local remoteInfo = ""
    local isOk = false
	
	local function onReadyStateChange()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			print(xhr.response)
            remoteInfo = xhr.response
            isOk = true
		else
			print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
		end
		
		--回调
        callback(isOk, remoteInfo)
	end

	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

return UpdateManager

require ("src.cocos.init")
require ("src.adapter.preProc")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    luaj = require "src.cocos.cocos2d.luaj"
elseif (cc.PLATFORM_OS_IPAD == targetPlatform or cc.PLATFORM_OS_IPHONE == targetPlatform) then
    print("is ios")
    luaoc = require "src.cocos.cocos2d.luaoc"
end

cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
cc.FileUtils:getInstance():addSearchPath("res/ui")
    
local SceneLauncher = class("SceneLauncher", function()
	local scene = cc.Scene:create()
    return scene
end)

HOT_UPDATE = true
local remoteJsonUrl = JSON_URL

function SceneLauncher:ctor()
    print("SceneLauncher:ctor()")

    --加载UI
    self.mainUI = cc.CSLoader:createNode("res/ui/loading/lancher.csb")
    self:addChild(self.mainUI)
    
    local Image_title = ccui.Helper:seekWidgetByName(self.mainUI, "Image_title")
    Image_title:loadTexture("res/effect/loading.png")
    
    --初始化进度条
    self.bar = ccui.Helper:seekWidgetByName(self.mainUI, "ui_loading_bar")
    self.bar:setPercent(0)
    
    self.barPanel = ccui.Helper:seekWidgetByName(self.mainUI, "ui_loading_bar_bg")
    self.barPanel:setVisible(false)
    
    --初始化文本
    self.txt = ccui.Helper:seekWidgetByName(self.mainUI, "progressBar_text")
    self:addStrokeOrShadow(self.txt)
    
    self:registerScriptHandler(function(eventType)
        if eventType == "enterTransitionFinish" then
            print("***Scene enterTransitionFinish***")
            if self.onEnterTransitionFinish then
                self:onEnterTransitionFinish()
            end
        end
    end)
end

function SceneLauncher:dtor()
    print("SceneLauncher:dtor")
end

function SceneLauncher:onEnterTransitionFinish()
    print("SceneLauncher:onEnterTransitionFinish")
	
    local function onUpdateFinish()
        print("[SceneLauncher][onUpdateFinish]")

        if (IS_IN_REVIEW) and (not luaj) then
            require("src.main1")
        else
            require("src.main")
        end
    end
    
    self:checkUpdate(onUpdateFinish)
end

function SceneLauncher:checkUpdate(_finishCallBack)
    print("SceneLauncher:onEnterTransitionFinish")
	
	self.finishCallBack = _finishCallBack
	self:getRemoteFile()
end

function SceneLauncher:getRemoteFile()
	local packageVersion = self:getVersionCode()
    local packageName = self:getPackageName()
    local default = "default_sg_ios"
    
    self.txt:setString("正在获取远程配置文件")
    
    if luaj then
        default = "default_android"
    end
    
	--下载并解析远程配置文件
    local function callback(isOk, msg)
		if isOk == true then
			local jsonTable = json.decode(msg)
			local packageUrl = jsonTable.packageUrls[packageName] or jsonTable.packageUrls[default]
			local curVersion = jsonTable.versions[packageName] or jsonTable.versions[default]
            local reviewVersion = nil
			if jsonTable.reviewVersions then
                reviewVersion = jsonTable.reviewVersions[packageName]
            end
            _G_URL_NOTICE = jsonTable.notices[packageName] or jsonTable.notices[default]
            _G_URL_SERVER_INFO = jsonTable.servers[packageName] or jsonTable.servers[default]
            _G_URL_PACKAGE = packageUrl
            _G_CONFIG_JSON = jsonTable
            
            --判断是否是审核
            if reviewVersion and self:isReviewVersion(packageVersion, reviewVersion) then
                print("是审核")
                IS_IN_REVIEW = true --当前版本是否是IOS审核版本
                _G_URL_NOTICE = jsonTable.notices["review"]
                _G_URL_SERVER_INFO = jsonTable.servers["review"]
            else
                print("不是审核")
                IS_IN_REVIEW = false
            end
            
            --判断是否是版号申请
            if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
                if (packageName == "com.funyou.wkxxz.sw") then
                    print("是版号申请")
                    IS_BANHAO = true
                else
                    print("不是版号申请")
                end
            end
            
            if (cc.PLATFORM_OS_WINDOWS == targetPlatform) then
                --IS_BANHAO = true
                print("是WINDOWS测试版号申请")
            end
			
            --是否是热更白名单
            local idfa = self:getIdfa()
            for k,v in pairs(jsonTable.whitelist or {}) do
                if idfa == v then
                    print("是热更白名单")
                    self.isWhiteUser = true
                    break
                end
            end
            
			if self.isWhiteUser ~= true then
				HIDE_LOG = true
			end
			
			--是否需要下载最新包
            if curVersion and self:isNeedDownLoad(packageVersion, curVersion) then
				self:showPackageDownLoadWarning(packageUrl)
			else
				self:unZip()
			end
		else
		    --获取远程文件失败,放弃版本控制和白名单校验,直接开始obb/hotupdate
            local function reGet()
                print("获取失败，重新获取文件")
                self:getRemoteInfoAsync(remoteJsonUrl, callback)
            end

            local seq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(reGet))
            self:runAction(seq)
			--self:unZip()
		end
	end
	self:getRemoteInfoAsync(remoteJsonUrl, callback)
end

function SceneLauncher:showPackageDownLoadWarning(packageUrl)
	self:junpToDownLoadPackage(packageUrl)
end

function SceneLauncher:junpToDownLoadPackage(_packageUrl)
    packageUrl = _packageUrl or ""
    print("[junpToDownLoadPackage]url"..packageUrl)
    
	local warningLayer = cc.CSLoader:createNode("res/ui/Common/W_reconnect.csb")
    self:addChild(warningLayer)
    
    local text_message_2 = ccui.Helper:seekWidgetByName(warningLayer, "text_message_2")
    text_message_2:setString("当前版本较旧，请下载最新版本")
    
    local function hdTouch(sender,eventType)
        if  eventType == ccui.TouchEventType.ended then
            if packageUrl and packageUrl ~= "" then
                cc.Application:getInstance():openURL(packageUrl)
            end
            os.exit()
        end
    end

    local btn_ok = ccui.Helper:seekWidgetByName(warningLayer, "btn_ok")
    btn_ok:addTouchEventListener(hdTouch)
end

function SceneLauncher:isNeedDownLoad(packageVersion, curVersion)
	local isNeed = self:compareVersion(packageVersion, curVersion) < 0
	
	return isNeed
end

function SceneLauncher:isReviewVersion(packageVersion, reviewVersion)
    if reviewVersion == nil then
        print("[WARNNING][SceneLauncher:isReviewVersion]reviewVersion is nil")
        return false
    end
    
    if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
        --return false
    end
    
    local isReview = self:compareVersion(packageVersion, reviewVersion) >= 0
	return isReview
end

function SceneLauncher:hotUpdate()
    print("SceneLauncher:hotUpdate")
    
    self.txt:setString("正在检查更新")
    
    if IS_IN_REVIEW or (HOT_UPDATE ~= true) then
        print("[WARNING]Hot Update is off!!!")
		self:updateFinish()
		return
	end
	
    --更新列表配置文件
    local manifest_folder = self:getPackageName()
    local manifest = "src/Manifests/"..manifest_folder.."/project.manifest"
	
    --本地更新包存储目录
    local versionCode = self:getVersionCode()
    local storagePath = "update_"..versionCode
	if self.isWhiteUser then
		print("Manifests_test/project.manifest")
        manifest = "Manifests_test/"..manifest_folder.."/project.manifest"
		storagePath = "update_test_"..versionCode
	end
    local savepath = cc.FileUtils:getInstance():getWritablePath() .. storagePath

    local assetsManagerEx = cc.AssetsManagerEx:create(manifest, savepath)
	assetsManagerEx:retain()
	
    if not assetsManagerEx:getLocalManifest():isLoaded() then
        print("Fail to update assets, step skipped.")
    else
        local function onUpdateEvent(event)
            local eventCode = event:getEventCode()
            if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
                print("No local manifest file found, skip assets update.")

            elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
                local assetId = event:getAssetId()
                local percent = event:getPercent()
                local strprint = ""

                if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                    strprint = string.format("Version file: %d%%", percent)

                elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                    strprint = string.format("Manifest file: %d%%", percent)

                else
                    strprint = string.format("%d%%", percent)
                end
				
                self:setPercent(percent)  
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
                print("ERROR_DOWNLOAD_MANIFEST")
				assetsManagerEx:release()
                self:updateFinish()
                
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then
                print("ALREADY_UP_TO_DATE")
				assetsManagerEx:release()
				self:updateFinish()
				
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
                print("UPDATE_FINISHED")
				assetsManagerEx:release()
				self:updateFinish()
            elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
                print("Asset "..event:getAssetId()..", "..event:getMessage())
            end
        end
        local listener = cc.EventListenerAssetsManagerEx:create(assetsManagerEx, onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)

        assetsManagerEx:update()
    end
end

function SceneLauncher:setPercent(percent)
    percent = math.floor(percent)
	print("[SceneLauncher][setPercent]percent="..percent)
    
    self.barPanel:setVisible(true)
    self.txt:setString("正在更新"..percent.."%")
    self.bar:setPercent(percent)
end

--更新完成
function SceneLauncher:updateFinish()
    print("SceneLauncher:updateFinish()")
	--目录显示标签
    --print("[DEBUG]********************************")
	local spath = cc.FileUtils:getInstance():getSearchPaths()
	for i=1, #spath do 
		local tmp = string.format("%d %s", i,spath[i])
		print(tmp)
	end
    --print("[DEBUG]********************************")
	
    SHOW_VERSION = ""
    local versionCode = self:getVersionCode()
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
	
	if self.am_unZip then
		self.am_unZip:release()
	end
    
	self.finishCallBack(0)
end

--异步获取远端数据
function SceneLauncher:getRemoteInfoAsync(url, callback)
    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    
    local remoteprint = ""
    local isOk = false
	
	local function onReadyStateChange()
		if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			print(xhr.response)
            remoteprint = xhr.response
            isOk = true
		else
			print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
		end
		
		--回调
        callback(isOk, remoteprint)
	end

	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

function SceneLauncher:unZip()
	print("SceneLauncher:unZip")
	
    local versionCode = self:getVersionCode()
    local storagePath = "unzip"
    local savepath = cc.FileUtils:getInstance():getWritablePath() .. storagePath	
	local spath = cc.FileUtils:getInstance():getSearchPaths()
	--cc.FileUtils:getInstance():addSearchPath(savepath.."/res/")
	print("[DEBUG][SceneLauncher:unZip]savepath="..savepath)
	table.insert(spath,1,savepath.."/")
	cc.FileUtils:getInstance():setSearchPaths(spath)
	
	local strpath = ""
	local spath = cc.FileUtils:getInstance():getSearchPaths()
	for i=1, #spath do 
		local tmp = string.format("%d %s\n", i,spath[i])
		strpath = strpath..tmp
	end
	print(strpath)
	
	if (not self:isNeedUnzip()) then
		print("this version already unziped, skip unzip")
		--进热更
		self:hotUpdate()
		
		return
	end
	
	local zipFileName = "res/extra.zip"
	local zipFileFullName = cc.FileUtils:getInstance():fullPathForFilename(zipFileName)
	if (not cc.FileUtils:getInstance():isFileExist(zipFileFullName)) then
		print("zip file not found, skip unzip")
		--进热更
		self:hotUpdate()
		
		return
	end

    --更新列表配置文件
    local manifest_folder = self:getPackageName()
    local manifest = "src/Manifests/"..manifest_folder.."/project.manifest"

    self.am_unZip = nil
    self.am_unZip = cc.AssetsManagerEx:create(manifest, savepath)
	self.am_unZip:setUncompress(true)
    self.am_unZip:retain()
	
	self.am_unZip:setUnzipPath(savepath.."/")
	self.am_unZip:unZipAsync(zipFileFullName)
	
    self.barPanel:setVisible(true)
    
	local function getFinishCount()
		local percent = self.am_unZip:getUnZipPercent()
		
		if percent ~= 100 then
			--没解压完，显示进度条
			self.bar:setPercent(percent)
			self.txt:setString("正在解压缩(不消耗流量)"..percent.."%")
		else
			if self.unzipTimer ~= nil then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.unzipTimer)
				self.unzipTimer = nil
			end
			
			--解压完,记录解压版本
			local curUnzipVersion = self:getVersionCode()
			print("curUnzipVersion="..curUnzipVersion)
			cc.UserDefault:getInstance():setStringForKey("curUnzipVersion", tostring(curUnzipVersion))
			
            if luaoc then
				print("[INFO][spath="..savepath)

		        local args = {["para"]=savepath}
		    	local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "addSkipBackupAttributeToItemAtURL", args)
		    	if _ok then
		        	print("LuaOcBridge addSkipBackupAttributeToItemAtURL ok")
		    	else
		        	print("LuaOcBridge addSkipBackupAttributeToItemAtURL error")
		    	end
		    end
            
			--进热更
			cc.FileUtils:getInstance():removeFile(zipFileFullName)
			self:hotUpdate()
		end
	end
	self.unzipTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(getFinishCount, 0.1, false)
end

--根据版本号判断是否需要解压缩
function SceneLauncher:isNeedUnzip()
    local verApk = self:getVersionCode()
    print("[isNeedUnzip]verApk="..verApk or "nil")
    local curUnzipVersion =  cc.UserDefault:getInstance():getStringForKey("curUnzipVersion")
    print("[isNeedUnzip]curUnzipVersion="..curUnzipVersion)
    curUnzipVersion = curUnzipVersion or 0
    
    --没有解压记录
    if curUnzipVersion == 0  then
        return true
    end
    
    local isNewstVersion = (curUnzipVersion >= verApk) --unzip记录是否最新版本
    local isUnzipExsist = self:isUnzipExsist()--unzip文件是否还在
    if isNewstVersion and isUnzipExsist then
        print("[isNeedUnzip]上次解压的是最新版本，且解压后的文件还在，则不需解压")
        return false --上次解压的是最新版本，且解压后的文件还在，则不需解压
    else
        print("[isNeedUnzip]需解压")
        return true --否则，需解压
    end
end

--obb解压缩文件是否存在
function SceneLauncher:isUnzipExsist()
	if true then return true end
	
    local tester = cc.Sprite:create("texture/icon/wear/1_wear.png")
	if tester ~= nil then
	    print("unzip file exsist")
		return true
	else
	    print("unzip file not exsist")
		return false
	end
end

function SceneLauncher:compareVersion(ver1, ver2)
    local verTable1 = self:split(ver1, "%p")
    local verTable2 = self:split(ver2, "%p")
    
    local power1 = verTable1[1]*10000 + verTable1[2]*100 + verTable1[3]
    local power2 = verTable2[1]*10000 + verTable2[2]*100 + verTable2[3]
    
    return power1 - power2
end

--传入字符串和分隔符，返回分割后的table
function SceneLauncher:split(str, spe)      
    local  ret = {}
	local count = 0
	
	while (true) do
		local pos = string.find(str, spe)
		
		if pos then
			count = count + 1
			table.insert(ret, count, string.sub(str, 1, pos-1))
			str = string.sub(str, pos+1, string.len(str))
		else
			count = count + 1
			table.insert(ret, count, str)
			break
		end
	end
	
	return ret
end

function SceneLauncher:getVersionCode()
	local ret = "1.0.0"
	
	if luaj then
        print("getVersionCode android")
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getVersionName", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
        print("getVersionCode ios")
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "getVersionCode", args)
		if _ok then
			ret = _ret
		end
	end
    
	print("[SceneLauncher][getVersionCode]"..ret)
	return ret
end

function SceneLauncher:getPackageName()
	local ret = "com.funyou.dmw"
	
	if luaj then
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getPackageName", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "getPackageName", args)
		if _ok then
			ret = _ret
		end
	end
    
    print("[SceneLauncher][getPackageName]"..ret)
	
	return ret
end

function SceneLauncher:getIdfa()
	local ret = "0"
	
	if luaj then
		
	elseif luaoc then
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "getIdfa", args)
		if _ok then
			ret = _ret
		end
	end
	
    print("[SceneLauncher][getIdfa]"..ret)
    
	return ret
end

--从android.manifest或者ios的info.plist中根据key获取value，如果没有定义则返回""
function SceneLauncher:getMetaData(key)
	local ret = ""
	
	if luaj then
		local args = {key}
		local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getMetaData", args, sigs)
		if _ok then
            if _ret ~= "" then
                ret = _ret
            end
		end
	elseif luaoc then
		print("ios没有实现getMetaData!!!")
	end
	
    print(string.format("[SceneLauncher][getMetaData][key=%s][value=%s]", key, ret))
    
	return ret
end

-------------------------
-- 给Lable添加描边或阴影
-- 
function SceneLauncher:addStrokeOrShadow(lable)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_ANDROID == targetPlatform then
        lable:enableOutline(cc.c4b(0,0,0,255),2)
    else
        lable:enableShadow(cc.c4b(0,0,0,255), cc.size(1, -1), 10)
    end
end

return SceneLauncher


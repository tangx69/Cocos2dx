local targetPlatform = cc.Application:getInstance():getTargetPlatform() 
if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    luaj = require "src.cocos.cocos2d.luaj"
elseif (cc.PLATFORM_OS_IPAD == targetPlatform or cc.PLATFORM_OS_IPHONE == targetPlatform) then
    
    luaoc = require "src.cocos.cocos2d.luaoc"
end

local INFO = INFO
if not INFO then
    INFO  = function (...)
        local args = {...}
        args[1] = "[INFO]"..args[1]
        cclog(unpack(args))
    end
end

-- tgx
function zzy.cUtils.getNetString(url,func)
    INFO("[getNetString][SEND]%s", url)
    
    local function callback(isOk, msg)
        local result = -1
        if isOk then
            result = 0
        end
        func(result, msg)
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET", url)
    
    --getNetFile
    local remoteInfo = ""
    local isOk = false
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            INFO("[getNetString][RECV]%s", xhr.response)
            remoteInfo = xhr.response
            isOk = true
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end

        callback(isOk, remoteInfo)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function zzy.cUtils.post(url,jsonStr,func)
    INFO("[POST]%s", url)
    
    local function callback(isOk, msg)
        local result = -1
        if isOk then
            result = 0
        end
        func(result, msg)
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("POST", url)
    xhr:setRequestHeader("Content-type", "application/json; charset=utf-8");

    
    --getNetFile
    local remoteInfo = ""
    local isOk = false
    local function onReadyStateChange()
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
            INFO("[getNetString][RECV]%s", xhr.response)
            remoteInfo = xhr.response
            isOk = true
        else
            print("xhr.readyState is:", xhr.readyState, "xhr.status is: ",xhr.status)
        end

        callback(isOk, remoteInfo)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(jsonStr)
end

function zzy.cUtils.isLowMemory()
    INFO("[%s]", "Utils.isLowMemory")

	local ret = false
	
	if luaj then
		local args = {}
		local sigs = "()I"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getMemory", args, sigs)
		if _ok then
			ret = (_ret >= 100)
		end
	elseif luaoc then
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "_getMemory", args)
		if _ok then
			ret = (_ret >= 100)
		end
	end
	
	return ret
end

function zzy.cUtils.getVersionCode()
    INFO("[%s]", "Utils.getVersionCode")

	local ret = "1.0.0"
	
	if luaj then
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getVersionName", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "getVersionCode", args)
		if _ok then
			ret = _ret
		end
	end
	
	return ret
end

function zzy.cUtils.getPackageName()
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
    
    local customParam = zzy.cUtils.getCustomParam()
    if luaj and customParam and customParam ~="" then
        if (tonumber(customParam) >= 2001 and tonumber(customParam) <= 2020) then
            --ret = ret.."."..customParam
        end
    end
	
    INFO("[zzy.cUtils.getPackageName][%s]", ret)
    
	return ret
end

function zzy.cUtils.getNetworkState()
	local ret = 1
	
	if luaj then
		local args = {}
		local sigs = "()I"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getNetworkState", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "getNetworkState", args)
		if _ok then
			ret = _ret
		end
	end
    
    --INFO("Utils.getNetworkState"..ret)
	
	return ret
end

function zzy.cUtils.getDeviceModel()
	local deviceName = "unknown-device"
	
	if luaj then
        INFO("Utils.getDeviceModel Android")
		local args = {}
        local sigs = "()Ljava/lang/String;"
        local className = "com/funyou/utils/Utils"
        local ok,ret  = luaj.callStaticMethod(className, "getDeviceName", args, sigs)
        if ok then
            deviceName = ret
            cclog("ret="..ret)
            cclog("getDeviceName:luaj.callStaticMethod ok")
        else
            cclog("ret="..ret)
            cclog("getDeviceName:luaj.callStaticMethod error")
        end
	elseif luaoc then
        INFO("Utils.getDeviceModel IOS")
		local args = {["para"]="para"}
        local ok,ret  = luaoc.callStaticMethod("LuaOcBridge", "getDeviceName", args)
        if ok then
            cclog("ret="..ret)
            cclog("LuaOcBridge getDeviceName ok")
        else
            cclog("ret="..ret)
            cclog("LuaOcBridge getDeviceName error")
        end
        
        deviceName = ret
        if (ret == "iPhone1,1") then deviceName = "iPhone 1G"        end
        if (ret == "iPhone1,2") then deviceName = "iPhone 3G"        end
        if (ret == "iPhone2,1") then deviceName = "iPhone 3GS"       end
        if (ret == "iPhone3,1") then deviceName = "iPhone 4"         end
        if (ret == "iPhone3,2") then deviceName = "Verizon iPhone 4" end
        if (ret == "iPhone4,1") then deviceName = "iPhone 4s"        end
        if (ret == "iPhone5,2") then deviceName   = "iPhone 5"       end
        if (ret == "iPhone5,3") then deviceName   = "iPhone 5c"      end
        if (ret == "iPhone5,4") then deviceName   = "iPhone 5c"      end
        if (ret == "iPhone6,2") then deviceName   = "iPhone 5s"      end
        if (ret == "iPhone7,1") then deviceName   = "iPhone 6"       end
        if (ret == "iPhone7,2") then deviceName   = "iPhone 6p"      end
        if (ret == "iPhone8,1") then deviceName   = "iPhone 6s"      end
        if (ret == "iPhone8,2") then deviceName   = "iPhone 6sp"     end
        
        if (ret == "iPod1,1") then deviceName   = "iPod Touch 1G"    end
        if (ret == "iPod2,1") then deviceName   = "iPod Touch 2G"    end
        if (ret == "iPod3,1") then deviceName   = "iPod Touch 3G"    end
        if (ret == "iPod4,1") then deviceName   = "iPod Touch 4G"    end
        
        if (ret == "iPad1,1") then deviceName   = "iPad"             end
        if (ret == "iPad2,1") then deviceName   = "iPad 2 (WiFi)"    end
        if (ret == "iPad2,2") then deviceName   = "iPad 2 (GSM)"     end
        if (ret == "iPad2,3") then deviceName   = "iPad 2 (CDMA)"    end
        if (ret == "iPad2,5") then deviceName   = "iPad mini"        end
        if (ret == "iPad3,1") then deviceName   = "iPad 3"           end
        if (ret == "iPad3,4") then deviceName   = "iPad 4"           end
        
        if (ret == "i386") then deviceName      = "Simulator"        end
        if (ret == "x86_64") then deviceName    = "Simulator"        end
	end
	
    INFO("[zzy.cUtils.getDeviceModel][%s]", deviceName)
	return deviceName
end

--custompara一般是定义在anysdk或者易接中的。对于没有使用这两个sdk的包，获取到的是""
--如果用户在android.manifest或者ios的info.plist中定义了customParam字段，则会使用这个值来覆盖上面步骤中获取到的�?
function zzy.cUtils.getCustomParam()
	local ret = cc.libPlatform:getInstance():getCustomParam() --先看sdk中是否有定义
	
    local metaData = zzy.cUtils.getMetaData("customParam") --再看android的manifest/ios的info.plist中是否有定义，有则覆￿
    if metaData ~= "" then
        ret = metaData
    end
    
    INFO("[zzy.cUtils.getCustomParam]"..ret or "")
	
	return ret
end

--custompara一般是定义在anysdk或者易接中的。对于没有使用这两个sdk的包，获取到的是""
--如果用户在android.manifest或者ios的info.plist中定义了customParam字段，则会使用这个值来覆盖上面步骤中获取到的�?
function zzy.cUtils.getYJPayType()

    local ret = ""
    local metaData = zzy.cUtils.getMetaData("payType") --再看android的manifest/ios的info.plist中是否有定义，有则覆￿
    if metaData ~= "" then
        ret = metaData
    end
    
    INFO("[zzy.cUtils.getYJPayType]"..ret or "")
	
	return ret
end

--从android.manifest或者ios的info.plist中根据key获取value，如果没有定义则返回""
function zzy.cUtils.getMetaData(key)
	local ret = ""
	
	if luaj then
		local args = {key}
		local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getMetaData", args, sigs)
		if _ok then
            if _ret ~= "" and _ret ~= 0 and _ret ~= "0" then
                ret = _ret
            end
		end
	elseif luaoc then
		WARNING("ios没有实现getMetaData!!!")
	end
	
    INFO("[zzy.cUtils.getMetaData][key=%s][value=%s]", key, ret)
    
	return ret
end

function zzy.cUtils.isBcAllowed()
    INFO("[zzy.cUtils.isBcAllowed]")
    local packageName = zzy.cUtils.getPackageName()
    
    if IS_IN_REVIEW then --ios审核版本,不用beecloud
        INFO("[zzy.cUtils.isBcAllowed]review false")
        return false
    end
    
    if not _G_CONFIG_JSON then
        INFO("[zzy.cUtils.isBcAllowed]not _G_CONFIG_JSON false")
        return false
    end
    
    if not _G_CONFIG_JSON.bcVersions then
        INFO("[zzy.cUtils.isBcAllowed]not _G_CONFIG_JSON.bcVersions false")
        return false
    end
    
    if not _G_CONFIG_JSON.bcVersions[packageName] then
        INFO("[zzy.cUtils.isBcAllowed]not _G_CONFIG_JSON.bcVersions[%s] false", packageName)
        return false
    end
    
    local curVer = zzy.cUtils.getVersionCode()
    local bcVer = _G_CONFIG_JSON.bcVersions[packageName]
    
    if bcVer then
        INFO("[zzy.cUtils.isBcAllowed]curver=%s, bcver=%s", tostring(curVer), tostring(bcVer))
        if zzy.cUtils.compareVersion(curVer, bcVer) <= 0 then --如果远程配置了bcVer，并￿=curVer，则开启bc
            return true
        end        
    end
    
    return false
end

function zzy.cUtils.compareVersion(ver1, ver2)
    INFO("[zzy.cUtils.compareVersion]ver1=%s, ver2=%s", ver1, ver2)
    local verTable1 = zzy.cUtils.split(ver1, "%p")
    local verTable2 = zzy.cUtils.split(ver2, "%p")
    
    local power1 = verTable1[1]*10000 + verTable1[2]*100 + verTable1[3]
    local power2 = verTable2[1]*10000 + verTable2[2]*100 + verTable2[3]
    
    return power1 - power2
end

--传入字符串和分隔符，返回分割后的table
function zzy.cUtils.split(str, spe)      
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

function zzy.cUtils.openUrl()
end

function zzy.cUtils.getDeviceID()
    return zzy.cUtils.getIdfa()
end

function zzy.cUtils.getVersion()
    return "1.0.0"
end

function zzy.cUtils.isDebug()
    return false
end

function zzy.cUtils.getDeviceSystem()
end

function zzy.cUtils.removeFile()
end

function zzy.cUtils.writeFileWithString()
end

function zzy.cUtils.bsPatch()
end

function zzy.cUtils.download()
end

function zzy.cUtils.doString()
end

function zzy.cUtils.cancelLocalNotifications()
end

function zzy.cUtils.sendToFriendLua()
end

function zzy.cUtils.installApk()
end

function zzy.cUtils.getMemory()
end

function zzy.cUtils.reStart()
end

function zzy.cUtils.getDirFiles()
end

function zzy.cUtils.getAppConfig()
    return ""
end

function zzy.cUtils.getIdfa()
	local ret = "865166029722645"
	
	if luaj then
        local imei = zzy.cUtils.getIMEI()
		local imsi = zzy.cUtils.getIMSI()
        local mac = zzy.cUtils.getMac()
        ret = imei.."_"..imsi.."_"..mac
	elseif luaoc then
		local args = {["para"]="para"}
		local _ok,_ret  = luaoc.callStaticMethod("LuaOcBridge", "getIdfa", args)
		if _ok then
			ret = _ret
		end
	end
    
    if luaj or luaoc then
        release_print("[getIdfa]"..ret)
    else
        print("[getIdfa]"..ret)
    end
    
	return ret
end

function zzy.cUtils.tdAdTrace_onLogin(userid)
    if luaj then
        local args = {tostring(userid)}
        local sigs = "(Ljava/lang/String;)V"
        local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/TalkingDataAdapter", "onLogin", args, sigs)
    elseif luaoc then
        
    end
end

function zzy.cUtils.tdAdTrace_onPaySuccess(userid, order, price, priceType, payType)
    if luaj then
        local args = {tostring(userid),tostring(order), tonumber(price), tostring(priceType), tostring(payType)}
        local sigs = "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;)V"
        local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/TalkingDataAdapter", "onPaySuccess", args, sigs)
    elseif luaoc then
        
    end
end

function zzy.cUtils.getIMEI()
    INFO("[%s]", "Utils.getIMEI")

	local ret = "imei"
	
	if luaj then
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getIMEI", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
		
	end
	
	return ret
end

function zzy.cUtils.getIMSI()
    INFO("[%s]", "Utils.getIMSI")

	local ret = "imsi"
	
	if luaj then
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getIMSI", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
		
	end
	
	return ret
end

function zzy.cUtils.getMac()
    INFO("[%s]", "Utils.getMac")

	local ret = "mac"
	
	if luaj then
		local args = {}
		local sigs = "()Ljava/lang/String;"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "getMac", args, sigs)
		if _ok then
			ret = _ret
		end
	elseif luaoc then
		
	end
	
	return ret
end

function zzy.cUtils.restartApp()
    INFO("[%s]", "Utils.restartApp")

	if luaj then
        local args = {}
		local sigs = "()V"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "restartApplication", args, sigs)
		if _ok then
			ret = _ret
		end
    end
end

function zzy.cUtils.finishActivity()
    INFO("[%s]", "Utils.finishActivity")

	if luaj then
        local args = {}
		local sigs = "()V"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "finishActivity", args, sigs)
		if _ok then
			ret = _ret
		end
    end
end

function zzy.cUtils.testJavaCrash()
    INFO("[%s]", "Utils.testJavaCrash")

	if luaj then
        local args = {}
		local sigs = "()V"
		local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/Utils", "testJavaCrash", args, sigs)
		if _ok then
			ret = _ret
		end
    end
end

function zzy.cUtils.sendImage()
    INFO("[%s]", "Utils.sendImage")

	local ret = "error"	
    local function cbGetImage(imageData)
        INFO("[%s]", "[zzy.cUtils.sendImage][cbGetImage]")
        if imageData == nil or imageData == "" then
            INFO("[%s]", "Utils.sendImage: cancel")
            return
        end

        imageData = imageData or ""
        --INFO("[IMAGE][%d]%s", string.len(imageData), imageData)
        INFO("[IMAGE.LEN][%d]", string.len(imageData))

        local function cbPostImage(isOk, msg)
            local _msg = msg or ""
            INFO("[cbPostImage]"..msg)

            if msg == nil or msg == "" then
                return
            end
            
            local msgTable = json.decode(msg)
            ch.UIManager:showMsgBox(1,true,msgTable.error,function()
                end,nil,nil,nil)
            return
        end

        local channelType = zzy.cUtils.getCustomParam()
        local serverId = tostring(SERVER_ID)
        local playerId = tostring(PLAYER_ID)
        local playerUnid = tostring(ch.PlayerModel:getPlayerUnid())
        local jsonTable = {imgSrc = imageData}
        local jsonImageStr = json.encode(jsonTable)
        
        POST_URL = "http://gjlogin.hzfunyou.com:11001/AppManager/addReview"
        postReq = string.format("%s?appId=%s&serverId=%s&playerId=%s&playerUnid=%s", POST_URL,channelType,serverId,playerId,playerUnid)

        zzy.cUtils.post(postReq, jsonImageStr, cbPostImage)
    end

    local maxWidth = 600
    local maxHeigh = 800
    local qualityRatio = 100
	if luaj then
        --ch.UIManager:showWaiting(true)
        local args = {cbGetImage, maxWidth, maxHeigh, qualityRatio}
        local sigs = "(IFFF)V"
        local _ok,_ret  = luaj.callStaticMethod("com/funyou/utils/PhotosManager", "getScreenShot", args, sigs)
        if _ok then
            ret = _ret
        end
    elseif luaoc then
        --ch.UIManager:showWaiting(true)

        local args = {["scriptHandler"]=cbGetImage, ["maxWidth"]=maxWidth, ["maxHeigh"]=maxHeigh, ["qualityRatio"]=qualityRatio}
    
        local _ok,_ret  = luaoc.callStaticMethod("LaunchCameraManager", "registerScriptHandler", args)
        if _ok then
            ret = _ret
        end
    end
	
	return ret
end

function zzy.cUtils.ToBase64(source_str)
    if true then return source_str end


	local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local s64 = ''
	local str = source_str
	while # str > 0 do
		local bytes_num = 0
		local buf = 0
		for byte_cnt = 1, 3 do
			buf =(buf * 256)
			if # str > 0 then
				buf = buf + string.byte(str, 1, 1)
				str = string.sub(str, 2)
				bytes_num = bytes_num + 1
			end
		end
		for group_cnt = 1,(bytes_num + 1) do
			local b64char = math.fmod(math.floor(buf / 262144), 64) + 1
			s64 = s64 .. string.sub(b64chars, b64char, b64char)
			buf = buf * 64
		end
		for fill_cnt = 1,(3 - bytes_num) do
			s64 = s64 .. '='
		end
	end
	return s64
end

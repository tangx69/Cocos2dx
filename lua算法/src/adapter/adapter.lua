ADAPTER = true

require "src.adapter.zzy_cUtils"

local LOG_LEVEL_E = {
    "ERROR",
    "WARNING",
    "DEBUG",
}

--配置

--1:ERROR
--2:WARNING
--3:INFO
--4:DEBUG
LOG_LEVEL = 0

 --是否白名单
 local idfa = zzy.cUtils.getIdfa()
 for k,v in pairs(_G_CONFIG_JSON.whitelist or {}) do
     if string.find(idfa, v) then
        LOG_LEVEL = 4
        break
     end
 end


md5.sumhexa = function(str)
    local sum_hex = cc.CppAdapter:hexdigest(str)
    print("[MD5.SUMHEXA]input="..str)
    print("[MD5.SUMHEXA]output="..sum_hex)
    return sum_hex
end
--print(md5.sumhexa("123"))

-- tgx

if true then
local _CTA = cc.TextureCache.addImage
cc.TextureCache.addImage = function(...)
    local args = {...}
    local tex = args[1]:getTextureForKey(args[2])
    
--    if "res/icon/skill_01.png" == args[2] then
--        INFO("XXXXXX")
--    end

    if (#args == 3 and type(args[3]) == "function") then
        local function callback()
            local tex = args[1]:getTextureForKey(args[2])
            
            if tex ~= nil and type(args[3]) == "function" then
                args[3](tex)
            end
        end

        local tex = args[1]:getTextureForKey(args[2])
        if tex == nil then
            --_CTA(args[1], args[2])
        else
            return args[3](tex)
        end
        
        --_CTA(args[1], args[2])
        cc.TextureCache.addImageAsync(args[1], args[2], callback)
    else
        cclog("------------------")
        _CTA(...)
    end
end

else

-- 对异步加载图片做检查
local _CTA = cc.TextureCache.addImage
cc.TextureCache.addImage = function(...)
    local args = {...}
    if #args == 3 and type(args[3]) == "function" then
        local tex = args[1]:getTextureForKey(args[2])
        if tex ~= nil then
            return args[3](tex)
        end
    end
    return _CTA(...)
end

end

zzy.Sdk.getFlag = function()
    return cc.libPlatform:getInstance():getFlag()
end

local _ICE = zzy.CocosExtra.isCobjExist
zzy.CocosExtra.isCobjExist = function(...)
    local args = {...}
    return _ICE(zzy.CocosExtra, unpack(args))
end

local _SNBN = zzy.CocosExtra.seekNodeByName
zzy.CocosExtra.seekNodeByName = function(...)
    local args = {...}
    return _SNBN(zzy.CocosExtra, unpack(args))
end

local _GMDFC = zzy.CocosExtra.getMovementDataFrameCount
zzy.CocosExtra.getMovementDataFrameCount = function(...)
    local args = {...}
    return _GMDFC(zzy.CocosExtra, unpack(args))
end


local one_msg_len = 800
local function logsplite(str)
    local len = string.len(str)
    if len > one_msg_len then
        cclog("%s", string.sub(str, 1, one_msg_len))
        logsplite(string.sub(str, one_msg_len+1, len))
    else
        cclog("%s", str)
    end
end

function DEBUG(...)
    if LOG_LEVEL and LOG_LEVEL >= 4 then
        local args = {...}
        args[1] = "[DEBUG]"..args[1]
        cclog(unpack(args))
        --log2File(string.format(unpack(args)))
    end
end

function INFO(...)
    if LOG_LEVEL and LOG_LEVEL >= 3 then
        local args = {...}
        args[1] = "[INFO]"..args[1]
        --logsplite(unpack(args))
        logsplite(string.format(unpack(args)))
        --log2File(string.format(unpack(args)))
    end
end

function WARNING(...)
    if LOG_LEVEL and LOG_LEVEL >= 2 then
        local args = {...}
        args[1] = "[WARNING]"..args[1]
        cclog(unpack(args))
        --log2File(string.format(unpack(args)))
    end
end

function ERROR(...)
    if LOG_LEVEL and LOG_LEVEL >= 1 then
        local args = {...}
        args[1] = "[ERROR]"..args[1]
        cclog(unpack(args))
        --log2File(string.format(unpack(args)))
    end
end


local logFileName = "log_"..os.date("%Y%m%d%H%M%S",os_clock())..".txt"
local errorDict = {}
-- for CCLuaEngine traceback
function log2File(msg)
    errorDict["t:"..os.date("%Y-%m-%d %H:%M:%S",os_clock())] = tostring(msg)
    cc.FileUtils:getInstance():writeToFile(errorDict, logFileName)
end

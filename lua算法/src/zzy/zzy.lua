zzy = zzy or {}

-- 查找额外搜索路径
if cc.FileUtils:getInstance():isFileExist("docpath") then
    cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getStringFromFile("docpath"))
end

-- 获取时间
os_clock = require("socket").gettime

_SERVER_TIME_DIS = 0
os_time = function()
    return os_clock() + _SERVER_TIME_DIS
end

-- 前后台切换
__G__ONBACKGROUND__ = function(back)
    local evt = {type = zzy.Events.BackgroundEventType}
    
    if back then
      INFO("__G__ONBACKGROUND__ back")  
    else
      INFO("__G__ONBACKGROUND__ force")  
      cc.Device:setKeepScreenOn(true)
    end
    evt.isBack = back
    zzy.EventManager:dispatch(evt)
end

-- cclog
cclog = function(...)
    if zzy.config.debugMode == 0  then return end
    local args = {...}
    args[1] = tostring(args[1])
    print(string.format(unpack(args)))
end

md5.sumhexa = function(k)
    k = md5.sum(k)
    return (string.gsub(k, ".", function (c)
        return string.format("%02x", string.byte(c))
    end))
end

local errorLogFileName = "errorlog."..os.date("%Y%m%d%H%M%S",os_clock())..".log"
local errorDict = {}
-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    
    errorDict["t:"..os.date("%Y-%m-%d %H:%M:%S",os_clock())] = tostring(msg) .. ">>>>" .. debug.traceback()
    --cc.FileUtils:getInstance():writeToFile(errorDict, cc.FileUtils:getInstance():getWritablePath() .. errorLogFileName)
    
    return msg
end

--[[
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
]]--


local classPath = {}

---
-- ui基类
-- @field [parent=#zzy] uiViewBase#uiViewBase uiViewBase
classPath.uiViewBase = "src/zzy/uiview/uiViewBase"
---
-- @field [parent=#zzy] Events#Events Events
classPath.Events = "src/zzy/Events"
---
-- @field [parent=#zzy] config#config config
classPath.config = "src/zzy/config"

---------------------------------------------------
-----------------MANAGER---------------------------
---------------------------------------------------

---
-- @field [parent=#zzy] EventManager#EventManager EventManager
classPath.EventManager = "src/zzy/manager/EventManager"
---
-- @field [parent=#zzy] BindManager#BindManager BindManager
classPath.BindManager = "src/zzy/manager/BindManager"
---
-- @field [parent=#zzy] DebugManager#DebugManager DebugManager
classPath.DebugManager = "src/zzy/manager/DebugManager"
---
-- @field [parent=#ch] EffectResManager#EffectResManager EffectResManager
classPath.EffectResManager = "src/zzy/manager/EffectResManager"
---
-- @field [parent=#zzy] NetManager#NetManager NetManager
classPath.NetManager = "src/zzy/manager/NetManager"

---------------------------------------------------
-----------------UTILS-----------------------------
---------------------------------------------------

---
-- @field [parent=#zzy] ZFileUtils#ZFileUtils FileUtils
classPath.FileUtils = "src/zzy/utils/ZFileUtils"
---
-- 字符串工具
-- @field [parent=#zzy] StringUtils#StringUtils StringUtils
classPath.StringUtils = "src/zzy/utils/StringUtils"
---
-- 权限设置工具
-- @field [parent=#zzy] PermissionUtils#PermissionUtils PermissionUtils
classPath.PermissionUtils = "src/zzy/utils/PermissionUtils"
---
-- 颜色工具
-- @field [parent=#zzy] ColorUtils#ColorUtils ColorUtils
classPath.ColorUtils = "src/zzy/utils/ColorUtils"
---
-- 本地加密存储工具
-- @field [parent=#zzy] LocalStorageUtils#LocalStorageUtils LocalStorageUtils
classPath.LocalStorageUtils = "src/zzy/utils/LocalStorageUtils"
---
-- 大任务处理工具
-- @field [parent=#zzy] BigTaskUtils#BigTaskUtils BigTaskUtils
classPath.BigTaskUtils = "src/zzy/utils/BigTaskUtils"
---
-- GUID生成工具
-- @field [parent=#zzy] GuidUtils#GuidUtils GuidUtils
classPath.GuidUtils = "src/zzy/utils/GuidUtils"
---
-- 时间工具
-- @field [parent=#zzy] TimerUtils#TimerUtils TimerUtils
classPath.TimerUtils = "src/zzy/utils/TimerUtils"
---
-- TABLE工具
-- @field [parent=#zzy] TableUtils#TableUtils TableUtils
classPath.TableUtils = "src/zzy/utils/TableUtils"
---
-- ui处理工具
-- @field [parent=#zzy] UIUtils#UIUtils UIUtils
classPath.UIUtils = "src/zzy/utils/UIUtils"

---
-- 两种动画混合导致出现的这个
-- @field [parent=#zzy] ExportJsonHelper#ExportJsonHelper ExportJsonHelper
classPath.ExportJsonHelper = "src/zzy/utils/ExportJsonHelper"

---------------------------------------------------
---------------c/c++ API---------------------------
---------------------------------------------------

---
-- cocos扩展方法
-- @field [parent=#zzy] CocosExtra#CocosExtra CocosExtra

---
-- socket连接
-- @field [parent=#zzy] Socket#Socket Socket
 
---
-- cUtils
-- @field [parent=#zzy] cUtils#cUtils cUtils
-- 
---
-- Sdk
-- @field [parent=#zzy] Sdk#Sdk Sdk

local loadedModules = {}
setmetatable(zzy,{__index = function(t, k)
    if not classPath[k] then return nil end
    table.insert(loadedModules, k)
    local module = require(classPath[k])
    zzy[k] = module
    return module
end})

---
-- 清除所有已加载内容
-- @function [parent=#zzy] clean
zzy.clean = function()
    if zzy.config.debugMode == 1 then zzy.DebugManager:clean() end
    zzy.BindManager:clean()
    for i,k in ipairs(loadedModules) do
        zzy[k] = nil
        package.loaded[classPath[k]] = nil
    end
    package.loaded["src.zzy.zzy"] = nil
end

if zzy.config.debugMode == 1  then zzy.DebugManager:init() end
--if zzy.config.RUN_DEMO_UI then cc.SpriteFrameCache:getInstance():addSpriteFrames("res/demoui/demoui.plist") end


return zzy
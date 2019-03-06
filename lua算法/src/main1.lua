md5 = {}

require "src.cocos.init"
require "src.adapter.code"

local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if (cc.PLATFORM_OS_ANDROID == targetPlatform) then
    print("is android")
    luaj = require "src.cocos.cocos2d.luaj"
elseif (cc.PLATFORM_OS_IPAD == targetPlatform or cc.PLATFORM_OS_IPHONE == targetPlatform) then
    print("is ios")
    luaoc = require "src.cocos.cocos2d.luaoc"
end

USE_SPINE = true --是否使用spine骨骼动画

require "src.adapter.preProc"
require "src.zzy.zzy"
require "src.adapter.adapter"

require "res.config.GameConfig"
require "res.language.Language"
require "src.clickhero.ch"

require "src.tinygame.tInit"


function log2Screen(...)
    if not PALYER_UNID or tostring(PALYER_UNID) ~= "1000047" then
        return
    end

    logLabels = logLabels or {}
    totalHeight = totalHeight or 0
    logIndex = logIndex or 1

    if logIndex >= 15 then
        for k,label in pairs(logLabels) do
            label:removeFromParent()
        end

        logLabels = {}
        logIndex = 1
        totalHeight = 0
    end

    if cc.Director:getInstance():getRunningScene() == nil then
        return
        --cc.Director:getInstance():runWithScene(cc.Scene:create())
    end
    local scene = cc.Director:getInstance():getRunningScene()
    local label = cc.Label:createWithSystemFont("", "", 18)
    label:setColor(cc.c3b(0, 200, 0))
    label:enableOutline(cc.c4b(0,0,0,255),3)
    label:setAnchorPoint(cc.p(0.5, 0.5))
    label:setString(string.format(...))
    label:setPosition(label:getContentSize().width/2,480-label:getContentSize().height/2-totalHeight)
    totalHeight = totalHeight + label:getContentSize().height
    scene:addChild(label)
    logLabels[logIndex] = label
    logIndex = logIndex + 1
end

local savepath = cc.FileUtils:getInstance():getWritablePath()
local logFileName = savepath.."/".."xygj_log_"..os.date("%Y%m%d%H%M%S",os_clock())..".txt"
local errorDict = {}
-- for CCLuaEngine traceback
function _log2File(msg)
    LOG_INDEX = LOG_INDEX or 1
    LOG_INDEX = LOG_INDEX + 1
    errorDict["index:"..LOG_INDEX] = tostring(msg)
    cc.FileUtils:getInstance():writeToFile(errorDict, logFileName)
end

function cclog(...)
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        print(string.format(...))
    else
        release_print(string.format(...))
    end
    --_log2File(string.format(...))
    --log2Screen(...)
end

cc.Device:setKeepScreenOn(true)

zzy.config.linkSocket = false --不联网

local function main()    
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    zzy.cUtils.cancelLocalNotifications()
    local director = cc.Director:getInstance()
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_MAC or
        cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        --director:setDisplayStats(true)
    else
         director:setDisplayStats(false)
    end 
   
    director:setAnimationInterval(1.0 / 30)
    
    director:getOpenGLView():setDesignResolutionSize(640, 1136, cc.ResolutionPolicy.SHOW_ALL)
    gameScene = cc.Scene:create()
    
    -- 启动场景
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end

    --  网络测试 
    math.randomseed(os_clock())
    local totalFrame = 0
    local count=0
    local _lastTime = os_clock()
    local _timeInterval = 5
    local lastcheck=false --上次检测结果 true为加速 只有2次都出问题才认为加速 防止自动同步系统时间导致误判

    if _G_TICK then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_G_TICK)
    end
    _G_TICK = director:getScheduler():scheduleScriptFunc(function()
        count=count+1
        if  count==math.floor(_timeInterval*30*1.3)  then
            if  os_clock() < _lastTime + _timeInterval then
               if lastcheck ==false then
                     lastcheck=true
               else
                   ch.fightRoleLayer:pause()
                   local realFps = count / (os_clock() - _lastTime)
                   local fps = 30
                   local ratio = realFps / fps
                   ch.UIManager:showMsgBox(1,true,Language.src_main_1,function()
                        os.exit()
                        return
                   end)
               end
            else
                lastcheck=false
            end
            _lastTime = os_clock()
            count=0
        end

        -- 大任务处理器
        zzy.BigTaskUtils:loop()
        -- 时间工具
        zzy.TimerUtils:update()
       
        -- 自动移除不在使用的纹理
        if totalFrame % 300 == 0 then
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
        
        if totalFrame % 300 == 0 then
            cc.AnimationCache:destroyInstance()
            ch.CommonFunc:delCardSkes()
        end
        -- 抛出帧频时间
        local tickEvt = zzy.Events:createTickEvent()
        tickEvt.frameCount = totalFrame
        zzy.EventManager:dispatch(tickEvt)
        totalFrame = totalFrame + 1
         --定时发送指令和控制
        ch.TimerController:update()
    end, 0, false)
    -- cocostudio配置
    zzy.uiViewBase.DEFAULT_CSB_PATH_BASE = "res/ui/"


    local loginView = ch.LoginView:new()
    gameScene:addChild(loginView)
    loginView:init(gameScene)
end



local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end


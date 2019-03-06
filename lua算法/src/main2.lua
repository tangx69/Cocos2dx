require "src.cocos.init"
require "src.zzy.zzy"

-- 重载view脚本
if __G_NOT_FIRST_ENTER then
    package.loaded["src.clickhero.ch"] = nil
    return require "src.clickhero.ch"
end

__G_NOT_FIRST_ENTER = true

local resLoadedFun = nil

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    
    -- initialize director
    local director = cc.Director:getInstance()

    --turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)

    cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1200, 1136, cc.ResolutionPolicy.FIXED_HEIGHT)  
    
    
    math.randomseed(os_clock())
    local totalFrame = 0
    director:getScheduler():scheduleScriptFunc(function()
        -- 大任务处理器
        zzy.BigTaskUtils:loop()
        -- 时间工具
        zzy.TimerUtils:update()

        -- 自动移除不在使用的纹理
        if totalFrame % 300 == 0 then
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        end
        -- 抛出帧频时间
        local tickEvt = zzy.Events:createTickEvent()
        tickEvt.frameCount = totalFrame
        zzy.EventManager:dispatch(tickEvt)
        totalFrame = totalFrame + 1
    end, 0, false)
    
    local gameScene = cc.Scene:create()
    local n = cc.Node:create()
    n:setName("a1")
    gameScene:addChild(n)
    local m = cc.Node:create()
    m:setName("a2")
    n:addChild(m)
    zzy.TimerUtils:setTimeOut(0.1,function()
        n:removeFromParent()
        m:removeFromParent()
    end)
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
end

cclog = function(...)
    local args = {...}
    args[1] = tostring(args[1])
    print(string.format(unpack(args)))
end

function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
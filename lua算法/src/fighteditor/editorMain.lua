require "src.cocos.init"
require "src.zzy.zzy"
require "src.language.Language"
require "res.config.GameConfig"
require "src.clickhero.ch"


-- 重载view脚本
if __G_NOT_FIRST_ENTER then
    package.loaded["src.clickhero.ch"] = nil
    return require "src.clickhero.ch"
end
__G_NOT_FIRST_ENTER = true

local function main()
    collectgarbage("collect")
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local director = cc.Director:getInstance()
    director:setDisplayStats(true)
    director:setAnimationInterval(1.0 / 30)
    director:getOpenGLView():setDesignResolutionSize(640, 1136, cc.ResolutionPolicy.FIXED_WIDTH)
    
    local totalFrame = 0
    director:getScheduler():scheduleScriptFunc(function()
        -- 大任务处理器
        zzy.BigTaskUtils:loop()
        -- 时间工具
        zzy.TimerUtils:update()
        -- 自动移除不在使用的纹理
--        if totalFrame % 300 == 0 then
--            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
--        end
        -- 抛出帧频时间
        local tickEvt = zzy.Events:createTickEvent()
        tickEvt.frameCount = totalFrame
        zzy.EventManager:dispatch(tickEvt)
        totalFrame = totalFrame + 1
    end, 0, false)
    
    --create scene 
    local gameScene = cc.Scene:create()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(gameScene)
    else
        cc.Director:getInstance():runWithScene(gameScene)
    end
    
    -- 临时测试数据
--    local str = ch.ModelManager:getData()
--    ch.ModelManager:init(str)
    ch.LevelModel:init(ch.ModelManager.basedata)
    ch.StatisticsModel:init(ch.ModelManager.basedata)
    ch.PartnerModel:init(ch.ModelManager.basedata)
    ch.TotemModel:init(ch.ModelManager.basedata)
    ch.RunicModel:init(ch.ModelManager.basedata)
    ch.MagicModel:init(ch.ModelManager.basedata)
    ch.PowerModel:init(ch.ModelManager.basedata)
    ch.FamiliarModel:init(ch.ModelManager.basedata)
    ch.LevelModel:setCurLevel(5)
    ch.UserTitleModel:init()
    
    require("src/fighteditor/common")
    require("src/fighteditor/scene")
    require("src/fighteditor/role")
    require("src/fighteditor/view")
    
    ch.fightRoleLayer:preLoadResource()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("editor_res/EditorRes.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/ui/aaui_png/common02.plist")
    zzy.uiViewBase.DEFAULT_CSB_PATH_BASE = "editor_res/"
    local onEnterScene = function()
        gameScene:unregisterScriptHandler()
        ch.UIManager:init(gameScene)
        ch.LevelController:debug()

        gameScene:addChild(zzy.uiViewBase:new("fightEditorMain"))
    end
    ch.LevelController.mode = ch.LevelController.GameMode.normal
    gameScene:registerScriptHandler(onEnterScene)
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end

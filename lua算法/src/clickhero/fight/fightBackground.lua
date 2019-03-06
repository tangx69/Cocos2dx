local background = {}

local SCENE_IMAGE_FLIE_PATH = "res/scene/%s.png"

local inited = false
local config
local batchNode
local frontLayer
local loadingLayer
local loadingAni
local loadingAniWait = false

local skyLayer
local monLayer
local grdLayer
local config
local currentPx = 0
local completeCallback = nil


local sceneImage ={
    "anyemilin",
    "jinglingsenlin",
    "linhaixueyuan",
    "longku",
    "luoripingyuan",
    "mengxianghaian",
    "tiankongzhicheng",
    "yishijie",
    "yueguangzhiqiu",
    "zhuoreshamo"
}


function background:playGoldBossReady(type,func)
    local zName = type == 1 and "tx_zaoyu" or "tx_zaoyuhunshi"
    ch.RoleResManager:loadEffect(zName,function()
        local ani = ccs.Armature:create(zName)
        local dirSize = cc.Director:getInstance():getWinSize()
        ani:setPosition(dirSize.width/2, dirSize.height/2 + 200)
        ani:getAnimation():play("play")
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                ani:removeFromParent()
                ch.RoleResManager:releaseEffect(zName)
                local dName = type == 1 and "tx_zhunbeiduoqu" or "tx_zhunbeiduoquhunshi"
                ch.RoleResManager:loadEffect(dName)
                local ani1 = ccs.Armature:create(dName)
                local dirSize = cc.Director:getInstance():getWinSize()
                ani1:setPosition(dirSize.width/2, dirSize.height/2 + 100)
                ani1:getAnimation():play("play",-1,1)
                ani1:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
                    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                        ani1:removeFromParent()
                        ch.RoleResManager:releaseEffect(dName)
                        if func then func() end
                    end
                end)
                ch.UIManager:getAutoFightLayer():addChild(ani1, 9)
            end
        end)
        ch.UIManager:getAutoFightLayer():addChild(ani, 9)
    end)
end

function background:playBossReady(func)
    ch.RoleResManager:loadEffect("bossready_tx",function()
        local ani = ccs.Armature:create("bossready_tx")
        local dirSize = cc.Director:getInstance():getWinSize()
        ani:setPosition(dirSize.width/2, dirSize.height/2 + 100)
        ani:getAnimation():play("play")
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                ani:removeFromParent()
                ch.RoleResManager:releaseEffect("bossready_tx")
                if func then func() end
            end
        end)
        ch.UIManager:getAutoFightLayer():addChild(ani, 9)
    end)
end

function background:playWarpathReady(func)
    ch.RoleResManager:loadEffect("bossready_tx",function()
        ch.RoleResManager:loadEffect("tx_daojishishuoming")
        local ani = ccs.Armature:create("bossready_tx")
        local dirSize = cc.Director:getInstance():getWinSize()
        ani:setPosition(dirSize.width/2, dirSize.height/2 + 100)
        ani:getAnimation():play("play")
        local ani2 = ccs.Armature:create("tx_daojishishuoming")
        ani2:setPosition(dirSize.width/2, dirSize.height/2 + 125)
        ani2:getAnimation():play("play")
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                ani:removeFromParent()
                ani2:removeFromParent()
                ch.RoleResManager:releaseEffect("tx_daojishishuoming")
                ch.RoleResManager:releaseEffect("bossready_tx")
                if func then func() end
            end
        end)
        ch.UIManager:getAutoFightLayer():addChild(ani, 9)
        ch.UIManager:getAutoFightLayer():addChild(ani2, 9)
    end)
end


function background:playSamsaraEffect(func)
    ch.RoleResManager:loadEffect("jiesuo_tx",function()
        local ani = ccs.Armature:create("jiesuo_tx")
        local dirSize = cc.Director:getInstance():getWinSize()
        ani:setPosition(dirSize.width/2, dirSize.height/2 + 100)
        ani:getAnimation():play("wujinzhuansheng")
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                ani:removeFromParent()
                ch.RoleResManager:releaseEffect("jiesuo_tx")
                if func then func() end
            end
        end)
        ch.UIManager:getAutoFightLayer():addChild(ani, 9)
    end)
end

function background:playDoubleDPSEffect(index,func)
    ch.RoleResManager:loadEffect("tx_gongjijiabei",function()
        local node = cc.Node:create()
        local ani = ccs.Armature:create("tx_gongjijiabei")
        ani:getAnimation():setSpeedScale(0.3)
        ani:getAnimation():play("play")
        local dirSize = cc.Director:getInstance():getWinSize()
        local text = ccui.TextBMFont:create(index, "res/ui/aaui_font/font_red.fnt")
        text:setPosition(-20,-45)
        text:setAnchorPoint(0.5,0.5)
        node:addChild(ani)
        node:addChild(text)
        node:setPosition(dirSize.width/2, dirSize.height/2)
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
                node:removeFromParent()
                ch.RoleResManager:releaseEffect("tx_gongjijiabei")
                if func then func() end
            end
        end)
        ch.UIManager:getSysPopupLayer():addChild(node, 9)
    end)
end

function background:playVictoryInWarpath(index,func)
    ch.RoleResManager:loadEffect("tx_wujinzhengtu",function()
        local node = cc.Node:create()
        local ani = ccs.Armature:create("tx_wujinzhengtu")
        ani:getAnimation():setSpeedScale(0.5)
        ani:getAnimation():play("shengli_appear")
        local dirSize = cc.Director:getInstance():getWinSize()
        local text = ccui.TextAtlas:create(index,"res/ui/aaui_font/num_boss.png",34,64,'0')
        text:setPosition(-20, -65)
        text:setAnchorPoint(1,0.5)
        node:addChild(ani)
        node:addChild(text)
        node:setPosition(dirSize.width/2, dirSize.height/2 + 100)
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
                if string.find(movementID, "disappear") then
                    node:removeFromParent()
                    ch.RoleResManager:releaseEffect("tx_wujinzhengtu")
                    if func then func() end
                elseif string.find(movementID, "appear") then
                    ani:getAnimation():play("shengli_disappear")
                end
            end
        end)
        ch.UIManager:getAutoFightLayer():addChild(node, 9)
        ch.SoundManager:play("shengli")
    end)
end


function background:showRandomScene(onComplete)
    local sceneName = self:getRandomSceneName()
    self:showScene(sceneName,nil,nil,onComplete)
end

function background:clearBackground()
	if batchNode then
        batchNode:removeFromParent()
        batchNode = nil
        skyLayer = nil
        monLayer = nil
        grdLayer = nil
	end
	if frontLayer then
	   frontLayer:removeFromParent()
       frontLayer = nil
    end    
end

function background:getRandomSceneName()
    local count = #sceneImage
    return sceneImage[math.random(1,count)]
end

function background:showScene(sceneName,loadAni,level,onComplete)    
    completeCallback = onComplete
	config = ch.editorConfig:getSceneConfig(sceneName)

    if IS_IN_REVIEW and (not USE_SPINE) then
        sceneName = "shenhe_yueguangzhiqiu"
        config = ch.editorConfig:getSceneConfig("yueguangzhiqiu")
    end

    local oldBatchNode = batchNode
	if batchNode then
        batchNode = nil
        frontLayer:removeFromParent()
        frontLayer = nil
    end
    
    if not loadingLayer then
        local dirSize = cc.Director:getInstance():getWinSize()
        loadingLayer = ccui.Layout:create()
        loadingLayer:setContentSize(dirSize)
--        loadingLayer:setBackGroundColorType(1)
--        loadingLayer:setBackGroundColor(cc.c3b(255,255,255))
        ch.UIManager:getAutoFightLayer():addChild(loadingLayer, 8)
    end
    if loadAni == 1 then
        ch.RoleResManager:loadEffect("tx_guoguan")
        loadingAni = ccs.Armature:create("tx_guoguan")
        loadingAni:getAnimation():play("guoguan_appear")
        loadingLayer:setVisible(true)
        ch.SoundManager:play("guoguan")
    elseif loadAni == 2 then
        ch.RoleResManager:loadEffect("tx_tiaozhanshengli")
        loadingAni = ccs.Armature:create("tx_tiaozhanshengli")
        loadingAni:getAnimation():play("shengli_appear")
        loadingLayer:setVisible(true)
        ch.SoundManager:play("shengli")
    else
        --cc.Director:getInstance():getTextureCache():addImage(string.format(SCENE_IMAGE_FLIE_PATH, sceneName))
        loadingLayer:setVisible(false)
    end
    
    if loadAni ==1 or loadAni == 2 then
        --loadingAni:getAnimation():setSpeedScale(2)
        local dirSize = cc.Director:getInstance():getWinSize()
        loadingAni:setPosition(dirSize.width/2, dirSize.height/2 + 100)
        loadingLayer:addChild(loadingAni)
        local text = nil
        if level then
            text = ccui.TextAtlas:create(level,"res/ui/aaui_font/num_boss.png",34,64,'0')
            text:setPosition(dirSize.width/2, dirSize.height/2 + 22)
            loadingLayer:addChild(text)
        end
        loadingAni:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete then
                if string.find(movementID, "disappear") then
                    loadingLayer:setVisible(false)
                    loadingAni:removeFromParent()
                    loadingAni = nil
                    text:removeFromParent()
                    if loadAni == 1 then
                        ch.RoleResManager:releaseEffect("tx_guoguan")
                    else
                        ch.RoleResManager:releaseEffect("tx_tiaozhanshengli")
                    end
                    return completeCallback and completeCallback()
                elseif string.find(movementID, "appear") then
                    loadingAniWait = true
                end
            end
        end)
    end
    
    
    local onLoadImgDone = function(tex)
        if loadingAniWait then
            if loadAni == 1 then
                loadingAni:getAnimation():play("guoguan_disappear")
            elseif loadAni == 2 then
                loadingAni:getAnimation():play("shengli_disappear")
            end
            loadingAniWait = false
        end
        
        if oldBatchNode then oldBatchNode:removeFromParent() end
        
        batchNode = cc.SpriteBatchNode:createWithTexture(tex)
        --local dirSize2 = cc.Director:getInstance():getWinSize()
        --batchNode:setAnchorPoint(0.5,0.5)
        --batchNode:setContentSize(cc.size(dirSize2.width,dirSize2.height))
        --batchNode:setPositionX(dirSize2.width/2)
        --batchNode:setPositionY(dirSize2.height/2 + ch.editorConfig:getSceneGlobalConfig().baseh)
        batchNode:setPositionY(ch.editorConfig:getSceneGlobalConfig().baseh)
        ch.UIManager:getAutoFightLayer():addChild(batchNode, 1)

        local sf = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, 0, tex:getPixelsWide(), config.sky.h))
        skyLayer = cc.Sprite:createWithSpriteFrame(sf)
        skyLayer:setPositionY(config.sky.o)
        skyLayer:setAnchorPoint(cc.p(0,0))
        batchNode:addChild(skyLayer)
        local child = cc.Sprite:createWithSpriteFrame(sf)
        child:setAnchorPoint(cc.p(1,0))
        skyLayer:addChild(child)

        sf = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, config.sky.h, tex:getPixelsWide(), config.mon.h))
        monLayer = cc.Sprite:createWithSpriteFrame(sf)
        monLayer:setPositionY(config.mon.o)
        monLayer:setAnchorPoint(cc.p(0,0))
        batchNode:addChild(monLayer)
        local child = cc.Sprite:createWithSpriteFrame(sf)
        child:setAnchorPoint(cc.p(1,0))
        monLayer:addChild(child)

        sf = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, config.sky.h+config.mon.h, tex:getPixelsWide(), tex:getPixelsHigh()-config.sky.h-config.mon.h-config.frt.h))
        grdLayer = cc.Sprite:createWithSpriteFrame(sf)
        grdLayer:setAnchorPoint(cc.p(0,0))
        batchNode:addChild(grdLayer)
        local child = cc.Sprite:createWithSpriteFrame(sf)
        child:setAnchorPoint(cc.p(1,0))
        grdLayer:addChild(child)

        sf = cc.SpriteFrame:createWithTexture(tex, cc.rect(0, tex:getPixelsHigh()-config.frt.h, tex:getPixelsWide(), config.frt.h))
        frontLayer = cc.Sprite:createWithSpriteFrame(sf)
        frontLayer:setAnchorPoint(cc.p(0,0))
        frontLayer:setPositionY(ch.editorConfig:getSceneGlobalConfig().baseh+config.frt.o)
        ch.UIManager:getAutoFightLayer():addChild(frontLayer, 6)
        local child = cc.Sprite:createWithSpriteFrame(sf)
        child:setAnchorPoint(cc.p(1,0))
        frontLayer:addChild(child)
        self:_updateXTo(320)
        if not loadAni then
           if completeCallback then completeCallback() end
        end
    end
    
    local waitLoadImage 
    waitLoadImage = function(tex)
    	zzy.TimerUtils:setTimeOut(0,function()
    	   if loadingAniWait then
    	       onLoadImgDone(tex)
               tex:release()
               cc.Director:getInstance():getTextureCache():removeUnusedTextures()
           else
               waitLoadImage(tex)
    	   end
    	end)
    end
    
    cc.Director:getInstance():getTextureCache():addImage(string.format(SCENE_IMAGE_FLIE_PATH, sceneName), function(tex)
        if loadingAniWait or not loadAni then
            onLoadImgDone(tex)
            cc.Director:getInstance():getTextureCache():removeUnusedTextures()
        else
            tex:retain()
            waitLoadImage(tex)
        end
    end)
end


local lookToDebugViewer
function background:debugLook()
    if lookToDebugViewer then return end
    lookToDebugViewer = cc.DrawNode:create()
    lookToDebugViewer:drawDot(cc.p(0,0), 60, cc.c4b(1,1,1,1))
    lookToDebugViewer:setPositionY(ch.editorConfig:getSceneGlobalConfig().baseh + 100)
    ch.UIManager:getAutoFightLayer():addChild(lookToDebugViewer, 2)
end

function background:destoryDebugLook()
    if not lookToDebugViewer then return end
    lookToDebugViewer:removeFromParent()
    lookToDebugViewer = nil
end

function background:debugLookTo(px)
    if lookToDebugViewer then
        background:lookTo(px)
        lookToDebugViewer:setPositionX(px - self:getOffset() + 320)
    end
end

function background:clearRes()
    if loadingAni then
        loadingAni:removeFromParent()
        loadingAni = nil
    end
    ch.RoleResManager:releaseEffect("bossready_tx")
    ch.RoleResManager:releaseEffect("tx_tiaozhanshengli")
    ch.RoleResManager:releaseEffect("tx_guoguan")
end

function background:getOffset()
    return currentPx
end

function background:lookTo(px)
    local lookParams = ch.editorConfig:getSceneGlobalConfig()
    local difx = px - currentPx
    local speedMX = math.pow(lookParams.baseFllowSpeed, math.min(math.abs(difx) / lookParams.maxOffsetX, 1) * lookParams.fllowSpeedA / 1000)
    if speedMX > math.abs(difx) then
        self:_updateXTo(px)
    else
        local npx = currentPx + speedMX * (difx > 0 and 1 or -1)
        if npx > px + lookParams.maxOffsetX then
            npx = px + lookParams.maxOffsetX
        elseif  npx < px - lookParams.maxOffsetX then
            npx = px - lookParams.maxOffsetX
        end
        self:_updateXTo(npx)
    end
end

function background:_updateXTo(px)
    currentPx = px
    
    if not batchNode then return end
    
    grdLayer:setPositionX(-px % grdLayer:getContentSize().width)
    monLayer:setPositionX(config.mon.s * -px % monLayer:getContentSize().width)
    skyLayer:setPositionX(config.sky.s * -px % skyLayer:getContentSize().width)
    frontLayer:setPositionX(config.frt.s * -px % frontLayer:getContentSize().width)

    ch.fightRoleLayer:updateOffsetX(-px + 320)
    ch.clickLayer:updateOffsetX(-px + 320)
    ch.goldLayer:updateOffsetX(-px + 320)
end

function background:shock()
    -- 去掉震屏效果
    return 
--    if not batchNode then return end
--    local animation1 = cc.RotateBy:create(0.03,-3)
--    local animation2 = cc.RotateBy:create(0.03,6)
--    local animation3 = cc.RotateBy:create(0.03,-3)
--    local animation4 = cc.RotateBy:create(0.03,-1)
--    local animation5 = cc.RotateBy:create(0.03,2)
--    local animation6 = cc.RotateBy:create(0.03,-1)
--    local animation7 = cc.RotateBy:create(0.03,-2)
--    local animation8 = cc.RotateBy:create(0.03,4)
--    local animation9 = cc.RotateBy:create(0.03,-2)
--    local animation10 = cc.RotateBy:create(0.03,-1)
--    local animation11 = cc.RotateTo:create(0.03,0)
--    local seq = cc.Sequence:create(animation1,animation2,animation3,animation4,animation5,animation6,animation7,animation8,animation9,animation10,animation11)
--    local act = cc.Repeat:create(seq,1)
--    batchNode:stopAllActions()
--    batchNode:runAction(act)
end

return background
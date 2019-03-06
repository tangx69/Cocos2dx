local layer = {}
layer.CLICK_EVENT_TYPE = "CLICK_EVENT_TYPE" -- 点击事件

local _layer
local flyLayer
--local bombLayer
local bombs = nil

local clickCount = 0
local frameCount = 0

function layer:init()
    if _layer then return end
    _layer = ccui.Layout:create()
    _layer:setContentSize(cc.Director:getInstance():getWinSize())
    _layer:setTouchEnabled(true)
    ch.UIManager:getAutoFightLayer():addChild(_layer, 4)
    
    ch.RoleResManager:loadEffect("tx_dianjixiaoguo")
    
    _layer:addTouchEventListener(function(obj, evt)
        if evt == ccui.TouchEventType.began then
            if clickCount >= 6 then return end
            if ch.PowerModel:getPower() <= 0 then
                ch.UIManager:showUpTips(Language.src_clickhero_fight_clickLayer_1)
            else
                self:addClickEffect(obj:getTouchBeganPosition())
                self:click(true)
                clickCount = clickCount + 1
            end
        end
    end)

    flyLayer = cc.Layer:create() 
   -- bombLayer = cc.Layer:create() 
    flyLayer:setPositionY(ch.editorConfig:getSceneGlobalConfig().roleh)
    --bombLayer:setPositionY(ch.editorConfig:getSceneGlobalConfig().roleh)
    _layer:addChild(flyLayer)
--    _layer:addChild(bombLayer)
    bombs = {}
    local lastUpdateTime = os_clock()
    zzy.EventManager:listen(zzy.Events.TickEventType, function()
        if ch.fightRoleLayer:isPause() then return end
        local curT = os_clock()
        self:update(curT - lastUpdateTime)
        lastUpdateTime = curT
    end)
end

function layer:addClickEffect(from)
    local role = ch.fightRoleLayer:getNearestEnemy()
    if not role then return end
    local p = role:getBoneOffset("body")
    p = role:convertToWorldSpace(p)
    local to = ch.UIManager:getNavigationLayer():convertToNodeSpace(p)
    local scale = math.sqrt(math.pow(to.x - from.x,2)+math.pow(to.y - from.y,2))/340
    local angle = 90
    if to.y - from.y ~= 0 then
        angle = math.atan((to.x-from.x)/(to.y - from.y))
        if to.y - from.y < 0 then
            angle = 180 + angle * 180/math.pi
        else
            angle = angle * 180/math.pi
        end
    end
    local ani = ccs.Armature:create("tx_dianjixiaoguo")
    ani:setPosition(from)
    ani:setScaleY(scale)
    ani:setRotation(angle)
    ani:getAnimation():play("shandian1",-1,0)
    ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID) 
        if movementType == ccs.MovementEventType.complete then
            if movementID == "shandian1" then
                ani:getAnimation():play("shandian2",-1,0)
                local ani1 = ccs.Armature:create("tx_dianjixiaoguo")
                ani1:setPosition(to)
                ani1:getAnimation():play("bomb",-1,0)
                ani1:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
                    if movementType == ccs.MovementEventType.complete then
                        ani1:removeFromParent()
                    end
                end)
                ch.UIManager:getNavigationLayer():addChild(ani1)
            else
                ani:removeFromParent()
            end
        end
    end)
    ch.UIManager:getNavigationLayer():addChild(ani)
end


function layer:updateOffsetX(px)
    if not flyLayer then return end
    flyLayer:setPositionX(px)
    --bombLayer:setPositionX(px)
end

local nextAutoClickTime
local autoClickTS
local autoSpeed = 0

function layer:autoClick(timesPerSec)
    if timesPerSec > 0 then
        nextAutoClickTime = os_clock()
        autoClickTS = 1 / timesPerSec
        ch.StatisticsModel:setMaxClickSpeed(timesPerSec)
        autoSpeed = timesPerSec
    else
        autoClickTS = nil
        autoSpeed = 0
    end
end

local attackSpeedLevel = 1
local counterTime = 0
local counter = 0
local clickSpeed = 0

function layer:getClickSpeed()
    local now = os_clock()
    if now > counterTime + 1 then
        clickSpeed = counter / (now - counterTime)
        counterTime = now
        counter = 0
        if clickSpeed < 1 then
            attackSpeedLevel = 1
        elseif clickSpeed < 5 then
            attackSpeedLevel = 2
        else
            attackSpeedLevel = 3
        end
        ch.StatisticsModel:setMaxClickSpeed(clickSpeed)
    end
    -- 保证开自动点击时返回值不小于自动点击秒速
    if autoSpeed > 0 and autoSpeed > clickSpeed then
        clickSpeed = autoSpeed
    end
    return clickSpeed
end

local lastBombTime = os_clock()
function layer:click(isTouch)
    if ch.fightRoleLayer:isPause() then return end
    local mainRole = ch.fightRoleLayer:getMainRole()
    if not mainRole or not mainRole:isVisible() then return end
    if not ch.fightRoleAI.bossStartAtkTime or ch.fightRoleAI.bossStartAtkTime > os_clock() then return end
    if ch.LevelController:getState() ~= 2 then return end
    if not mainRole.chongwu then return end
    if isTouch then
        ch.PowerModel:addPower(-1)
    end
    counter = counter + 1
    self:getClickSpeed()   
    ch.StatisticsModel:addClickTimes(1)
    zzy.EventManager:dispatch({
        type = layer.CLICK_EVENT_TYPE
    })

    local now = os_clock()
    ch.fightRoleLayer:getMainRole().chongwu:attack(attackSpeedLevel)
    local aniLevel = math.floor(ch.RunicModel:getLevel() / 100 + 1)
    if aniLevel > 7 then aniLevel = 7 end
    local petConfig = GameConfig.PartnerConfig:getData(ch.PartnerModel:getCurPartner())
    local px = ch.fightRoleLayer:getMainRole().chongwu.pos + petConfig.offset_x * ch.fightRoleLayer:getMainRole():getDir()
    local py = GameConst.PAT_OFFSET_HEIGHT + petConfig.offset_y
    local ani
    if now - lastBombTime > 0.07 then
        ani = ch.CommonFunc:createAnimation(ch.fightRoleLayer:getMainRole().chongwu.petName)
        ch.CommonFunc:playAni(ani, "fly"..aniLevel, false)
        --ani:getAnimation():play("fly"..aniLevel)
        ani.isBomb = true
        lastBombTime = now
        ch.SoundManager:play("huoqiu")
    else
        ani = cc.Node:create()
    end
    ani:setPosition(px, py)
    ani.topos = ch.fightRoleLayer:getMainRole():getPositionX() + ch.fightRoleLayer:getMainRole():getDir() * GameConst.PAT_ATTACK_POS_TO_ROLE
    ani.dir = ani.topos > ch.fightRoleLayer:getMainRole().chongwu.pos and 1 or -1
    ani.time = now
    local rotation = math.atan2(py, ani.topos-px) / math.pi * 180 - 90
    --DEBUG("====================%s=======================", tostring(rotation))
    ani:setRotation(rotation)
    flyLayer:addChild(ani)
    table.insert(bombs,ani)
end

function layer:update(dt)
    frameCount = frameCount + 1
    if frameCount >= 5 then
        frameCount = 0
        clickCount = 0
    end
    local index = 1
    local time = os_clock()
    while index<=#bombs do
        local ani = bombs[index]
        dt = time - ani.time
        ani.time = time
        local px,py = ani:getPosition()
        local mx = ani.dir * dt * GameConst.PAT_ATTACK_FLY_SPEED
        local mr =  math.abs(mx / (px - ani.topos))
        if mr >= 1.3 then
            table.remove(bombs,index)
            local iscrict = math.random() < ch.RunicModel:getCritRate()
            local damage = self:getDamage(iscrict)
            ch.fightRoleLayer:fuwenAttack(ani.topos,damage, iscrict)
            if iscrict then
                ch.StatisticsModel:addRunicCritTimes(1)
            end
            if ani.isBomb then
                ch.CommonFunc:playAni(ani, "bomb", true)--ani:getAnimation():play("bomb")
                ani:setRotation(0)
                ani:setPosition(ani.topos,0)
                ch.CommonFunc:setAniCb(ani, function(armatureBack,movementType,movementID)
                    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                        ani:setVisible(false)
                        local delay = cc.DelayTime:create(0.1)
                        local seq = cc.Sequence:create(delay, cc.CallFunc:create(function() ani:removeFromParent() end))
                        ani:runAction(seq)
                    end
                end)
            else
                ani:removeFromParent()
            end
        else
            px = px + mx
            py = py * (1 - mr)
            ani:setPosition(px, py)
            index = index + 1
        end
    end

    if autoClickTS and os_clock() > nextAutoClickTime then
        nextAutoClickTime = os_clock()+autoClickTS
        layer:click()
--        nextAutoClickTime = nextAutoClickTime + autoClickTS
    end
end

local minDamage = ch.LongDouble:new(1)
function layer:getDamage(iscrict)
    local damage = 0
    local restrain = nil
    if ch.LevelController.mode == ch.LevelController.GameMode.warpath then
        local bossId = ch.WarpathModel:getBossId()
        restrain = GameConfig.WarpathConfig:getData(bossId).property
        damage = ch.RunicModel:getWarpathDPS()
        damage = damage < minDamage and ch.LongDouble:new(1) or damage
        if iscrict then
            damage = damage * ch.RunicModel:getCritTimes()*GameConst.WARPATH_CRICT_HARM_RATIO
        end
    else
        damage = ch.RunicModel:getDPS()
        if iscrict then
            damage = ch.RunicModel:getDPS() * ch.RunicModel:getCritTimes()
        end
        if ch.LevelController.mode == ch.LevelController.GameMode.normal then
            restrain = ch.LevelModel:getRestrain()
        else --黄金大魔王等为1属性
            restrain = 1
        end
    end
    if GameConst.PET_ATTRIBUTE_RESTRAIN[ch.PartnerModel:getCurPartnerRestrain()] == 0 or restrain == GameConst.PET_ATTRIBUTE_RESTRAIN[ch.PartnerModel:getCurPartnerRestrain()] then
        if ch.PartnerModel:getCurPartner() == "20007" and GameConst.PET_RESTRAIN_HARM_RATIO_1 then
            damage = damage * (1+GameConst.PET_RESTRAIN_HARM_RATIO_1)
        elseif ch.PartnerModel:getCurPartner() == "20008" and GameConst.PET_RESTRAIN_HARM_RATIO_2 then
            damage = damage * (1+GameConst.PET_RESTRAIN_HARM_RATIO_2)
        else
            damage = damage * (1+GameConst.PET_RESTRAIN_HARM_RATIO)
        end
        
    end
    return ch.LongDouble:floor(damage)
end

function layer:clearBombs()
    for k, bomb in ipairs(bombs) do
        bomb:removeFromParent()
    end
    bombs = {}
end

function layer:clear()
    ch.RoleResManager:releaseEffect("tx_dianjixiaoguo")
    self:clearBombs()
end

return layer
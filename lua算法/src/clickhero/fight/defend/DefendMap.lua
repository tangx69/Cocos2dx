local petAutoAttack = 10
local petMaxPositionFix = 550

local DefendMap = {
    _layer = nil,
    _widget = nil,
    _enemies = nil,
    _moneys = nil,
    _isPausing = nil,
    _eventId = nil,
    _frontLayer = nil,
    
    _pet = nil,
    _refreshAI = nil,
    
    _enemyRes = nil,
    
    --_addHpCount = nil,
    _isWaiting = nil,
    
--    _clickCount = nil, --用于防作弊
--    _frameCount = nil,
    _lastKilledCount = nil,
    
    _skills = nil,
    _readyAni = nil,
    
    rewardGetEvent = "DEFEND_REWARD_GET_EVENT",
    ReadyCompletedEvent = "DEFEND_READY_COMPLETED_EVENT",
    _rewardEventId = nil,
    
    --单步加载资源
    _curIndex = nil,
    _resId = nil
}

local res = {"tx_shuijingdiaoluo","tx_hunhuodiaoluo","tx_zhudongjineng","tx_juesejineng"}

function DefendMap:init(isGuide)
    ch.DefendTimer:init()
    self:_initData()
    self:_initRenderer()
    self:addPet()
    if not isGuide then
        self:playReady(function()
            self:startLevel()
        end)
    end
    self._eventId =  zzy.EventManager:listen(zzy.Events.TickEventType,function()
        self:_update()
    end)
    self._rewardEventId = zzy.EventManager:listen(self.rewardGetEvent,function()
        ch.DefendModel:nextLevel()
        self:startLevel()
        ch.DefendModel:resumeSkill()
        self._isWaiting = false
    end)
    self._curIndex = 1
    self:loadResource()
end

function DefendMap:loadResource()
    ch.RoleResManager:loadEffect(res[self._curIndex],function()
        if self._curIndex >= #res then
            self._curIndex = nil
        else
            self._curIndex = self._curIndex + 1
            self:loadResource()
        end
    end)
end

function DefendMap:endGuide()
    self:playReady(function()
        self:startLevel()
    end)
end

function DefendMap:resume()
    if self._isPausing then
        ch.DefendTimer:resume()
        self._isPausing = nil
        if self._pet then
            self._pet:resume()
        end
        for k,v in ipairs(self._enemies) do
            v:resume()
        end
        for k,v in ipairs(self._skills) do
            v:resume()
        end
        for k,v in ipairs(self._moneys) do
            v:getAnimation():resume()
        end
        ch.DefendModel:resumeSkill()
    end
end

function DefendMap:pause()
    if self._isPausing then return end
    ch.DefendTimer:pause()
    self._isPausing = true
    if self._pet then
        self._pet:pause()
    end
    for k,v in ipairs(self._enemies) do
        v:pause()
    end
    for k,v in ipairs(self._skills) do
        v:pause()
    end
    for k,v in ipairs(self._moneys) do
        v:getAnimation():pause()
    end
    ch.DefendModel:pauseSkill()
end

function DefendMap:_initData()
    self._enemies = {}
    self._moneys = {}
    self._enemyRes = {}
    self._addHpCount = 0
    self._isWaiting = false
    self._lastKilledCount = 0
    self._refreshAI = ch.DefendRefreshAI:create()
    self._isPausing = nil
    self._skills = {}
    ch.DefendModel:start()
end

function DefendMap:_initRenderer()
    if not self._layer then
        self._layer = cc.Layer:create()
        self._layer:setPositionY(ch.editorConfig:getSceneGlobalConfig().roleh)
        ch.UIManager:getDefendLayer():addChild(self._layer, 1)
--        local clickLayer = ccui.Layout:create()
--        clickLayer:setContentSize(cc.Director:getInstance():getWinSize())
--        clickLayer:setTouchEnabled(true)
--        ch.UIManager:getDefendLayer():addChild(clickLayer)
--        clickLayer:addTouchEventListener(function(obj, evt)
--            if evt == ccui.TouchEventType.ended then
--                if self._isWaiting then
--                    
--                end
--            end
--        end)
        self._widget = zzy.uiViewBase:new("MainScreen/W_JSZDmain")
        ch.UIManager:getMainViewLayer():addChild(self._widget)
    end
end

function DefendMap:fail()
    self:pause()
    self._pet:clearBombs()
    self:_clearMoney()
    ch.UIManager:showGamePopup("Guild/W_JSZDresult")
end

function DefendMap:_clearMoney()
	for k,v in ipairs(self._moneys) do
	   v:removeFromParent()
	end
	self._moneys = nil
end

function DefendMap:startLevel()
    if self._curIndex then
        self._resId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
            if not self._curIndex then
                self._refreshAI:start()
                self._pet:setAutoAttack(true)
                zzy.EventManager:unListen(self._resId)
                self._resId = nil
            end
        end)
    else
        self._refreshAI:start()
        self._pet:setAutoAttack(true)
    end
end

function DefendMap:isWon()
    if self._refreshAI:isCompleted() then
        return #self._enemies == 0
    end
    return false
end

function DefendMap:addChild(child,zOrder)
    zOrder= zOrder or 0
    self._layer:addChild(child,zOrder)
end

function DefendMap:addEnemy(gid)
    ch.RoleResManager:load(GameConst.DEFEND_MONSTERS[gid].name,function()
        self._enemyRes[GameConst.DEFEND_MONSTERS[gid].name] = true
        local enemy = ch.DefendEnemy:create(gid,ch.DefendModel:getEnemyHP())
        enemy:setPosition(cc.p(700,0))
        self._layer:addChild(enemy:getRenderer(),2)
        table.insert(self._enemies,enemy)
        if self._isPausing then
            enemy:pause()
        end
    end)
end

function DefendMap:addPet()
    local petId = ch.PartnerModel:getCurPartner()
    local name = GameConfig.PartnerConfig:getData(petId).apath
    ch.RoleResManager:load(name,function()
        self._pet = ch.DefendPet:create(petId)
        self._pet:addAutoAttackCount(petAutoAttack)
        self._pet:setPosition(cc.p(0,300))
        self._layer:addChild(self._pet:getRenderer(),3)
        if self._isPausing then
            self._pet:pause()
        end
    end)
end

function DefendMap:attackEnemy(x,range,damage,isCrict)
    local count = 0
    for k,enemy in ipairs(self._enemies) do
        if enemy:getState()~= 3 and enemy:isContained(x,range) then
            if enemy:underAttack(damage) then--死亡
                count = count + 1
            end
            local p = enemy:getBoneOffset("top")
            self:showDamage(p.x + enemy:getPositionX(),p.y,damage,isCrict)
        end
    end
    ch.DefendModel:addkilledCount(count)
end

function DefendMap:attackOneEnemy(enemy,damage,isCrict,isPlay)
    if enemy:getState() == 3 then return end
    if enemy:underAttack(damage,isPlay) then--死亡
        ch.DefendModel:addkilledCount(1)
    end
    local p = enemy:getBoneOffset("top")
    self:showDamage(p.x + enemy:getPositionX(),p.y,damage,isCrict)
end


--function DefendMap:_addKillCount(count)
--    ch.DefendModel:addkilledCount(count)
--    self._addHpCount = self._addHpCount + count
--    local hp = math.floor(self._addHpCount/addHpNeedKillCount) 
--    if hp>0 then
--        ch.DefendModel:addHP(hp)
--        self._addHpCount = self._addHpCount%addHpNeedKillCount
--    end
--end

function DefendMap:showDamage(x,y,value,isCrtial)
    local fontTmp = isCrtial and "res/ui/aaui_font/font_crtical.fnt" or "res/ui/aaui_font/font_yellow.fnt"
    local text = ccui.TextBMFont:create(ch.NumberHelper:harmToString(value), fontTmp)
    self._layer:addChild(text)
    text:setPosition(x,y)
    text:setScale(1)
    local time = 0.6
    text:runAction(cc.EaseOut:create(cc.MoveBy:create(time, cc.vertex2F(0, 200)), time))
    text:runAction(cc.MoveBy:create(time, cc.vertex2F(70, 0)))
    text:runAction(cc.Sequence:create(cc.EaseOut:create(cc.FadeOut:create(time), time), cc.CallFunc:create(function()
        return zzy.CocosExtra.isCobjExist(text) and text:removeFromParent()
    end)))
end

function DefendMap:dropMoney(px, py, num,type)
    type = type or 1
    local name = type == 1 and "tx_shuijingdiaoluo" or "tx_hunhuodiaoluo"
    for i = 1,num do
        local ani = ccs.Armature:create(name)
        ani:getAnimation():play("zhuan")
        ani:setPosition(px, py)
        self._layer:addChild(ani,5)
        table.insert(self._moneys,ani)
        ani.vx = math.random(GameConst.GOLD_DROP_FLY_MIN_VX, GameConst.GOLD_DROP_FLY_MAX_VX)
        ani.vy = math.random(GameConst.GOLD_DROP_FLY_MIN_VY, GameConst.GOLD_DROP_FLY_MAX_VY)       
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if (movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete)
                and movementID == "faguang" then
                ani:removeFromParent()
                for k,v in ipairs(self._moneys) do
                    if v == ani then
                        table.remove(self._moneys,k)
                        break
                    end
                end
            end
        end)
    end
end

function DefendMap:playReady(callFunc)
    if not self._layer then return end
    ch.RoleResManager:loadEffect("tx_zhunbeifangshou")
    self._readyAni = ccs.Armature:create("tx_zhunbeifangshou")
    local dirSize = cc.Director:getInstance():getWinSize()
    self._readyAni:setPosition(dirSize.width/2, dirSize.height/2 + 100 -ch.editorConfig:getSceneGlobalConfig().roleh)
    --ani:getAnimation():setSpeedScale(2)
    self._readyAni:getAnimation():play("play")
    self._readyAni:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            self._readyAni:removeFromParent()
            ch.RoleResManager:releaseEffect("tx_zhunbeifangshou")
            self._readyAni = nil
            if callFunc then callFunc() end
            local evt = {type = self.ReadyCompletedEvent}
            zzy.EventManager:dispatch(evt)
        end
    end)
    self._layer:addChild(self._readyAni)
end

--function DefendMap:playNextLevel(callFunc)
--    ch.RoleResManager:loadEffect("tx_shoudongdianji")
--    self._waitAni = ccs.Armature:create("tx_shoudongdianji")
--    local dirSize = cc.Director:getInstance():getWinSize()
--    self._waitAni:setPosition(dirSize.width/2, dirSize.height/2 + 100 -ch.editorConfig:getSceneGlobalConfig().roleh)
--    self._waitAni:getAnimation():setSpeedScale(2)
--    self._waitAni:getAnimation():play("play",-1,1)
--    self._layer:addChild(self._waitAni)
--end

function DefendMap:getEnemyMinX()
    local x = 0
    if #self._enemies > 0 then
        x = self._enemies[1]:getPositionX()
        for k,enemy in ipairs(self._enemies) do
            if enemy:getState() ~= 3 and enemy:getPositionX() < x then
                x = enemy:getPositionX()
            end
        end
    end
    return x
end

function DefendMap:getAllEnemy()
	return self._enemies
end

function DefendMap:getPet()
    return self._pet
end

function DefendMap:clearEnemyRes()
    for k,v in pairs(self._enemyRes) do
        ch.RoleResManager:release(k)
    end
    self._enemyRes = {}
end

function DefendMap:useSkill(id)
	local skill = ch.SkillFactory:create(id)
	if skill then
        ch.DefendModel:useSkill(id)
        table.insert(self._skills,skill)
	end
end

function DefendMap:removeSkill(skill)    
    for k,v in ipairs(self._skills) do
        if v == skill then
            table.remove(self._skills,k)
            break
        end
	end
	skill:destroy()
end

function DefendMap:removeEnemy(enemy)    
    for k,v in ipairs(self._enemies) do
        if v == enemy then
            table.remove(self._enemies,k)
            break
        end
    end
    enemy:destroy()
end

function DefendMap:destory()
    for k,enemy in ipairs(self._enemies) do
        enemy:destroy()
    end
    self._pet:destroy()
    for _,v in ipairs(self._skills) do
        v:destroy()
    end
    ch.UIManager:getDefendLayer():removeAllChildren()
    zzy.EventManager:unListen(self._eventId)
    zzy.EventManager:unListen(self._rewardEventId)
    self:clearEnemyRes()
    self._widget:destory()
    ch.DefendModel:clearAllSkillCD()
    
    self._enemyRes = nil
    self._enemies = nil
    self._pet = nil
    self._layer = nil
    self._moneys = nil
    self._refreshAI = nil
    self._skills = nil
    self._isPausing = nil
    if self._resId then
        zzy.EventManager:unListen(self._resId)
        self._resId = nil
    end
    ch.RoleResManager:releaseEffect("tx_shuijingdiaoluo")
    ch.RoleResManager:releaseEffect("tx_hunhuodiaoluo")
    ch.RoleResManager:releaseEffect("tx_zhudongjineng")
    ch.RoleResManager:releaseEffect("tx_juesejineng")
end

function DefendMap:_isEnd()
    local removeList = {}
    for k,enemy in ipairs(self._enemies) do
        if enemy:getPositionX() < - enemy:getHalfWidth() then
            table.insert(removeList,k)
        end
    end
    local index = #removeList
    while index > 0 do
        local key = removeList[index]
        local enemy = self._enemies[key]
        enemy:destroy()
        table.remove(self._enemies,key)
        index = index - 1
        ch.DefendModel:addHP(-1)
        if ch.DefendModel:getHP() == 0 then
            self:fail()
            return true
        end
    end
    return false
end

function DefendMap:_updateSkill()
	for _,skill in ipairs(self._skills) do
	   skill:update()
	end
end

function DefendMap:_updatePet()
    if not self._pet then return end
    local x = self._pet:getPositionX()
    if #self._enemies == 0 then
        local posX = petMaxPositionFix - self._pet:getAttackDistance()
        if x < posX then
            local distance = GameConst.DEFEND_PET_MOVE_SPEED *ch.DefendTimer:getDeltaTime()
            if x+ distance > posX then
                distance = posX - x
            end
            self._pet:move(distance)
        end
    else
        local minX = self:getEnemyMinX()
        minX = minX > petMaxPositionFix and petMaxPositionFix or minX
        local posX = minX - self._pet:getAttackDistance()
        posX = posX < 80 and 80 or posX
        local distance = posX - x
        local maxDistance  = GameConst.DEFEND_PET_MOVE_SPEED *ch.DefendTimer:getDeltaTime()
        if math.abs(distance) > maxDistance then
            distance = distance > 0 and maxDistance or -maxDistance
        end
        self._pet:move(distance)
    end
    self._pet:update()
end

function DefendMap:_updateMoney()
    local dt = ch.DefendTimer:getDeltaTime()
    for _,ani in ipairs(self._moneys) do
        if ani.vx then
            local px,py = ani:getPosition()
            py = py + ani.vy * dt
            px = px + ani.vx * dt
            if py > 0 then
                ani.vy = ani.vy + GameConst.GOLD_DROP_FLY_G * dt
            else
                ani.vx = nil
                py = 0
                ani:getAnimation():play("faguang")
            end
            ani:setPosition(px, py)
        end
    end
end

function DefendMap:_update()
    if self._isPausing then return end
    ch.DefendTimer:update()
    self._refreshAI:update()
    for k,enemy in ipairs(self._enemies) do
        enemy:update()
    end
    self:_updateSkill()
    if self:_isEnd() then return end -- 游戏结束
    self:_updatePet()
    self:_updateMoney()
    
    if self:isWon() and not self._isWaiting then
        self._isWaiting = true
        self._pet:setAutoAttack(false)
        ch.DefendModel:pauseSkill()
        local killed = ch.DefendModel:getkilledCount() - self._lastKilledCount
        self._lastKilledCount = ch.DefendModel:getkilledCount()
        ch.NetworkController:defendLevelVictory(killed,self._refreshAI:getTotalEnemyCount())   
        self:clearEnemyRes()
    end
end

return DefendMap
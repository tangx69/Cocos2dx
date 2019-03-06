local DefendPet = {
    _renderer = nil,
    _bombs = nil,
    _config = nil,
    _attackTime = nil,
    _attackCount = nil,
    _isAutoAttack = nil,
    _autoAttackLastTime = nil,
    _attackDistance = nil,
    _attackRange = nil, 
    _autoAttackInterval = nil,
    _autoAttackCount = nil,
    _isUsingSkill = nil,
    _aniLevel = nil,
}

DefendPet.__index = DefendPet

local defaultAttackRange = 50 

function DefendPet:create(petId)
    local o = {}
    setmetatable(o,DefendPet)
    o._config = GameConfig.PartnerConfig:getData(petId)
    o._renderer = ch.petRole:create(o._config.apath)
    o._renderer:stand()
    o._bombs = {}
    o._attackCount = 0
    o._autoAttack = false
    o._aniLevel = math.floor(ch.RunicModel:getLevel() / 100 + 1)
    if o._aniLevel > 7 then o._aniLevel = 7 end
    o._attackDistance = o._config.offset_x + GameConst.DEFEND_PET_ATTACK_DISTANCE
    o._attackRange = defaultAttackRange
    return o
end

function DefendPet:getRenderer()
    return self._renderer
end

function DefendPet:getAttackDistance()
    return self._attackDistance
end

function DefendPet:update()
    self:_updateBombs(ch.DefendTimer:getDeltaTime())
    self:_updateAutoAttack()
end

function DefendPet:move(distance)
    local x = self._renderer:getPositionX() + distance
    self._renderer:setPositionX(x)
    self._renderer:move()
end

function DefendPet:isAutoAttack()
    return self._isAutoAttack
end

function DefendPet:setAutoAttack(autoAttack)
    self._isAutoAttack = autoAttack
end

function DefendPet:pause()
    self._renderer:pause()
    for k,v in ipairs(self._bombs) do
        ch.CommonFunc:pauseAni(v)--v:getAnimation():pause()
    end
end

function DefendPet:resume()
    self._renderer:resume()
    for k,v in ipairs(self._bombs) do
        ch.CommonFunc:resumeAni(v)--v:getAnimation():resume()
    end
end

function DefendPet:addAutoAttackCount(count)
    if count == 0 then return end
    self._autoAttackCount = self._autoAttackCount or 0
    self._autoAttackCount = self._autoAttackCount + count
    self._autoAttackCount = self._autoAttackCount>0 and self._autoAttackCount or 0
    if self._autoAttackCount > 0 then 
        self._autoAttackInterval = 1/self._autoAttackCount
    else
        self._autoAttackInterval = nil
    end
end

function DefendPet:attack()
    if self._isAutoAttack then
        self._attackCount = self._attackCount + 1
        self._renderer:attack(self:_getClickSpeed())
        local bomb = self:_createBomb()
        table.insert(self._bombs,bomb)
        ch.DefendMap:addChild(bomb,4)
        ch.SoundManager:play("huoqiu")
    end
end

function DefendPet:stand()
    self._renderer:stand()
end

function DefendPet:clearBombs()
	for k,bomb in ipairs(self._bombs) do
        bomb:removeFromParent()
	end
	self._bombs = {}
end

function DefendPet:_updateBombs(dt)
    local index = 1
    local time = ch.DefendTimer:getGameTime()
    while index<=#self._bombs do
        local ani = self._bombs[index]
        dt = time - ani.time
        ani.time = time
        local px,py = ani:getPosition()
        local mx = dt * GameConst.PAT_ATTACK_FLY_SPEED
        local mr = math.abs(mx / (px - ani.topos))
        if mr >= 1 then
            table.remove(self._bombs,index)
            local iscrict = math.random() < ch.DefendModel:getCritRate()
            local damage = ch.DefendModel:getDPS()
            if iscrict then
                damage = damage * (ch.RunicModel:getCritTimes() * GameConst.DEFEND_PET_CRICT_RATIO)
            end
            ch.DefendMap:attackEnemy(ani.topos, self._attackRange, damage, iscrict)
            ch.CommonFunc:playAni(ani, "bomb", false)--ani:getAnimation():play("bomb")
            ani:setRotation(0)
            ani:setPosition(ani.topos,0)
            ch.CommonFunc:setAniCb(ani, function(armatureBack,movementType,movementID)
            --ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
                if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                    ani:setVisible(false)
                    local delay = cc.DelayTime:create(0.1)
                    local seq = cc.Sequence:create(delay, cc.CallFunc:create(function() ani:removeFromParent() end))
                    ani:runAction(seq)
                end
            end)
        else
            px = px + mx
            py = py * (1 - mr)
            ani:setPosition(px, py)
            index = index + 1
        end
     end   
end

function DefendPet:_updateAutoAttack()
	if self._isAutoAttack and self._autoAttackInterval then
	   local now = ch.DefendTimer:getGameTime()
	   if self._autoAttackLastTime then
	       if now > self._autoAttackLastTime + self._autoAttackInterval then
	           self._autoAttackLastTime = now
	           self:attack()
	       end
	   else
	       self._autoAttackLastTime = now
	       self:attack()
	   end
	end
end

function DefendPet:_getClickSpeed()
    local now = ch.DefendTimer:getGameTime()
    if self._attackTime then
        if now > self._attackTime + 1 then
            local clickSpeed = self._attackCount/(now - self._attackTime)
            self._attackTime = now
            self._attackCount = 0
            if clickSpeed < 1 then
                return 1
            elseif clickSpeed < 5 then
                return 2
            else
                return 3
            end
        end
    else
        self._attackTime = now
        return 1
    end
end

function DefendPet:setPosition(pos)
    self._renderer:setPosition(pos)
end

function DefendPet:getPositionX()
    return self._renderer:getPositionX()
end

function DefendPet:addSkillEffect()
    self._renderer:addSkillEffect()
    self._isUsingSkill = true
end

function DefendPet:removeSkillEffect()
    self._renderer:removeSkillEffect()
    self._isUsingSkill = nil
end

function DefendPet:destroy()
    for k, v in ipairs(self._bombs) do
        v:removeFromParent()
    end
    self._bombs = nil
    self._renderer:destory()
end

function DefendPet:_createBomb()
    local aniLevel = self._isUsingSkill and 8 or self._aniLevel
    local px = self:getPositionX() + self._config.offset_x
    local py = GameConst.PAT_OFFSET_HEIGHT + self._config.offset_y

    local ani = ch.CommonFunc:createAnimation(self._config.apath)
    ch.CommonFunc:playAni(ani, "fly"..aniLevel, false)
    ani:setPosition(px, py)
    ani.topos = self:getPositionX() + self._attackDistance
    ani.time = ch.DefendTimer:getGameTime()
    ani:setRotation(math.atan2(py, ani.topos-px) / math.pi * 180 - 90)
    return ani
end



return DefendPet
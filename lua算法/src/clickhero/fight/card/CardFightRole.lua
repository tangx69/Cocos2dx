local role = {
    _state = nil,
    _targetRole = nil,
    _hp = nil,
    _maxHp = nil,
    _startAttackTime = nil,
    _lastFrame = nil,
    _curSkillIndex = nil,
    _onAttackCompleted = nil,
    _onAttacking = nil,
    _speed = nil,
    _isPaused = nil,
}

local totalWidget = nil
local skills = nil
function role:initSkill()
    if skills then return end
    totalWidget = 0
    skills = {}
    for _,s in ipairs(GameConst.CARD_FIGHT_SKILL) do
        totalWidget = totalWidget + s.weight
        local skill = GameConst.MAIN_ROLE_SKILL_CONFIG.nanzhanshi[s.index]
        skills[s.index] = {}
        local w = 0
        for k,v in pairs(skill) do
            if string.sub(k,1,1) == "f" then
                local frame = tonumber(string.sub(k,2))
                for k1,v1 in pairs(v) do
                    if v1[4] == 1 then
                        w = w + v1[5]
                        skills[s.index][frame] = {sound = v1[3],ratio = v1[5]} 
                        break
                    end
                end
            end
        end
        for k,fData in pairs(skills[s.index]) do
            fData.ratio = fData.ratio/w
        end
    end
end

function role:create(hp,roleName,weapon,scaleX,maxHp)
    local obj = cc.Node:create()
    for k,v in pairs(role) do obj[k] = v end

    obj._ani = ch.CommonFunc:createAnimation(roleName)
    ch.CommonFunc:setAniCb(obj._ani, function(...) obj:onMovementEvent(...) end)
    obj._effectAni = ch.CommonFunc:createAnimation("mainRoleEffect")

    obj._speed = GameConst.MAIN_ROLE_ACTION_SPEED_SCALE
    ch.CommonFunc:speedAni(obj._ani, obj._speed)
    ch.CommonFunc:speedAni(obj._effectAni, obj._speed)

    obj._ani:setScaleX(scaleX)
    obj._effectAni:setScaleX(scaleX)
    
    obj._hp = hp
    obj._maxHp = maxHp and maxHp or hp
    if weapon then
        obj:changeWeapon(weapon)
    end
    obj:addChild(obj._ani)
    obj:addChild(obj._effectAni)
    return obj
end

function role:setAttackCompletedCallBack(func)
    self._onAttackCompleted = func
end

function role:setAttackingCallBack(func)
    self._onAttacking = func
end

function role:changeWeapon(name)
    ch.CommonFunc:changeWeapon(self._ani, name)
end

function role:update()
    if self._isPaused then return end
    local now = os_clock()
    if self._state == 2 then
        local curFrame = math.floor((now - self._startAttackTime) * 30 * self._speed + 0.5)
        local skillInfo = skills[self._curSkillIndex]
        for f,fdata in pairs(skills[self._curSkillIndex]) do
            if f>self._lastFrame and f<= curFrame then
                local isDodge = false
                local hp = 0
                if ch.CardFightMap:isDodge() then
                    self._targetRole:playDodge()
                    isDodge = true
                else
                    hp = ch.CardFightMap:getHarm()*fdata.ratio
                    self._targetRole:underAttact(hp,ch.CardFightMap:isCrit())
                end
                self._onAttacking(self._targetRole,fdata.ratio)
                if string.len(fdata.sound) > 0 then
                    ch.SoundManager:play(fdata.sound)
                end
                self._targetRole:showDefenceEffect()
            end
        end
        self._lastFrame = curFrame
    end
end

function role:showDefenceEffect()  
    ch.RoleResManager:loadEffect("nanzhanshi_hit")
    local effect = ch.CommonFunc:createAnimation("mainRoleEffect")
    ch.CommonFunc:playAni(effect, "play", false)
    effect:setPosition(self:getBoneOffset("body"))
    ch.CommonFunc:setAniCb(effect, function(...) effect:removeFromParent() end)
    self:addChild(effect)
end

function role:attack(targetRole)
    self._targetRole = targetRole
    self._startAttackTime = os_clock()
    self._lastFrame = 0
    self._curSkillIndex = self:getSkillIndex()
    self:playAttack(self._curSkillIndex)
end

function role:showSkillEffect()
    local ani = ch.CommonFunc:createAnimation("tx_shifangkapai")
    ch.CommonFunc:playAni(ani, "play", false)
    ani:setScale(0.5)
    ch.CommonFunc:setAniCb(ani, function(...) ani:removeFromParent() end)
    local p = self:getBoneOffset("body")
    ani:setPosition(p.x,p.y+180)
    self:addChild(ani)
end

function role:underAttact(harm,isCrit)
	self:playCrash()
    self._hp = self._hp - harm
    if self._hp < 0 then self._hp = 0 end
    ch.CardFightMap:showRoleHP(self,isCrit,-harm)
end

function role:recoveHP(hp)
    self._hp = self._hp + hp
    if self._hp > self._maxHp then 
        self._hp = self._maxHp
    elseif self._hp < 0 then
        self._hp = 0
    end    
    ch.CardFightMap:showRoleHP(self,false,hp)
end

function role:addMaxHp(maxHp)
    self._maxHp = self._maxHp + maxHp
end

function role:getHPRatio()
	return self._hp/self._maxHp
end

function role:die()
    --self:playCrash()
    self:runAction(cc.Sequence:create(cc.Blink:create(0.6,6), cc.CallFunc:create(function()
        if zzy.CocosExtra.isCobjExist(self) then
            self:setVisible(false)
        end
    end)))
end

function role:destroy()
	self:removeFromParent()
end

function role:onMovementEvent(armatureBack,movementType,movementID)
    if movementType == ccs.MovementEventType.complete then
        if movementID == "hurt" or movementID == "evade" then
            self:playStand()
        elseif string.sub(movementID,1,6) == "attack" then
            self:playStand()
            if self._onAttackCompleted then
                self:_onAttackCompleted()
            end
        end
    end
end

function role:getSkillIndex()
    local random = math.random(1,totalWidget)
    local cur = 0
    for k,v in ipairs(GameConst.CARD_FIGHT_SKILL) do
        cur = cur + v.weight
        if random <= cur then
            return v.index
        end
    end
    return GameConst.CARD_FIGHT_SKILL[1].index
end

function role:playMove()
    if self._state == 0 then return end
    self._state = 0
    ch.CommonFunc:playAni(self._ani, "move", true)
    ch.CommonFunc:stopAni(self._effectAni)
    self._effectAni:setVisible(false)
end

function role:playStand()
    if self._state == 1 then return end
    self._state = 1
    ch.CommonFunc:playAni(self._ani, "ready", true)
    ch.CommonFunc:stopAni(self._effectAni)
    self._effectAni:setVisible(false)
end

function role:playAttack(skillIndex)
    self._state = 2
    self._effectAni:setVisible(true)
    ch.CommonFunc:playAni(self._ani, "attack"..skillIndex, false)
    ch.CommonFunc:playAni(self._effectAni, "attack"..skillIndex, false)
end

function role:pause()
    if self._isPaused then return end
    self._isPaused = true
	ch.CommonFunc:pauseAni(self._ani)
    ch.CommonFunc:pauseAni(self._effectAni)
end

function role:resume()
    if not self._isPaused then return end
    self._isPaused = false
    ch.CommonFunc:resumeAni(self._ani)
    ch.CommonFunc:resumeAni(self._effectAni)
end

function role:playCrash()
    self._state = 3
    ch.CommonFunc:playAni(self._ani, "hurt", false)
end

function role:playDodge()
    self._state = 4
    ch.CommonFunc:playAni(self._ani, "evade", false)
end

function role:stop()
    ch.CommonFunc:stopAni(self._ani)
end

function role:getBoneOffset(boneName)
    return ch.CommonFunc:getHpBarPos(self, boneName)
end

return role
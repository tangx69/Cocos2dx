local role = {}
role.DEAD_EVENT_TYPE = "FIGHT_ROLE_DEAD_EVENT_TYPE" --roleType 1=小怪 2=boss 3=宝箱 ,4 =主角
role.BOSS_HP_CHANGE_EVENT_TYPE = "BOSS_HP_CHANGE_EVENT_TYPE"
role.BOSS_PASS_EVENT_TYPE = "FIGHT_BOSS_PASS_EVENT_TYPE"

role.roleType = {
    monster = 1,
    boss = 2,
    chest = 3,
    mainRole = 4,
}

function role:create(roleName, hp, scale, roleType, actionSpeed,maxhp)
    local obj = cc.Node:create()
    obj.effPannel = cc.Node:create()
    
    for k,v in pairs(role) do obj[k] = v end
    if roleType == role.roleType.mainRole then
        obj.config = ch.editorConfig:getRoleConfig("nanzhanshi")
    else 
        obj.config = ch.editorConfig:getRoleConfig(roleName)
    end
    obj.roleName = roleName
    obj.maxhp = maxhp and maxhp or hp
    obj.curhp = hp
    obj.realhp = hp --实际怪物的血量
    obj.scale = scale or 1
    obj.scale = obj.scale * (obj.config.c or 1)
    if obj.scale ~= 1 then
        obj.config = zzy.TableUtils:copy(obj.config)
        obj.config.w = obj.config.w * obj.scale
    end
    
    -- 0=闲/移动 1=攻击中 2=受击中 3=击飞中,4=隐身,5=耍帅
    obj.state = 0
    
    obj._atkIndex = 0
    obj._nxtAtkSkills = nil
    obj._atkStartTime = 0
    obj._lastFrame = 0
    obj._moveSpeed = 0
    obj._moveOverTime = 0
    obj._flySpeed = 0
    obj._gravity = 0
    
    obj._baseActionSpeed = actionSpeed
    obj._actionSpeedRatio = 1
    
    obj._laseUpdateTime = os_clock()
    obj._hpBarHiddenTime = 0
    obj._roleType = roleType
    
    if hp and roleType == role.roleType.boss then obj:updateHpBar() end
    
    obj._ani = ch.CommonFunc:createAnimation(roleName)

    obj:addChild(obj._ani)
    if roleType == role.roleType.mainRole then
        obj._effectAni = ch.CommonFunc:createAnimation("mainRoleEffect")
        obj:addChild(obj._effectAni)
        obj._ani:setScale(obj.scale)
        obj._effectAni:setScale(obj.scale)
        --obj.effPannel:setScale(obj.scale)
        obj.ai = ch.fightRoleAI.mainDefault 
    else  -- 小怪反转
        if ch.CommonFunc:isSpine(obj) then
            obj:setScaleX(-obj:getScaleX())
        else
            obj._ani:setScaleX(-obj.scale)
            obj._ani:setScaleY(obj.scale)
        end
        --obj.effPannel:setScaleX(-obj.scale)
        --obj.effPannel:setScaleY(obj.scale)
        obj.ai = ch.fightRoleAI.default
    end
    obj:playStand()

    ch.CommonFunc:setAniCb(obj._ani, function(...) obj:onMovementEvent(...) end)

    obj:addChild(obj.effPannel)
    
    ch.CommonFunc:speedAni(obj._ani, obj._baseActionSpeed * obj._actionSpeedRatio)
    ch.CommonFunc:speedAni(obj._effectAni, obj._baseActionSpeed * obj._actionSpeedRatio)
    
    obj.basey = 0
    if roleType == role.roleType.monster then
        obj.basey = math.random(0, GameConst.FIGHT_UNIT_RANDOM_Y)
        obj._ani:setPosition(obj.basey * GameConst.FIGHT_UNIT_OFFSET_X_RATIO, obj.basey)
    end
    
    if roleType == role.roleType.mainRole then
        obj.chongwu = ch.petRole:create(ch.PartnerModel:getCurPartnerAvatar())
        obj.chongwu:setPosition(-GameConst.PAT_OFFSET_X, GameConst.PAT_OFFSET_HEIGHT)
        obj.chongwu:move()
        obj:addChild(obj.chongwu)
        obj.chongwu.pos = -GameConst.PAT_OFFSET_X
        -- 有某个宠物才加上
        if ch.PartnerModel:getCurPartnerClickSpeed() > 0  then
            ch.clickLayer:autoClick(ch.PartnerModel:getCurPartnerClickSpeed())
        end
    elseif obj._roleType == role.roleType.boss then
            zzy.EventManager:dispatch({
            type = role.BOSS_HP_CHANGE_EVENT_TYPE,
            curhp = obj.curhp,
            maxhp = obj.maxhp
        })    
    end
    return obj
end

function role:updateSkillEffect()
    if self._frontEffect then
        local p = self:getBoneOffset("body")
        self._frontEffect:setPosition(p.x,0)
        self._backEffect:setPosition(p.x,0)
    end
end

function role:changeAvatar(name)
    if self._roleType ~= role.roleType.mainRole or self.roleName == name then return end

	self._ani:removeFromParent()

    self._ani = ch.CommonFunc:createAnimation(name)
    ch.CommonFunc:setAniCb(self._ani, function(...) self:onMovementEvent(...) end)
    self:playStand()
    self.roleName = name
    self:addChild(self._ani)
end

function role:changeWeapon(name)
    if self._roleType ~= role.roleType.mainRole then return end
    ch.CommonFunc:changeWeapon(self._ani, name)
end

function role:getRoleType()
    return self._roleType
end

function role:addSkillEffect()
    if self._shadowEffect then return end
    ch.RoleResManager:loadEffect("tx_shuangchongdaji",function()
        local p = self:getBoneOffset("body")
        self._frontEffect = ccs.Armature:create("tx_shuangchongdaji")
        self._frontEffect:setPosition(p.x,0)
        self._frontEffect:getAnimation():play("front",-1,1)
        self:addChild(self._frontEffect)
        self._backEffect = ccs.Armature:create("tx_shuangchongdaji")
        self._backEffect:setPosition(p.x,0)
        self._backEffect:getAnimation():play("behind",-1,1)
        self:addChild(self._backEffect,-1)
    end)
end

function role:removeSkillEffect()
    if self._frontEffect then
        self._frontEffect:removeFromParent()
        self._frontEffect = nil
        self._backEffect:removeFromParent()
        self._backEffect = nil
        ch.RoleResManager:releaseEffect("tx_shuangchongdaji")
    end
end

function role:changePetRole(petName,petId)
    if not self.chongwu then return end
    ch.clickLayer:autoClick(0)
    ch.clickLayer:clearBombs()
    local x,y = self.chongwu:getPosition()
    local pos = self.chongwu.pos
    local oldPetName = self.chongwu.petName
    self.chongwu:destory()
    self.chongwu = nil
    ch.RoleResManager:release(oldPetName)
    ch.RoleResManager:load(petName, function()    
        self.chongwu = ch.petRole:create(petName)
        self.chongwu:setPosition(x,y)
        self.chongwu:move()
        self:addChild(self.chongwu)
        self.chongwu.pos = pos
        local click  = 0

        -- 有某个宠物才加上
        if ch.PartnerModel:getCurPartnerClickSpeed() > 0 then
            click = click + ch.PartnerModel:getCurPartnerClickSpeed()
        end
        if ch.RunicModel:getSkillDuration(ch.RunicModel.skillId.zhudongchuji)> 0 then
            click = click + ch.RunicModel:getSkillEffect(ch.RunicModel.skillId.zhudongchuji)
        end
        if click > 0 then
            ch.clickLayer:autoClick(click)
        end
        ch.PartnerModel:czChangeEvt(ch.PartnerModel.dataType.fight,petId)
    end)
end

function role:pauseAnimation()
    self:pause()
    self.effPannel:pause()
    ch.CommonFunc:pauseAni(self._ani)
    ch.CommonFunc:pauseAni(self._effectAni)

    if self.chongwu then
        self.chongwu:pause()
    end
end

function role:resumeAnimation()
    self:resume()
    self.effPannel:resume()
    ch.CommonFunc:resumeAni(self._ani)
    ch.CommonFunc:resumeAni(self._effectAni)
    
    if self.chongwu then
        self.chongwu:resume()
    end
end

function role:stopAnimation()
    self:stop()
    self.effPannel:stop()
    ch.CommonFunc:stopAni(self._ani)
    ch.CommonFunc:stopAni(self._effectAni)
    if self.chongwu then
        self.chongwu:stop()
    end
end

function role:reset()
    self:playStand()
    if self.chongwu then
        self.chongwu:setPosition(-GameConst.PAT_OFFSET_X, GameConst.PAT_OFFSET_HEIGHT)
        self.chongwu.pos = -GameConst.PAT_OFFSET_X
        self.chongwu:move()
    end
    if self._hpBar then
        self._hpBar:stopAllActions()
        self._hpTiao:stopAllActions()
        self._hpBar:setOpacity(0)
        self._hpBarHiddenTime = 0
    end
    self._atkIndex = 0
    self._nxtAtkSkills = nil
    self._atkStartTime = 0
    self._lastFrame = 0
    self._laseUpdateTime = os_clock()
end

function role:onMovementEvent(armatureBack,movementType,movementID)
    if self._roleType == role.roleType.mainRole then
        --DEBUG("[%s][onMovementEvent]%s,%d", self.roleName, movementID, movementType)
    end
    
    if movementType == ccs.MovementEventType.complete then
        if movementID == "victory" then
            if self._victoryCallFunc then
                self._victoryCallFunc() 
            end

            self._victoryCallFunc = nil
            -- 胜利动作仅仅是正常速度的两倍，不受其他影响，结束后恢复原来的速度
            ch.CommonFunc:speedAni(self._ani, self._baseActionSpeed * self._actionSpeedRatio)
            ch.CommonFunc:speedAni(self._effectAni, self._baseActionSpeed * self._actionSpeedRatio)

            return
        end
        
        local sk = ch.fightRoleAI:getSkill(self.roleName, self._nxtAtkSkills)
        if sk then
            --DEBUG("[onMovementEvent][animation change]%7s =====> skill%d", movementID, sk)
            self:attack(sk)
        else
            --DEBUG("[onMovementEvent][animation change]%7s =====> stand", movementID)
            self:playStand()
        end
    end
end

function role:getDir()
    return self._ani:getScaleX() > 0 and 1 or -1
end

function role:updateHpBar()
    if self._roleType == role.roleType.boss then
        return zzy.EventManager:dispatch({
            type = role.BOSS_HP_CHANGE_EVENT_TYPE,
            curhp = self.curhp,
            maxhp = self.maxhp
        })
    end
	if not self._hpBar then
        local di = cc.Sprite:createWithSpriteFrameName("aaui_common/enemy_hp_bar_di.png")
        di:setAnchorPoint(cc.vertex2F(0.5,0.5))
        di:setCascadeOpacityEnabled(true)
        di:setPosition(self:getBoneOffset("top"))
        self:addChild(di)
        local tiao = cc.Sprite:createWithSpriteFrameName("aaui_common/enemy_hp_bar_tiao.png")
        tiao:setAnchorPoint(cc.vertex2F(0,0))
        tiao:setColor(GameConst.FIGHT_HP_COLOR[1].c)
        di:addChild(tiao)
        self._hpBar = di
        self._hpTiao = tiao
	end

    self._hpBar:stopAllActions()
    self._hpTiao:stopAllActions()
    self._hpBar:setOpacity(255)
    local per = self.curhp/self.maxhp
    self._hpTiao:runAction(cc.ScaleTo:create(0.3,per:toNumber(), 1))
    self._hpBarHiddenTime = os_clock() + 5
end

function role:updateHpBarColor()
    if self._roleType == role.roleType.boss then return end
    self._hpBar:setPosition(self:getBoneOffset("top"))
    if self._hpBarHiddenTime < os_clock() then
        self._hpBar:runAction(cc.FadeOut:create(0.5))
        self._hpBarHiddenTime = 0
    else
        local sx = self._hpTiao:getScaleX()
        for _, opt in ipairs(GameConst.FIGHT_HP_COLOR) do
        	if opt.r < sx then
                return self._hpTiao:setColor(opt.c)
        	end
        end
    end
end

local effectRes = {}

function role:addChongwuEffect(effect,actionName)
    if not self.chongwu or string.len(effect) == 0 then return end
    if effectRes[effect] then
        effectRes[effect] = effectRes[effect] + 1
    else
        effectRes[effect] = 1
    end
    ch.RoleResManager:loadEffect(effect,function()
        local ani = ch.CommonFunc:createAnimation(effect)  --ccs.Armature:create(effect)
        ch.CommonFunc:playAni(ani, actionName or "play", false)  --ani:getAnimation():play(actionName or "play")
        ch.CommonFunc:setAniCb(ani,
        --ani:getAnimation():setMovementEventCallFunc(
        function(...) 
            ani:removeFromParent()
            effectRes[effect] = effectRes[effect] - 1
            if effectRes[effect] == 0 then
                ch.RoleResManager:releaseEffect(effect)
                effectRes[effect] = nil
            end
        end)
        self.chongwu:addChild(ani, 999)
        -- 宠物光效位置（暂时凑活下）
        ani:setPosition(0,50)
    end)
end

-- 宝物升级光效（暂时凑活下）
function role:showMagicEffect(effect, actionName)
    if string.len(effect) == 0 then return end
    if effectRes[effect] then
        effectRes[effect] = effectRes[effect] + 1
    else
        effectRes[effect] = 1
    end
    ch.RoleResManager:loadEffect(effect,function()
        local ani = ccs.Armature:create(effect)
        ani:getAnimation():play(actionName or "play")
        ani:getAnimation():setMovementEventCallFunc(function(...) 
            ani:removeFromParent()
            effectRes[effect] = effectRes[effect] - 1
            if effectRes[effect] == 0 then
                ch.RoleResManager:releaseEffect(effect)
                effectRes[effect] = nil
            end
        end)
        self._ani:addChild(ani,999)
    end)
end

function role:showDefenceEffect(effect, actionName)
    if string.len(effect) == 0 then return end   
    ch.RoleResManager:loadEffect(effect)
    local effect = ccs.Armature:create(effect)
    effect:getAnimation():play(actionName or "play")
    effect:getAnimation():setMovementEventCallFunc(function(...) effect:removeFromParent() end)
    self.effPannel:addChild(effect)
end

function role:getBoneOffset(boneName)
    return ch.CommonFunc:getHpBarPos(self, boneName)
end

local minDamage = ch.LongDouble:new(1)
function role:underAttack(damage)
    if self.state ~= 3 and self.state ~= 1 then
        self.state = 2
        if ch.CommonFunc:isSpine(self) then
            self:spineSetAnimation("0", "hitted", false)
        else
            self._ani:getAnimation():setSpeedScale(GameConst.GUAI_CRASH_SPEED_SCALE)
            self._ani:getAnimation():play("crush")
        end
    end
    damage = damage < minDamage and minDamage or damage
    self.curhp = self.curhp - damage
    self.curhp = self.curhp < ch.LongDouble.zero and ch.LongDouble.zero or self.curhp
    self:updateHpBar()
    local tp = self:getBoneOffset("top")
    ch.fightRoleLayer:showDamage(tp.x+self:getPositionX(), tp.y+self:getPositionY(), 1, damage)
end

function role:fuwenAttack(damage, type, iscrict)
    if self.isdie then return end
    self.curhp = self.curhp - damage
    self.curhp = self.curhp < ch.LongDouble.zero and ch.LongDouble.zero or self.curhp
    self:updateHpBar()
    local tp = self:getBoneOffset("top")
    ch.fightRoleLayer:showDamage(tp.x + self:getPositionX(), tp.y + self:getPositionY(), iscrict and 3 or 2, damage)
    self._colorRecT = os_clock() + 0.1
    self._ani:setColor(cc.c3b(255,160,87))
end

function role:die()
    self.isdie = true
    if self.config.d and string.len(self.config.d) > 0 then
        ch.SoundManager:play(self.config.d)
    end
    
    if ch.CommonFunc:isSpine(self) then
        self:spineSetAnimation(0, "hitted", false)
    else
        self._ani:getAnimation():stop()
    end

    local tp = self:getBoneOffset("top")
    local goldpx,goldpy = self:getPosition()
    
    zzy.EventManager:dispatch({
        type = role.DEAD_EVENT_TYPE,
        roleType = self._roleType,
        level = self.level,
        x= tp.x+goldpx,
        y = tp.y + goldpy,
        harm = self.realhp - self.curhp
    })
    self:runAction(cc.Sequence:create(cc.Blink:create(0.5,10), cc.CallFunc:create(function()
        if zzy.CocosExtra.isCobjExist(self) then
            ch.fightRoleLayer:removeEnemy(self)
            self:destory()
        end
    end)))
end

function role:kickFly(ts, height)
    if self.state == 1 then
        self._ani:runAction(cc.Sequence:create(
            cc.EaseIn:create(cc.MoveBy:create(ts/2, cc.vertex2F(0, height)),0.5),
            cc.EaseOut:create(cc.MoveBy:create(ts/2, cc.vertex2F(0, -height)),0.5)))
    else
        if ch.CommonFunc:isSpine(self) then
            self:spineSetAnimation(0, "hitted", false)
        else
            self._ani:getAnimation():pause()
        end
        self.state = 3
        
        self._flySpeed = height * 2 / ts
        self._gravity = self._flySpeed / ts
    end
end

function role:kickMove(ts, distance)
    if self.state == 1 then
        self:runAction(cc.MoveBy:create(ts, cc.vertex2F(distance, 0)))
    else
        if ch.CommonFunc:isSpine(self) then
            self:spineSetAnimation(0, "hitted", false)
        else
            self._ani:getAnimation():pause()
        end

        self.state = 3
        self._moveSpeed = distance / ts
        self._moveOverTime = os_clock() + ts
    end
end

function role:playMove()
    if self.state == 4 then return end
    if not self._isstand and self.state == 0 then return end
    
    self.state = 0
    self._isstand = false
    
    ch.CommonFunc:playAni(self._ani, "move", true)
    ch.CommonFunc:playAni(self._effectAni, "move", true)    
end

function role:playVictory(callfunc)
    if self._roleType ~= role.roleType.mainRole then return end 
    self.state = 5
    self._victoryCallFunc = callfunc

    ch.CommonFunc:playAni(self._ani, "victory", false)
    ch.CommonFunc:playAni(self._effectAni, "victory", false)
    ch.CommonFunc:speedAni(self._ani, self._baseActionSpeed * 2)
    ch.CommonFunc:speedAni(self._effectAni, self._baseActionSpeed * 2)
end

function role:setActionSpeed(ratio)
    if ch.CommonFunc:isSpine(self) then return end
    self._actionSpeedRatio = ratio

    ch.CommonFunc:speedAni(self._ani, self._baseActionSpeed * self._actionSpeedRatio)
    ch.CommonFunc:speedAni(self._effectAni, self._baseActionSpeed * self._actionSpeedRatio)
end

function role:playStand()
    if (self._isstand and self.state == 0) or self.state == 4 then return end
    
    ch.CommonFunc:speedAni(self._ani, self._baseActionSpeed * self._actionSpeedRatio)
    ch.CommonFunc:speedAni(self._effectAni, self._baseActionSpeed * self._actionSpeedRatio)

    self._isstand = true
    self.state = 0
    
    
    if ch.CommonFunc:isSpine(self) then
        ch.CommonFunc:playAni(self._ani, "stand", true)
        ch.CommonFunc:playAni(self._effectAni, "stand", true)
    else
        if self._ani:getAnimation():getAnimationData():getMovement("stand") then
            ch.CommonFunc:playAni(self._ani, "stand", true)
            ch.CommonFunc:playAni(self._effectAni, "stand", true)
        else
            ch.CommonFunc:playAni(self._ani, "move", true)
            ch.CommonFunc:playAni(self._effectAni, "move", true)
        end
    end
    
end

function role:update()
    local curTime = os_clock()
    local dt = curTime - self._laseUpdateTime
    
    if self._colorRecT and self._colorRecT < curTime then
        self._ani:setColor(cc.c3b(255,255,255))
        self._colorRecT = nil
    end
    
    if table.maxn(self.effPannel:getChildren()) > 0 then
        self.effPannel:setPosition(self:getBoneOffset("body"))
    end
    if self._hpBarHiddenTime ~= 0 then
        self:updateHpBarColor()
    end
    
    if self.state == 0 then
        if self.curhp and self.curhp <= ch.LongDouble.zero then
            self:die()
        else          
            self.ai(self)
        end
    elseif self.state == 1 then
        local atkConfig = GameConst.MAIN_ROLE_SKILL_CONFIG.nanzhanshi[self._atkIndex]
        local curFrame = math.floor((curTime - self._atkStartTime) * 30 * self._baseActionSpeed * self._actionSpeedRatio + 0.5)
        for k,config in pairs(atkConfig) do
            if string.sub(k,1,1) == "f" then
                local fCount = string.sub(k,2,string.len(k))
                fCount = tonumber(fCount)
                if fCount>= self._lastFrame and fCount <= curFrame then
                    local gold = ch.fightRoleLayer:getAttackDropMoney()
                    for _,effectParam in ipairs(config) do
                        local enemys = ch.fightRoleLayer:getEnemyRoles(effectParam[1])
                        for _,enemy in ipairs(enemys) do
                            ch.fightRoleLayer:doEffect(self, enemy,unpack(effectParam,4))
                            if gold > ch.LongDouble.zero and effectParam[4] == 1 then
                                enemy:dropGold(gold)
                            end
                            enemy:showDefenceEffect(effectParam[2])
                        end
                        if string.len(effectParam[3]) > 0 then
                            --DEBUG("play effect%s"effectParam[3])
                            ch.SoundManager:play(effectParam[3])
                        end
                    end
                end
            end
        end
        self._lastFrame = curFrame + 1
    elseif self.state == 2 then
        if self.curhp and self.curhp <= ch.LongDouble.zero then
            self:die()
        end
    elseif self.state == 3 then
        if self._flySpeed ~= 0 then
            self._flySpeed = self._flySpeed - self._gravity * dt
            local fy = self._ani:getPositionY()
            fy = fy + self._flySpeed * dt
            if fy <= self.basey then
                fy = self.basey
                self._flySpeed = 0
            elseif self._moveSpeed ~= 0 and self._moveOverTime < curTime then
                self._moveOverTime = curTime
            end
            self._ani:setPositionY(fy)
        end
        
        if curTime <= self._moveOverTime then
            self:setPositionX(self:getPositionX() + self._moveSpeed * dt)
        else
            self._moveSpeed = 0
            self._moveOverTime = 0
        end
        
        if self._moveSpeed == 0 and self._flySpeed == 0 then
            self:playStand()
        end
    elseif self.state == 4 then
        local enemys = ch.fightRoleLayer:getEnemyRoles(599999)
        if #enemys > 0 then
            local enemy = enemys[1]
            self:moveAd(enemy:getPositionX(), enemy.config.w)
        else
            self:playStand()
        end
    end
    
    if self.chongwu then
        local chongwuToPos = self:getPositionX() - GameConst.PAT_OFFSET_X * self:getDir()
        local moveDis = GameConst.PAT_MOVE_SPEED * dt
        local chongwuPos
        if math.abs(chongwuToPos - self.chongwu.pos) < moveDis then
            if self.chongwu:getCurStatue() == ch.petRole.roleStatue.move then
                self.chongwu:stand()
            end
            chongwuPos = chongwuToPos
        else
            if self.chongwu:getCurStatue() == ch.petRole.roleStatue.stand then
                self.chongwu:move()
            end
            chongwuPos = self.chongwu.pos + (chongwuToPos > self.chongwu.pos and 1 or -1) * moveDis
        end
        self.chongwu.pos = chongwuPos
        self.chongwu:setPositionX(chongwuPos - self:getPositionX())
        self.chongwu:setScaleX(self:getDir())
        self.chongwu:update()
    end
    self:updateSkillEffect()
    self._laseUpdateTime = curTime
end

function role:setRoleVisible(isVisible)
    self.state = isVisible and 0 or 4
	self:setVisible(isVisible)
	if not isVisible then
        ch.CommonFunc:stopAni(self._ani)
	end

	if self._effectAni then
        self._effectAni:setVisible(isVisible)
    end
end

function role:isRoleVisible()
    return self:isVisible()
end

function role:destory()
    if self.chongwu then
        self.chongwu:destory()
    end
    self:removeSkillEffect()
	self:removeFromParent()
end

function role:moveAd(tx, tw)
    if self.state ~= 0 and self.state ~= 4 then return end

    local cx = self:getPositionX()
    local distance = math.abs(tx - cx)
    local minDistance = tw + self.config.w
    
    if tx ~= cx then
        if self._roleType == role.roleType.mainRole then
            --self._ani:setScaleX(self.scale * (tx > cx and 1 or -1))
            self._effectAni:setScaleX(self.scale * (tx > cx and 1 or -1))
        else
            --self._ani:setScaleX(self.scale * (tx > cx and -1 or 1))
        end
    end
    
    if distance <= minDistance then
        return self:playStand()
    end
    
    local nDistance = distance - self.config.s * (os_clock() - self._laseUpdateTime)
    if nDistance < minDistance then
        nDistance = minDistance
    end
    local nx
    if tx > cx then
        nx = tx - nDistance
    else
        nx = tx + nDistance
    end

    self._ani:setPositionX(self.basey * GameConst.FIGHT_UNIT_OFFSET_X_RATIO * (tx > cx and 1 or -1))
    if self._effectAni then
        self._effectAni:setPositionX(self.basey * GameConst.FIGHT_UNIT_OFFSET_X_RATIO * (tx > cx and 1 or -1))
    end
    self:setPositionX(nx)
    self:playMove()
end

function role:attack(skIndex)
    --DEBUG("role:attack(%d)", skIndex)
    local atkConfig = GameConst.MAIN_ROLE_SKILL_CONFIG.nanzhanshi[skIndex]
    local enemys = ch.fightRoleLayer:getEnemyRoles(atkConfig.te[1])
    if table.maxn(enemys) < atkConfig.te[2] then
        return false
    end
    
    self.state = 1
    self._atkIndex = skIndex
    self._nxtAtkSkills = atkConfig.nt
    self._atkStartTime = os_clock()
    self._lastFrame = 1
    
    ch.CommonFunc:playAni(self._ani, "attack"..skIndex, false)
    ch.CommonFunc:playAni(self._effectAni, "attack"..skIndex, false)

    if not atkConfig.harmRatio then
        local frameCount = 30
        if ch.CommonFunc:isSpine(self) then
            frameCount = ch.CommonFunc:getFramesCount(skIndex)
        else
            frameCount = zzy.CocosExtra.getMovementDataFrameCount(self._ani:getAnimation():getAnimationData():getMovement("attack"..skIndex))
        end
        --INFO("[attack%d][frame=%d]", skIndex, frameCount)

        local totalWidget = 0
        local waitToRatio = {}
        
        for f = 1, frameCount do
            local effectConfig = atkConfig["f"..f]
            for _,effectParam in ipairs(effectConfig or {}) do
                if effectParam[4] == 1 then
                    totalWidget = totalWidget + effectParam[5]
                    table.insert(waitToRatio, effectParam)
                end
            end
        end
        if totalWidget > 0 then
            atkConfig.harmRatio = frameCount / totalWidget / 30
            atkConfig.harmRatio = atkConfig.harmRatio/GameConst.MAIN_ROLE_ACTION_SPEED_SCALE
            for _, var in ipairs(waitToRatio) do
                var[5] = var[5] * atkConfig.harmRatio
            end
        else
            atkConfig.harmRatio = 1
            cclog("attack"..skIndex.." has no damage!")
        end
    end

    return true
end

function role:dropGold(gold) -- 黄金季节
    local tp = self:getBoneOffset("top")
    local goldpx,goldpy = self:getPosition()
    goldpx,goldpy = goldpx + tp.x,goldpy + tp.y
    ch.fightRoleLayer:addHJJJGold(gold)
    if math.random(1,10) == 1 then
        ch.goldLayer:dropMoney(goldpx, goldpy, 1,1)
    end
end

function role:spineSetAnimation(trackId, aniName, isLoop)
    --DEBUG("[self:spineSetAnimation]%s", aniName)
    ch.CommonFunc:playAni(self._ani, aniName, isLoop)
    --self._ani:setAnimation(trackId, aniName, isLoop)
end

function role:objPlayAni(trackId, aniName, isLoop)
    --DEBUG("[self:spineSetAnimation]%s", aniName)
    --self._ani:setAnimation(trackId, aniName, isLoop)
    ch.CommonFunc:playAni(self._ani, aniName, isLoop)
end

return role
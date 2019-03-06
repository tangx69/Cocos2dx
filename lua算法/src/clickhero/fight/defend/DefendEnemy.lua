local DefendEnemy = {
    _renderer = nil,
    _ani = nil,
    _state = nil, -- 0,为空闲,1为移动，2为受击,3为死亡,4为击飞
    _speed = nil,
    _speedRatio = nil, -- 一帧有效
    _config = nil,
    
    _totalHp = nil,
    _curHp = nil,
    
    _hpBar = nil,
    _hpTiao = nil,
    _colorRecTime = nil, 
    _hpBarHiddenTime = nil,
    _halfWidth = nil,
    _prePositionX = nil,
}

DefendEnemy.__index = DefendEnemy

function DefendEnemy:create(gid,baseHp)
    local o = {}
    setmetatable(o,DefendEnemy) 
    local info = GameConst.DEFEND_MONSTERS[gid]
    o._config = ch.editorConfig:getRoleConfig(info.name)
    o._renderer = cc.Node:create()
    o._ani = ch.CommonFunc:createAnimation(info.name)--ccs.Armature:create(info.name)
    o._ani:setScale(info.scale)
    if ch.CommonFunc:isSpine(o._ani) then
        o._ani:setScaleX(-o._ani:getScaleX())
    end

    o._halfWidth = o._config.w * info.scale
    o._prePositionX = 0
    o._speedRatio = 1
    o._renderer:addChild(o._ani)
    o:playMove()
    
    --ch.CommonFunc:setAniCb(o._ani, function(...) o:onMovementEvent(...) end)--o._ani:getAnimation():setMovementEventCallFunc(function(...) o:onMovementEvent(...) end)
    o._speed = info.speed
    o:_initHp(info.hpRatio * baseHp)
    return o
end

function DefendEnemy:getRenderer()
	return self._renderer
end

function DefendEnemy:underAttack(harm,isPlay)
    if self._state == 3 then return false end
    self._curHp = self._curHp - harm
    if self._curHp < ch.LongDouble.zero then self._curHp = ch.LongDouble.zero end
    self._hpBar:stopAllActions()
    self._hpTiao:stopAllActions()
    self._hpBar:setOpacity(255)
    local per = (self._curHp/self._totalHp):toNumber()
    self._hpTiao:runAction(cc.ScaleTo:create(0.3, math.max(per, 0), 1))
    self._hpBarHiddenTime = os_clock()+5
    self._colorRecTime = os_clock() + 0.1
    self._ani:setColor(cc.c3b(255,160,87))
    if self._curHp == ch.LongDouble.zero then
        self:die()
        return true
    else
        if isPlay then
            self:playCrush()
        end
        return false 
    end
end

function DefendEnemy:getState()
    return self._state
end

function DefendEnemy:getHalfWidth()
	return self._halfWidth
end

function DefendEnemy:playMove()
    if self._state == 1 or self._state == 3 then return end
    self._state = 1
    
    ch.CommonFunc:playAni(self._ani, "move", true)--self._ani:getAnimation():play("move",-1,1)
end

function DefendEnemy:kickFly(time,distance)
    if self._state == 3 then return end
    self._state = 4
    ch.CommonFunc:playAni(self._ani, "crush", false)--self._ani:getAnimation():play("crush",-1,0)
    self._renderer:stopAllActions()
    local pos = cc.p(self._renderer:getPositionX()+distance,0)
    local call = cc.CallFunc:create(function()
        self:playMove()
    end)
    local seq = cc.Sequence:create(cc.JumpTo:create(time,pos,100,1),call)
    self._renderer:runAction(seq)
end

function DefendEnemy:playCrush()
    if self._state == 3 then return end
    self._state = 2
    ch.CommonFunc:playAni(self._ani, "crush", false)--self._ani:getAnimation():play("crush",-1,0)
end

function DefendEnemy:onMovementEvent(armatureBack,movementType,movementID)
    if movementType == ccs.MovementEventType.complete then
        if movementID == "crush" then
            if self._state == 2 then
                self:playMove()
            end
        end
    end
end

function DefendEnemy:pause()
    self._renderer:pause()
    if self._state ~= 3 then
        ch.CommonFunc:pauseAni(self._ani)--self._ani:getAnimation():pause()
    end
end

function DefendEnemy:resume()
    self._renderer:resume()
    if self._state ~= 3 then
        ch.CommonFunc:resumeAni(self._ani)--self._ani:getAnimation():resume()
    end
end

function DefendEnemy:die()
    if self._state == 3 then return end
    self._state = 3
    ch.CommonFunc:stopAni(self._ani)--self._ani:getAnimation():stop()
    if self._config.d and string.len(self._config.d) > 0 and not ch.SettingModel:isNoSoundPlaying() then
        cc.SimpleAudioEngine:getInstance():playEffect(string.format("res/sound/%s.wav", self._config.d))
    end
    self._renderer:runAction(cc.Sequence:create(cc.Blink:create(0.5,10), cc.CallFunc:create(function()
        if zzy.CocosExtra.isCobjExist(self._renderer) then
            ch.DefendMap:removeEnemy(self)
        end
    end)))
    if self._config.d ~= nil and self._config.d ~= "" then 
        ch.SoundManager:play(self._config.d)
    end
    self:_onDeadth()
end

function DefendEnemy:_onDeadth()
    local pos = self:getBoneOffset("top")
    if math.random() < ch.DefendModel:getCrystalsRate() then
        local num = ch.DefendModel:getCrystalsDropNum()
        ch.DefendModel:addCrystals(num)
        ch.DefendMap:dropMoney(self._renderer:getPositionX()+ pos.x,self._renderer:getPositionY() + pos.y,num)
    end
    local num = 1
    if math.random() < ch.DefendModel:getPowerRate() then
        num = num + ch.DefendModel:getPowerDropNum()
    end
    ch.DefendModel:addPower(num)
    ch.DefendMap:dropMoney(self._renderer:getPositionX()+ pos.x,self._renderer:getPositionY() + pos.y,num,2)
end

function DefendEnemy:move(distance)
    local x = self._renderer:getPositionX() + distance
    self._renderer:setPositionX(x)
end

function DefendEnemy:getTotalHP()
    return self._totalHp
end

function DefendEnemy:setBaseSpeed(speed)
    self._speed = speed
end

function DefendEnemy:setSpeedRatio(ratio)
    self._speedRatio = ratio
end

function DefendEnemy:getSpeed()
    if self._state == 1 or self._state == 0 then
        return self._speed * self._speedRatio
    end
    return 0
end

function DefendEnemy:setPosition(pos)
    self._renderer:setPosition(pos)
end

function DefendEnemy:destroy()
    self._renderer:removeFromParent()
end

function DefendEnemy:update()
    self._prePositionX = self._renderer:getPositionX()
    ch.EnemyAI:update(self)
    if self._colorRecTime and os_clock() > self._colorRecTime then
        self._ani:setColor(cc.c3b(255,255,255))
        self._colorRecTime = nil
    end
	self:_updateHpBarColor()
	self._speedRatio = 1
end

function DefendEnemy:isContained(x,range)
    return self:getPositionX() + self:getHalfWidth() > x-range and self:getPositionX() - self:getHalfWidth() < x+range
end

function DefendEnemy:getBoneOffset(boneName)
    return ch.CommonFunc:getHpBarPos(self, boneName)
end

function DefendEnemy:getPositionX()
    return self._renderer:getPositionX()
end

function DefendEnemy:getPrePositionX()
    return self._prePositionX
end

function DefendEnemy:_initHp(hp)
    self._hpBar = cc.Sprite:createWithSpriteFrameName("aaui_common/enemy_hp_bar_di.png")
    self._hpBar:setAnchorPoint(cc.p(0.5,0.5))
    self._hpBar:setCascadeOpacityEnabled(true)
    self._hpBar:setOpacity(0)
    self._hpBar:setPosition(self:getBoneOffset("top"))
    self._renderer:addChild(self._hpBar)
    self._hpTiao = cc.Sprite:createWithSpriteFrameName("aaui_common/enemy_hp_bar_tiao.png")
    self._hpTiao:setAnchorPoint(cc.vertex2F(0,0))
    self._hpTiao:setColor(GameConst.FIGHT_HP_COLOR[1].c)
    self._hpBar:addChild(self._hpTiao)
    self._totalHp = hp
    self._curHp = self._totalHp
end

function DefendEnemy:_updateHpBarColor()
    if not self._hpBarHiddenTime then return end
    self._hpBar:setPosition(self:getBoneOffset("top"))
    if self._hpBarHiddenTime < os_clock() then
        self._hpBar:runAction(cc.FadeOut:create(0.5))
        self._hpBarHiddenTime = nil
    else
        local sx = self._hpTiao:getScaleX()
        for _, opt in ipairs(GameConst.FIGHT_HP_COLOR) do
            if opt.r < sx then
                return self._hpTiao:setColor(opt.c)
            end
        end
    end
end

return DefendEnemy
local effectName = "anleizhan"

---
-- 暗雷斩
-- @module ALZSkill
local ALZSkill = {
    _startTime = nil,
    _renderer = nil,
    _lastTime = nil,
    _config = nil,
    _value = nil,
}

ALZSkill.__index = ALZSkill

---
-- 创建
-- @function [parent=#ALZSkill] create
-- @param #ALZSkill self
-- @return #ALZSkill
function ALZSkill:create()
    local o = {}
    setmetatable(o,self)
    o:_init()
    return o
end

---
-- 获得renderer
-- @function [parent=#ALZSkill] getRenderer
-- @param #ALZSkill self
-- @return #Node
function ALZSkill:getRenderer()
    return self._renderer
end

---
-- 初始化
-- @function [parent=#ALZSkill] _init
-- @param #ALZSkill self
function ALZSkill:_init()
    self._config = GameConfig.SkillConfig:getData(ch.DefendModel.skillId.ALZ)
    self._value = self._config.value/10000
    self._renderer = ccs.Armature:create("tx_zhudongjineng")
    self._renderer:getAnimation():play(effectName,-1,1)
    self._renderer:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.loopComplete then
            local scaleX = self._renderer:getScaleX() * -1
            self._renderer:setScaleX(scaleX)
        end
    end)
    self._startTime = ch.DefendTimer:getGameTime()
    self._lastTime = 0
    self._renderer:setPosition(140,0)
    ch.DefendMap:addChild(self._renderer,10)
end

---
-- 暂停
-- @function [parent=#ALZSkill] pause
-- @param #ALZSkill self
function ALZSkill:pause()
	self._renderer:getAnimation():pause()
end

---
-- 恢复
-- @function [parent=#ALZSkill] resume
-- @param #ALZSkill self
function ALZSkill:resume()
    self._renderer:getAnimation():resume()
end

---
-- 获得初始位置
-- @function [parent=#ALZSkill] getInitX
-- @param #ALZSkill self
-- @return #number
function ALZSkill:getInitX()
    return 0
end

---
-- 每帧运算
-- @function [parent=#ALZSkill] update
-- @param #ALZSkill self
function ALZSkill:update()
    if not self._startTime then return end
    local now = ch.DefendTimer:getGameTime()
    if now - self._startTime >= self._config.duration then
        self:_onEnd()
    elseif now - self._lastTime >= self._config.interval then
        self._lastTime = now
        local attack = ch.DefendModel:getDPS() * self._value
        for k,enemy in ipairs(ch.DefendMap:getAllEnemy()) do
            if enemy:getState()~= 3 then
                local enemyX = enemy:getPositionX() - enemy:getHalfWidth()
                if enemyX <= self._config.endX then
                    ch.DefendMap:attackOneEnemy(enemy,attack)
                end
            end
        end
    end
end

---
-- 技能结束
-- @function [parent=#ALZSkill] _onEnd
-- @param #ALZSkill self
function ALZSkill:_onEnd()
    ch.DefendMap:removeSkill(self)
end

---
-- 销毁
-- @function [parent=#ALZSkill] destroy
-- @param #ALZSkill self
function ALZSkill:destroy()
    self._renderer:removeFromParent()
    self._renderer = nil
end

return ALZSkill
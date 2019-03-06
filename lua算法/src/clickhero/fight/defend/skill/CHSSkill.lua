local effectName = "chihuanshu"

---
-- 迟缓术
-- @module CHSSkill
local CHSSkill = {
    _startTime = nil,
    _renderer = nil,
    _lastTime = nil,
    _config = nil,
    _value = nil,
}

CHSSkill.__index = CHSSkill

---
-- 创建
-- @function [parent=#CHSSkill] create
-- @param #CHSSkill self
-- @return #CHSSkill
function CHSSkill:create()
    local o = {}
    setmetatable(o,self)
    o:_init()
    return o
end

---
-- 获得renderer
-- @function [parent=#CHSSkill] getRenderer
-- @param #CHSSkill self
-- @return #Node
function CHSSkill:getRenderer()
    return self._renderer
end

---
-- 初始化
-- @function [parent=#CHSSkill] _init
-- @param #CHSSkill self
function CHSSkill:_init()
    self._config = GameConfig.SkillConfig:getData(ch.DefendModel.skillId.CHS)
    self._value = 1 - self._config.value/10000
    self._renderer = ccs.Armature:create("tx_zhudongjineng")
    self._renderer:setScaleX(1.8)
    self._renderer:getAnimation():play("chihuanshu_start",-1,0)
    self._renderer:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
        if movementType == ccs.MovementEventType.complete then
            if movementID == "chihuanshu_start" then
                self._renderer:getAnimation():play("chihuanshu_play",-1,1)
            elseif movementID == "chihuanshu_end" then
                ch.DefendMap:removeSkill(self)
            end
        end
    end)
    self._startTime = ch.DefendTimer:getGameTime()
    self._renderer:setPosition((self._config.startX +self._config.endX)/2,0)
    ch.DefendMap:addChild(self._renderer,1)
end

---
-- 暂停
-- @function [parent=#CHSSkill] pause
-- @param #CHSSkill self
function CHSSkill:pause()
    self._renderer:getAnimation():pause()
end

---
-- 恢复
-- @function [parent=#CHSSkill] resume
-- @param #CHSSkill self
function CHSSkill:resume()
    self._renderer:getAnimation():resume()
end

---
-- 获得初始位置
-- @function [parent=#CHSSkill] getInitX
-- @param #CHSSkill self
-- @return #number
function CHSSkill:getInitX()
    return 0
end

---
-- 每帧运算
-- @function [parent=#CHSSkill] update
-- @param #CHSSkill self
function CHSSkill:update()
    if not self._startTime then return end
    local now = ch.DefendTimer:getGameTime()
    if now - self._startTime >= self._config.duration then
        self:_onEnd()
    else
        for k,enemy in ipairs(ch.DefendMap:getAllEnemy()) do
            if enemy:getState()~= 3 then
                local leftX = enemy:getPositionX() - enemy:getHalfWidth()
                local rightX = enemy:getPositionX() + enemy:getHalfWidth()
                if leftX <= self._config.endX and rightX >= self._config.startX then
                    enemy:setSpeedRatio(self._value)
                end
            end
        end
    end
end

---
-- 技能结束
-- @function [parent=#CHSSkill] _onEnd
-- @param #CHSSkill self
function CHSSkill:_onEnd()
    self._startTime = nil
    self._renderer:getAnimation():play("chihuanshu_end",-1,0)
end

---
-- 销毁
-- @function [parent=#CHSSkill] destroy
-- @param #CHSSkill self
function CHSSkill:destroy()
    self._renderer:removeFromParent()
    self._renderer = nil
end

return CHSSkill
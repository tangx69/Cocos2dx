--local durtion = 5
--local value = 20
---
-- 复苏之风
-- @module FSZFSkill
local FSZFSkill = {
    _startTime = nil,
    _renderer = nil,
    _config = nil,
    _value = nil
}

FSZFSkill.__index = FSZFSkill

---
-- 创建
-- @function [parent=#FSZFSkill] create
-- @param #FSZFSkill self
-- @return #FSZFSkill
function FSZFSkill:create()
    local o = {}
    setmetatable(o,self)
    o:_init()
    return o
end

---
-- 获得renderer
-- @function [parent=#FSZFSkill] getRenderer
-- @param #FSZFSkill self
-- @return #Node
function FSZFSkill:getRenderer()
    return self._renderer
end

---
-- 初始化
-- @function [parent=#FSZFSkill] _init
-- @param #FSZFSkill self
function FSZFSkill:_init()
    self._config = GameConfig.SkillConfig:getData(ch.DefendModel.skillId.FSZF)
    self._value = self._config.value/10000
    self._startTime = ch.DefendTimer:getGameTime()
    ch.DefendMap:getPet():addAutoAttackCount(self._value)
    ch.DefendMap:getPet():addSkillEffect()
end

---
-- 获得初始位置
-- @function [parent=#FSZFSkill] getInitX
-- @param #FSZFSkill self
-- @return #number
function FSZFSkill:getInitX()
    return 0
end

---
-- 暂停
-- @function [parent=#FSZFSkill] pause
-- @param #FSZFSkill self
function FSZFSkill:pause()
    
end

---
-- 恢复
-- @function [parent=#FSZFSkill] resume
-- @param #FSZFSkill self
function FSZFSkill:resume()
    
end

---
-- 每帧运算
-- @function [parent=#FSZFSkill] update
-- @param #FSZFSkill self
function FSZFSkill:update()
    if not self._startTime then return end
    if ch.DefendTimer:getGameTime() - self._startTime >= self._config.duration then
        self:_onEnd()
    end
end

---
-- 技能结束
-- @function [parent=#FSZFSkill] _onEnd
-- @param #FSZFSkill self
function FSZFSkill:_onEnd()
    ch.DefendMap:getPet():addAutoAttackCount(-self._value)
    ch.DefendMap:getPet():removeSkillEffect()
    ch.DefendMap:removeSkill(self)
end

---
-- 销毁
-- @function [parent=#FSZFSkill] destroy
-- @param #FSZFSkill self
function FSZFSkill:destroy()
    
end

return FSZFSkill
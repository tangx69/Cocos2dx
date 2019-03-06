local effectName = "huohaishu"

---
-- 火海术
-- @module HHSSkill
local HHSSkill = {
    _startTime = nil,
    _renderer = nil,
    _lastTime = nil,
    _config = nil,
    _value = nil,
}

HHSSkill.__index = HHSSkill

---
-- 创建
-- @function [parent=#HHSSkill] create
-- @param #HHSSkill self
-- @return #HHSSkill
function HHSSkill:create()
    local o = {}
    setmetatable(o,self)
    o:_init()
    return o
end

---
-- 获得renderer
-- @function [parent=#HHSSkill] getRenderer
-- @param #HHSSkill self
-- @return #Node
function HHSSkill:getRenderer()
    return self._renderer
end

---
-- 初始化
-- @function [parent=#HHSSkill] _init
-- @param #HHSSkill self
function HHSSkill:_init()
    self._config = GameConfig.SkillConfig:getData(ch.DefendModel.skillId.HHS)
    self._value = self._config.value/10000
    self._startTime = ch.DefendTimer:getGameTime()
    self._lastTime = 0
    self._fontRenderer = ccs.Armature:create("tx_zhudongjineng")
    self._fontRenderer:getAnimation():play(effectName,-1,1)
    self._fontRenderer:setPosition(320,-30)
    ch.DefendMap:addChild(self._fontRenderer,9)
    self._backRenderer = ccs.Armature:create("tx_zhudongjineng")
    self._backRenderer:getAnimation():play(effectName,-1,1)
    self._backRenderer:setPosition(320,100)
    ch.DefendMap:addChild(self._backRenderer,-1)
end

---
-- 获得初始位置
-- @function [parent=#HHSSkill] getInitX
-- @param #HHSSkill self
-- @return #number
function HHSSkill:getInitX()
    return 0
end

---
-- 暂停
-- @function [parent=#HHSSkill] pause
-- @param #HHSSkill self
function HHSSkill:pause()
    self._fontRenderer:getAnimation():pause()
    self._backRenderer:getAnimation():pause()
end

---
-- 恢复
-- @function [parent=#HHSSkill] resume
-- @param #HHSSkill self
function HHSSkill:resume()
    self._fontRenderer:getAnimation():resume()
    self._backRenderer:getAnimation():resume()
end

---
-- 每帧运算
-- @function [parent=#HHSSkill] update
-- @param #HHSSkill self
function HHSSkill:update()
    if not self._startTime then return end
    local now = ch.DefendTimer:getGameTime()
    if now - self._startTime >= self._config.duration then
        self:_onEnd()
    elseif now - self._lastTime >= self._config.interval then
        self._lastTime = now
        local attack = ch.DefendModel:getDPS() * self._value
        for k,enemy in ipairs(ch.DefendMap:getAllEnemy()) do
            if enemy:getState() ~= 3 then
                ch.DefendMap:attackOneEnemy(enemy,attack)
            end
        end
    end
end

---
-- 技能结束
-- @function [parent=#HHSSkill] _onEnd
-- @param #HHSSkill self
function HHSSkill:_onEnd()
    ch.DefendMap:removeSkill(self)
end

---
-- 销毁
-- @function [parent=#HHSSkill] destroy
-- @param #HHSSkill self
function HHSSkill:destroy()
    self._fontRenderer:removeFromParent()
    self._backRenderer:removeFromParent()
    self._fontRenderer = nil
    self._backRenderer = nil
end

return HHSSkill
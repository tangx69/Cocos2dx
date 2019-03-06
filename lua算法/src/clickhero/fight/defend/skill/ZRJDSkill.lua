local speed = 0
local offsetLenght = 350
local addSpeed = 20

---
-- 主人驾到
-- @module ZRJDSkill
local ZRJDSkill = {
    _startTime = nil,
    _renderer = nil,
    _width = nil,
    _curSpeed = nil,
    _config = nil,
    _value = nil,
    _roleAni = nil,
}

ZRJDSkill.__index = ZRJDSkill

---
-- 创建
-- @function [parent=#ZRJDSkill] create
-- @param #ZRJDSkill self
-- @return #ZRJDSkill
function ZRJDSkill:create()
	local o = {}
	setmetatable(o,self)
	o:_init()
	return o
end

---
-- 获得renderer
-- @function [parent=#ZRJDSkill] getRenderer
-- @param #ZRJDSkill self
-- @return #Node
function ZRJDSkill:getRenderer()
    return self._renderer
end

---
-- 初始化
-- @function [parent=#ZRJDSkill] _init
-- @param #ZRJDSkill self
function ZRJDSkill:_init()
    self._config = GameConfig.SkillConfig:getData(ch.DefendModel.skillId.ZRJD)
    self._value = self._config.value/10000
	self._renderer = cc.Node:create()
    self._width = ch.editorConfig:getRoleConfig("nanzhanshi").w/2
    self._roleAni = ccs.Armature:create("tx_juesejineng")
    self._roleAni:getAnimation():play("play",-1,1)
    self._roleAni:getAnimation():setSpeedScale(1.2)
    self._renderer:addChild(self._roleAni)
    self._renderer:setPositionX(self:getInitX())
    self._startTime = ch.DefendTimer:getGameTime()
    self._curSpeed = speed
    ch.DefendMap:addChild(self._renderer,7)
end

---
-- 获得初始位置
-- @function [parent=#ZRJDSkill] getInitX
-- @param #ZRJDSkill self
-- @return #number
function ZRJDSkill:getInitX()
    return -self._width - offsetLenght
end

---
-- 暂停
-- @function [parent=#ZRJDSkill] pause
-- @param #ZRJDSkill self
function ZRJDSkill:pause()
    self._roleAni:getAnimation():pause()
end

---
-- 恢复
-- @function [parent=#ZRJDSkill] resume
-- @param #ZRJDSkill self
function ZRJDSkill:resume()
    self._roleAni:getAnimation():resume()
end

---
-- 每帧运算
-- @function [parent=#ZRJDSkill] update
-- @param #ZRJDSkill self
function ZRJDSkill:update()
	if not self._startTime then return end
    local x = self._renderer:getPositionX()
    local posX = x + self._curSpeed * ch.DefendTimer:getDeltaTime()
    local harm = ch.MagicModel:getTotalDPS() * self._value
    for k,enemy in ipairs(ch.DefendMap:getAllEnemy()) do
        if enemy:getState() ~= 3 then
            local enemyX = enemy:getPositionX() - enemy:getHalfWidth()
            local enemyPreX = enemy:getPrePositionX() - enemy:getHalfWidth()
            if enemyPreX >x + offsetLenght  and enemyX <= posX + offsetLenght then
                ch.DefendMap:attackOneEnemy(enemy,harm,false,true)
            end
        end
    end
    if posX > 640 + self._width then
        self:_onEnd()
    else
        self._renderer:setPositionX(posX)
    end
    self._curSpeed = self._curSpeed + addSpeed
end

---
-- 技能结束
-- @function [parent=#ZRJDSkill] _onEnd
-- @param #ZRJDSkill self
function ZRJDSkill:_onEnd()
    ch.DefendMap:removeSkill(self)
end

---
-- 销毁
-- @function [parent=#ZRJDSkill] destroy
-- @param #ZRJDSkill self
function ZRJDSkill:destroy()
    self._renderer:removeFromParent()
    self._renderer = nil
    self._roleAni = nil
end

return ZRJDSkill
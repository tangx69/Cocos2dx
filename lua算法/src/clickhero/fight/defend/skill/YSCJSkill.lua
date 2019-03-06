local effectName = "yanshichongji"
local totalCount = 5

local startX = 60
local intervalLenght = 122
local halfWidth = 75
local distance = intervalLenght + 15

---
-- 岩石冲击
-- @module YSCJSkill
local YSCJSkill = {
    _startTime = nil,
    _renderer = nil,
    _lastTime = nil,
    _config = nil,
    _value = nil,
    _count = nil,
    _isAniEnd = nil
}

YSCJSkill.__index = YSCJSkill

---
-- 创建
-- @function [parent=#YSCJSkill] create
-- @param #YSCJSkill self
-- @return #YSCJSkill
function YSCJSkill:create()
    local o = {}
    setmetatable(o,self)
    o:_init()
    return o
end

---
-- 获得renderer
-- @function [parent=#YSCJSkill] getRenderer
-- @param #YSCJSkill self
-- @return #Node
function YSCJSkill:getRenderer()
    return self._renderer
end

---
-- 初始化
-- @function [parent=#YSCJSkill] _init
-- @param #YSCJSkill self
function YSCJSkill:_init()
    self._config = GameConfig.SkillConfig:getData(ch.DefendModel.skillId.YSCJ)
    self._renderer = cc.Node:create()
    self._startTime = ch.DefendTimer:getGameTime()
    self._lastTime = 0
    self._count = 0
    self._renderer:setPosition(0,0)
    ch.DefendMap:addChild(self._renderer,8)
end

---
-- 获得初始位置
-- @function [parent=#YSCJSkill] getInitX
-- @param #YSCJSkill self
-- @return #number
function YSCJSkill:getInitX()
    return 0
end

---
-- 暂停
-- @function [parent=#YSCJSkill] pause
-- @param #YSCJSkill self
function YSCJSkill:pause()
    for k,v in ipairs(self._renderer:getChildren()) do
        v:getAnimation():pause()
    end
end

---
-- 恢复
-- @function [parent=#YSCJSkill] resume
-- @param #YSCJSkill self
function YSCJSkill:resume()
    for k,v in ipairs(self._renderer:getChildren()) do
        v:getAnimation():resume()
    end
end

---
-- 每帧运算
-- @function [parent=#YSCJSkill] update
-- @param #YSCJSkill self
function YSCJSkill:update()
    if not self._startTime then return end
    local now = ch.DefendTimer:getGameTime()
    if self._count < totalCount then
        if now - self._lastTime > self._config.interval then
            local ani = ccs.Armature:create("tx_zhudongjineng")
            ani:getAnimation():play(effectName,-1,0)
            local curX = startX+intervalLenght*self._count
            ani:setPositionX(curX)
            self._renderer:addChild(ani)
            self._count = self._count + 1
            self._lastTime = now
            if self._count == totalCount then
                ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType)
                    if movementType == ccs.MovementEventType.complete then
                        self._isAniEnd = true
                    end
                end)
            end
            for k,enemy in ipairs(ch.DefendMap:getAllEnemy()) do
                if enemy:getState() ~= 3 then
                    local leftX = enemy:getPositionX() - enemy:getHalfWidth()
                    local rightX = enemy:getPositionX() + enemy:getHalfWidth()
                    if rightX>= curX - halfWidth and leftX<=curX + halfWidth then
                        enemy:kickFly(self._config.interval,distance)
                    end
                end
            end
        end
    elseif self._isAniEnd then
        self:_onEnd()
    end
end

---
-- 技能结束
-- @function [parent=#YSCJSkill] _onEnd
-- @param #YSCJSkill self
function YSCJSkill:_onEnd()
    ch.DefendMap:removeSkill(self)
end

---
-- 销毁
-- @function [parent=#YSCJSkill] destroy
-- @param #YSCJSkill self
function YSCJSkill:destroy()
    self._renderer:removeFromParent()
    self._renderer = nil
end

return YSCJSkill
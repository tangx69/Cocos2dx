local petRole = {
    _ani = nil,
    _timeId = nil,
    _statue = nil, -- -1初始化， 0闲置，1移动，2攻击
   -- _level = 1,
    roleStatue = {
        stand = 0,
        move = 1,
        attack1 = 2,
        attack2 = 3,
        attack3 = 4
    }
}

function petRole:create(petName)
	local node = cc.Node:create()
	for k,v in pairs(petRole) do
	   node[k] = v
	end
    node.petName = petName

    node._ani = ch.CommonFunc:createAnimation(petName)
    node:addChild(node._ani)
    node._statue = -1
    if ch.CommonFunc:isSpine(node._ani) then
        local function callBack(...)
            local args = {...}
            local movementID = args[1].animation
            if movementID then
                if string.sub(movementID,1,6)  == "attack" and node and node.stand then
                    node:stand()
                end
            end
        end
        node._ani:registerSpineEventHandler(callBack, sp.EventType.ANIMATION_COMPLETE)
    else
        node._ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if (movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete)
                and string.sub(movementID,1,6)  == "attack" then
                --node._timeId = zzy.TimerUtils:setTimeOut(0,function()
                    if node and node.stand then 
                        node:stand()
    --                    node._backAni:getAnimation():stop()
    --                    node._backAni:setVisible(false)
    --                    node._level = 1
                    end
                    --node._timeId = nil
            -- end)
            end
        end)
    end
    if ch.RunicModel:getSkillDuration(ch.RunicModel.skillId.qianshouzhili) > 0 then
        node:addSkillEffect()
    end
    
    return node
end

function petRole:update()
    self:updateSkillEffect()
end

function petRole:getCurStatue()
	return self._statue
end

function petRole:stand()
	if self._statue == 0 then return end
    if ch.CommonFunc:isSpine(self._ani) then
        self._ani:setAnimation(0, "move", true)
    else
	    self._ani:getAnimation():play("stand",-1,1)
    end
	self._statue = 0
end

function petRole:move()
    if self._statue == 1 or self._statue == 2 then return end
    if ch.CommonFunc:isSpine(self._ani) then
        self._ani:setAnimation(0, "move", true)
    else
        self._ani:getAnimation():play("move",-1,1)
    end
    self._statue = 1
end

function petRole:updateSkillEffect()
    if self._shadowEffect then
        local p = self:getBoneOffset("body")
        self._shadowEffect:setPosition(p.x,80)
    end
end

function petRole:addSkillEffect()
    if self._shadowEffect then return end
    ch.RoleResManager:loadEffect("tx_qianshouzhili",function()
        if not zzy.CocosExtra.isCobjExist(self) then return end
        self._shadowEffect = ccs.Armature:create("tx_qianshouzhili")
        local p = self:getBoneOffset("body")
        self._shadowEffect:setPosition(p.x,80)
        self._shadowEffect:getAnimation():play("Animation1")
        self:addChild(self._shadowEffect)
    end)
end

function petRole:removeSkillEffect()
    if self._shadowEffect then
        self._shadowEffect:removeFromParent()
        self._shadowEffect = nil
        ch.RoleResManager:releaseEffect("tx_qianshouzhili")
    end
end

function petRole:getBoneOffset(boneName)
    return ch.CommonFunc:getHpBarPos(self, boneName)
--[[
    local boneP = self._ani:getBone(boneName):getWorldInfo():getPosition()
    local newX = boneP.x * self._ani:getScaleX()
    local newY = boneP.y * self._ani:getScaleY()
    return cc.p(newX,newY)
    ]]
end

function petRole:attack(level)
--    if self._timeId then
--        zzy.TimerUtils:cancelTimeOut(self._timeId)
--        self._timeId = nil
--    end
    if 2 ~= self._statue then 
        if ch.CommonFunc:isSpine(self._ani) then
            self._ani:setAnimation(0, "attack", true) 
        else
            self._ani:getAnimation():play("attack",-1,1)
        end
        self._statue = 2
    end
--    if level == 1 then
--        if self._level ~= 1 then
--            self._backAni:getAnimation():stop()
--            self._backAni:setVisible(false)
--        end
--    else
--        if self._level ~= level then
--            self._backAni:getAnimation():play("play"..level-1,-1,1)
--            self._backAni:setVisible(true)
--        end 
--    end
--    self._level = level
end

function petRole:pause()
    if ch.CommonFunc:isSpine(self._ani) then
        self._ani:setAnimation(0, "move", true)
    else
	    self._ani:getAnimation():pause()
    end
    if self._shadowEffect then
        self._shadowEffect:getAnimation():pause()
    end
end

function petRole:resume()
    if ch.CommonFunc:isSpine(self._ani) then
        self._ani:setAnimation(0, "move", true)
    else
        self._ani:getAnimation():resume()
    end
    if self._shadowEffect then
        self._shadowEffect:getAnimation():resume()
    end
end

function petRole:destory()
    self:removeSkillEffect()
    self:removeFromParent()
end

return petRole
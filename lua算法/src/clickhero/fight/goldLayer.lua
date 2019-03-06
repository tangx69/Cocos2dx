local layer = {
    _count = nil,
    resName = nil,
}

local _layer

function layer:init()
    ch.RoleResManager:loadEffect("tx_jinbi")
	_layer = cc.Layer:create()
    _layer:setPositionY(ch.editorConfig:getSceneGlobalConfig().roleh)
    ch.UIManager:getAutoFightLayer():addChild(_layer, 5)

    local lastUpdateTime = os_clock()
    zzy.EventManager:listen(zzy.Events.TickEventType, function()
        local curT = os_clock()
        self:update(curT - lastUpdateTime)
        lastUpdateTime = curT
    end)
    self._count = {0,0,0,0,0,0,0,0,0,0,0}
    self.resName = { -- 添加类型需要添加self._count
        "tx_jinbi","tx_hunshidiaoluo","tx_shengguangdiaoluo",
        "tx_jinbi","tx_kapaidiaoluo","tx_rongyudiaoluo",
        "tx_fuwendiaoluo","tx_bianpaodiaoluo","tx_yuanxiaodiaoluo",
        "tx_honghuadiaoluo","tx_zongzidiaoluo"
    }
end

function layer:dropMoneyByWorldPosition(px, py, num,type)
    local p = _layer:convertToNodeSpace(cc.p(px,py))
    self:dropMoney(p.x,p.y,num,type)
    
end

function layer:clear()
    if _layer then
        _layer:removeAllChildren()
        self._count = nil
        for k,v in ipairs(self.resName) do
            ch.RoleResManager:releaseEffect(v)
        end
    end
end

function layer:_createAni(px, py, num,type)
    self._count[type] = self._count[type] +  num
    for i = 1,num do
        local ani = ccs.Armature:create(self.resName[type])
        local zhuanName = "zhuan"
        local faguangName = "faguang"
        if type == 4 then
            zhuanName = "zhuan_1"
            faguangName = "faguang_1"
        end
        ani:getAnimation():play(zhuanName)
        ani:setPosition(px, py)
        _layer:addChild(ani)
        ani.faguangName = faguangName
        ani.vx = math.random(GameConst.GOLD_DROP_FLY_MIN_VX, GameConst.GOLD_DROP_FLY_MAX_VX)
        ani.vy = math.random(GameConst.GOLD_DROP_FLY_MIN_VY, GameConst.GOLD_DROP_FLY_MAX_VY)
        ani:getAnimation():setMovementEventCallFunc(function(armatureBack,movementType,movementID)
            if (movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete)
                and movementID == faguangName then
                ani:removeFromParent()
                self._count[type] = self._count[type] - 1
                if self._count[type] == 0 then
                    if type~= 1 and type ~= 4 then
                        ch.RoleResManager:releaseEffect(self.resName[type])
                    end
                end
            end
        end)
    end
end

---
-- 掉落
-- @function [parent=#goldLayer] dropMoney
-- @param #goldLayer self
-- @param #number px x坐标
-- @param #number py y坐标
-- @param #number num 数量
-- @param #number type 类型，1为金币，2为魂石，3为圣光,4为大金币,5为整卡,6为荣誉,7为符文,8为鞭炮,9为元宵,10为红花,11为粽子
function layer:dropMoney(px, py, num,type)
    type = type or 1
    if type == 1 or type == 4 then
        self:_createAni(px,py,num,type)
    elseif self.resName[type] then
        ch.RoleResManager:loadEffect(self.resName[type],function()
            self:_createAni(px,py,num,type)
        end)    
    end
end

function layer:updateOffsetX(px)
    _layer:setPositionX(px)
end

function layer:update(dt)
    local anis = _layer:getChildren()
    for _,ani in ipairs(anis) do
        if ani.vx then
            local px,py = ani:getPosition()
            py = py + ani.vy * dt
            px = px + ani.vx * dt
            if py > 0 then
                ani.vy = ani.vy + GameConst.GOLD_DROP_FLY_G * dt
            else
                ani.vx = nil
                py = 0
                ani:getAnimation():play(ani.faguangName)
            end
            ani:setPosition(px, py)
        end
    end
end

return layer
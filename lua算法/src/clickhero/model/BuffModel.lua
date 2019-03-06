local BuffModel = {
    _data = nil,
    _effect = nil, --{0,0,0,0,0,0} 
    _tickId = nil,
    dataChangeEventType = "BUFF_MODEL_DATA_CHANGE", --{type=,dataType=,statue =}
    dataType = {
        card = 1,
        sStone = 2,
        inspire = 3,
        manyGold = 4,
        cardMoney = 22,
        cardGold = 23,
    },
    statue = {
        began = 1,
        ended = 2
    }
}

-- effect 说明
-- 1为宝物攻击力加成，2为宠物攻击力加成，3为魂石掉落量加成
-- 4为魂石掉落概率加成，5为金币掉落量加成，6为挂机金币加成,

function BuffModel:_raiseDataChangeEvent(ty,st)
    local evt = {type = self.dataChangeEventType}
    evt.dataType = ty
    evt.statue = st
    zzy.EventManager:dispatch(evt)
end

---
-- 初始化
-- @function [parent=#BuffModel] init
-- @param #BuffModel self
-- @param #table data
function BuffModel:init(data)
	self._data = data.buff
    
    if data.ext then
        if data.ext.goldCard then
            self._data.goldCard = data.ext.goldCard.endTime
        end
        
        if data.ext.moneyCard then
            self._data.moneyCard = data.ext.moneyCard.endTime
        end
    end
    
	self:_initEffect()
    self._tickId = zzy.EventManager:listen(zzy.Events.TickEventType,function()
        local removeBuffs = {}
        local now = os_time()
        for k,v in pairs(self._data) do
            if now > v then
                table.insert(removeBuffs,k) 
            end
        end
        for _,v in ipairs(removeBuffs) do
            self._data[v] = nil
            self:_setEffect(self.dataType[v],false)
            self:_raiseDataChangeEvent(self.dataType[v],self.statue.ended)
        end
	end)
end

---
-- 清理
-- @function [parent=#BuffModel] clean
-- @param #BuffModel self
function BuffModel:clean()
    self._data = nil
    self._effect = nil
    zzy.EventManager:unListen(self._tickId)
    self._tickId = nil
end

---
-- 初始化
-- @function [parent=#BuffModel] _initEffect
-- @param #BuffModel self
function BuffModel:_initEffect()
	self._effect = {0,0,0,0,0,0}
	local now = os_time()
    local removeBuffs = {}
    for k,v in pairs(self._data) do
        if now >= v then
            table.insert(removeBuffs,k)
        else
            self:_setEffect(self.dataType[k],true)
        end
    end
    for _,v in ipairs(removeBuffs) do
        self._data[v] = nil
    end
end


---
-- 添加月卡buff
-- @function [parent=#BuffModel] addCardBuff
-- @param #BuffModel self
-- @param #number time
function BuffModel:addCardBuff(time, type_item)
    local key = "card"
    
    if type_item == 10 then
        key = "moneyCard"
    elseif type_item == 11 then
        key = "goldCard"
    end
    
	if self._data[key] then
        self._data[key] = self._data[key] + time
	else
        self._data[key] = os_time() + time
        self:_setEffect(self.dataType.card,true)
        self:_raiseDataChangeEvent(self.dataType.card,self.statue.began)
	end
end

---
-- 添加魂石buff
-- @function [parent=#BuffModel] addSStoneBuff
-- @param #BuffModel self
-- @param #number time
function BuffModel:addSStoneBuff(time)
    if self._data["sStone"] then
        self._data["sStone"] = self._data["sStone"] + time
    else
        self._data["sStone"] = os_time() + time
        self:_setEffect(self.dataType.sStone,true)
        self:_raiseDataChangeEvent(self.dataType.sStone,self.statue.began)
    end
end

---
-- 添加鼓舞buff
-- @function [parent=#BuffModel] addInspireBuff
-- @param #BuffModel self
-- @param #number time
function BuffModel:addInspireBuff(time)
    if self._data["inspire"] then
        self._data["inspire"] = self._data["inspire"] + time
    else
        self._data["inspire"] = os_time() + time
        self:_setEffect(self.dataType.inspire,true)
        self:_raiseDataChangeEvent(self.dataType.inspire,self.statue.began)
    end
end

---
-- 添加万金buff
-- @function [parent=#BuffModel] addManyGoldBuff
-- @param #BuffModel self
-- @param #number time
function BuffModel:addManyGoldBuff(time)
    if self._data["manyGold"] then
        self._data["manyGold"] = self._data["manyGold"] + time
    else
        self._data["manyGold"] = os_time() + time
        self:_setEffect(self.dataType.manyGold,true)
        self:_raiseDataChangeEvent(self.dataType.manyGold,self.statue.began)
    end
end

---
-- 添加万金buff
-- @function [parent=#BuffModel] addBuff
-- @param #BuffModel self
-- @param #number type buff类型
-- @param #number time buff时间
function BuffModel:addBuff(type,time)
    type = tonumber(type)
    time = tonumber(time)
    if type == self.dataType.card then
        self:addCardBuff(time)
    elseif type == self.dataType.sStone then
        self:addSStoneBuff(time)
    elseif type == self.dataType.inspire then
        self:addInspireBuff(time)
    elseif type == self.dataType.manyGold then
        self:addManyGoldBuff(time)
    end
end

---
-- 获取月卡buff剩余时间
-- @function [parent=#BuffModel] getCardBuffTime
-- @param #BuffModel self
-- @return #number
function BuffModel:getCardBuffTime(type_item)
    local key = "card"
    
    if type_item == 10 then
        key = "moneyCard"
    elseif type_item == 11 then
        key = "goldCard"
    end
    
    if self._data and self._data[key] then
        local leftTime = self._data[key] - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 获取魂石buff剩余时间
-- @function [parent=#BuffModel] getSStoneTime
-- @param #BuffModel self
-- @return #number
function BuffModel:getSStoneTime()
    if self._data and self._data["sStone"] then
        local leftTime = self._data["sStone"] - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end
 
---
-- 获取鼓舞buff剩余时间
-- @function [parent=#BuffModel] getInspireTime
-- @param #BuffModel self
-- @return #number
function BuffModel:getInspireTime()
    if self._data and self._data["inspire"] then
        local leftTime = self._data["inspire"] - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 获取万金buff剩余时间
-- @function [parent=#BuffModel] getManyGoldTime
-- @param #BuffModel self
-- @return #number
function BuffModel:getManyGoldTime()
    if self._data and self._data["manyGold"] then
        local leftTime =  self._data["manyGold"] - os_time()
        if leftTime > 0 then return math.floor(leftTime) end
    end
    return -1
end

---
-- 添加万金buff
-- @function [parent=#BuffModel] getBuffTime
-- @param #BuffModel self
-- @param #number type buff类型
-- @return #number time buff时间
function BuffModel:getBuffTime(type)
    type = tonumber(type)
    if type == self.dataType.card then
        return self:getCardBuffTime()
    elseif type == self.dataType.sStone then
        return self:getSStoneTime()
    elseif type == self.dataType.inspire then
        return self:getInspireTime()
    elseif type == self.dataType.manyGold then
        return self:getManyGoldTime()
    end
    return -1
end

---
-- 获取宝物攻击的buff效果
-- @function [parent=#BuffModel] getMagicAddtion
-- @param #BuffModel self
-- @return #number
function BuffModel:getMagicAddtion()
	return self._effect[1]
end

---
-- 获取宠物攻击的buff效果
-- @function [parent=#BuffModel] getRunicAddtion
-- @param #BuffModel self
-- @return #number
function BuffModel:getRunicAddtion()
    return self._effect[2]
end

---
-- 获取魂石掉落量buff效果
-- @function [parent=#BuffModel] getSNumberAddtion
-- @param #BuffModel self
-- @return #number
function BuffModel:getSNumberAddtion()
    return self._effect[3]
end

---
-- 获取魂石掉落概率buff效果
-- @function [parent=#BuffModel] getSDRateAddtion
-- @param #BuffModel self
-- @return #number
function BuffModel:getSDRateAddtion()
    return self._effect[4]
end

---
-- 获取打怪获得的金币的buff效果
-- @function [parent=#BuffModel] getNGoldAddtion
-- @param #BuffModel self
-- @return #number
function BuffModel:getNGoldAddtion()
    return self._effect[5]
end

---
-- 获取挂机掉落金币的buff效果
-- @function [parent=#BuffModel] getOGoldAddtion
-- @param #BuffModel self
-- @return #number
function BuffModel:getOGoldAddtion()
    return self._effect[6]
end

---
-- 设置buff效果,(设计宝物攻击力的因为有缓存，要重置宝物攻击力)
-- @function [parent=#BuffModel] _setEffect
-- @param #BuffModel self
-- @param #number buff
-- @param #bool isAdd
function BuffModel:_setEffect(buff,isAdd)
    local sign = isAdd and 1 or -1
    if buff == self.dataType.card then
        self._effect[1] = self._effect[1] + GameConst.BUFF_EFFECT_VALUE[1][1] * sign
        self._effect[2] = self._effect[2] + GameConst.BUFF_EFFECT_VALUE[1][1] * sign
        self._effect[4] = self._effect[4] + GameConst.BUFF_EFFECT_VALUE[1][4] * sign
        self._effect[5] = self._effect[5] + GameConst.BUFF_EFFECT_VALUE[1][2] * sign
        self._effect[6] = self._effect[6] + GameConst.BUFF_EFFECT_VALUE[1][3] * sign
        ch.MagicModel:resetTotalDPS()
    elseif buff == self.dataType.sStone then
        self._effect[3] = self._effect[3] + GameConst.BUFF_EFFECT_VALUE[2] * sign
    elseif buff == self.dataType.inspire then
        self._effect[1] = self._effect[1] + GameConst.BUFF_EFFECT_VALUE[3] * sign
        self._effect[2] = self._effect[2] + GameConst.BUFF_EFFECT_VALUE[3] * sign
        ch.MagicModel:resetTotalDPS()
    elseif buff == self.dataType.manyGold then
        self._effect[5] = self._effect[5] + GameConst.BUFF_EFFECT_VALUE[4] * sign
    end
end

-- effect 说明
-- 1为宝物攻击力加成，2为宠物攻击力加成，3为魂石掉落量加成
-- 4为魂石掉落概率加成，5为金币掉落量加成，6为挂机金币加成,

return BuffModel
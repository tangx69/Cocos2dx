---
-- 神坛 model层     结构 {clean = 0,own={"1":0}, ... },randshentan={}}
--@module ShentanModel
local ShentanModel = {
    _data = nil,
    _skillData = nil,
    _shentanOrderData = nil,  -- 数组，{"15","12"}保证神坛的显示顺序
    _ownshentans = nil,
    _restshentans = nil,
    dataChangeEventType = "ShentanModelDataChange", --{type = ,id=,dataType =}

    dataType = {
        level = 1,
        refresh = 2
    }
}

ENCODE_NUM = ENCODE_NUM or function(num)
    return num
end

DECODE_NUM = DECODE_NUM or function(num)
    return num
end

---
-- @function [parent=#ShentanModel] init
-- @param #ShentanModel self
-- @param #table data
function ShentanModel:init(data)
    self._data = data.holyland or {}
    self._ownshentans = {}
    self._restshentans = {}
end

---
-- @function [parent=#ShentanModel] clean
-- @param #ShentanModel self
function ShentanModel:clean()
    self._data = nil
    self._skillData = nil
    self._shentanOrderData = nil
    self._ownshentans = nil
    self._restshentans = nil
end

function ShentanModel:_raiseDataChangeEvent(id,dataType,num)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType,
        value = num or 0
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 获取神坛等级
-- @function [parent=#ShentanModel] getLevel
-- @param #ShentanModel self
-- @param #string id
-- @return #number
function ShentanModel:getLevel(id)
    id = tostring(id)
    if self._data and self._data[id] then
        return DECODE_NUM(self._data[id])
    else
        return 0
    end
end

---
-- 设置神坛等级
-- @function [parent=#ShentanModel] setLevel
-- @param #ShentanModel self
-- @param #string id
-- @param #number level
function ShentanModel:setLevel(id,level)
    id = tostring(id)
    local old = self:getLevel(id)
    if old ~= level then
        if not self._data[id] then
            self._data[id] = 0
        end
        self._data[id] = level
        self._data[id] = ENCODE_NUM(self._data[id])
        self:_cacheSkillData(id)
        self:_raiseDataChangeEvent(id,self.dataType.level)
    end
end

---
-- 添加神坛等级
-- @function [parent=#ShentanModel] addLevel
-- @param #ShentanModel self
-- @param #string id
-- @param #number level 默认为1
function ShentanModel:addLevel(id,level)
    level = level or 1
    id = tostring(id)
    if level ~= 0 then
        if not self._data[id] then
            self._data[id] = 0
        end
        self._data[id] = self:getLevel(id) + level
        self._data[id] = ENCODE_NUM(self._data[id])
        if id == "9" or id == "10" then
            ch.MagicModel:resetDPS()
        end
        self:_raiseDataChangeEvent(id,self.dataType.level,level)
    end
end

---
-- 获得神坛升级需要的神灵
-- @function [parent=#ShentanModel] getLevelUpCost
-- @param #ShentanModel self
-- @param #string id 神坛id
-- @param #number addLevel 要升的等级数(暂时没加，只是升一级的消耗)
-- @return #number
function ShentanModel:getLevelUpCost(id)
    local cost = 10000
    local level = self:getLevel(id)
    
    id = tostring(id)
    local config = GameConfig.ShentanConfig:getData(id)
    
    if config then
        cost = GameConst.SHENTAN_LEVEL_UP_COST(id, level+1)
    else
        error("该神坛在配置表中不存在，神坛id:"..id)
    end
    
    return cost
end

---
-- 获取拥有神坛个数
-- @function [parent=#ShentanModel] getOwnshentanNum
-- @param #ShentanModel self
-- @return #number
function ShentanModel:getOwnshentanNum()
    return table.maxn(self._ownshentans)
end

-- 获取重置次数
function ShentanModel:getResetTimes()
    return self._data.r or 0
end

-- 增加重置次数
function ShentanModel:addResetTimes(num)
    local _num = num or 1
    self._data.r = self._data.r or 0
    self._data.r = self._data.r + _num
end

---
-- 所有神坛个数
-- @function [parent=#ShentanModel] getAllshentanNum
-- @param #ShentanModel self
-- @return #number
function ShentanModel:getAllshentanNum()
    return table.maxn(self._shentanOrderData)
end

--

---
-- 神坛等级上限
-- @function [parent=#ShentanModel] getMaxLevel
-- @param #ShentanModel self
-- @param #string id
-- @return #string
function ShentanModel:getMaxLevel(id)
    return GameConst.SHENTAN_MAX_LEVEL(id, ch.StatisticsModel:getMaxLevel())
end

---
-- 是否达到神坛等级上限
-- @function [parent=#ShentanModel] ifLvMax
-- @param #ShentanModel self
-- @param #string id
-- @return #number
function ShentanModel:ifLvMax(id)
    return self:getLevel(id) >= self:getMaxLevel(id)
end

---
-- 神坛加成
-- @function [parent=#ShentanModel] getSkillData
-- @param #ShentanModel self
-- @param #string id
-- @param #boolean ifshentan 外部计算用
-- @param #number level
-- @return #number
function ShentanModel:getSkillData(id,level)
    level = level or self:getLevel(id)
    local num = 0
    if GameConst.SHENTAN_EFFECT then
        num = GameConst.SHENTAN_EFFECT(id, level)
    end
    return num
end

---
-- 填充神坛描述数据
-- @function [parent=#ShentanModel] getDesData
-- @param #ShentanModel self
-- @param #string id
-- @param #number level
-- @return #string
function ShentanModel:getDesData(id,level)
    level = level or self:getLevel(id)
    local skillData = self:getSkillData(id,level)

    skillData = string.format("%.4f",skillData)
    
    return "+"..skillData*100 .."%"
end

function ShentanModel:getNextMaxLevel(id)
    local step = 100
    
    local curMaxGk = ch.StatisticsModel:getMaxLevel()
    local curMaxLevel = self:getMaxLevel(id)
    
    local nextMaxGk = math.floor(curMaxGk/step)*step --nextMaxGk从整百开始
    local nextMaxLevel = curMaxLevel
    
    for i=1,math.floor(10000/step) do
        --DEBUG("i=%d", i)
        nextMaxGk = nextMaxGk + step
        nextMaxLevel = GameConst.SHENTAN_MAX_LEVEL(id,  nextMaxGk) --nextMaxGk整百整百的往下看，nextLevel是否有增加
        if nextMaxLevel > curMaxLevel then
            break
        end
    end
    
    return nextMaxGk, nextMaxLevel
end

return ShentanModel
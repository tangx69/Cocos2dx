---
-- 关卡model层
--@module LevelModel

local LevelModel = {
    _data = nil,
    dataChangeEventType = "Level_MODEL_DATA_CHANGE", --{type=,dataType=,}
    buyCountEventType = "LEVEL_BUY_COUNT_CHANGE",--{type=,dataType=,}
    dataType = {
        curLevel = 1,
        killedCount = 2,
        sstone = 3,
        card = 4,
        Firecracker = 5,
        conversion = 6
    },
    buyDataType = {
        buy = 1,
        giveUp = 2
    },
    _killedCount = nil,
    _buyCount = nil,
    _sStoneDropData = nil,
    _cardDropData = nil,
    _firecrackerDropData = nil,
    _conversionMoneyDropData = nil,
    _accumulator = nil,
}

---
-- @function [parent=#LevelModel] init
-- @param #LevelModel self
-- @param #table data
function LevelModel:init(data)
    self._data = data.level
    if self._data.maxLevel - self._data.curLevel > 1 then
        self._data.maxLevel = self._data.curLevel + 1
    end
    self._killedCount = 0
    self._buyCount = 0
    self._accumulator = 0
    self._sStoneDropData = {}
    self._cardDropData = {}
    self._firecrackerDropData = {}
    self._conversionMoneyDropData = {}
end

---
-- @function [parent=#LevelModel] clean
-- @param #LevelModel self
function LevelModel:clean()
    self._data = nil
    self._killedCount = nil
    self._buyCount = nil
    self._sStoneDropData = nil
    self._cardDropData = nil
    self._firecrackerDropData = nil
    self._conversionMoneyDropData = nil
    self._accumulator = nil
end

function LevelModel:_raiseDataChangeEvent(dataType)
    local evt = {
        type = self.dataChangeEventType,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
--  获取当前关卡
-- @function [parent=#LevelModel] getCurLevel
-- @param #LevelModel self
-- @return #number
function LevelModel:getCurLevel()
	return self._data.curLevel
end

---
--  设置当前关卡
-- @function [parent=#LevelModel] setCurLevel
-- @param #LevelModel self
-- @param #number level
function LevelModel:setCurLevel(level)
    self._data.curLevel = level
    self._data.maxLevel = level
    ch.StatisticsModel:setMaxLevel(self._data.curLevel)
    self._buyCount = 0
    self._killedCount = 0
    self:_raiseDataChangeEvent(self.dataType.curLevel)
end

---
--  获取最大关卡
-- @function [parent=#LevelModel] getMaxLevel
-- @param #LevelModel self
-- @return #number
function LevelModel:getMaxLevel()
    return self._data.maxLevel
end

-----
----  获取掉落魂石的关卡
---- @function [parent=#LevelModel] getSStoneLevel
---- @param #LevelModel self
---- @return #number
--function LevelModel:getSStoneLevel()
--    return self._data.sStoneLevel
--end
--
-----
----  设置掉落魂石的关卡
---- @function [parent=#LevelModel] setSStoneLevel
---- @param #LevelModel self
---- @param #number level
--function LevelModel:setSStoneLevel(level)
--    self._data.sStoneLevel = level or 0
--end

---
--  获取已杀死的小怪数量
-- @function [parent=#LevelModel] getKilledCount
-- @param #LevelModel self
-- @return #number
function LevelModel:getKilledCount()
    return self._killedCount
end

---
--  添加已杀死的小怪数量
-- @function [parent=#LevelModel] addKilledCount
-- @param #LevelModel self
function LevelModel:addKilledCount()
    self._killedCount = self._killedCount + 1
    self:_raiseDataChangeEvent(self.dataType.killedCount)
end


local levelCount = table.maxn(GameConfig.LevelConfig:getTable())

---
-- 获取当前关卡的小怪数量
-- @function [parent=#LevelModel] getTotalCount
-- @param #LevelModel self
-- @param #number id 关卡id
function LevelModel:getTotalCount(id)  
    id = math.floor(id % levelCount)
    id = id == 0 and levelCount or id
    local count = GameConfig.LevelConfig:getData(id).killCount
    if id % 5 ~= 0 then
        count = count - ch.TotemModel:getTotemSkillData(3,3)
    end
    return count
end

---
--  获取上次掉落镀金的关卡
-- @function [parent=#LevelModel] getStarLevel
-- @param #LevelModel self
-- @return #number
function LevelModel:getStarLevel()
    return self._data.starLevel
end

---
--  设置上次掉落镀金的关卡
-- @function [parent=#LevelModel] setStarLevel
-- @param #LevelModel self
-- @param #number level
function LevelModel:setStarLevel(level)
    self._data.starLevel = level or 0
end

---
--  累加器计数
-- @function [parent=#LevelModel] addAccumulator
-- @param #LevelModel self
function LevelModel:addAccumulator()
    self._accumulator = self._accumulator+1
end

---
--  得到属性
-- @function [parent=#LevelModel] getRestrain
-- @param #LevelModel self
-- @param #number level
-- @return #number
function LevelModel:getRestrain(level)
--    if not self._data.boss then
--        self._data.boss = {3,2,3,4,5}
--    end
--    if self._data.curLevel%5 == 0 then
--        local bossCount = table.maxn(self._data.boss)
--        self._accumulator = math.floor(self._accumulator % bossCount)
--        self._accumulator = self._accumulator == 0 and bossCount or self._accumulator
--        return self._data.boss[self._accumulator]
--    else
--        return 1
--    end
    local curLevel = level or self._data.curLevel
    if curLevel%5 == 0 then
        return self:getLevelConfig(curLevel).property
    else
        return 1
    end
end

---
--  下一关卡
-- @function [parent=#LevelModel] nextLevel
-- @param #LevelModel self
function LevelModel:nextLevel()
    self._data.curLevel = self._data.curLevel + 1
    ch.fightRoleLayer:clearHJJJGold()
    if self._data.curLevel > self._data.maxLevel then
        self._data.maxLevel = self._data.curLevel
    end
    ch.StatisticsModel:setMaxLevel(self._data.curLevel)
    self._buyCount = 0
    self._killedCount = 0
    self:_raiseDataChangeEvent(self.dataType.curLevel)
end

---
--  上一关卡
-- @function [parent=#LevelModel] preLevel
-- @param #LevelModel self
function LevelModel:preLevel()
    self._data.curLevel = self._data.curLevel - 1
    ch.fightRoleLayer:clearHJJJGold()
    self._killedCount = 0
    self._buyCount = 0
    self:_raiseDataChangeEvent(self.dataType.curLevel)
end

---
-- 获得当前boss的购买次数
-- @function [parent=#LevelModel] getBuyCount
-- @param #LevelModel self
-- @return #number boss关购买次数
function LevelModel:getBuyCount()
    return self._buyCount
end

---
-- 添加当前boss的购买次数
-- @function [parent=#LevelModel] addBuyCount
-- @param #LevelModel self
function LevelModel:addBuyCount()
    self._buyCount = self._buyCount + 1
end


local levelCount = table.maxn(GameConfig.LevelConfig:getTable())
---
--  获得关卡的场景配置
-- @function [parent=#LevelModel] getLevelConfig
-- @param #LevelModel self
-- @param #number levelId
-- @return #LevelConfig
function LevelModel:getLevelConfig(levelId)
    levelId = math.floor(levelId % levelCount)
    levelId = levelId == 0 and levelCount or levelId
    return GameConfig.LevelConfig:getData(levelId)
end

---
-- 添加魂石掉落数据
-- @function [parent=#LevelModel] addSStoneDropData
-- @param #LevelModel self
-- @param #number levelId
-- @param #number num
function LevelModel:addSStoneDropData(levelId,num)
    if levelId then
        self._sStoneDropData[levelId] = num
        self:_raiseDataChangeEvent(self.dataType.sstone)
    end
end

---
-- 获取魂石掉落数据
-- @function [parent=#LevelModel] getSStoneDropData
-- @param #LevelModel self
-- @param #number levelId
-- @return num
function LevelModel:getSStoneDropData(levelId)
    return self._sStoneDropData[levelId] or 0
end

---
-- 添加卡牌掉落数据
-- @function [parent=#LevelModel] addCardDropData
-- @param #LevelModel self
-- @param #number levelId
-- @param #table cardId
-- @param #number num
function LevelModel:addCardDropData(levelId,card)
    if levelId then
        self._cardDropData[levelId] = card
        self:_raiseDataChangeEvent(self.dataType.card)
    end
end

---
-- 获取卡牌掉落数据
-- @function [parent=#LevelModel] getCardDropData
-- @param #LevelModel self
-- @param #number levelId
-- @return num
function LevelModel:getCardDropData(levelId)
    return self._cardDropData[levelId]
end

---
-- 添加爆竹掉落数据
-- @function [parent=#LevelModel] addFirecrackerDropData
-- @param #LevelModel self
-- @param #number levelId
-- @param #number num
function LevelModel:addFirecrackerDropData(levelId,num)
    if levelId then
        self._firecrackerDropData[levelId] = num
        self:_raiseDataChangeEvent(self.dataType.Firecracker)
    end
end

---
-- 获取爆竹掉落数据
-- @function [parent=#LevelModel] getFirecrackerDropData
-- @param #LevelModel self
-- @param #number levelId
-- @return #number num
function LevelModel:getFirecrackerDropData(levelId)
    return self._firecrackerDropData[levelId]
end

---
-- 添加兑换货币掉落数据
-- @function [parent=#LevelModel] addConversionMoneyDropData
-- @param #LevelModel self
-- @param #number levelId
-- @param #number num
function LevelModel:addConversionMoneyDropData(levelId,num)
    if levelId then
        self._conversionMoneyDropData[levelId] = num
        self:_raiseDataChangeEvent(self.dataType.conversion)
    end
end

---
-- 获取兑换货币掉落数据
-- @function [parent=#LevelModel] getConversionMoneyDropData
-- @param #LevelModel self
-- @param #number levelId
-- @return #number num
function LevelModel:getConversionMoneyDropData(levelId)
    return self._conversionMoneyDropData[levelId]
end


---
-- 轮回
-- @function [parent=#LevelModel] onSamsara
-- @param #LevelModel self
function LevelModel:onSamsara()
    local totemAdd = ch.TotemModel:getTotemSkillData(2,3)+1
    self._data.curLevel =  totemAdd == 0 and 1 or totemAdd
    self._data.maxLevel = self._data.curLevel
    self._killedCount = 0
    self._sStoneDropData = {}
    self._cardDropData = {}
    self._firecrackerDropData = {}
    self:_raiseDataChangeEvent(self.dataType.curLevel)
end

return LevelModel
---
-- 挂机model
--@module AFKModel
local AFKModel = {
    _data = nil,
    dataChangeEventType = "AFK_MODEL_DATA_CHANGE", --{type=}
    _isAFKing = nil,
    showEffect = true,
}

function AFKModel:_raiseDataChangeEvent()
    local evt = {type = self.dataChangeEventType}
    zzy.EventManager:dispatch(evt)
end

---
-- 初始化
-- @function [parent=#AFKModel] init
-- @param #AFKModel self
-- @param #table data
function AFKModel:init(data)
    if data.autofight.reward then
        data.autofight.reward.gold = tonumber(data.autofight.reward.gold)
        data.autofight.reward.offGold = tonumber(data.autofight.reward.offGold)
        data.autofight.reward.petGold = tonumber(data.autofight.reward.petGold)
    end
    self._data = data.autofight
    if self._data.reward then
       self._data.maxLevel = ch.LevelModel:getCurLevel()
    end
end

---
-- 清理
-- @function [parent=#AFKModel] clean
-- @param #AFKModel self
function AFKModel:clean()
    self._data = nil
    self._isAFKing = nil
    self.showEffect = true
end

local maxAFKTime = 9999*24*3600

---
-- 获得上次挂机的目标关卡
-- @function [parent=#AFKModel] getLastTargetLevel
-- @param #AFKModel self
-- @return #number
function AFKModel:getLastTargetLevel()
    return self._data and self._data.maxLevel
end

---
-- 清理上次挂机目标关卡
-- @function [parent=#AFKModel] cleanLastTargetLevel
-- @param #AFKModel self
function AFKModel:cleanLastTargetLevel()
    self._data.maxLevel = nil
end

---
-- 是否正在挂机
-- @function [parent=#AFKModel] isAFKing
-- @param #AFKModel self
-- @return #bool
function AFKModel:isAFKing()
    return self._isAFKing
end

---
-- 设置是否正在挂机
-- @function [parent=#AFKModel] setAFKing
-- @param #AFKModel self
-- @param #bool isAFKing
function AFKModel:setAFKing(isAFKing)
    self._isAFKing = isAFKing
end

---
-- 清理上次挂机信息
-- @function [parent=#AFKModel] cleanLastAFKInfo
-- @param #AFKModel self
function AFKModel:cleanLastAFKInfo()
    self._data = nil
    self:_raiseDataChangeEvent()
end

---
-- 获得上次挂机的奖励内容
-- @function [parent=#AFKModel] getLastReward
-- @param #AFKModel self
-- @return #table
function AFKModel:getLastReward()
    return self._data and self._data.reward
end

---
-- 获得挂机的最大等级和时间
-- @function [parent=#AFKModel] getAFKLevelAndTime
-- @param #AFKModel self
-- @return #number level,time
function AFKModel:getAFKLevelAndTime()
    local maxLevel = math.floor(ch.StatisticsModel:getMaxLevel()* GameConst.AUTO_FIGHT_RATIO)
    maxLevel = maxLevel > ch.StatisticsModel:getMaxLevel() - 50 and maxLevel or ch.StatisticsModel:getMaxLevel() - 50    
    if maxLevel%5 == 0 then
        maxLevel = maxLevel - 1
    end
    local time = self:getTotalTime(ch.LevelModel:getCurLevel(),maxLevel)
	if time > maxAFKTime then
        maxLevel,time = self:getMaxLevel(ch.LevelModel:getCurLevel(),maxAFKTime)
	end
    return maxLevel,time
end

---
-- 获得挂机所需时间
-- @function [parent=#AFKModel] getTotalTime
-- @param #AFKModel self
-- @param #number from
-- @param #number to
-- @return #number
function AFKModel:getTotalTime(from,to)
    to = to%5 == 0 and to-1 or to
    local totalCount = to - from
    local num = from %5
    local firstBossLevel = from
    if num ~= 0 then
        firstBossLevel = firstBossLevel + 5 - num
    end
    local bossCount = 0
    if firstBossLevel < to then
        bossCount = math.ceil((to - firstBossLevel)/5)
    end
    local time = ch.LevelModel:getTotalCount(1)
    return (totalCount - bossCount) * time + bossCount * GameConst.AUTO_FIGHT_BOSS_TIME
end

---
-- 获得指定时间能达到的最大关卡数
-- @function [parent=#AFKModel] getMaxLevel
-- @param #AFKModel self
-- @param #number from
-- @param #number time
-- @return #number maxLevel, realTime
function AFKModel:getMaxLevel(from,time)
    local cTime = ch.LevelModel:getTotalCount(1)
    local uTime = cTime * 4 + GameConst.AUTO_FIGHT_BOSS_TIME
    local nextBossDistance = 5 - from %5
    nextBossDistance = nextBossDistance == 5 and 0 or nextBossDistance
    local nextBossTime = nextBossDistance*cTime
    local targetLevel
    local totalTime = 0
    if time > nextBossTime then
        local leftTime = time - nextBossTime
        targetLevel = from + nextBossDistance
        local uCount = math.floor(leftTime/uTime)
        targetLevel = targetLevel + uCount*5
        leftTime = leftTime - uCount * uTime
        if leftTime >= GameConst.AUTO_FIGHT_BOSS_TIME then
            targetLevel = targetLevel + 1
            leftTime = leftTime - GameConst.AUTO_FIGHT_BOSS_TIME
            local cCount = math.floor(leftTime/cTime)
            targetLevel = targetLevel + cCount
            leftTime = leftTime - cCount*cTime
        end
        totalTime = time - leftTime
    else
        local count = math.floor(time/cTime)
        targetLevel = from + count
        totalTime = cTime * count
    end
    if targetLevel %5 == 0 then
        targetLevel = targetLevel - 1
        totalTime = totalTime - cTime
    end
    return targetLevel,totalTime
end

---
-- 是否要显示光效
-- @function [parent=#AFKModel] setShowEffect
-- @param #AFKModel self
-- @param #boolean isShow
function AFKModel:setShowEffect(isShow)
    self.showEffect = isShow
    self:_raiseDataChangeEvent()
end

---
-- 是否要显示光效
-- @function [parent=#AFKModel] getShowEffect
-- @param #AFKModel self
-- @return #boolean
function AFKModel:getShowEffect()
    return self.showEffect
end

--验证算法用的
--function AFKModel:getRealTime(from,to)
--    local curLevel = from
--    local cTime = ch.LevelModel:getTotalCount(1)
--    local totalTime = 0
--    while curLevel < to do
--    	if curLevel%5 == 0 then
--            totalTime = totalTime + GameConst.AUTO_FIGHT_BOSS_TIME
--    	else
--            totalTime = totalTime + cTime
--    	end
--        curLevel = curLevel + 1
--    end
--    return totalTime
--end

return AFKModel
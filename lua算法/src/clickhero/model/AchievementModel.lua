---
-- 成就 model层     结构 {{type = 1,index = 1,s = 0}, ... }
--@module AchievementModel
local AchievementModel = {
    _data = nil,
    _achievementOrderData = nil,  -- 数组，{"15","12"}保证成就的显示顺序
    _diamondNum = 0,
    _allAchievementNum = 0,
    _ownAchievement = nil,
    _rewardData = nil,
    _tmpTypeValue = nil,
    _typeEventId = nil,
    dataChangeEventType = "AchievementModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        state = 1,
        value = 2
    }
}

-- 成就监听的事件
local achievementTypeEvent = {
    ch.MoneyModel.dataChangeEventType, -- 拥有金币数量
    ch.MoneyModel.dataChangeEventType, -- 累计金币数量
    ch.LevelModel.dataChangeEventType, -- 通过关卡数
    ch.LevelModel.dataChangeEventType, -- 击败第几关魔王
    ch.fightRole.DEAD_EVENT_TYPE, -- 累计击败魔王数
    ch.MagicModel.dataChangeEventType, -- 累计提升宝物等级
    ch.clickLayer.CLICK_EVENT_TYPE, -- 点击次数
    ch.clickLayer.CLICK_EVENT_TYPE, -- 秒速
    ch.StatisticsModel.samsaraAddRTimesEventType, -- 转生
    ch.fightRole.DEAD_EVENT_TYPE, -- 累计消灭怪物
    ch.fightRole.DEAD_EVENT_TYPE, -- 累计消灭宝箱怪
    ch.PlayerModel.allDPSChangeEventType, -- dps攻击力
    ch.StatisticsModel.dataChangeEventType  -- 历史最高排名
}

-- 成就计算函数
local achievementTypeValue = {
    function() return ch.MoneyModel:getGold() end, -- 拥有金币数量
    function() return ch.StatisticsModel:getGotGold() end, -- 累计金币数量
    function() return ch.StatisticsModel:getMaxLevel()-1 end, -- 通过关卡数
    function() return ch.StatisticsModel:getMaxLevel()-1 end, -- 击败第几关魔王
    function() return ch.StatisticsModel:getKilledBosses() end, -- 累计击败魔王数
    function() return ch.StatisticsModel:getMagicGotLevel() end, -- 累计提升宝物等级
    function() return ch.StatisticsModel:getClickTimes() end, -- 点击次数
    function() return ch.StatisticsModel:getMaxClickSpeed() end, -- 秒速
    function() return ch.StatisticsModel:getRTimes() end, -- 转生
    function() return ch.StatisticsModel:getKilledMonsters() end, -- 累计消灭怪物
    function() return ch.StatisticsModel:getKilledBoxes() end, -- 累计消灭宝箱怪
    function() return ch.StatisticsModel:getMaxDPS() end, -- dps攻击力
    function() return -ch.StatisticsModel:getMaxRank() end  -- 历史最高排名
}


---
-- @function [parent=#AchievementModel] init
-- @param #AchievementModel self
-- @param #table data
function AchievementModel:init(data)
    self._data = data.achievement
    self:_orderAchievement()
    self:_achievementNum()
    self:curAchievement()
    self:initCurAchievement()
    self:_cacheAllRewardData()
end

---
-- 清理
-- @function [parent=#AchievementModel] clean
-- @param #AchievementModel self
function AchievementModel:clean()
    self._data = nil
    for k,v in pairs(self._typeEventId) do
        zzy.EventManager:unListen(v)
    end
    self._typeEventId = nil
    self._tmpTypeValue = nil
    self._ownAchievement = nil
    self._rewardData = nil
end


function AchievementModel:_raiseDataChangeEvent(typeId,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = typeId,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 从表中取数据
-- @function [parent=#AchievementModel] getDataByType
-- @param #AchievementModel self
-- @param #string type
-- @param #number index
-- @return #table
function AchievementModel:getDataByType(type,index)
    -- 从表中取数据
    local achievementData = GameConfig.AchievementConfig:getTable()
    for k,v in pairs(achievementData) do
        if v.type == type and v.index == index then
            return GameConfig.AchievementConfig:getData(k)
        end
    end
end

---
-- 缓存所有的奖励数据
-- @function [parent=#AchievementModel] _cacheAllRewardData
-- @param #AchievementModel self
function AchievementModel:_cacheAllRewardData()
    self._rewardData = {}
    if self._ownAchievement then
        for k,v in pairs(self._ownAchievement) do
            self:_cacheRewardData(v)
        end
    end
end

---
-- 缓存成就不同类型的奖励数据
-- @function [parent=#AchievementModel] _cacheRewardData
-- @param #AchievementModel self
-- @param #string id
function AchievementModel:_cacheRewardData(id)
    id = tostring(id)
    local type = GameConfig.AchievementConfig:getData(id).typeReward
    local value = GameConfig.AchievementConfig:getData(id).rewards/10000
    if type == GameConst.ACHIEVEMENT_REWARD_ATTACK then
        if self._rewardData[type] == nil then 
            self._rewardData[type] = 1 
        end
        self._rewardData[type] = self._rewardData[type]*(1+value)
        ch.MagicModel:resetDPS()
    else
        if self._rewardData[type] == nil then 
            self._rewardData[type] = 0 
        end
        self._rewardData[type] = self._rewardData[type] + value
    end
end

---
-- 得到成就不同类型的奖励数据
-- @function [parent=#AchievementModel] getRewardData
-- @param #AchievementModel self
-- @param #string type -- 奖励类型
-- @return #number rewardData
function AchievementModel:getRewardData(type)
    type = tostring(type)
    if self._rewardData == nil then self._rewardData = {} end
    if self._rewardData[type] == nil then
        if type == GameConst.ACHIEVEMENT_REWARD_ATTACK then
            self._rewardData[type] = 1 
        else
            self._rewardData[type] = 0 
        end
    end
    return self._rewardData[type]
end

---
-- 成就列表
-- @function [parent=#AchievementModel] _achievementNum
-- @param #AchievementModel self
function AchievementModel:_achievementNum()
    local cs = GameConfig.AchievementConfig:getTable()
    local num = 0
    for k,v in pairs(cs) do
        num = num+1
    end
    self._allAchievementNum = num
end

---
-- 类型列表
-- @function [parent=#AchievementModel] _orderAchievement
-- @param #AchievementModel self
function AchievementModel:_orderAchievement()
    local cs = GameConfig.AchievementConfig:getTable()
    self._allAchievementNum = table.maxn(cs)
    self._achievementOrderData = {}
    for k,v in pairs(cs) do
        if v.index == 1 then
            table.insert(self._achievementOrderData, v.type)
        end
    end
--    table.sort(self._achievementOrderData,function(t1,t2)
--       return GameConst.ACHIEVEMENT_INDEX[tonumber(t1)]< GameConst.ACHIEVEMENT_INDEX[tonumber(t2)]
--    end)
end

---
-- 得到新成就
-- @function [parent=#AchievementModel] getNewAchievement
-- @param #AchievementModel self
-- @param #string type
function AchievementModel:getNewAchievement(aType)
    if self._data[aType].s ~= 3 then
        local index = self._data[aType].index
        if index+1 <= self:getAllTypeNum(aType) then 
            self._data[aType].index = index+1
            local curNum = self:getCurNum(aType)
            local goalNUm = self:getGoalNum(aType)
            if type(curNum) == "number" then
                curNum = ch.LongDouble:new(curNum)
            end
            if type(goalNUm) == "number" then
                goalNUm = ch.LongDouble:new(goalNUm)
            end
            if curNum >= goalNUm then
                self._data[aType].s = 2
                ch.NetworkController:changeAchState(aType,self:getID(aType))
            else
                self._data[aType].s = 1
            end
        else
            self._data[aType].s = 3
        end
        local id = self:getDataByType(aType,index).id
        table.insert(self._ownAchievement,tostring(id))
        self:_cacheRewardData(id)
        self:_getCurNum(aType)
        if GameConfig.AchievementConfig:getData(id).typeReward == GameConst.ACHIEVEMENT_REWARD_ATTACK then
            ch.MagicModel:resetDPS()
        end
        self:_raiseDataChangeEvent(aType,self.dataType.state)
    end
end

---
-- 初始化当前列表
-- @function [parent=#AchievementModel] initCurAchievement
-- @param #AchievementModel self
function AchievementModel:initCurAchievement()
    for k,v in pairs(self._achievementOrderData) do
        if not self._data[v] then
            self._data[v] = {index = 1,s=1}
        end
    end
    self._tmpTypeValue = {}
    self._typeEventId = {}
    -- 加入监听
    for k,v in pairs(self._achievementOrderData) do
        self:_getCurNum(tostring(k))
    end
end


---
-- 获取当前已获得的成就
-- @function [parent=#AchievementModel] curAchievement
-- @param #AchievementModel self
function AchievementModel:curAchievement()
    self._ownAchievement = {}
    for k,v in pairs(self._data) do
        for i = 1,self._data[k].index-1 do
            table.insert(self._ownAchievement,self:getDataByType(k,i).id)
        end
        if self._data[k].s == 3 then
            table.insert(self._ownAchievement,self:getDataByType(k,self._data[k].index).id)
        end
    end
end


---
-- 已获得的钻石奖励
-- @function [parent=#AchievementModel] getDiamondNum
-- @param #AchievementModel self
-- @return #number
function AchievementModel:getDiamondNum()
    -- 获得钻石总数
    local num = 0
        for k,v in pairs(self._ownAchievement) do
            num = num + GameConfig.AchievementConfig:getData(v).diamond
        end
    self._diamondNum = num
    return self._diamondNum
end

---
-- 成就总数
-- @function [parent=#AchievementModel] getAllAchievementNum
-- @param #AchievementModel self
-- @return #number
function AchievementModel:getAllAchievementNum()
    return self._allAchievementNum
end

---
-- 已获得成就数
-- @function [parent=#AchievementModel] getOwnAchievementNum
-- @param #AchievementModel self
-- @return #number
function AchievementModel:getOwnAchievementNum()
    --return table.maxn(self._ownAchievement)
    local num = 0
    for k,v in pairs(self._achievementOrderData) do
        num = num+AchievementModel:getOwnTypeNum(v)
    end
    return num
end

---
-- 成就列表
-- @function [parent=#AchievementModel] getAchievementList
-- @param #AchievementModel self
-- @return #table
function AchievementModel:getAchievementList()
    -- 成就列表
    local achievement = {}
    for k,v in pairs(self._achievementOrderData) do
    	table.insert(achievement, v)
    end
    -- 卡顿，暂时屏蔽
    table.sort(achievement,function(t1,t2)
        local t1state = self._data[t1].s
        local t2state = self._data[t2].s
        if t1state == t2state then
            return GameConst.ACHIEVEMENT_INDEX[tonumber(t1)]< GameConst.ACHIEVEMENT_INDEX[tonumber(t2)]
        elseif t1state == 2 and t2state ~= 2 then
            return true
        elseif t1state ~= 2 and t2state == 2 then
            return false
        elseif t1state ~= 2 and t2state ~= 2 then
            return t1state < t2state
        end
    end)
    return achievement
end

---
-- 此类成就数量
-- @function [parent=#AchievementModel] getAllTypeNum
-- @param #AchievementModel self
-- @param #string type
-- @return #number
function AchievementModel:getAllTypeNum(type)
    -- 此类成就数量
    local cs = GameConfig.AchievementConfig:getTable()
    local num = 0
    for k,v in pairs(cs) do
        if v.type == type then
            num = num+1
        end
    end
    return num
end

---
-- 获得此类成就数量
-- @function [parent=#AchievementModel] getOwnTypeNum
-- @param #AchievementModel self
-- @param #string type
-- @return #number
function AchievementModel:getOwnTypeNum(type)
    -- 获得此类成就数量
    if self._data[type].s == 3 then
        return self._data[type].index
    else
        return self._data[type].index - 1
    end
end

---
-- 此类成就是否已经达成至少1个(可领奖)
-- @function [parent=#AchievementModel] getCanReceive
-- @param #AchievementModel self
-- @param #string type
-- @return #boolean
function AchievementModel:getCanReceive(type)
    -- 此类成就是否已经达成至少1个(可领奖)
    return self:getOwnTypeNum(type)>0
end

---
-- 是否已经领取完所有奖励(已领奖)
-- @function [parent=#AchievementModel] getOverReceive
-- @param #AchievementModel self
-- @param #string type
-- @return #boolean
function AchievementModel:getOverReceive(type)
    -- 是否已经领取完所有奖励(已领奖)
    return self:getOwnTypeNum(type)==self:getAllTypeNum(type)
end


---
-- 成就进度当前(进度)
-- @function [parent=#AchievementModel] _getCurNum
-- @param #AchievementModel self
-- @param #string type
function AchievementModel:_getCurNum(type)
    if self._data[type].s == 3 then
        return 
    end

    local evtType = nil
    local func = nil
--    if not self._tmpTypeValue then
--        self._tmpTypeValue = {}
--    end
    self._tmpTypeValue[type] = achievementTypeValue[tonumber(type)]()
    evtType = achievementTypeEvent[tonumber(type)]
    if not self._typeEventId[type] then
        self._typeEventId[type] = zzy.EventManager:listen(evtType,function(obj,evt)
--            if self._data[type].s == 1 then
                self._tmpTypeValue[type] = achievementTypeValue[tonumber(type)]()
--            else
--                self._tmpTypeValue[type] = self:getGoalNum(type)
--            end
            self:changeState(type)
        end)
    end
--    self:_raiseDataChangeEvent(type,self.dataType.value)
    self:changeState(type)
end

---
-- 成就进度当前(状态)
-- @function [parent=#AchievementModel] changeState
-- @param #AchievementModel self
-- @param #string aType
function AchievementModel:changeState(aType)
    local goal = self:getGoalNum(aType)
    if aType ~= "13" or (self._tmpTypeValue[13] and self._tmpTypeValue[13] ~= 0) then
        local tyValue = self._tmpTypeValue[aType]
        local gValue = goal
        if type(tyValue) == "number" then
            tyValue = ch.LongDouble:new(tyValue)
        end
        if type(gValue) == "number" then
            gValue = ch.LongDouble:new(gValue)
        end
        if self._data[aType].s == 1 and tyValue >= gValue then
            self._data[aType].s = 2
            self._tmpTypeValue[aType] = goal
            if self._typeEventId[aType] then
                zzy.EventManager:unListen(self._typeEventId[aType])
                self._typeEventId[aType] = nil
            end
            self:_raiseDataChangeEvent(aType,self.dataType.state)
            ch.NetworkController:changeAchState(aType,self:getID(aType))
        end
    end
end

---
-- 成就进度当前(进度)
-- @function [parent=#AchievementModel] getCurNum
-- @param #AchievementModel self
-- @param #string type
-- @return #number
function AchievementModel:getCurNum(type)
    if self._tmpTypeValue[type] then
        return self._tmpTypeValue[type]
    else
        return 0
    end
end

--
-- 当前获得的目标数量(进度)
-- @function [parent=#AchievementModel] getCurNum
-- @param #AchievementModel self
-- @param #string type
-- @return #number
--function AchievementModel:getCurNum(type)
--    -- 当前获得的目标数量(进度)
--    local num = 0
--    if type == "1" then
--        num = ch.MoneyModel:getGold()
--    elseif type == "2" then
--        num = ch.StatisticsModel:getGotGold()
--    elseif type == "3" then
--        num = ch.StatisticsModel:getMaxLevel()-1
--    elseif type == "4" then
--        num = ch.StatisticsModel:getMaxLevel()-1
--    elseif type == "5" then
--        num = ch.StatisticsModel:getKilledBosses()
--    elseif type == "6" then
--        num = ch.StatisticsModel:getMagicGotLevel()
--    elseif type == "7" then  -- 点击次数
--        num = ch.StatisticsModel:getClickTimes()
--    elseif type == "8" then    -- 点击秒速
--        num = ch.StatisticsModel:getMaxClickSpeed()
--    elseif type == "9" then
--        num = ch.StatisticsModel:getRTimes()
--    elseif type == "10" then
--        num = ch.StatisticsModel:getKilledMonsters()
--    elseif type == "11" then
--        num = ch.StatisticsModel:getKilledBoxes()
--    elseif type == "12" then
--        num = ch.StatisticsModel:getMaxDPS()
--    else
--        num = 0
--    end
--    
--    if self._data[type].s ~= 3 then
--        if num >= self:getGoalNum(type) then
--            self._data[type].s = 2
--            num = self:getGoalNum(type)
--            self:_raiseDataChangeEvent(type,self.dataType.state)
--        else
--            self._data[type].s = 1
--        end
--    end
--    return num
--end

---
-- 获得成就的目标总数(进度)
-- @function [parent=#AchievementModel] getGoalNum
-- @param #AchievementModel self
-- @param #string type
-- @return #number
function AchievementModel:getGoalNum(type)
    -- 获得成就的目标总数(进度)
    return self:getDataByType(type,self._data[type].index).goal
end

---
-- 获得成就进度
-- @function [parent=#AchievementModel] getProgress
-- @param #AchievementModel self
-- @param #string aType
-- @return #number
function AchievementModel:getProgress(aType)
    -- 获得成就进度
    local curNum = self:getCurNum(aType)
    local goalNum = self:getGoalNum(aType)
    if type(curNum) == "number" then
        curNum = ch.LongDouble:new(curNum)
    end
    if type(goalNum) == "number" then
        goalNum = ch.LongDouble:new(goalNum)
    end
    
    if self:getOverReceive(aType) then
    	return 1
    elseif curNum > goalNum then
        return 1
    else
        return (curNum/goalNum):toNumber()
    end
end

---
-- 当前可领取奖励个数
-- @function [parent=#AchievementModel] getCurNoReceiveNum
-- @param #AchievementModel self
-- @return #number
function AchievementModel:getCurNoReceiveNum()
    local num = 0
    for k,v in pairs(self._data) do
        if v.s == 2 then
            num = num + 1
        end
    end
    return num
end

---
-- 当前是否可领取奖励
-- @function [parent=#AchievementModel] getCurNoReceive
-- @param #AchievementModel self
-- @param #string type
-- @return #boolean
function AchievementModel:getCurNoReceive(type)
    -- 当前是否可领取奖励
    return self._data[type].s == 2
end

---
-- 成就ID
-- @function [parent=#AchievementModel] getID
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getID(type)
    return self:getDataByType(type,self._data[type].index).id
end

---
-- 图标Icon
-- @function [parent=#AchievementModel] getIcon
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getIcon(type)
    return self:getDataByType(type,self._data[type].index).icon
end

---
-- 名字Name
-- @function [parent=#AchievementModel] getName
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getName(type)
    return self:getDataByType(type,self._data[type].index).name
end

---
-- 描述Des
-- @function [parent=#AchievementModel] getDes
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getDes(type)
    local data = self:getDataByType(type,self._data[type].index)
    local tmpDesc = ""
    if type == "13" then
        if self._data[type].index < self:getAllTypeNum(type) then
            tmpDesc = string.format(data.desc,-data.goal,-self:getDataByType(type,self._data[type].index+1).goal+1)
        else
            tmpDesc = string.format(data.desc,-data.goal)
        end
    else
        tmpDesc = string.format(data.desc,ch.NumberHelper:toString(ch.AchievementModel:getGoalNum(type)))
    end
    return tmpDesc
end

---
-- 获得奖励类型
-- @function [parent=#AchievementModel] getRewardType
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getRewardType(type)
    return self:getDataByType(type,self._data[type].index).typeReward
end

---
-- 获得奖励描述
-- @function [parent=#AchievementModel] getRewardText
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getRewardText(type)
    local typeReward = self:getDataByType(type,self._data[type].index).typeReward
    if typeReward == GameConst.ACHIEVEMENT_REWARD_DIAMOND then
        return "+"..self:getDataByType(type,self._data[type].index).rewards/10000
    elseif typeReward == GameConst.ACHIEVEMENT_REWARD_ATTACK then
        return "+"..self:getDataByType(type,self._data[type].index).rewards/100 .. "%"
    elseif typeReward == GameConst.ACHIEVEMENT_REWARD_BASE then
        return "+"..self:getDataByType(type,self._data[type].index).rewards/10000
    else
        return self:getDataByType(type,self._data[type].index).rewards/10000
    end 
end

---
-- 得到的奖励
-- @function [parent=#AchievementModel] getReward
-- @param #AchievementModel self
-- @param #string type
-- @return #string
function AchievementModel:getReward(type)
    return self:getDataByType(type,self._data[type].index).rewards/10000
end

---
-- 通过ID获取描述Des
-- @function [parent=#AchievementModel] getDesById
-- @param #AchievementModel self
-- @param #string id
-- @return #string
function AchievementModel:getDesById(id)
    local data = GameConfig.AchievementConfig:getData(id)
    local tmpDesc = ""
    if data.type == "13" then
        if self._data[data.type].index < self:getAllTypeNum(data.type) then
            tmpDesc = string.format(data.desc,-data.goal,-self:getDataByType(data.type,self._data[data.type].index+1).goal+1)
        else
            tmpDesc = string.format(data.desc,-data.goal)
        end
    else
        tmpDesc = string.format(data.desc,ch.NumberHelper:toString(data.goal))
    end
    return tmpDesc
end

---
-- 通过ID获取成就状态(可领奖和已领奖返回true)
-- @function [parent=#AchievementModel] getStateById
-- @param #AchievementModel self
-- @param #string id
-- @return #boolean
function AchievementModel:getStateById(id)
    local data = GameConfig.AchievementConfig:getData(id)
    if self._data[data.type].s == 3 then
        return true
    elseif self._data[data.type].s == 2 and data.index <= self._data[data.type].index then
        return true
    elseif self._data[data.type].s == 1 and data.index < self._data[data.type].index then
        return true
    else
        return false
    end
end

function AchievementModel:getIconById(id)
    local data = GameConfig.AchievementConfig:getData(id)
    return data.icon
end

return AchievementModel
---
-- 开服活动 model层     结构 {{type = 1,index = 1,s = 0}, ... }
--@module FestivityModel
local FestivityModel = {
    _data = nil,
    _week = 0,
    _day = 0,
    _festivityOrderType = nil,
    _festivityData = nil,
    _festivityNum = nil,
    _typeEventId = nil,
    dataChangeEventType = "FestivityModelDataChange", --{type = ,id=,dataType =}
    dataType = {
        state = 1,
        value = 2,
        nextday = 3
    }
}

-- 活动监听的事件
local festivityTypeEvent = {
    ch.LevelModel.dataChangeEventType, -- 闯关奖励
    ch.TotemModel.dataChangeEventType, -- 图腾升级
    ch.TotemModel.dataChangeEventType, -- 图腾组合
    ch.AchievementModel.dataChangeEventType, -- 成就达人
    nil, -- 累计充值
    nil, -- 天天充值【连续】
    nil, -- 累计消耗
    nil, -- 名列前茅
    nil, -- 天天充值【当日】
    ch.PartnerModel.czChangeEventType, -- 萌宠收集乐
    ch.ShopModel.dataChangeEventType, -- 钻石圣光转移【当日】
    ch.TaskModel.dataChangeEventType, -- 钻石任务刷新【累计】
    nil, -- 天梯排行榜
    ch.PetCardModel.dataChangeEventType -- 卡牌收集【最低等级】
}

---
-- @function [parent=#FestivityModel] init
-- @param #FestivityModel self
-- @param #table data
function FestivityModel:init(data)
    self._data = data.festivity
    self._festivityNum = {}
    self._typeEventId = {}
    if self._data and self._data.days then
        self:setWeekAndDay(self._data.days)
        self:setFestivityData(self._data.getReward,self._data.canReward)
        self:_festivityOrderByType(self._week)
    else
        self._week = 0
        self._day = 0
        self._festivityData = {}
        self._festivityOrderType = {}
    end
end

---
-- @function [parent=#FestivityModel] clean
-- @param #FestivityModel self
function FestivityModel:clean()
    self._data = nil
    self._week = 0
    self._day = 0
    self._festivityOrderType = nil
    self._festivityData = nil
    self._festivityNum = nil
    for k,v in pairs(self._typeEventId) do
        zzy.EventManager:unListen(v)
    end
    self._typeEventId = nil
end

function FestivityModel:_raiseDataChangeEvent(id,dataType)
    local evt = {
        type = self.dataChangeEventType,
        id = id,
        dataType = dataType
    }
    zzy.EventManager:dispatch(evt)
end

---
-- 按照类型存放活动ID
-- @function [parent=#FestivityModel] _festivityOrderByType
-- @param #FestivityModel self
-- @param #number week
function FestivityModel:_festivityOrderByType(week)
    self._festivityOrderType = {}
    local festivityData = self:getCSVDataByType():getTable()
    for k,v in pairs(festivityData) do
        if v.week == week then
            if not self._festivityOrderType[v.type] then
                self._festivityOrderType[v.type] = {}
            end
            table.insert(self._festivityOrderType[v.type],v.id)
        end
    end
end

---
-- 设置当前为第几周，第几天
-- @function [parent=#FestivityModel] setWeekAndDay
-- @param #FestivityModel self
-- @param #number days
function FestivityModel:setWeekAndDay(days)
    self._week = math.ceil(days/7)
    if days < 8 then
        self._day = days%8
        self._week = 1
    else
        self._day = days%7
        if self._day == 0 then
            self._day = 7
        end
    end
end

---
-- 当前为第几周
-- @function [parent=#FestivityModel] getWeek
-- @param #FestivityModel self
-- @return #number
function FestivityModel:getWeek()
    return self._week
end

---
-- 当前为本周第几天
-- @function [parent=#FestivityModel] getDay
-- @param #FestivityModel self
-- @return #number
function FestivityModel:getDay()
    return self._day
end

---
-- 设置当前活动完成状态 0不可领1可领奖2已领奖3不到时间
-- @function [parent=#FestivityModel] setFestivityData
-- @param #FestivityModel self
-- @param #table getData
-- @param #table canData
function FestivityModel:setFestivityData(getData,canData)
    self._festivityData = {}
    if canData and table.maxn(canData) > 0 then
        for k,v in pairs(canData) do
            self._festivityData[tonumber(v)] = 1
        end
    end
    if getData and table.maxn(getData) > 0 then
        for k,v in pairs(getData) do
            self._festivityData[tonumber(v)] = 2
        end
    end
    local festivityData = self:getCSVDataByType():getTable()
    for k,v in pairs(festivityData) do
        if v.week == self._week then
            if v.index > self._day then
                self._festivityData[v.id] = 3
            elseif not self._festivityData[k] then
                self._festivityData[v.id] = 0
                self:_getCurNum(v.id)
            end
        end
    end
end

---
-- 获取活动完成状态
-- @function [parent=#FestivityModel] getFestivityState
-- @param #FestivityModel self
-- @param #number id
-- @return #number
function FestivityModel:getFestivityState(id)
    return self._festivityData[id]
end

---
-- 更改可领取状态
-- @function [parent=#FestivityModel] setFestivityState
-- @param #FestivityModel self
-- @param #number id
-- @param #number state
function FestivityModel:setFestivityState(id,state)
    if state == 1 and self._festivityData[id] == 2 then
        return
    end
    self._festivityData[id] = state
    if state == 1 then
        table.insert(self._data.canReward,id)
    elseif state == 2 then
        table.insert(self._data.getReward,id)
    end
    self:_raiseDataChangeEvent(id,self.dataType.state)
end

---
-- 从表中取数据
-- @function [parent=#FestivityModel] getDataByType
-- @param #FestivityModel self
-- @param #number type
-- @param #number week
-- @param #number index
-- @return #table
function FestivityModel:getDataByType(type,week,index)
    -- 从表中取数据
    local festivityData = self:getCSVDataByType():getTable()
    for k,v in pairs(festivityData) do
        if v.type == type and v.index == index and v.week == week then
            return self:getCSVDataByType():getData(k)
        end
    end
end

---
-- 根据日期显示每天的活动
-- @function [parent=#FestivityModel] getListByIndex
-- @param #FestivityModel self
-- @param #number week
-- @param #number index
-- @return #table
function FestivityModel:getListByIndex(week,index)
    -- 从表中取数据
    local tmpList = {}
    local festivityData = self:getCSVDataByType():getTable()
    for k,v in pairs(festivityData) do
        if v.week == week and v.index == index then
            table.insert(tmpList,v)
        end
    end
    table.sort(tmpList,function(t1,t2)
        local t1state = self:getFestivityState(t1.id)
        local t2state = self:getFestivityState(t2.id)
        if t1state == t2state then
            return self:getCSVDataByType():getData(t1.id).order < self:getCSVDataByType():getData(t2.id).order
        elseif t1state == 1 and t2state ~= 1 then
            return true
        elseif t1state ~= 1 and t2state == 1 then
            return false
        elseif t1state ~= 1 and t2state ~= 1 then
--            if t1state == t2state then
--                return GameConfig.FestivityConfig:getData(t1.id).order < GameConfig.FestivityConfig:getData(t2.id).order
--            else
                return t1state < t2state
--            end
        end
    end)
    return tmpList
end

---
-- 获得奖励图标
-- @function [parent=#FestivityModel] getRewardIcon
-- @param #FestivityModel self
-- @param #number id
-- @return #string
function FestivityModel:getRewardIcon(id)
    local data = self:getCSVDataByType():getData(id)
    local type = data.rewardType
    local index =""
    if type == 1 then
        index = "db"..data.rewardId
    elseif type == 2 then
        index = "cw"..data.rewardId
    elseif type == 3 then
        index = "bf"..data.rewardId
    elseif type == 4 then    
        return GameConst.MSG_FJ_ICON[1]["db90002"]
    elseif type == 5 then
        if data.rewardId >51000 then
            return GameConst.CARD_GET_ICON.chips
        else
            return GameConst.CARD_GET_ICON.card
        end
    elseif type == 6 then
        if data.rewardId == 40100 then
            return GameConst.MSG_FJ_ICON[1]["db90004"]
        elseif data.rewardId == 40101 then
            return GameConst.MSG_FJ_ICON[1]["db90003"]
        end
    elseif type == 7 then
        return "res/icon/icon_boss.png"
    end
    return GameConst.MSG_FJ_ICON[type][index]
end

---
-- 获得奖励名称
-- @function [parent=#FestivityModel] getRewardName
-- @param #FestivityModel self
-- @param #number id
-- @return #string
function FestivityModel:getRewardName(id)
    local data = self:getCSVDataByType():getData(id)
    local type = data.rewardType
    local index =""
    if type == 1 then
        index = "db"..data.rewardId
    elseif type == 2 then
        index = "cw"..data.rewardId
    elseif type == 3 then
        index = "bf"..data.rewardId
    elseif type == 4 then    
        return GameConst.MSG_FJ_NAME[1]["db90002"]
    elseif type == 5 then 
        return GameConfig.CardConfig:getData(data.rewardId).name
    elseif type == 6 then
        if data.rewardId == 40100 then
            return GameConst.MSG_FJ_NAME[1]["db90004"]
        elseif data.rewardId == 40101 then
            return GameConst.MSG_FJ_NAME[1]["db90003"]
        end
    elseif type == 7 then
        return GameConfig.FamiliarConfig:getData(id).name
    end
    return GameConst.MSG_FJ_NAME[type][index]
end

---
-- 获得奖励数量
-- @function [parent=#FestivityModel] getRewardValue
-- @param #FestivityModel self
-- @param #number id
-- @return #string
function FestivityModel:getRewardValue(id)
    local type = self:getCSVDataByType():getData(id).rewardType
    local num = self:getCSVDataByType():getData(id).rewardValue
    if type == 3 then
        return string.format(Language.MSG_G_HOUR,num/3600)
    elseif type == 4 then
        local tmpNum = ch.CommonFunc:getOffLineGold(num)
        return ch.NumberHelper:toString(tmpNum)
    elseif type == 6 then
        local level = math.floor(ch.StatisticsModel:getMaxLevel()/5)*5
        local tmpNum = math.floor(ch.LevelController:getPrimalHeroSoulRewards(level)*num)
        if tmpNum < 1 then
            tmpNum = 1
        end
        return tmpNum
    else
        return ch.NumberHelper:toString(num)
    end
end

---
-- 活动进度当前(进度)
-- (1.闯关奖励 2.图腾升级 3.图腾组合 
-- 4.成就达人 5.累计充值 6.天天充值【连续】 
-- 7.累计消耗 8.名列前茅 9.天天充值【当日】 
-- 10.萌宠收集乐 11.钻石圣光转移【当日】 12.钻石任务刷新【累计】)
-- 13.天梯排行榜 14.卡牌收集【最低等级】
-- @function [parent=#FestivityModel] _getCurNum
-- @param #FestivityModel self
-- @param #number id
function FestivityModel:_getCurNum(id)
    if self:getFestivityState(id) == 3 or self:getFestivityState(id) == 2 then
        return 
    end
    local evtType = nil
    local func = nil
    local type = self:getCSVDataByType():getData(id).type
    
    if type == 1 then   -- 闯关奖励
        func = function(obj,evt)
            if evt.dataType == ch.LevelModel.dataType.curLevel then
                self._festivityNum[type] = ch.StatisticsModel:getMaxLevel()-1
                self:changStateByType(self._week,type)
            end
        end
    elseif type == 2 or type == 3 then  -- 图腾升级 和 图腾组合
        func = function(obj,evt)
            if evt.dataType == ch.TotemModel.dataType.level then
                -- 图腾升级
                self._festivityNum[2] = ch.TotemModel:getTotemFullNum()
                self:changStateByType(self._week,2)
                -- 图腾组合
                for k,v in pairs(self._festivityOrderType[3]) do
                    local totems = zzy.StringUtils:split(self:getCSVDataByType():getData(v).totems,"|")
                    if self:getFestivityState(v) < 1 and ch.TotemModel:isTotemGroupOwn(totems) then
                        self:setFestivityState(v,1)
                    end
                end
            end
        end
    elseif type == 4 then  -- 成就达人 
        func = function(obj,evt)
            if evt.dataType == ch.AchievementModel.dataType.state then
                self._festivityNum[type] = ch.AchievementModel:getOwnAchievementNum()
                self:changStateByType(self._week,type)
            end
        end
    elseif type == 10 then -- 萌宠收集乐
        func = function(obj,evt)
            if evt.dataType == ch.PartnerModel.dataType.get then
                for k,v in pairs(self._festivityOrderType[10]) do
                    if self:getCSVDataByType():getData(v).index <= self._day and ch.PartnerModel:ifHavePartner(tostring(self:getCSVDataByType():getData(v).goal)) then
                        self:setFestivityState(v,1)
                    end
                end
            end
        end
    elseif type == 11 then -- 钻石圣光转移【当日】
        func = function(obj,evt)
            if evt.dataType == ch.ShopModel.dataType.diamondStar or evt.dataType == ch.ShopModel.dataType.all then
                self._festivityNum[type] = ch.ShopModel:getDiamondStar()
                self:changStateByType(self._week,type)
            end
        end
        -- 改为服务器主动推送
--    elseif type == 12 then -- 钻石任务刷新【累计】
--        func = function(obj,evt)
--            if evt.dataType == ch.TaskModel.dataType.state and evt.id == "-1" and ch.TaskModel:getTodaySign() > 1 then
--                self._festivityNum[type] = self._festivityNum[type] + 1
--                self:changStateByType(self._week,type)
--            end
--        end
    elseif type == 14 then -- 卡牌收集【最低等级】
        func = function(obj,evt)
            if evt.dataType == ch.PetCardModel.dataType.level then
                for k,v in pairs(self._festivityOrderType[14]) do
                    local tmpData = self:getCSVDataByType():getData(v)
                    if self:getFestivityState(v) < 1 and ch.PetCardModel:getCardNumByMinLv(tmpData.cardMinLv) >= tmpData.goal then
                        self:setFestivityState(v,1)
                    end
                end
            end
        end
    else
        return
    end
   
    evtType = festivityTypeEvent[tonumber(type)]
    if not self._typeEventId[id] then
        self._typeEventId[id] = zzy.EventManager:listen(evtType,func)
    end
end

---
-- 获得活动内容数量
-- @function [parent=#FestivityModel] getCurNumByType
-- @param #FestivityModel self
-- @param #number type
function FestivityModel:getCurNumByType(type)
    return self._festivityNum[type] or 0
end

---
-- 设置活动内容数量
-- @function [parent=#FestivityModel] setCurNum
-- @param #FestivityModel self
-- @param #table
function FestivityModel:setCurNum(data)
    for k,v in pairs(data) do
        self._festivityNum[tonumber(k)] = v
        self:changStateByType(self._week,tonumber(k))
    end
end

---
-- 判断活动内容可领奖状态
-- @function [parent=#FestivityModel] changStateByType
-- @param #FestivityModel self
-- @param #number week
-- @param #number type
function FestivityModel:changStateByType(week,type)
    if not self._festivityOrderType[type] then
        return
    end
    if type == 9 or type == 11 then --当日类型
        for k,v in pairs(self._festivityOrderType[type]) do
            local config = self:getCSVDataByType():getData(v)
            if self:getFestivityState(v) < 1 and self:getCurNumByType(type) >= config.goal
                and config.index == self._day then
                self:setFestivityState(v,1)
            end
        end
    else
        for k,v in pairs(self._festivityOrderType[type]) do
            if self:getFestivityState(v) < 1 and self:getCurNumByType(type) >= self:getCSVDataByType():getData(v).goal then
                self:setFestivityState(v,1)
            end
        end
    end
end

---
-- 可领奖数量 day为0是全部数量
-- @function [parent=#FestivityModel] getCurCanNum
-- @param #FestivityModel self
-- @param #number day
-- @return #number
function FestivityModel:getCurCanNum(day)
    local num = 0
    if day > 0 then
        local tmpData = ch.FestivityModel:getListByIndex(self._week,day)
        for k,v in pairs(tmpData) do
            if self._festivityData[tonumber(v.id)] == 1 then
                num = num + 1
            end
        end
    else
        for k,v in pairs(self._festivityData) do
            if v == 1 then
                num = num + 1
            end
        end
    end
    return num
end

---
-- 读表类型
-- @function [parent=#FestivityModel] getCSVDataByType
-- @param #FestivityModel self
-- @return #table
function FestivityModel:getCSVDataByType()
    if self._data.type == 0 then
        return GameConfig.Festivity_oldConfig
    else
        return GameConfig.FestivityConfig
    end
end

---
-- 过天逻辑
-- @function [parent=#FestivityModel] onNextDay
-- @param #FestivityModel self
function FestivityModel:onNextDay()
    if self._data and self._data.days and self._data.days < self._data.maxDays then
        self._data.days = self._data.days + 1
        self:setWeekAndDay(self._data.days)
        self:setFestivityData(self._data.getReward,self._data.canReward)
        self:_festivityOrderByType(self._week)
        self:_raiseDataChangeEvent(self.dataType.nextday)
    else
        self._week = 0
        self._day = 0
        self._festivityData = {}
        self._festivityOrderType = {}
        self:_raiseDataChangeEvent(self.dataType.nextday)
    end
end

return FestivityModel